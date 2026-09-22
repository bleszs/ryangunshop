import { randomUUID } from "node:crypto";
import { z } from "zod";
import { FirestoreStoreRepository } from "./firestore-store.js";
import { parsePeriod } from "./normalization.js";
import type { AgentContext, UserRole } from "./types.js";

export interface OllamaToolDefinition {
  type: "function";
  function: {
    name: string;
    description: string;
    parameters: Record<string, unknown>;
  };
}

interface ToolEntry {
  definition: OllamaToolDefinition;
  schema: z.ZodType;
  allowedRoles: ReadonlySet<UserRole>;
  execute: (args: never, context: AgentContext) => Promise<unknown>;
}

export class ToolRegistry {
  private readonly entries: ReadonlyMap<string, ToolEntry>;

  constructor(private readonly store: FirestoreStoreRepository) {
    const owner = new Set<UserRole>(["OWNER"]);
    const staff = new Set<UserRole>(["OWNER", "CASHIER"]);
    const entries: ToolEntry[] = [
      {
        definition: tool(
          "getProductStock",
          "Ambil stok produk dari database toko berdasarkan nama produk.",
          objectSchema({ productName: stringProperty("Nama produk") }, ["productName"]),
        ),
        schema: z.object({ productName: z.string().trim().min(1).max(120) }),
        allowedRoles: staff,
        execute: async (args: { productName: string }, context) =>
          this.store.getProductStock(context.storeId, args.productName),
      } as ToolEntry,
      {
        definition: tool("getLowStock", "Ambil daftar produk yang stoknya menipis.", objectSchema({}, [])),
        schema: z.object({}),
        allowedRoles: staff,
        execute: async (_args: Record<string, never>, context) =>
          this.store.getLowStock(context.storeId),
      } as ToolEntry,
      {
        definition: tool(
          "getSalesSummary",
          "Ambil omzet, laba kotor, dan jumlah transaksi berhasil untuk periode.",
          objectSchema({ period: stringProperty("hari ini, 7 hari, atau YYYY-MM-DD") }, ["period"]),
        ),
        schema: z.object({ period: z.string().trim().min(1).max(40) }),
        allowedRoles: owner,
        execute: async (args: { period: string }, context) =>
          this.store.getSalesSummary(context.storeId, parsePeriod(args.period)),
      } as ToolEntry,
      {
        definition: tool(
          "getBestSellingProducts",
          "Ambil lima produk terlaris berdasarkan transaksi berhasil untuk periode.",
          objectSchema({ period: stringProperty("hari ini, 7 hari, atau YYYY-MM-DD") }, ["period"]),
        ),
        schema: z.object({ period: z.string().trim().min(1).max(40) }),
        allowedRoles: owner,
        execute: async (args: { period: string }, context) =>
          this.store.getBestSellingProducts(context.storeId, parsePeriod(args.period)),
      } as ToolEntry,
      {
        definition: tool(
          "getRestockRecommendation",
          "Ambil rekomendasi restok berbasis stok minimum dan laju jual yang tersimpan.",
          objectSchema({}, []),
        ),
        schema: z.object({}),
        allowedRoles: owner,
        execute: async (_args: Record<string, never>, context) =>
          this.store.getRestockRecommendation(context.storeId),
      } as ToolEntry,
      {
        definition: tool(
          "generateReport",
          "Buat request laporan toko. Tool mengembalikan job ID; jangan mengaku file selesai sebelum status selesai.",
          objectSchema(
            {
              date: stringProperty("Tanggal YYYY-MM-DD"),
              format: { type: "string", enum: ["PDF", "CSV"] },
            },
            ["date", "format"],
          ),
        ),
        schema: z.object({
          date: z.iso.date(),
          format: z.enum(["PDF", "CSV"]),
        }),
        allowedRoles: owner,
        execute: async (args: { date: string; format: "PDF" | "CSV" }, context) =>
          this.store.requestReport(context, args.date, args.format),
      } as ToolEntry,
    ];
    this.entries = new Map(entries.map((entry) => [entry.definition.function.name, entry]));
  }

  definitions(): OllamaToolDefinition[] {
    return [...this.entries.values()].map((entry) => entry.definition);
  }

  async execute(name: string, rawArguments: unknown, context: AgentContext): Promise<{
    actionId: string;
    data: unknown;
  }> {
    const actionId = randomUUID();
    const entry = this.entries.get(name);
    const parameters = parseArguments(rawArguments);
    let status: "SUCCESS" | "DENIED" | "FAILED" = "FAILED";
    let summary = "Tool gagal sebelum menghasilkan data";

    try {
      if (!entry) {
        status = "DENIED";
        throw new ToolDeniedError(`Tool '${name}' tidak terdaftar`);
      }
      if (!entry.allowedRoles.has(context.role)) {
        status = "DENIED";
        throw new ToolDeniedError("Peran pengguna tidak memiliki izin untuk tool ini");
      }
      const validated = entry.schema.parse(parameters);
      const data = await entry.execute(validated as never, context);
      status = "SUCCESS";
      summary = safeSummary(data);
      return { actionId, data };
    } catch (error) {
      if (error instanceof ToolDeniedError) status = "DENIED";
      summary = safeError(error);
      throw error;
    } finally {
      await this.store.auditAction({
        context,
        actionId,
        tool: name,
        parameters,
        status,
        resultSummary: summary,
      });
    }
  }
}

export class ToolDeniedError extends Error {}

function tool(
  name: string,
  description: string,
  parameters: Record<string, unknown>,
): OllamaToolDefinition {
  return { type: "function", function: { name, description, parameters } };
}

function objectSchema(
  properties: Record<string, unknown>,
  required: string[],
): Record<string, unknown> {
  return { type: "object", additionalProperties: false, properties, required };
}

function stringProperty(description: string): Record<string, unknown> {
  return { type: "string", description };
}

function parseArguments(value: unknown): unknown {
  if (typeof value !== "string") return value ?? {};
  try {
    return JSON.parse(value) as unknown;
  } catch {
    throw new Error("Argumen tool bukan JSON valid");
  }
}

function safeSummary(value: unknown): string {
  try {
    return JSON.stringify(value).slice(0, 500);
  } catch {
    return "Hasil tool tidak dapat diringkas";
  }
}

function safeError(error: unknown): string {
  return error instanceof Error ? error.message.slice(0, 500) : "Kesalahan tool";
}

