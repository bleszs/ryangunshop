import { createHash } from "node:crypto";
import {
  FieldValue,
  Firestore,
  Timestamp,
} from "firebase-admin/firestore";
import type { IncomingTextMessage } from "./types.js";

const jobCollection = "whatsappJobs";
const deadLetterCollection = "whatsappDeadLetters";
const retentionMs = 7 * 86_400_000;
const deadLetterRetentionMs = 30 * 86_400_000;

export interface QueuedWhatsAppJob extends IncomingTextMessage {
  queueId: string;
  attemptCount: number;
}

export interface ClaimWhatsAppJobsInput {
  workerId: string;
  now: Date;
  leaseMs: number;
  limit: number;
}

export interface QueueTransitionInput {
  queueId: string;
  workerId: string;
  now: Date;
}

export interface RetryWhatsAppJobInput extends QueueTransitionInput {
  availableAt: Date;
  lastError: string;
}

export interface DeadLetterWhatsAppJobInput extends QueueTransitionInput {
  lastError: string;
}

export interface DurableWhatsAppQueue {
  enqueue(message: IncomingTextMessage): Promise<boolean>;
  claimDue(input: ClaimWhatsAppJobsInput): Promise<QueuedWhatsAppJob[]>;
  complete(input: QueueTransitionInput): Promise<void>;
  retry(input: RetryWhatsAppJobInput): Promise<void>;
  deadLetter(input: DeadLetterWhatsAppJobInput): Promise<void>;
}

/**
 * Firestore-backed queue. Document IDs are hashes of Meta message IDs so a
 * webhook replay cannot create a second job and arbitrary IDs cannot alter a
 * collection path.
 */
export class FirestoreWhatsAppQueue implements DurableWhatsAppQueue {
  constructor(
    private readonly db: Firestore,
    private readonly clock: () => Date = () => new Date(),
  ) {}

  async enqueue(message: IncomingTextMessage): Promise<boolean> {
    const now = this.clock();
    const queueId = queueIdFor(message.id);
    try {
      await this.jobs.doc(queueId).create({
        externalMessageId: message.id,
        from: message.from,
        text: message.text,
        status: "PENDING",
        attemptCount: 0,
        availableAt: Timestamp.fromDate(now),
        createdAt: Timestamp.fromDate(now),
        updatedAt: Timestamp.fromDate(now),
        expiresAt: Timestamp.fromMillis(now.getTime() + retentionMs),
      });
      return true;
    } catch (error) {
      const code = (error as { code?: number | string }).code;
      if (code === 6 || code === "already-exists") return false;
      throw error;
    }
  }

  async claimDue(input: ClaimWhatsAppJobsInput): Promise<QueuedWhatsAppJob[]> {
    const now = Timestamp.fromDate(input.now);
    const candidates = await this.jobs
      .where("status", "in", ["PENDING", "PROCESSING"])
      .where("availableAt", "<=", now)
      .orderBy("availableAt", "asc")
      .limit(input.limit * 2)
      .get();
    const claimed: QueuedWhatsAppJob[] = [];

    for (const candidate of candidates.docs) {
      if (claimed.length >= input.limit) break;
      const job = await this.db.runTransaction(async (transaction) => {
        const current = await transaction.get(candidate.ref);
        const data = current.data();
        if (!current.exists || !isClaimable(data, input.now)) return null;
        const parsed = parseJob(candidate.id, data);
        const attemptCount = parsed.attemptCount + 1;
        const leaseUntil = new Date(input.now.getTime() + input.leaseMs);
        transaction.update(candidate.ref, {
          status: "PROCESSING",
          attemptCount,
          leaseOwner: input.workerId,
          leaseUntil: Timestamp.fromDate(leaseUntil),
          availableAt: Timestamp.fromDate(leaseUntil),
          updatedAt: now,
        });
        return { ...parsed, attemptCount };
      });
      if (job) claimed.push(job);
    }
    return claimed;
  }

  async complete(input: QueueTransitionInput): Promise<void> {
    await this.updateOwnedJob(input, {
      status: "COMPLETED",
      completedAt: Timestamp.fromDate(input.now),
      updatedAt: Timestamp.fromDate(input.now),
      leaseOwner: FieldValue.delete(),
      leaseUntil: FieldValue.delete(),
      lastError: FieldValue.delete(),
    });
  }

  async retry(input: RetryWhatsAppJobInput): Promise<void> {
    await this.updateOwnedJob(input, {
      status: "PENDING",
      availableAt: Timestamp.fromDate(input.availableAt),
      updatedAt: Timestamp.fromDate(input.now),
      lastError: input.lastError,
      leaseOwner: FieldValue.delete(),
      leaseUntil: FieldValue.delete(),
    });
  }

  async deadLetter(input: DeadLetterWhatsAppJobInput): Promise<void> {
    const jobRef = this.jobs.doc(input.queueId);
    const deadLetterRef = this.db.collection(deadLetterCollection).doc(input.queueId);
    await this.db.runTransaction(async (transaction) => {
      const snapshot = await transaction.get(jobRef);
      const data = snapshot.data();
      assertOwnedProcessingJob(data, input.workerId);
      const failedAt = Timestamp.fromDate(input.now);
      const {
        leaseOwner: _leaseOwner,
        leaseUntil: _leaseUntil,
        ...deadLetterData
      } = data;
      transaction.set(deadLetterRef, {
        ...deadLetterData,
        status: "DEAD_LETTER",
        failedAt,
        updatedAt: failedAt,
        lastError: input.lastError,
        expiresAt: Timestamp.fromMillis(
          input.now.getTime() + deadLetterRetentionMs,
        ),
      });
      transaction.update(jobRef, {
        status: "DEAD_LETTER",
        failedAt,
        updatedAt: failedAt,
        lastError: input.lastError,
        leaseOwner: FieldValue.delete(),
        leaseUntil: FieldValue.delete(),
        expiresAt: Timestamp.fromMillis(
          input.now.getTime() + deadLetterRetentionMs,
        ),
      });
    });
  }

  private async updateOwnedJob(
    input: QueueTransitionInput,
    update: FirebaseFirestore.UpdateData<FirebaseFirestore.DocumentData>,
  ): Promise<void> {
    const reference = this.jobs.doc(input.queueId);
    await this.db.runTransaction(async (transaction) => {
      const snapshot = await transaction.get(reference);
      assertOwnedProcessingJob(snapshot.data(), input.workerId);
      transaction.update(reference, update);
    });
  }

  private get jobs() {
    return this.db.collection(jobCollection);
  }
}

export function queueIdFor(messageId: string): string {
  return createHash("sha256").update(messageId).digest("hex");
}

function isClaimable(
  data: FirebaseFirestore.DocumentData | undefined,
  now: Date,
): data is FirebaseFirestore.DocumentData {
  if (!data || (data.status !== "PENDING" && data.status !== "PROCESSING")) {
    return false;
  }
  return data.availableAt instanceof Timestamp
    && data.availableAt.toMillis() <= now.getTime();
}

function parseJob(
  queueId: string,
  data: FirebaseFirestore.DocumentData,
): QueuedWhatsAppJob {
  if (
    typeof data.externalMessageId !== "string"
    || typeof data.from !== "string"
    || typeof data.text !== "string"
    || typeof data.attemptCount !== "number"
  ) {
    throw new Error("Payload antrean WhatsApp tidak valid");
  }
  return {
    queueId,
    id: data.externalMessageId,
    from: data.from,
    text: data.text,
    attemptCount: Math.max(0, Math.trunc(data.attemptCount)),
  };
}

function assertOwnedProcessingJob(
  data: FirebaseFirestore.DocumentData | undefined,
  workerId: string,
): asserts data is FirebaseFirestore.DocumentData {
  if (
    !data
    || data.status !== "PROCESSING"
    || data.leaseOwner !== workerId
  ) {
    throw new Error("Lease antrean WhatsApp tidak lagi dimiliki worker");
  }
}
