import assert from "node:assert/strict";
import { createHmac } from "node:crypto";
import type { AddressInfo } from "node:net";
import test from "node:test";
import pino from "pino";
import { createHttpApp } from "./app.js";
import type { AppConfig } from "./config.js";

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
  WHATSAPP_QUEUE_MAX_ATTEMPTS: 5,
  WHATSAPP_QUEUE_LEASE_MS: 120_000,
  OLLAMA_HOST: "http://ollama.invalid",
  OLLAMA_MODEL: "test-model",
  FIREBASE_PROJECT_ID: "demo-ryangunshop",
};

test("webhook terverifikasi disimpan ke antrean sebelum ACK", async () => {
  const enqueued: Array<{ id: string; from: string; text: string }> = [];
  const app = createHttpApp({
    config,
    log: pino({ enabled: false }),
    queue: {
      async enqueue(message) {
        enqueued.push(message);
        return true;
      },
    },
  });
  const server = app.listen(0, "127.0.0.1");

  try {
    await new Promise<void>((resolve) => server.once("listening", resolve));
    const { port } = server.address() as AddressInfo;
    const rawBody = JSON.stringify({
      entry: [{ changes: [{ value: { messages: [{
        id: "wamid-1",
        from: "+62 812-3456-789",
        text: { body: "stok kopi?" },
      }] } }] }],
    });
    const signature = `sha256=${createHmac("sha256", config.WHATSAPP_APP_SECRET)
      .update(rawBody)
      .digest("hex")}`;

    const response = await fetch(`http://127.0.0.1:${port}/webhooks/whatsapp`, {
      method: "POST",
      headers: { "content-type": "application/json", "x-hub-signature-256": signature },
      body: rawBody,
    });
    assert.equal(response.status, 200);
    assert.deepEqual(enqueued, [{
      id: "wamid-1",
      from: "+62 812-3456-789",
      text: "stok kopi?",
    }]);
  } finally {
    await new Promise<void>((resolve, reject) => {
      server.close((error) => error ? reject(error) : resolve());
    });
  }
});

test("webhook menolak signature tidak valid sebelum memproses pesan", async () => {
  let enqueued = false;
  const app = createHttpApp({
    config,
    log: pino({ enabled: false }),
    queue: {
      async enqueue() {
        enqueued = true;
        return true;
      },
    },
  });
  const server = app.listen(0, "127.0.0.1");

  try {
    await new Promise<void>((resolve) => server.once("listening", resolve));
    const { port } = server.address() as AddressInfo;
    const response = await fetch(`http://127.0.0.1:${port}/webhooks/whatsapp`, {
      method: "POST",
      headers: { "content-type": "application/json", "x-hub-signature-256": "sha256=invalid" },
      body: JSON.stringify({ entry: [] }),
    });

    assert.equal(response.status, 401);
    assert.equal(enqueued, false);
  } finally {
    await new Promise<void>((resolve, reject) => {
      server.close((error) => error ? reject(error) : resolve());
    });
  }
});

test("webhook meminta retry Meta ketika penyimpanan antrean gagal", async () => {
  const app = createHttpApp({
    config,
    log: pino({ enabled: false }),
    queue: {
      async enqueue() {
        throw new Error("Firestore unavailable");
      },
    },
  });
  const server = app.listen(0, "127.0.0.1");

  try {
    await new Promise<void>((resolve) => server.once("listening", resolve));
    const { port } = server.address() as AddressInfo;
    const rawBody = JSON.stringify({
      entry: [{ changes: [{ value: { messages: [{
        id: "wamid-retry",
        from: "628123456789",
        text: { body: "stok kopi?" },
      }] } }] }],
    });
    const signature = `sha256=${createHmac("sha256", config.WHATSAPP_APP_SECRET)
      .update(rawBody)
      .digest("hex")}`;
    const response = await fetch(`http://127.0.0.1:${port}/webhooks/whatsapp`, {
      method: "POST",
      headers: { "content-type": "application/json", "x-hub-signature-256": signature },
      body: rawBody,
    });
    assert.equal(response.status, 503);
  } finally {
    await new Promise<void>((resolve, reject) => {
      server.close((error) => error ? reject(error) : resolve());
    });
  }
});
