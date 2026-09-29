import { getApps, initializeApp } from "firebase-admin/app";
import { getFirestore } from "firebase-admin/firestore";
import { getStorage } from "firebase-admin/storage";
import pino from "pino";
import { AgentService } from "./agent.js";
import { createHttpApp } from "./app.js";
import { loadConfig } from "./config.js";
import { FirestoreStoreRepository } from "./firestore-store.js";
import { ToolRegistry } from "./tool-registry.js";
import { FirestoreWhatsAppQueue } from "./whatsapp-queue.js";
import { sendWhatsAppText } from "./whatsapp.js";
import { WhatsAppQueueWorker } from "./whatsapp-worker.js";
import { MidtransClient } from "./midtrans.js";
import { FirestorePaymentRepository, PaymentService } from "./payments.js";
import { FirestoreReportQueue } from "./report-queue.js";
import {
  FirebaseReportPublisher,
  FirestoreReportDataSource,
  ReportWorker,
} from "./report-worker.js";

const config = loadConfig();
const log = pino({ level: config.LOG_LEVEL });
const firebaseApp = getApps()[0] ?? initializeApp({
  projectId: config.FIREBASE_PROJECT_ID,
  ...(config.FIREBASE_STORAGE_BUCKET
    ? { storageBucket: config.FIREBASE_STORAGE_BUCKET }
    : {}),
});
const firestore = getFirestore(firebaseApp);
firestore.settings({ ignoreUndefinedProperties: true });

const reportQueue = new FirestoreReportQueue(firestore);
const store = new FirestoreStoreRepository(firestore, reportQueue);
const registry = new ToolRegistry(store);
const agent = new AgentService(config.OLLAMA_HOST, config.OLLAMA_MODEL, registry);
const queue = new FirestoreWhatsAppQueue(firestore);
const worker = new WhatsAppQueueWorker({
  config,
  queue,
  store,
  agent,
  sendText: sendWhatsAppText,
  log,
});
const paymentRepository = config.MIDTRANS_SERVER_KEY
  ? new FirestorePaymentRepository(firestore)
  : undefined;
const paymentService = config.MIDTRANS_SERVER_KEY && paymentRepository
  ? new PaymentService(
      paymentRepository,
      new MidtransClient(config.MIDTRANS_SERVER_KEY, config.MIDTRANS_IS_PRODUCTION),
    )
  : undefined;
const app = createHttpApp({
  config,
  queue,
  log,
  ...(paymentService && paymentRepository
    ? { payment: { firebaseApp, service: paymentService, repository: paymentRepository } }
    : {}),
});
const reportWorker = config.FIREBASE_STORAGE_BUCKET
  ? new ReportWorker({
      config,
      queue: reportQueue,
      dataSource: new FirestoreReportDataSource(firestore),
      publisher: new FirebaseReportPublisher(
        getStorage(firebaseApp).bucket(config.FIREBASE_STORAGE_BUCKET),
        config.REPORT_LINK_TTL_MINUTES * 60_000,
      ),
      sendText: sendWhatsAppText,
      log,
    })
  : undefined;

const server = app.listen(config.PORT, () => {
  log.info({ port: config.PORT }, "RyanGunshop agent listening");
});

const poll = () => {
  void worker.processBatch().catch((error) => {
    log.error({ error }, "Worker antrean WhatsApp gagal");
  });
};
const pollTimer = setInterval(poll, config.WHATSAPP_QUEUE_POLL_MS);
pollTimer.unref();
poll();
const reportPoll = () => {
  void reportWorker?.processBatch().catch((error) => {
    log.error({ error }, "Worker laporan gagal");
  });
};
const reportPollTimer = reportWorker
  ? setInterval(reportPoll, config.REPORT_QUEUE_POLL_MS)
  : undefined;
reportPollTimer?.unref();
reportPoll();

for (const signal of ["SIGINT", "SIGTERM"] as const) {
  process.once(signal, () => {
    clearInterval(pollTimer);
    if (reportPollTimer) clearInterval(reportPollTimer);
    server.close((error) => {
      if (error) {
        log.error({ error }, "Gagal menutup server");
        process.exitCode = 1;
      }
    });
  });
}
