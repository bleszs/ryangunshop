import { randomUUID } from "node:crypto";
import type { AppConfig } from "./config.js";
import { normalizePhone } from "./normalization.js";
import type {
  DurableWhatsAppQueue,
  QueuedWhatsAppJob,
} from "./whatsapp-queue.js";
import type {
  WhatsAppAgent,
  WhatsAppStore,
  WhatsAppTextSender,
} from "./whatsapp.js";

export interface WhatsAppWorkerResult {
  attempted: number;
  completed: number;
  retried: number;
  deadLettered: number;
  skippedBecauseBusy: boolean;
}

export interface WhatsAppQueueWorkerDependencies {
  config: AppConfig;
  queue: DurableWhatsAppQueue;
  store: WhatsAppStore;
  agent: WhatsAppAgent;
  sendText: WhatsAppTextSender;
  log: { error: (input: unknown, message?: string) => void };
  clock?: () => Date;
  workerId?: string;
}

export class WhatsAppQueueWorker {
  private readonly clock: () => Date;
  private readonly workerId: string;
  private running = false;

  constructor(private readonly dependencies: WhatsAppQueueWorkerDependencies) {
    this.clock = dependencies.clock ?? (() => new Date());
    this.workerId = dependencies.workerId ?? randomUUID();
  }

  async processBatch(): Promise<WhatsAppWorkerResult> {
    if (this.running) return emptyResult(true);
    this.running = true;
    try {
      const jobs = await this.dependencies.queue.claimDue({
        workerId: this.workerId,
        now: this.clock(),
        leaseMs: this.dependencies.config.WHATSAPP_QUEUE_LEASE_MS,
        limit: this.dependencies.config.WHATSAPP_QUEUE_BATCH_SIZE,
      });
      const result = emptyResult(false);
      result.attempted = jobs.length;
      for (const job of jobs) {
        await this.processJob(job, result);
      }
      return result;
    } finally {
      this.running = false;
    }
  }

  private async processJob(
    job: QueuedWhatsAppJob,
    result: WhatsAppWorkerResult,
  ): Promise<void> {
    try {
      const phone = normalizePhone(job.from);
      const authorized = await this.dependencies.store.findAuthorizedUser(phone);
      if (!authorized) {
        await this.dependencies.sendText(
          this.dependencies.config,
          job.from,
          "Nomor ini belum terdaftar untuk RyanGunshop.",
        );
      } else {
        const answer = await this.dependencies.agent.answer(
          { ...authorized, whatsappMessageId: job.id },
          job.text,
        );
        await this.dependencies.sendText(
          this.dependencies.config,
          job.from,
          answer,
        );
      }
      await this.dependencies.queue.complete({
        queueId: job.queueId,
        workerId: this.workerId,
        now: this.clock(),
      });
      result.completed += 1;
    } catch (error) {
      const lastError = safeQueueError(error);
      try {
        if (job.attemptCount >= this.dependencies.config.WHATSAPP_QUEUE_MAX_ATTEMPTS) {
          await this.dependencies.queue.deadLetter({
            queueId: job.queueId,
            workerId: this.workerId,
            now: this.clock(),
            lastError,
          });
          result.deadLettered += 1;
        } else {
          const now = this.clock();
          await this.dependencies.queue.retry({
            queueId: job.queueId,
            workerId: this.workerId,
            now,
            availableAt: new Date(now.getTime() + retryDelayMs(job.attemptCount)),
            lastError,
          });
          result.retried += 1;
        }
      } catch (transitionError) {
        this.dependencies.log.error(
          { transitionError, queueId: job.queueId },
          "Gagal memperbarui status antrean WhatsApp",
        );
      }
      this.dependencies.log.error(
        { error: lastError, queueId: job.queueId, attemptCount: job.attemptCount },
        "Pemrosesan job WhatsApp gagal",
      );
    }
  }
}

export function retryDelayMs(attemptCount: number): number {
  const exponent = Math.min(Math.max(attemptCount - 1, 0), 10);
  return Math.min(30_000 * (2 ** exponent), 6 * 60 * 60 * 1_000);
}

export function safeQueueError(error: unknown): string {
  const message = error instanceof Error ? error.message : String(error);
  return message
    .replace(/Bearer\s+[A-Za-z0-9._~+\/-]+=*/gi, "Bearer [REDACTED]")
    .replace(/[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,}/gi, "[REDACTED_EMAIL]")
    .replace(/\+?\d[\d\s().-]{7,}\d/g, "[REDACTED_PHONE]")
    .slice(0, 500);
}

function emptyResult(skippedBecauseBusy: boolean): WhatsAppWorkerResult {
  return {
    attempted: 0,
    completed: 0,
    retried: 0,
    deadLettered: 0,
    skippedBecauseBusy,
  };
}
