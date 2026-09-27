import express, { type Express } from "express";
import type { Logger } from "pino";
import { pinoHttp } from "pino-http";
import type { AppConfig } from "./config.js";
import {
  registerWhatsAppRoutes,
} from "./whatsapp.js";
import type { DurableWhatsAppQueue } from "./whatsapp-queue.js";
import {
  registerPaymentRoutes,
  type FirestorePaymentRepository,
  type PaymentService,
} from "./payments.js";
import type { App } from "firebase-admin/app";

export interface HttpAppDependencies {
  config: AppConfig;
  queue: Pick<DurableWhatsAppQueue, "enqueue">;
  log: Logger;
  payment?: {
    firebaseApp: App;
    service: PaymentService;
    repository: FirestorePaymentRepository;
  };
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
  if (dependencies.payment) {
    registerPaymentRoutes(app, {
      firebaseApp: dependencies.payment.firebaseApp,
      payments: dependencies.payment.service,
      repository: dependencies.payment.repository,
      log,
    });
  }

  app.use((_request, response) => response.sendStatus(404));
  app.use((error: unknown, _request: express.Request, response: express.Response, _next: express.NextFunction) => {
    log.error({ error }, "Unhandled request error");
    response.status(500).json({ error: "internal_error" });
  });

  return app;
}
