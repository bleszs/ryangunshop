import { createHmac, timingSafeEqual } from "node:crypto";
import type { Request, Response, Router } from "express";
import { AgentService } from "./agent.js";
import type { AppConfig } from "./config.js";
import { FirestoreStoreRepository } from "./firestore-store.js";
import { normalizePhone } from "./normalization.js";
import type { IncomingTextMessage } from "./types.js";

type RawRequest = Request & { rawBody?: Buffer };

export function registerWhatsAppRoutes(
  router: Router,
  dependencies: {
    config: AppConfig;
    store: FirestoreStoreRepository;
    agent: AgentService;
    log: { error: (input: unknown, message?: string) => void };
  },
): void {
  const { config, store, agent, log } = dependencies;

  router.get("/webhooks/whatsapp", (request: Request, response: Response) => {
    const mode = request.query["hub.mode"];
    const token = request.query["hub.verify_token"];
    const challenge = request.query["hub.challenge"];
    if (mode === "subscribe" && token === config.WHATSAPP_VERIFY_TOKEN && typeof challenge === "string") {
      response.status(200).send(challenge);
      return;
    }
    response.sendStatus(403);
  });

  router.post("/webhooks/whatsapp", (request: RawRequest, response: Response) => {
    const signature = request.header("x-hub-signature-256");
    if (!request.rawBody || !verifyMetaSignature(request.rawBody, signature, config.WHATSAPP_APP_SECRET)) {
      response.sendStatus(401);
      return;
    }

    const messages = extractTextMessages(request.body);
    response.sendStatus(200);

    // Untuk production, pindahkan pekerjaan ini ke queue durable setelah ACK.
    void Promise.all(messages.map(async (message) => {
      try {
        if (!(await store.claimMessage(message.id))) return;
        const phone = normalizePhone(message.from);
        const authorized = await store.findAuthorizedUser(phone);
        if (!authorized) {
          await sendWhatsAppText(config, message.from, "Nomor ini belum terdaftar untuk RyanGunshop.");
          return;
        }
        const answer = await agent.answer(
          { ...authorized, whatsappMessageId: message.id },
          message.text,
        );
        await sendWhatsAppText(config, message.from, answer);
      } catch (error) {
        log.error({ error, messageId: message.id }, "Gagal memproses pesan WhatsApp");
        await sendWhatsAppText(
          config,
          message.from,
          "Layanan sedang mengalami gangguan. Data tidak diubah; silakan coba lagi.",
        ).catch((sendError) => log.error({ sendError }, "Gagal mengirim pesan error"));
      }
    }));
  });
}

export function verifyMetaSignature(
  rawBody: Buffer,
  signatureHeader: string | undefined,
  appSecret: string,
): boolean {
  if (!signatureHeader?.startsWith("sha256=")) return false;
  const providedHex = signatureHeader.slice("sha256=".length);
  if (!/^[a-f0-9]{64}$/i.test(providedHex)) return false;
  const expected = createHmac("sha256", appSecret).update(rawBody).digest();
  const provided = Buffer.from(providedHex, "hex");
  return provided.length === expected.length && timingSafeEqual(provided, expected);
}

export function extractTextMessages(body: unknown): IncomingTextMessage[] {
  if (!body || typeof body !== "object") return [];
  const entries = (body as Record<string, unknown>).entry;
  if (!Array.isArray(entries)) return [];
  const output: IncomingTextMessage[] = [];

  for (const entry of entries) {
    if (!entry || typeof entry !== "object") continue;
    const changes = (entry as Record<string, unknown>).changes;
    if (!Array.isArray(changes)) continue;
    for (const change of changes) {
      if (!change || typeof change !== "object") continue;
      const value = (change as Record<string, unknown>).value;
      if (!value || typeof value !== "object") continue;
      const messages = (value as Record<string, unknown>).messages;
      if (!Array.isArray(messages)) continue;
      for (const raw of messages) {
        if (!raw || typeof raw !== "object") continue;
        const message = raw as Record<string, unknown>;
        const textContainer = message.text;
        const text = textContainer && typeof textContainer === "object"
          ? (textContainer as Record<string, unknown>).body
          : undefined;
        if (
          typeof message.id === "string" &&
          typeof message.from === "string" &&
          typeof text === "string" &&
          text.trim()
        ) {
          output.push({ id: message.id, from: message.from, text: text.trim() });
        }
      }
    }
  }
  return output;
}

async function sendWhatsAppText(
  config: AppConfig,
  recipient: string,
  body: string,
): Promise<void> {
  const endpoint = `https://graph.facebook.com/${config.WHATSAPP_GRAPH_VERSION}/${config.WHATSAPP_PHONE_NUMBER_ID}/messages`;
  const response = await fetch(endpoint, {
    method: "POST",
    headers: {
      authorization: `Bearer ${config.WHATSAPP_ACCESS_TOKEN}`,
      "content-type": "application/json",
    },
    body: JSON.stringify({
      messaging_product: "whatsapp",
      recipient_type: "individual",
      to: recipient,
      type: "text",
      text: { preview_url: false, body: body.slice(0, 4_000) },
    }),
    signal: AbortSignal.timeout(10_000),
  });
  if (!response.ok) {
    throw new Error(`WhatsApp Graph API gagal dengan HTTP ${response.status}`);
  }
}

