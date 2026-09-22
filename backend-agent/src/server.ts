import { getApps, initializeApp } from "firebase-admin/app";
import { getFirestore } from "firebase-admin/firestore";
import pino from "pino";
import { AgentService } from "./agent.js";
import { createHttpApp } from "./app.js";
import { loadConfig } from "./config.js";
import { FirestoreStoreRepository } from "./firestore-store.js";
import { ToolRegistry } from "./tool-registry.js";

const config = loadConfig();
const log = pino({ level: config.LOG_LEVEL });
const firebaseApp = getApps()[0] ?? initializeApp({ projectId: config.FIREBASE_PROJECT_ID });
const firestore = getFirestore(firebaseApp);
firestore.settings({ ignoreUndefinedProperties: true });

const store = new FirestoreStoreRepository(firestore);
const registry = new ToolRegistry(store);
const agent = new AgentService(config.OLLAMA_HOST, config.OLLAMA_MODEL, registry);
const app = createHttpApp({ config, store, agent, log });

app.listen(config.PORT, () => {
  log.info({ port: config.PORT }, "RyanGunshop agent listening");
});
