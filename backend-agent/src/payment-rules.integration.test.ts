import assert from "node:assert/strict";
import { randomUUID } from "node:crypto";
import test from "node:test";
import { deleteApp, initializeApp } from "firebase-admin/app";
import { getFirestore } from "firebase-admin/firestore";
import { FirestorePaymentRepository } from "./payments.js";

test("settlement QRIS atomik dan idempoten pada Firestore", {
  skip: !process.env.FIRESTORE_EMULATOR_HOST,
}, async () => {
  const suffix = randomUUID();
  const storeId = `payment-store-${suffix}`;
  const orderId = `RG-${suffix}`;
  const app = initializeApp({ projectId: "demo-ryangunshop" }, `payment-${suffix}`);
  const db = getFirestore(app);
  const product = db.collection("stores").doc(storeId).collection("products").doc("kopi");
  await product.set({
    name: "Kopi",
    active: true,
    sellingPrice: 6_000,
    purchasePrice: 4_000,
    stock: 10,
    minimumStock: 3,
    isLowStock: false,
  });
  const repository = new FirestorePaymentRepository(db);

  try {
    const prepared = await repository.prepareOrder({
      uid: "cashier-a",
      storeId,
      orderId,
      clientRequestId: randomUUID(),
      items: [{ productId: "kopi", quantity: 2 }],
    });
    assert.equal(prepared.grossAmount, 12_000);
    await repository.attachCharge(orderId, {
      transactionId: "midtrans-tx-1",
      qrUrl: "https://example.invalid/qr",
      expiresAt: new Date("2026-09-28T00:00:00Z"),
    });
    const settlement = {
      eventId: `settled-${suffix}`,
      orderId,
      transactionId: "midtrans-tx-1",
      grossAmount: 12_000,
      status: "SETTLED" as const,
    };
    await repository.applyVerifiedStatus(settlement);
    await repository.applyVerifiedStatus(settlement);

    const [updatedProduct, transaction, order] = await Promise.all([
      product.get(),
      db.collection("stores").doc(storeId).collection("transactions").doc(orderId).get(),
      db.collection("paymentOrders").doc(orderId).get(),
    ]);
    assert.equal(updatedProduct.data()?.stock, 8);
    assert.equal(transaction.data()?.total, 12_000);
    assert.equal(transaction.data()?.grossProfit, 4_000);
    assert.equal(order.data()?.status, "SETTLED");

    await repository.applyVerifiedStatus({
      ...settlement,
      eventId: `late-pending-${suffix}`,
      status: "PENDING",
    });
    assert.equal((await product.get()).data()?.stock, 8);
    assert.equal(
      (await db.collection("paymentOrders").doc(orderId).get()).data()?.status,
      "SETTLED",
    );

    await repository.applyVerifiedStatus({
      ...settlement,
      eventId: `refund-${suffix}`,
      status: "REFUNDED",
    });
    const [afterRefundProduct, refundedOrder] = await Promise.all([
      product.get(),
      db.collection("paymentOrders").doc(orderId).get(),
    ]);
    assert.equal(afterRefundProduct.data()?.stock, 8);
    assert.equal(refundedOrder.data()?.status, "REFUNDED");
    assert.equal(refundedOrder.data()?.requiresReview, true);
  } finally {
    await deleteApp(app);
  }
});
