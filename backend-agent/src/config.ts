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
});

export type AppConfig = z.infer<typeof schema>;

export function loadConfig(env: NodeJS.ProcessEnv = process.env): AppConfig {
  const parsed = schema.safeParse(env);
  if (!parsed.success) {
    throw new Error(`Konfigurasi tidak valid: ${z.prettifyError(parsed.error)}`);
  }
  return parsed.data;
}
