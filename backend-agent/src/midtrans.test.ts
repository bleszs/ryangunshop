import assert from "node:assert/strict";
import { createHash } from "node:crypto";
import test from "node:test";
import {
  InvalidMidtransSignatureError,
  mapMidtransStatus,
  MidtransClient,
} from "./midtrans.js";

const serverKey = "SB-Mid-server-test-key";

test("memvalidasi signature webhook dan memetakan settlement", () => {
  const notification = signedNotification("settlement");
  const client = new MidtransClient(serverKey, false);
  assert.deepEqual(client.parseAndVerifyNotification(notification), notification);
  assert.equal(mapMidtransStatus(notification), "SETTLED");
});

test("menolak webhook Midtrans yang telah dimodifikasi", () => {
  const client = new MidtransClient(serverKey, false);
  const notification = { ...signedNotification("settlement"), gross_amount: "999.00" };
  assert.throws(
    () => client.parseAndVerifyNotification(notification),
    InvalidMidtransSignatureError,
  );
});

test("membuat charge QRIS dinamis tanpa mengekspos server key", async () => {
  let captured: RequestInit | undefined;
  const client = new MidtransClient(serverKey, false, async (_url, init) => {
    captured = init;
    return Response.json({
      transaction_id: "tx-1",
      order_id: "RG-1",
      gross_amount: "12000.00",
      transaction_status: "pending",
      expiry_time: "2026-09-27 23:30:00 +0700",
      actions: [{
        name: "generate-qr-code-v2",
        method: "GET",
        url: "https://api.sandbox.midtrans.com/v2/qris/tx-1/qr-code",
      }],
    });
  });
  const result = await client.createQris({
    orderId: "RG-1",
    grossAmount: 12_000,
    items: [{ id: "kopi", name: "Kopi", price: 6_000, quantity: 2 }],
  });
  assert.equal(result.grossAmount, 12_000);
  assert.match(result.qrUrl, /qr-code$/);
  const requestBody = JSON.parse(String(captured?.body));
  assert.equal(requestBody.payment_type, "qris");
  assert.equal(requestBody.transaction_details.gross_amount, 12_000);
  assert.doesNotMatch(JSON.stringify(requestBody), new RegExp(serverKey));
});

function signedNotification(transactionStatus: string) {
  const notification = {
    transaction_id: "tx-1",
    order_id: "RG-1",
    gross_amount: "12000.00",
    status_code: "200",
    transaction_status: transactionStatus,
  };
  return {
    ...notification,
    signature_key: createHash("sha512")
      .update(
        notification.order_id
          + notification.status_code
          + notification.gross_amount
          + serverKey,
      )
      .digest("hex"),
  };
}
