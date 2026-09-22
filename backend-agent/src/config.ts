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

