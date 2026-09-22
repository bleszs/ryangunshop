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
  OLLAMA_HOST: "http://ollama.invalid",
  OLLAMA_MODEL: "test-model",
  FIREBASE_PROJECT_ID: "demo-ryangunshop",
};

test("webhook terverifikasi mengalir ke agent dan sender mock", async () => {
  const background: Promise<void>[] = [];
  const agentCalls: Array<{ text: string; storeId: string }> = [];
  const sent: Array<{ recipient: string; body: string }> = [];
  const app = createHttpApp({
    config,
    log: pino({ enabled: false }),
    store: {
      async claimMessage(id) {
        assert.equal(id, "wamid-1");
        return true;
      },
      async findAuthorizedUser(phone) {
        assert.equal(phone, "+628123456789");
        return { phone, userId: "owner-a", storeId: "store-a", role: "OWNER" };
      },
    },
    agent: {
      async answer(context, text) {
        agentCalls.push({ text, storeId: context.storeId });
        return "Stok Kopi tersisa 7 unit.";
      },
    },
    async sendText(_senderConfig, recipient, body) {
      sent.push({ recipient, body });
    },
    schedule(work) {
      background.push(work);
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
    await Promise.all(background);

    assert.deepEqual(agentCalls, [{ text: "stok kopi?", storeId: "store-a" }]);
    assert.deepEqual(sent, [{ recipient: "+62 812-3456-789", body: "Stok Kopi tersisa 7 unit." }]);
  } finally {
    await new Promise<void>((resolve, reject) => {
      server.close((error) => error ? reject(error) : resolve());
    });
  }
});

test("webhook menolak signature tidak valid sebelum memproses pesan", async () => {
  let claimed = false;
  const app = createHttpApp({
    config,
    log: pino({ enabled: false }),
    store: {
      async claimMessage() {
        claimed = true;
        return true;
      },
      async findAuthorizedUser() {
        return null;
      },
    },
    agent: { async answer() { return "tidak digunakan"; } },
    async sendText() {},
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
    assert.equal(claimed, false);
  } finally {
    await new Promise<void>((resolve, reject) => {
      server.close((error) => error ? reject(error) : resolve());
    });
  }
});
