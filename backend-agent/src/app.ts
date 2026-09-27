import express, { type Express } from "express";
import type { Logger } from "pino";
import { pinoHttp } from "pino-http";
import type { AppConfig } from "./config.js";
import {
  registerWhatsAppRoutes,
} from "./whatsapp.js";
import type { DurableWhatsAppQueue } from "./whatsapp-queue.js";

export interface HttpAppDependencies {
  config: AppConfig;
  queue: Pick<DurableWhatsAppQueue, "enqueue">;
  log: Logger;
}

export function createHttpApp(dependencies: HttpAppDependencies): Express {
  const { config, queue, log } = dependencies;
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
    queue,
    log,
  });

  app.use((_request, response) => response.sendStatus(404));
  app.use((error: unknown, _request: express.Request, response: express.Response, _next: express.NextFunction) => {
    log.error({ error }, "Unhandled request error");
    response.status(500).json({ error: "internal_error" });
  });

  return app;
}
