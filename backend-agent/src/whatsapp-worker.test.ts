import assert from "node:assert/strict";
import test from "node:test";
import type { AppConfig } from "./config.js";
import type {
  ClaimWhatsAppJobsInput,
  DeadLetterWhatsAppJobInput,
  DurableWhatsAppQueue,
  QueuedWhatsAppJob,
  QueueTransitionInput,
  RetryWhatsAppJobInput,
} from "./whatsapp-queue.js";
import {
  retryDelayMs,
  safeQueueError,
  WhatsAppQueueWorker,
} from "./whatsapp-worker.js";

const config: AppConfig = {
  NODE_ENV: "test",
  PORT: 8080,
  LOG_LEVEL: "silent",
  WHATSAPP_VERIFY_TOKEN: "verify-token-test",
  WHATSAPP_APP_SECRET: "app-secret-test-1234",
  WHATSAPP_ACCESS_TOKEN: "access-token-test-1234",
  WHATSAPP_PHONE_NUMBER_ID: "phone-id",
  WHATSAPP_GRAPH_VERSION: "v23.0",
  WHATSAPP_QUEUE_POLL_MS: 2_000,
  WHATSAPP_QUEUE_BATCH_SIZE: 10,
  WHATSAPP_QUEUE_MAX_ATTEMPTS: 3,
  WHATSAPP_QUEUE_LEASE_MS: 120_000,
  OLLAMA_HOST: "http://ollama.invalid",
  OLLAMA_MODEL: "test-model",
  FIREBASE_PROJECT_ID: "demo-ryangunshop",
};

test("worker memproses job terotorisasi lalu menandainya selesai", async () => {
  const queue = new FakeQueue([job(1)]);
  const sent: Array<{ recipient: string; body: string }> = [];
  const worker = new WhatsAppQueueWorker({
    config,
    queue,
    workerId: "worker-1",
    clock: () => new Date("2026-09-27T12:00:00Z"),
    store: {
      async findAuthorizedUser(phone) {
        assert.equal(phone, "+628123456789");
        return { phone, userId: "owner-a", storeId: "store-a", role: "OWNER" };
      },
    },
    agent: {
      async answer(context, text) {
        assert.equal(context.whatsappMessageId, "wamid-1");
        assert.equal(text, "stok kopi?");
        return "Stok Kopi tersisa 7 unit.";
      },
    },
    async sendText(_config, recipient, body) {
      sent.push({ recipient, body });
    },
    log: { error() {} },
  });

  const result = await worker.processBatch();

  assert.deepEqual(result, {
    attempted: 1,
    completed: 1,
    retried: 0,
    deadLettered: 0,
    skippedBecauseBusy: false,
  });
  assert.deepEqual(sent, [{
    recipient: "628123456789",
    body: "Stok Kopi tersisa 7 unit.",
  }]);
  assert.equal(queue.completed.length, 1);
});

test("worker menjadwalkan retry dengan error yang sudah diredaksi", async () => {
  const queue = new FakeQueue([job(1)]);
  const now = new Date("2026-09-27T12:00:00Z");
  const worker = new WhatsAppQueueWorker({
    config,
    queue,
    workerId: "worker-1",
    clock: () => now,
    store: {
      async findAuthorizedUser() {
        throw new Error("Bearer secret-token owner@example.com +628123456789");
      },
    },
    agent: { async answer() { return "unused"; } },
    async sendText() {},
    log: { error() {} },
  });

  const result = await worker.processBatch();

  assert.equal(result.retried, 1);
  assert.equal(queue.retried[0]?.availableAt.toISOString(), "2026-09-27T12:00:30.000Z");
  assert.doesNotMatch(queue.retried[0]?.lastError ?? "", /secret-token|owner@|628123/);
});

test("worker memindahkan kegagalan terakhir ke dead-letter queue", async () => {
  const queue = new FakeQueue([job(3)]);
  const worker = new WhatsAppQueueWorker({
    config,
    queue,
    workerId: "worker-1",
    store: { async findAuthorizedUser() { throw new Error("Ollama offline"); } },
    agent: { async answer() { return "unused"; } },
    async sendText() {},
    log: { error() {} },
  });

  const result = await worker.processBatch();

  assert.equal(result.deadLettered, 1);
  assert.equal(result.retried, 0);
  assert.equal(queue.deadLettered[0]?.lastError, "Ollama offline");
});

test("backoff dibatasi enam jam dan redaksi menangani credential", () => {
  assert.equal(retryDelayMs(1), 30_000);
  assert.equal(retryDelayMs(50), 6 * 60 * 60 * 1_000);
  assert.equal(
    safeQueueError(new Error("Authorization Bearer abc.def/test")),
    "Authorization Bearer [REDACTED]",
  );
});

function job(attemptCount: number): QueuedWhatsAppJob {
  return {
    queueId: "queue-1",
    id: "wamid-1",
    from: "628123456789",
    text: "stok kopi?",
    attemptCount,
  };
}

class FakeQueue implements DurableWhatsAppQueue {
  constructor(private jobs: QueuedWhatsAppJob[]) {}

  completed: QueueTransitionInput[] = [];
  retried: RetryWhatsAppJobInput[] = [];
  deadLettered: DeadLetterWhatsAppJobInput[] = [];

  async enqueue(): Promise<boolean> {
    return true;
  }

  async claimDue(_input: ClaimWhatsAppJobsInput): Promise<QueuedWhatsAppJob[]> {
    const jobs = this.jobs;
    this.jobs = [];
    return jobs;
  }

  async complete(input: QueueTransitionInput): Promise<void> {
    this.completed.push(input);
  }

  async retry(input: RetryWhatsAppJobInput): Promise<void> {
    this.retried.push(input);
  }

  async deadLetter(input: DeadLetterWhatsAppJobInput): Promise<void> {
    this.deadLettered.push(input);
  }
}
