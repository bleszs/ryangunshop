import assert from "node:assert/strict";
import test from "node:test";
import type { AppConfig } from "./config.js";
import type {
  DurableReportQueue,
  QueuedReportJob,
} from "./report-queue.js";
import {
  renderReport,
  ReportWorker,
  type DailyReportData,
} from "./report-worker.js";

const config: AppConfig = {
  NODE_ENV: "test",
  PORT: 8080,
  LOG_LEVEL: "silent",
  WHATSAPP_VERIFY_TOKEN: "verify-token-test",
  WHATSAPP_APP_SECRET: "app-secret-test-1234",
  WHATSAPP_ACCESS_TOKEN: "access-token-test-1234",
  WHATSAPP_PHONE_NUMBER_ID: "phone-id",
  WHATSAPP_GRAPH_VERSION: "v24.0",
  WHATSAPP_QUEUE_POLL_MS: 2_000,
  WHATSAPP_QUEUE_BATCH_SIZE: 10,
  WHATSAPP_QUEUE_MAX_ATTEMPTS: 5,
  WHATSAPP_QUEUE_LEASE_MS: 120_000,
  OLLAMA_HOST: "http://ollama.invalid",
  OLLAMA_MODEL: "test-model",
  FIREBASE_PROJECT_ID: "demo-ryangunshop",
  REPORT_QUEUE_POLL_MS: 5_000,
  REPORT_QUEUE_BATCH_SIZE: 3,
  REPORT_QUEUE_MAX_ATTEMPTS: 5,
  REPORT_QUEUE_LEASE_MS: 180_000,
  REPORT_LINK_TTL_MINUTES: 10,
  MIDTRANS_IS_PRODUCTION: false,
};

const job: QueuedReportJob = {
  jobId: "job-1",
  storeId: "store-a",
  requestedBy: "owner-a",
  recipientPhone: "628123456789",
  date: "2026-09-30",
  format: "CSV",
  attemptCount: 1,
};

const report: DailyReportData = {
  date: job.date,
  revenue: 12_000,
  grossProfit: 4_000,
  transactions: [{
    id: "transaction-1",
    occurredAt: new Date("2026-09-30T03:00:00Z"),
    total: 12_000,
    grossProfit: 4_000,
    paymentMethod: "QRIS_DYNAMIC",
    items: [{
      productName: "Kopi, Susu",
      quantity: 2,
      sellingPrice: 6_000,
      subtotal: 12_000,
    }],
  }],
};

test("renderer menghasilkan CSV aman dan PDF valid", async () => {
  const csv = await renderReport("CSV", report);
  assert.equal(csv.contentType, "text/csv; charset=utf-8");
  assert.match(csv.bytes.toString("utf8"), /"Kopi, Susu"/);
  assert.match(csv.bytes.toString("utf8"), /12000/);

  const pdf = await renderReport("PDF", report);
  assert.equal(pdf.contentType, "application/pdf");
  assert.equal(pdf.bytes.subarray(0, 4).toString("ascii"), "%PDF");
  assert.ok(pdf.bytes.length > 500);
});

test("worker mengirim signed URL lalu menyelesaikan lease", async () => {
  const transitions: string[] = [];
  const messages: string[] = [];
  const queue = fakeQueue({
    async complete(input) {
      transitions.push(`complete:${input.objectPath}`);
    },
  });
  const worker = new ReportWorker({
    config,
    queue,
    dataSource: { async loadDaily() { return report; } },
    publisher: {
      async publish() {
        return {
          url: "https://storage.example/signed",
          objectPath: "reports/store-a/job-1.csv",
          expiresAt: new Date("2026-09-30T04:10:00Z"),
        };
      },
    },
    async sendText(_config, _to, message) { messages.push(message); },
    log: { error() {} },
    workerId: "report-worker-a",
    clock: () => new Date("2026-09-30T04:00:00Z"),
  });

  const result = await worker.processBatch();
  assert.equal(result.completed, 1);
  assert.deepEqual(transitions, ["complete:reports/store-a/job-1.csv"]);
  assert.match(messages[0] ?? "", /https:\/\/storage\.example\/signed/);
  assert.match(messages[0] ?? "", /omzet/);
});

test("worker menjadwalkan retry tanpa mengirim pesan bila upload gagal", async () => {
  const transitions: string[] = [];
  const queue = fakeQueue({
    async retry(input) { transitions.push(`retry:${input.lastError}`); },
  });
  const worker = new ReportWorker({
    config,
    queue,
    dataSource: { async loadDaily() { return report; } },
    publisher: { async publish() { throw new Error("Storage offline"); } },
    async sendText() { throw new Error("tidak boleh dipanggil"); },
    log: { error() {} },
    workerId: "report-worker-a",
    clock: () => new Date("2026-09-30T04:00:00Z"),
  });

  const result = await worker.processBatch();
  assert.equal(result.retried, 1);
  assert.deepEqual(transitions, ["retry:Storage offline"]);
});

function fakeQueue(overrides: Partial<DurableReportQueue>): DurableReportQueue {
  return {
    async enqueue() { return { jobId: job.jobId, status: "QUEUED" }; },
    async claimDue() { return [job]; },
    async complete() {},
    async retry() {},
    async fail() {},
    ...overrides,
  };
}
