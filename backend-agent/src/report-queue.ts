import { createHash } from "node:crypto";
import {
  FieldValue,
  type Firestore,
  Timestamp,
} from "firebase-admin/firestore";
import type { AgentContext } from "./types.js";

const queueCollection = "reportGenerationJobs";

export type ReportFormat = "PDF" | "CSV";

export interface QueuedReportJob {
  jobId: string;
  storeId: string;
  requestedBy: string;
  recipientPhone: string;
  date: string;
  format: ReportFormat;
  attemptCount: number;
}

export interface ClaimReportJobsInput {
  workerId: string;
  now: Date;
  leaseMs: number;
  limit: number;
}

export interface ReportJobTransition {
  jobId: string;
  storeId: string;
  workerId: string;
  now: Date;
}

export interface ReportJobCompletion extends ReportJobTransition {
  objectPath: string;
  expiresAt: Date;
}

export interface ReportJobRetry extends ReportJobTransition {
  availableAt: Date;
  lastError: string;
}

export interface ReportJobFailure extends ReportJobTransition {
  lastError: string;
}

export interface DurableReportQueue {
  enqueue(
    context: AgentContext,
    date: string,
    format: ReportFormat,
  ): Promise<{ jobId: string; status: "QUEUED" }>;
  claimDue(input: ClaimReportJobsInput): Promise<QueuedReportJob[]>;
  complete(input: ReportJobCompletion): Promise<void>;
  retry(input: ReportJobRetry): Promise<void>;
  fail(input: ReportJobFailure): Promise<void>;
}

export class FirestoreReportQueue implements DurableReportQueue {
  constructor(
    private readonly db: Firestore,
    private readonly clock: () => Date = () => new Date(),
  ) {}

  async enqueue(
    context: AgentContext,
    date: string,
    format: ReportFormat,
  ): Promise<{ jobId: string; status: "QUEUED" }> {
    const jobId = reportJobId(context, date, format);
    const queueReference = this.jobs.doc(jobId);
    const ownerReference = this.ownerJob(context.storeId, jobId);
    const now = Timestamp.fromDate(this.clock());
    await this.db.runTransaction(async (transaction) => {
      const existing = await transaction.get(queueReference);
      if (existing.exists) return;
      transaction.create(queueReference, {
        storeId: context.storeId,
        requestedBy: context.userId,
        recipientPhone: context.phone,
        whatsappMessageId: context.whatsappMessageId,
        date,
        format,
        status: "QUEUED",
        attemptCount: 0,
        availableAt: now,
        createdAt: now,
        updatedAt: now,
      });
      transaction.create(ownerReference, {
        date,
        format,
        status: "QUEUED",
        requestedBy: context.userId,
        whatsappMessageId: context.whatsappMessageId,
        createdAt: now,
        updatedAt: now,
      });
    });
    return { jobId, status: "QUEUED" };
  }

  async claimDue(input: ClaimReportJobsInput): Promise<QueuedReportJob[]> {
    const now = Timestamp.fromDate(input.now);
    const candidates = await this.jobs
      .where("status", "in", ["QUEUED", "PROCESSING"])
      .where("availableAt", "<=", now)
      .orderBy("availableAt", "asc")
      .limit(input.limit * 2)
      .get();
    const claimed: QueuedReportJob[] = [];
    for (const candidate of candidates.docs) {
      if (claimed.length >= input.limit) break;
      const job = await this.db.runTransaction(async (transaction) => {
        const snapshot = await transaction.get(candidate.ref);
        const data = snapshot.data();
        if (!isClaimable(data, input.now)) return null;
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
        transaction.update(this.ownerJob(parsed.storeId, parsed.jobId), {
          status: "PROCESSING",
          updatedAt: now,
        });
        return { ...parsed, attemptCount };
      });
      if (job) claimed.push(job);
    }
    return claimed;
  }

  async complete(input: ReportJobCompletion): Promise<void> {
    await this.transition(input, {
      status: "COMPLETED",
      objectPath: input.objectPath,
      linkExpiresAt: Timestamp.fromDate(input.expiresAt),
      completedAt: Timestamp.fromDate(input.now),
      updatedAt: Timestamp.fromDate(input.now),
      leaseOwner: FieldValue.delete(),
      leaseUntil: FieldValue.delete(),
      lastError: FieldValue.delete(),
    });
  }

  async retry(input: ReportJobRetry): Promise<void> {
    await this.transition(input, {
      status: "QUEUED",
      availableAt: Timestamp.fromDate(input.availableAt),
      updatedAt: Timestamp.fromDate(input.now),
      lastError: input.lastError,
      leaseOwner: FieldValue.delete(),
      leaseUntil: FieldValue.delete(),
    });
  }

  async fail(input: ReportJobFailure): Promise<void> {
    await this.transition(input, {
      status: "FAILED",
      failedAt: Timestamp.fromDate(input.now),
      updatedAt: Timestamp.fromDate(input.now),
      lastError: input.lastError,
      leaseOwner: FieldValue.delete(),
      leaseUntil: FieldValue.delete(),
    });
  }

  private async transition(
    input: ReportJobTransition,
    update: FirebaseFirestore.UpdateData<FirebaseFirestore.DocumentData>,
  ) {
    const queueReference = this.jobs.doc(input.jobId);
    const ownerReference = this.ownerJob(input.storeId, input.jobId);
    await this.db.runTransaction(async (transaction) => {
      const snapshot = await transaction.get(queueReference);
      assertOwned(snapshot.data(), input.workerId, input.storeId);
      transaction.update(queueReference, update);
      const ownerUpdate = { ...update };
      delete ownerUpdate.leaseOwner;
      delete ownerUpdate.leaseUntil;
      transaction.update(ownerReference, ownerUpdate);
    });
  }

  private ownerJob(storeId: string, jobId: string) {
    return this.db.collection("stores").doc(storeId).collection("reportJobs").doc(jobId);
  }

  private get jobs() {
    return this.db.collection(queueCollection);
  }
}

export function reportJobId(
  context: Pick<AgentContext, "storeId" | "userId" | "whatsappMessageId">,
  date: string,
  format: ReportFormat,
): string {
  return createHash("sha256")
    .update(`${context.storeId}:${context.userId}:${context.whatsappMessageId}:${date}:${format}`)
    .digest("hex");
}

function isClaimable(
  data: FirebaseFirestore.DocumentData | undefined,
  now: Date,
): data is FirebaseFirestore.DocumentData {
  if (!data || (data.status !== "QUEUED" && data.status !== "PROCESSING")) return false;
  return data.availableAt instanceof Timestamp
    && data.availableAt.toMillis() <= now.getTime();
}

function parseJob(jobId: string, data: FirebaseFirestore.DocumentData): QueuedReportJob {
  if (
    typeof data.storeId !== "string"
    || typeof data.requestedBy !== "string"
    || typeof data.recipientPhone !== "string"
    || typeof data.date !== "string"
    || (data.format !== "PDF" && data.format !== "CSV")
    || typeof data.attemptCount !== "number"
  ) {
    throw new Error("Payload antrean laporan tidak valid.");
  }
  return {
    jobId,
    storeId: data.storeId,
    requestedBy: data.requestedBy,
    recipientPhone: data.recipientPhone,
    date: data.date,
    format: data.format,
    attemptCount: Math.max(0, Math.trunc(data.attemptCount)),
  };
}

function assertOwned(
  data: FirebaseFirestore.DocumentData | undefined,
  workerId: string,
  storeId: string,
): asserts data is FirebaseFirestore.DocumentData {
  if (
    !data
    || data.status !== "PROCESSING"
    || data.leaseOwner !== workerId
    || data.storeId !== storeId
  ) {
    throw new Error("Lease laporan tidak lagi dimiliki worker.");
  }
}
