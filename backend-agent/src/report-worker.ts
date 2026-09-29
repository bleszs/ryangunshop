import { randomUUID } from "node:crypto";
import {
  type Firestore,
  Timestamp,
} from "firebase-admin/firestore";
import PDFDocument from "pdfkit";
import type { AppConfig } from "./config.js";
import type {
  DurableReportQueue,
  QueuedReportJob,
  ReportFormat,
} from "./report-queue.js";
import type { WhatsAppTextSender } from "./whatsapp.js";
import { retryDelayMs, safeQueueError } from "./whatsapp-worker.js";

export interface ReportTransactionItem {
  productName: string;
  quantity: number;
  sellingPrice: number;
  subtotal: number;
}

export interface ReportTransaction {
  id: string;
  occurredAt: Date;
  total: number;
  grossProfit: number;
  paymentMethod: string;
  items: ReportTransactionItem[];
}

export interface DailyReportData {
  date: string;
  transactions: ReportTransaction[];
  revenue: number;
  grossProfit: number;
}

export interface ReportDataSource {
  loadDaily(storeId: string, date: string): Promise<DailyReportData>;
}

export interface PublishedReport {
  url: string;
  objectPath: string;
  expiresAt: Date;
}

export interface ReportPublisher {
  publish(input: {
    job: QueuedReportJob;
    bytes: Buffer;
    contentType: string;
    now: Date;
  }): Promise<PublishedReport>;
}

export class FirestoreReportDataSource implements ReportDataSource {
  constructor(private readonly db: Firestore) {}

  async loadDaily(storeId: string, date: string): Promise<DailyReportData> {
    const from = new Date(`${date}T00:00:00+07:00`);
    if (Number.isNaN(from.valueOf())) throw new Error("Tanggal laporan tidak valid.");
    const until = new Date(from.getTime() + 86_400_000);
    const snapshot = await this.db
      .collection("stores").doc(storeId).collection("transactions")
      .where("status", "==", "SUCCESS")
      .where("occurredAt", ">=", Timestamp.fromDate(from))
      .where("occurredAt", "<", Timestamp.fromDate(until))
      .orderBy("occurredAt", "asc")
      .limit(5_000)
      .get();
    const transactions = snapshot.docs.map((document) => {
      const data = document.data();
      return {
        id: document.id,
        occurredAt: data.occurredAt instanceof Timestamp
          ? data.occurredAt.toDate()
          : from,
        total: money(data.total ?? data.totalAmount),
        grossProfit: money(data.grossProfit ?? data.grossProfitAmount),
        paymentMethod: text(data.paymentMethod, "UNKNOWN"),
        items: parseItems(data.items),
      };
    });
    return {
      date,
      transactions,
      revenue: transactions.reduce((sum, transaction) => sum + transaction.total, 0),
      grossProfit: transactions.reduce(
        (sum, transaction) => sum + transaction.grossProfit,
        0,
      ),
    };
  }
}

export class FirebaseReportPublisher implements ReportPublisher {
  constructor(
    private readonly bucket: ReportBucket,
    private readonly linkLifetimeMs: number,
  ) {}

  async publish(input: {
    job: QueuedReportJob;
    bytes: Buffer;
    contentType: string;
    now: Date;
  }): Promise<PublishedReport> {
    const extension = input.job.format.toLowerCase();
    const objectPath = `reports/${input.job.storeId}/${input.job.jobId}.${extension}`;
    const file = this.bucket.file(objectPath);
    await file.save(input.bytes, {
      resumable: false,
      metadata: {
        contentType: input.contentType,
        cacheControl: "private, no-store, max-age=0",
        contentDisposition: `attachment; filename="laporan-${input.job.date}.${extension}"`,
        metadata: {
          storeId: input.job.storeId,
          jobId: input.job.jobId,
          requestedBy: input.job.requestedBy,
        },
      },
    });
    const expiresAt = new Date(input.now.getTime() + this.linkLifetimeMs);
    const [url] = await file.getSignedUrl({
      version: "v4",
      action: "read",
      expires: expiresAt,
    });
    return { url, objectPath, expiresAt };
  }
}

interface ReportBucket {
  file(path: string): {
    save(data: Buffer, options: object): Promise<unknown>;
    getSignedUrl(options: {
      version: "v4";
      action: "read";
      expires: Date;
    }): Promise<[string]>;
  };
}

export class ReportWorker {
  private readonly workerId: string;
  private readonly clock: () => Date;
  private running = false;

  constructor(private readonly dependencies: {
    config: AppConfig;
    queue: DurableReportQueue;
    dataSource: ReportDataSource;
    publisher: ReportPublisher;
    sendText: WhatsAppTextSender;
    log: { error: (input: unknown, message?: string) => void };
    workerId?: string;
    clock?: () => Date;
  }) {
    this.workerId = dependencies.workerId ?? randomUUID();
    this.clock = dependencies.clock ?? (() => new Date());
  }

  async processBatch() {
    if (this.running) return { attempted: 0, completed: 0, retried: 0, failed: 0 };
    this.running = true;
    const result = { attempted: 0, completed: 0, retried: 0, failed: 0 };
    try {
      const jobs = await this.dependencies.queue.claimDue({
        workerId: this.workerId,
        now: this.clock(),
        leaseMs: this.dependencies.config.REPORT_QUEUE_LEASE_MS,
        limit: this.dependencies.config.REPORT_QUEUE_BATCH_SIZE,
      });
      result.attempted = jobs.length;
      for (const job of jobs) await this.processJob(job, result);
      return result;
    } finally {
      this.running = false;
    }
  }

  private async processJob(
    job: QueuedReportJob,
    result: { completed: number; retried: number; failed: number },
  ) {
    try {
      const data = await this.dependencies.dataSource.loadDaily(job.storeId, job.date);
      const rendered = await renderReport(job.format, data);
      const now = this.clock();
      const published = await this.dependencies.publisher.publish({
        job,
        bytes: rendered.bytes,
        contentType: rendered.contentType,
        now,
      });
      await this.dependencies.sendText(
        this.dependencies.config,
        job.recipientPhone,
        reportMessage(job, data, published),
      );
      await this.dependencies.queue.complete({
        jobId: job.jobId,
        storeId: job.storeId,
        workerId: this.workerId,
        now: this.clock(),
        objectPath: published.objectPath,
        expiresAt: published.expiresAt,
      });
      result.completed += 1;
    } catch (error) {
      const now = this.clock();
      const lastError = safeQueueError(error);
      try {
        if (job.attemptCount >= this.dependencies.config.REPORT_QUEUE_MAX_ATTEMPTS) {
          await this.dependencies.queue.fail({
            jobId: job.jobId,
            storeId: job.storeId,
            workerId: this.workerId,
            now,
            lastError,
          });
          result.failed += 1;
        } else {
          await this.dependencies.queue.retry({
            jobId: job.jobId,
            storeId: job.storeId,
            workerId: this.workerId,
            now,
            availableAt: new Date(now.getTime() + retryDelayMs(job.attemptCount)),
            lastError,
          });
          result.retried += 1;
        }
      } catch (transitionError) {
        this.dependencies.log.error(
          { transitionError, jobId: job.jobId },
          "Gagal memperbarui antrean laporan",
        );
      }
      this.dependencies.log.error(
        { error: lastError, jobId: job.jobId, attemptCount: job.attemptCount },
        "Pembuatan laporan gagal",
      );
    }
  }
}

export async function renderReport(format: ReportFormat, data: DailyReportData) {
  return format === "CSV"
    ? { bytes: renderCsv(data), contentType: "text/csv; charset=utf-8" }
    : { bytes: await renderPdf(data), contentType: "application/pdf" };
}

function renderCsv(data: DailyReportData): Buffer {
  const rows: string[][] = [
    ["Tanggal", "ID Transaksi", "Waktu WIB", "Pembayaran", "Produk", "Qty", "Harga", "Subtotal", "Total", "Laba Kotor"],
  ];
  for (const transaction of data.transactions) {
    const items = transaction.items.length > 0
      ? transaction.items
      : [{ productName: "-", quantity: 0, sellingPrice: 0, subtotal: 0 }];
    for (const item of items) {
      rows.push([
        data.date,
        transaction.id,
        formatWibTime(transaction.occurredAt),
        transaction.paymentMethod,
        item.productName,
        String(item.quantity),
        String(item.sellingPrice),
        String(item.subtotal),
        String(transaction.total),
        String(transaction.grossProfit),
      ]);
    }
  }
  rows.push([]);
  rows.push(["Ringkasan", "Jumlah transaksi", String(data.transactions.length)]);
  rows.push(["Ringkasan", "Omzet", String(data.revenue)]);
  rows.push(["Ringkasan", "Laba kotor", String(data.grossProfit)]);
  return Buffer.from(`\uFEFF${rows.map((row) => row.map(csvCell).join(",")).join("\r\n")}\r\n`);
}

async function renderPdf(data: DailyReportData): Promise<Buffer> {
  const document = new PDFDocument({ size: "A4", margin: 42, info: {
    Title: `Laporan RyanGunshop ${data.date}`,
    Author: "RyanGunshop",
  } });
  const chunks: Buffer[] = [];
  document.on("data", (chunk: Buffer) => chunks.push(chunk));
  const finished = new Promise<Buffer>((resolve, reject) => {
    document.once("end", () => resolve(Buffer.concat(chunks)));
    document.once("error", reject);
  });
  document.fontSize(20).font("Helvetica-Bold").text("Laporan Penjualan RyanGunshop");
  document.moveDown(.3).fontSize(10).font("Helvetica").fillColor("#475569")
    .text(`Tanggal: ${data.date} (WIB)`);
  document.moveDown().fillColor("#0F172A").fontSize(12)
    .text(`Transaksi: ${data.transactions.length}`)
    .text(`Omzet: ${rupiah(data.revenue)}`)
    .text(`Laba kotor: ${rupiah(data.grossProfit)}`);
  document.moveDown();
  if (data.transactions.length === 0) {
    document.fontSize(11).fillColor("#64748B")
      .text("Tidak ada transaksi sukses pada tanggal ini.");
  } else {
    for (const transaction of data.transactions) {
      if (document.y > 720) document.addPage();
      document.font("Helvetica-Bold").fontSize(10).fillColor("#1E293B")
        .text(`${formatWibTime(transaction.occurredAt)}  ${transaction.id.slice(0, 12)}`);
      document.font("Helvetica").fontSize(9).fillColor("#475569")
        .text(`${transaction.paymentMethod} - ${rupiah(transaction.total)}`);
      for (const item of transaction.items) {
        document.text(`  ${item.quantity}x ${item.productName} - ${rupiah(item.subtotal)}`);
      }
      document.moveDown(.6);
    }
  }
  document.end();
  return finished;
}

function reportMessage(
  job: QueuedReportJob,
  data: DailyReportData,
  published: PublishedReport,
) {
  const expiry = published.expiresAt.toLocaleTimeString("id-ID", {
    timeZone: "Asia/Jakarta",
    hour: "2-digit",
    minute: "2-digit",
  });
  return [
    `Laporan ${job.format} ${job.date} sudah selesai.`,
    `${data.transactions.length} transaksi | omzet ${rupiah(data.revenue)} | laba kotor ${rupiah(data.grossProfit)}.`,
    `Unduh sebelum pukul ${expiry} WIB:`,
    published.url,
  ].join("\n");
}

function parseItems(value: unknown): ReportTransactionItem[] {
  if (!Array.isArray(value)) return [];
  return value.flatMap((raw) => {
    if (!raw || typeof raw !== "object") return [];
    const item = raw as Record<string, unknown>;
    const quantity = integer(item.quantity);
    const sellingPrice = money(item.sellingPrice ?? item.sellingPriceSnapshot);
    return [{
      productName: text(item.productName ?? item.productNameSnapshot, "Produk"),
      quantity,
      sellingPrice,
      subtotal: money(item.subtotal ?? item.subtotalAmount)
        || sellingPrice * quantity,
    }];
  });
}

function csvCell(value: string) {
  return /[",\r\n]/.test(value) ? `"${value.replaceAll('"', '""')}"` : value;
}

function formatWibTime(date: Date) {
  return date.toLocaleTimeString("id-ID", {
    timeZone: "Asia/Jakarta",
    hour: "2-digit",
    minute: "2-digit",
    second: "2-digit",
    hour12: false,
  });
}

function rupiah(value: number) {
  return new Intl.NumberFormat("id-ID", {
    style: "currency",
    currency: "IDR",
    maximumFractionDigits: 0,
  }).format(value);
}

function integer(value: unknown) {
  return typeof value === "number" && Number.isFinite(value)
    ? Math.max(0, Math.trunc(value))
    : 0;
}

function money(value: unknown) {
  return integer(value);
}

function text(value: unknown, fallback: string) {
  return typeof value === "string" && value.trim() ? value.trim() : fallback;
}
