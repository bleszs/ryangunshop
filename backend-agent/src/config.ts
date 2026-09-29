import { z } from "zod";

const schema = z.object({
  NODE_ENV: z.enum(["development", "test", "production"]).default("development"),
  PORT: z.coerce.number().int().positive().default(8080),
  LOG_LEVEL: z.string().default("info"),
  WHATSAPP_VERIFY_TOKEN: z.string().min(16),
  WHATSAPP_APP_SECRET: z.string().min(16),
  WHATSAPP_ACCESS_TOKEN: z.string().min(16),
  WHATSAPP_PHONE_NUMBER_ID: z.string().min(1),
  WHATSAPP_GRAPH_VERSION: z.string().regex(/^v\d+\.\d+$/),
  WHATSAPP_QUEUE_POLL_MS: z.coerce.number().int().min(250).max(60_000).default(2_000),
  WHATSAPP_QUEUE_BATCH_SIZE: z.coerce.number().int().min(1).max(50).default(10),
  WHATSAPP_QUEUE_MAX_ATTEMPTS: z.coerce.number().int().min(1).max(20).default(5),
  WHATSAPP_QUEUE_LEASE_MS: z.coerce.number().int().min(10_000).max(900_000).default(120_000),
  OLLAMA_HOST: z.url(),
  OLLAMA_MODEL: z.string().min(1),
  FIREBASE_PROJECT_ID: z.string().min(1),
  FIREBASE_STORAGE_BUCKET: z.string().min(3).optional(),
  REPORT_QUEUE_POLL_MS: z.coerce.number().int().min(1_000).max(60_000).default(5_000),
  REPORT_QUEUE_BATCH_SIZE: z.coerce.number().int().min(1).max(10).default(3),
  REPORT_QUEUE_MAX_ATTEMPTS: z.coerce.number().int().min(1).max(10).default(5),
  REPORT_QUEUE_LEASE_MS: z.coerce.number().int().min(30_000).max(900_000).default(180_000),
  REPORT_LINK_TTL_MINUTES: z.coerce.number().int().min(5).max(60).default(10),
  MIDTRANS_SERVER_KEY: z.string().min(10).optional(),
  MIDTRANS_IS_PRODUCTION: z.stringbool().default(false),
});

export type AppConfig = z.infer<typeof schema>;

export function loadConfig(env: NodeJS.ProcessEnv = process.env): AppConfig {
  const parsed = schema.safeParse(env);
  if (!parsed.success) {
    throw new Error(`Konfigurasi tidak valid: ${z.prettifyError(parsed.error)}`);
  }
  return parsed.data;
}
