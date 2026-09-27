import { createHash, timingSafeEqual } from "node:crypto";
import { z } from "zod";

const notificationSchema = z.object({
  transaction_id: z.string().min(1),
  order_id: z.string().min(1),
  gross_amount: z.string().regex(/^\d+(?:\.\d{1,2})?$/),
  status_code: z.string().regex(/^\d{3}$/),
  transaction_status: z.string().min(1),
  fraud_status: z.string().optional(),
  signature_key: z.string().regex(/^[a-fA-F0-9]{128}$/),
  expiry_time: z.string().optional(),
  settlement_time: z.string().optional(),
});

const chargeSchema = z.object({
  transaction_id: z.string().min(1),
  order_id: z.string().min(1),
  gross_amount: z.string(),
  transaction_status: z.string().min(1),
  expiry_time: z.string().optional(),
  actions: z.array(z.object({
    name: z.string(),
    method: z.string(),
    url: z.url(),
  })).default([]),
});

export type MidtransNotification = z.infer<typeof notificationSchema>;

export interface QrisChargeItem {
  id: string;
  name: string;
  price: number;
  quantity: number;
}

export interface QrisChargeResult {
  transactionId: string;
  orderId: string;
  grossAmount: number;
  transactionStatus: string;
  qrUrl: string;
  expiresAt: Date | null;
}

export class MidtransClient {
  private readonly baseUrl: string;

  constructor(
    private readonly serverKey: string,
    production: boolean,
    private readonly request: typeof fetch = fetch,
  ) {
    if (serverKey.trim().length < 10) throw new Error("MIDTRANS_SERVER_KEY tidak valid.");
    this.baseUrl = production
      ? "https://api.midtrans.com"
      : "https://api.sandbox.midtrans.com";
  }

  async createQris(input: {
    orderId: string;
    grossAmount: number;
    items: QrisChargeItem[];
  }): Promise<QrisChargeResult> {
    if (!Number.isSafeInteger(input.grossAmount) || input.grossAmount <= 0) {
      throw new Error("grossAmount harus bilangan bulat positif.");
    }
    const response = await this.request(`${this.baseUrl}/v2/charge`, {
      method: "POST",
      headers: this.headers(),
      body: JSON.stringify({
        payment_type: "qris",
        transaction_details: {
          order_id: input.orderId,
          gross_amount: input.grossAmount,
        },
        item_details: input.items.map((item) => ({
          id: item.id,
          name: item.name.slice(0, 50),
          price: item.price,
          quantity: item.quantity,
        })),
        qris: { acquirer: "gopay" },
      }),
      signal: AbortSignal.timeout(10_000),
    });
    const body = await response.json().catch(() => null);
    if (!response.ok) throw new MidtransApiError(response.status, body);
    const parsed = chargeSchema.parse(body);
    const qrUrl = parsed.actions.find((action) =>
      action.name === "generate-qr-code-v2" || action.name === "generate-qr-code"
    )?.url;
    if (!qrUrl) throw new Error("Respons Midtrans tidak memiliki URL QR.");
    return {
      transactionId: parsed.transaction_id,
      orderId: parsed.order_id,
      grossAmount: parseAmount(parsed.gross_amount),
      transactionStatus: parsed.transaction_status,
      qrUrl,
      expiresAt: parsed.expiry_time ? parseMidtransDate(parsed.expiry_time) : null,
    };
  }

  async getStatus(orderId: string): Promise<MidtransNotification> {
    const response = await this.request(
      `${this.baseUrl}/v2/${encodeURIComponent(orderId)}/status`,
      { headers: this.headers(), signal: AbortSignal.timeout(10_000) },
    );
    const body = await response.json().catch(() => null);
    if (!response.ok) throw new MidtransApiError(response.status, body);
    return notificationSchema.parse(body);
  }

  parseAndVerifyNotification(value: unknown): MidtransNotification {
    const notification = notificationSchema.parse(value);
    const expected = createHash("sha512")
      .update(
        notification.order_id
          + notification.status_code
          + notification.gross_amount
          + this.serverKey,
      )
      .digest();
    const provided = Buffer.from(notification.signature_key, "hex");
    if (provided.length !== expected.length || !timingSafeEqual(provided, expected)) {
      throw new InvalidMidtransSignatureError();
    }
    return notification;
  }

  private headers() {
    return {
      accept: "application/json",
      authorization: `Basic ${Buffer.from(`${this.serverKey}:`).toString("base64")}`,
      "content-type": "application/json",
    };
  }
}

export class InvalidMidtransSignatureError extends Error {
  constructor() {
    super("Signature notifikasi Midtrans tidak valid.");
  }
}

export class MidtransApiError extends Error {
  constructor(readonly statusCode: number, readonly responseBody: unknown) {
    super(`Midtrans merespons HTTP ${statusCode}.`);
  }
}

export function mapMidtransStatus(input: {
  transaction_status: string;
  fraud_status?: string | undefined;
}): "PENDING" | "SETTLED" | "EXPIRED" | "CANCELLED" | "REFUNDED" | "DENIED" {
  if (input.transaction_status === "capture") {
    return input.fraud_status === "challenge" ? "PENDING" : "SETTLED";
  }
  if (input.transaction_status === "settlement") return "SETTLED";
  if (input.transaction_status === "expire") return "EXPIRED";
  if (input.transaction_status === "cancel") return "CANCELLED";
  if (input.transaction_status === "refund" || input.transaction_status === "partial_refund") {
    return "REFUNDED";
  }
  if (input.transaction_status === "deny" || input.transaction_status === "failure") {
    return "DENIED";
  }
  return "PENDING";
}

function parseAmount(value: string): number {
  const amount = Number(value);
  if (!Number.isSafeInteger(amount) || amount <= 0) {
    throw new Error("Nominal Midtrans tidak valid.");
  }
  return amount;
}

function parseMidtransDate(value: string): Date | null {
  const normalized = value.includes("T") ? value : value.replace(" ", "T");
  const date = new Date(normalized.includes("+") || normalized.endsWith("Z")
    ? normalized
    : `${normalized}+07:00`);
  return Number.isNaN(date.valueOf()) ? null : date;
}
