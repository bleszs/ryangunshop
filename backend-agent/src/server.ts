import express from "express";
import { getApps, initializeApp } from "firebase-admin/app";
import { getFirestore } from "firebase-admin/firestore";
import pino from "pino";
import { pinoHttp } from "pino-http";
import { AgentService } from "./agent.js";
import { loadConfig } from "./config.js";
import { FirestoreStoreRepository } from "./firestore-store.js";
import { ToolRegistry } from "./tool-registry.js";
import { registerWhatsAppRoutes } from "./whatsapp.js";

const config = loadConfig();
const log = pino({ level: config.LOG_LEVEL });
const firebaseApp = getApps()[0] ?? initializeApp({ projectId: config.FIREBASE_PROJECT_ID });
const firestore = getFirestore(firebaseApp);
firestore.settings({ ignoreUndefinedProperties: true });

const store = new FirestoreStoreRepository(firestore);
const registry = new ToolRegistry(store);
const agent = new AgentService(config.OLLAMA_HOST, config.OLLAMA_MODEL, registry);

const app = express();
app.disable("x-powered-by");
app.use(pinoHttp({ logger: log }));
app.use(express.json({
  limit: "256kb",
  verify: (request, _response, buffer) => {
    (request as express.Request & { rawBody?: Buffer }).rawBody = Buffer.from(buffer);
  },
}));

app.get("/health", (_request, response) => {
  response.json({ status: "ok" });
});
registerWhatsAppRoutes(app, { config, store, agent, log });

app.use((_request, response) => response.sendStatus(404));
app.use((error: unknown, _request: express.Request, response: express.Response, _next: express.NextFunction) => {
  log.error({ error }, "Unhandled request error");
  response.status(500).json({ error: "internal_error" });
});

app.listen(config.PORT, () => {
  log.info({ port: config.PORT }, "RyanGunshop agent listening");
});
