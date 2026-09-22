import express, { type Express } from "express";
import type { Logger } from "pino";
import { pinoHttp } from "pino-http";
import type { AppConfig } from "./config.js";
import {
  registerWhatsAppRoutes,
  type WhatsAppAgent,
  type WhatsAppStore,
  type WhatsAppTextSender,
} from "./whatsapp.js";

export interface HttpAppDependencies {
  config: AppConfig;
  store: WhatsAppStore;
  agent: WhatsAppAgent;
  log: Logger;
  sendText?: WhatsAppTextSender;
  schedule?: (work: Promise<void>) => void;
}

export function createHttpApp(dependencies: HttpAppDependencies): Express {
  const { config, store, agent, log, sendText, schedule } = dependencies;
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
  registerWhatsAppRoutes(app, {
    config,
    store,
    agent,
    log,
    ...(sendText ? { sendText } : {}),
    ...(schedule ? { schedule } : {}),
  });

  app.use((_request, response) => response.sendStatus(404));
  app.use((error: unknown, _request: express.Request, response: express.Response, _next: express.NextFunction) => {
    log.error({ error }, "Unhandled request error");
    response.status(500).json({ error: "internal_error" });
  });

  return app;
}
