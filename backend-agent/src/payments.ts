import { createHash } from "node:crypto";
import type { Express, NextFunction, Request, Response } from "express";
import type { App } from "firebase-admin/app";
import { getAuth } from "firebase-admin/auth";
import {
  FieldValue,
  type Firestore,
  Timestamp,
} from "firebase-admin/firestore";
import type { Logger } from "pino";
import { z } from "zod";
import {
  InvalidMidtransSignatureError,
  mapMidtransStatus,
  MidtransClient,
  type QrisChargeItem,
} from "./midtrans.js";

const createPaymentSchema = z.object({
  clientRequestId: z.string().uuid(),
  items: z.array(z.object({
    productId: z.string().min(1).max(128),
    quantity: z.number().int().min(1).max(999),
  })).min(1).max(100),
}).superRefine((value, context) => {
  const productIds = new Set<string>();
  value.items.forEach((item, index) => {
    if (productIds.has(item.productId)) {
      context.addIssue({
        code: "custom",
        path: ["items", index, "productId"],
        message: "Produk duplikat harus digabung menjadi satu baris.",
      });
    }
    productIds.add(item.productId);
  });
});

interface PaymentIdentity {
  uid: string;
  storeId: string;
}

interface PreparedOrder {
  created: boolean;
  orderId: string;
  storeId: string;
  cashierId: string;
  grossAmount: number;
  status: string;
  items: Array<QrisChargeItem & { purchasePrice: number }>;
  qrUrl: string | null;
  expiresAt: Date | null;
}

export class FirestorePaymentRepository {
  constructor(private readonly db: Firestore) {}

  async prepareOrder(input: PaymentIdentity & {
    orderId: string;
    clientRequestId: string;
    items: Array<{ productId: string; quantity: number }>;
  }): Promise<PreparedOrder> {
    const orderReference = this.db.collection("paymentOrders").doc(input.orderId);
    return this.db.runTransaction(async (transaction) => {
      const existing = await transaction.get(orderReference);
      if (existing.exists) {
        const order = orderFrom(existing.data(), false);
        if (order.storeId !== input.storeId || order.cashierId !== input.uid) {
          throw new PaymentValidationError("Payment order bukan milik sesi ini.");
        }
        return order;
      }

      const productReferences = input.items.map((item) =>
        this.db.collection("stores").doc(input.storeId)
          .collection("products").doc(item.productId)
      );
      const snapshots = await transaction.getAll(...productReferences);
      const chargeItems = snapshots.map((snapshot, index) => {
        const requested = input.items[index]!;
        const data = snapshot.data();
        const sellingPrice = integer(data?.sellingPrice);
        const purchasePrice = integer(data?.purchasePrice);
        const stock = integer(data?.stock);
        if (!snapshot.exists || data?.active !== true || sellingPrice <= 0) {
          throw new PaymentValidationError(`Produk ${requested.productId} tidak tersedia.`);
        }
        if (stock < requested.quantity) {
          throw new PaymentValidationError(`Stok ${string(data?.name, "produk")} tidak cukup.`);
        }
        return {
          id: snapshot.id,
          name: string(data?.name, "Produk"),
          price: sellingPrice,
          purchasePrice,
          quantity: requested.quantity,
        };
      });
      const grossAmount = chargeItems.reduce(
        (total, item) => total + item.price * item.quantity,
        0,
      );
      const order = {
        orderId: input.orderId,
        storeId: input.storeId,
        cashierId: input.uid,
        clientRequestId: input.clientRequestId,
        grossAmount,
        status: "CREATING",
        items: chargeItems,
        qrUrl: null,
        expiresAt: null,
        createdAt: FieldValue.serverTimestamp(),
        updatedAt: FieldValue.serverTimestamp(),
      };
      transaction.create(orderReference, order);
      return orderFrom(order, true);
    });
  }

  async attachCharge(orderId: string, charge: {
    transactionId: string;
    qrUrl: string;
    expiresAt: Date | null;
  }): Promise<void> {
    await this.db.collection("paymentOrders").doc(orderId).update({
      transactionId: charge.transactionId,
      qrUrl: charge.qrUrl,
      expiresAt: charge.expiresAt ? Timestamp.fromDate(charge.expiresAt) : null,
      status: "PENDING",
      updatedAt: FieldValue.serverTimestamp(),
    });
  }

  async markChargeFailed(orderId: string): Promise<void> {
    await this.db.collection("paymentOrders").doc(orderId).update({
      status: "CREATE_FAILED",
      updatedAt: FieldValue.serverTimestamp(),
    });
  }

  async getOrder(orderId: string, identity: PaymentIdentity): Promise<PreparedOrder | null> {
    const snapshot = await this.db.collection("paymentOrders").doc(orderId).get();
    if (!snapshot.exists) return null;
    const order = orderFrom(snapshot.data(), false);
    if (order.storeId !== identity.storeId || order.cashierId !== identity.uid) return null;
    return order;
  }

  async applyVerifiedStatus(input: {
    eventId: string;
    orderId: string;
    transactionId: string;
    grossAmount: number;
    status: ReturnType<typeof mapMidtransStatus>;
  }): Promise<void> {
    const orderReference = this.db.collection("paymentOrders").doc(input.orderId);
    const eventReference = this.db.collection("paymentNotifications").doc(input.eventId);
    await this.db.runTransaction(async (transaction) => {
      const [event, orderSnapshot] = await Promise.all([
        transaction.get(eventReference),
        transaction.get(orderReference),
      ]);
      if (event.exists) return;
      const order = orderFrom(orderSnapshot.data(), false);
      if (!orderSnapshot.exists
        || order.grossAmount !== input.grossAmount
        || string(orderSnapshot.data()?.transactionId, "") !== input.transactionId) {
        throw new PaymentValidationError("Notifikasi tidak cocok dengan payment order.");
      }

      if (input.status === "SETTLED"
        && order.status !== "SETTLED"
        && order.status !== "REFUNDED") {
        await this.fulfill(transaction, orderReference, order);
      } else if (order.status !== "REFUNDED"
        && !(order.status === "SETTLED" && input.status !== "REFUNDED")) {
        transaction.update(orderReference, {
          status: input.status,
          requiresReview: input.status === "REFUNDED" && order.status === "SETTLED",
          updatedAt: FieldValue.serverTimestamp(),
        });
      }
      transaction.create(eventReference, {
        orderId: input.orderId,
        transactionId: input.transactionId,
        status: input.status,
        receivedAt: FieldValue.serverTimestamp(),
      });
    });
  }

  private async fulfill(
    transaction: FirebaseFirestore.Transaction,
    orderReference: FirebaseFirestore.DocumentReference,
    order: PreparedOrder,
  ) {
    const store = this.db.collection("stores").doc(order.storeId);
    const productReferences = order.items.map((item) =>
      store.collection("products").doc(item.id)
    );
    const productSnapshots = await transaction.getAll(...productReferences);
    if (productSnapshots.some((snapshot, index) =>
      !snapshot.exists || integer(snapshot.data()?.stock) < order.items[index]!.quantity
    )) {
      transaction.update(orderReference, {
        status: "MANUAL_REVIEW",
        failureReason: "INSUFFICIENT_STOCK_AFTER_PAYMENT",
        updatedAt: FieldValue.serverTimestamp(),
      });
      return;
    }

    for (let index = 0; index < productSnapshots.length; index += 1) {
      const snapshot = productSnapshots[index]!;
      const item = order.items[index]!;
      const nextStock = integer(snapshot.data()?.stock) - item.quantity;
      const minimumStock = integer(snapshot.data()?.minimumStock);
      transaction.update(snapshot.ref, {
        stock: nextStock,
        isLowStock: nextStock <= minimumStock,
        updatedAt: FieldValue.serverTimestamp(),
      });
      transaction.create(
        store.collection("inventoryMutations").doc(`qris-${order.orderId}-${item.id}`),
        {
          productId: item.id,
          delta: -item.quantity,
          transactionId: order.orderId,
          clientOccurredAt: FieldValue.serverTimestamp(),
          appliedAt: FieldValue.serverTimestamp(),
        },
      );
    }
    const grossProfit = order.items.reduce(
      (total, item) => total + (item.price - item.purchasePrice) * item.quantity,
      0,
    );
    transaction.create(store.collection("transactions").doc(order.orderId), {
      occurredAt: FieldValue.serverTimestamp(),
      items: order.items.map((item) => ({
        productId: item.id,
        productName: item.name,
        sellingPrice: item.price,
        purchasePrice: item.purchasePrice,
        quantity: item.quantity,
        subtotal: item.price * item.quantity,
      })),
      total: order.grossAmount,
      grossProfit,
      paymentMethod: "QRIS_DYNAMIC",
      receivedAmount: order.grossAmount,
      changeAmount: 0,
      cashierId: order.cashierId,
      status: "SUCCESS",
      deviceId: "midtrans-backend",
      clientMutationId: order.orderId,
      updatedAt: FieldValue.serverTimestamp(),
    });
    transaction.update(orderReference, {
      status: "SETTLED",
      fulfilledAt: FieldValue.serverTimestamp(),
      updatedAt: FieldValue.serverTimestamp(),
    });
  }
}

export class PaymentService {
  constructor(
    private readonly repository: FirestorePaymentRepository,
    private readonly midtrans: MidtransClient,
  ) {}

  async createQris(identity: PaymentIdentity, value: unknown) {
    const input = createPaymentSchema.parse(value);
    const orderId = `RG-${createHash("sha256")
      .update(`${identity.storeId}:${identity.uid}:${input.clientRequestId}`)
      .digest("hex").slice(0, 32)}`;
    const order = await this.repository.prepareOrder({ ...identity, ...input, orderId });
    if (!order.created) return publicOrder(order);
    try {
      const charge = await this.midtrans.createQris({
        orderId,
        grossAmount: order.grossAmount,
        items: order.items,
      });
      await this.repository.attachCharge(orderId, charge);
      return publicOrder({
        ...order,
        status: "PENDING",
        qrUrl: charge.qrUrl,
        expiresAt: charge.expiresAt,
      });
    } catch (error) {
      await this.repository.markChargeFailed(orderId);
      throw error;
    }
  }

  async handleNotification(value: unknown) {
    const notification = this.midtrans.parseAndVerifyNotification(value);
    const verified = await this.midtrans.getStatus(notification.order_id);
    if (verified.order_id !== notification.order_id
      || verified.transaction_id !== notification.transaction_id) {
      throw new PaymentValidationError("Status Midtrans tidak cocok dengan webhook.");
    }
    const status = mapMidtransStatus(verified);
    await this.repository.applyVerifiedStatus({
      eventId: createHash("sha256")
        .update(`${verified.transaction_id}:${verified.transaction_status}:${verified.status_code}`)
        .digest("hex"),
      orderId: verified.order_id,
      transactionId: verified.transaction_id,
      grossAmount: Number(verified.gross_amount),
      status,
    });
    return status;
  }
}

export function registerPaymentRoutes(app: Express, dependencies: {
  firebaseApp: App;
  payments: PaymentService;
  repository: FirestorePaymentRepository;
  log: Logger;
}) {
  const authenticate = async (request: Request, response: Response, next: NextFunction) => {
    const token = request.header("authorization")?.match(/^Bearer (.+)$/)?.[1];
    if (!token) return response.status(401).json({ error: "unauthenticated" });
    try {
      const decoded = await getAuth(dependencies.firebaseApp).verifyIdToken(token, true);
      if (decoded.active !== true || typeof decoded.storeId !== "string") {
        return response.status(403).json({ error: "inactive_or_missing_tenant" });
      }
      (request as AuthenticatedRequest).paymentIdentity = {
        uid: decoded.uid,
        storeId: decoded.storeId,
      };
      next();
    } catch {
      response.status(401).json({ error: "invalid_token" });
    }
  };

  app.post("/payments/qris", authenticate, async (request, response, next) => {
    try {
      const order = await dependencies.payments.createQris(
        (request as AuthenticatedRequest).paymentIdentity,
        request.body,
      );
      response.status(201).json(order);
    } catch (error) {
      if (error instanceof z.ZodError || error instanceof PaymentValidationError) {
        return response.status(422).json({ error: "invalid_payment", message: error.message });
      }
      next(error);
    }
  });

  app.get("/payments/qris/:orderId", authenticate, async (request, response, next) => {
    try {
      const orderId = request.params.orderId;
      if (typeof orderId !== "string") return response.sendStatus(404);
      const order = await dependencies.repository.getOrder(
        orderId,
        (request as AuthenticatedRequest).paymentIdentity,
      );
      if (!order) return response.sendStatus(404);
      response.json(publicOrder(order));
    } catch (error) {
      next(error);
    }
  });

  app.post("/webhooks/midtrans", async (request, response, next) => {
    try {
      const status = await dependencies.payments.handleNotification(request.body);
      response.json({ accepted: true, status });
    } catch (error) {
      if (error instanceof InvalidMidtransSignatureError) {
        return response.status(401).json({ error: "invalid_signature" });
      }
      if (error instanceof z.ZodError || error instanceof PaymentValidationError) {
        return response.status(422).json({ error: "invalid_notification" });
      }
      dependencies.log.error({ error }, "Midtrans webhook failed");
      next(error);
    }
  });
}

export class PaymentValidationError extends Error {}

interface AuthenticatedRequest extends Request {
  paymentIdentity: PaymentIdentity;
}

function orderFrom(value: FirebaseFirestore.DocumentData | undefined, created: boolean): PreparedOrder {
  if (!value) throw new PaymentValidationError("Payment order tidak ditemukan.");
  return {
    created,
    orderId: string(value.orderId, ""),
    storeId: string(value.storeId, ""),
    cashierId: string(value.cashierId, ""),
    grossAmount: integer(value.grossAmount),
    status: string(value.status, "UNKNOWN"),
    items: Array.isArray(value.items) ? value.items.map((item) => ({
      id: string(item.id, ""),
      name: string(item.name, "Produk"),
      price: integer(item.price),
      purchasePrice: integer(item.purchasePrice),
      quantity: integer(item.quantity),
    })) : [],
    qrUrl: typeof value.qrUrl === "string" ? value.qrUrl : null,
    expiresAt: value.expiresAt instanceof Timestamp ? value.expiresAt.toDate() : null,
  };
}

function publicOrder(order: PreparedOrder) {
  return {
    orderId: order.orderId,
    grossAmount: order.grossAmount,
    status: order.status,
    qrUrl: order.qrUrl,
    expiresAt: order.expiresAt?.toISOString() ?? null,
  };
}

function integer(value: unknown): number {
  return typeof value === "number" && Number.isSafeInteger(value) ? value : 0;
}

function string(value: unknown, fallback: string): string {
  return typeof value === "string" && value ? value : fallback;
}
