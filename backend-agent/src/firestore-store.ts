import { createHash, randomUUID } from "node:crypto";
import {
  FieldValue,
  Firestore,
  Timestamp,
} from "firebase-admin/firestore";
import { normalizeSearch } from "./normalization.js";
import type { AgentContext, AuthorizedUser, DateRange, UserRole } from "./types.js";

interface ProductRecord {
  id: string;
  name: string;
  stock: number;
  minimumStock: number;
  shelfLocation: string | null;
  averageDailySales: number;
}

interface TransactionItem {
  productId: string;
  productName: string;
  quantity: number;
}

export class FirestoreStoreRepository {
  constructor(private readonly db: Firestore) {}

  async findAuthorizedUser(phone: string): Promise<AuthorizedUser | null> {
    const snapshot = await this.db.collection("whatsappUsers").doc(phone).get();
    const data = snapshot.data();
    if (!snapshot.exists || data?.active !== true) return null;
    if (typeof data.storeId !== "string" || typeof data.userId !== "string") return null;
    if (!isRole(data.role)) return null;
    return { phone, storeId: data.storeId, userId: data.userId, role: data.role };
  }

  async claimMessage(messageId: string): Promise<boolean> {
    try {
      await this.db.collection("whatsappMessages").doc(messageId).create({
        createdAt: FieldValue.serverTimestamp(),
        expiresAt: Timestamp.fromMillis(Date.now() + 7 * 86_400_000),
      });
      return true;
    } catch (error) {
      const code = (error as { code?: number | string }).code;
      if (code === 6 || code === "already-exists") return false;
      throw error;
    }
  }

  async getProductStock(storeId: string, productName: string): Promise<{
    exact: ProductRecord | null;
    suggestions: ProductRecord[];
  }> {
    const normalizedName = normalizeSearch(productName);
    const collection = this.products(storeId);
    const exact = await collection
      .where("active", "==", true)
      .where("normalizedName", "==", normalizedName)
      .limit(1)
      .get();
    if (!exact.empty) {
      return { exact: productFrom(exact.docs[0]!), suggestions: [] };
    }

    const prefix = await collection
      .where("active", "==", true)
      .orderBy("normalizedName")
      .startAt(normalizedName)
      .endAt(`${normalizedName}\uf8ff`)
      .limit(5)
      .get();
    return { exact: null, suggestions: prefix.docs.map(productFrom) };
  }

  async getLowStock(storeId: string): Promise<ProductRecord[]> {
    const snapshot = await this.products(storeId)
      .where("active", "==", true)
      .where("isLowStock", "==", true)
      .orderBy("stock", "asc")
      .limit(100)
      .get();
    return snapshot.docs.map(productFrom);
  }

  async getSalesSummary(storeId: string, range: DateRange): Promise<{
    period: string;
    transactionCount: number;
    revenue: number;
    grossProfit: number;
  }> {
    const transactions = await this.successfulTransactions(storeId, range);
    return transactions.docs.reduce(
      (summary, doc) => {
        const data = doc.data();
        summary.transactionCount += 1;
        summary.revenue += numberField(data.total);
        summary.grossProfit += numberField(data.grossProfit);
        return summary;
      },
      { period: range.label, transactionCount: 0, revenue: 0, grossProfit: 0 },
    );
  }

  async getBestSellingProducts(storeId: string, range: DateRange): Promise<Array<{
    productId: string;
    name: string;
    quantity: number;
  }>> {
    const transactions = await this.successfulTransactions(storeId, range);
    const aggregate = new Map<string, { productId: string; name: string; quantity: number }>();
    for (const doc of transactions.docs) {
      for (const item of transactionItems(doc.data().items)) {
        const current = aggregate.get(item.productId) ?? {
          productId: item.productId,
          name: item.productName,
          quantity: 0,
        };
        current.quantity += item.quantity;
        aggregate.set(item.productId, current);
      }
    }
    return [...aggregate.values()].sort((a, b) => b.quantity - a.quantity).slice(0, 5);
  }

  async getRestockRecommendation(storeId: string): Promise<Array<{
    productId: string;
    name: string;
    currentStock: number;
    recommendedQuantity: number;
    estimatedDaysRemaining: number | null;
  }>> {
    const products = await this.getLowStock(storeId);
    return products.map((product) => {
      const target = Math.max(product.minimumStock * 2, product.minimumStock + 1);
      const recommendedQuantity = Math.max(0, target - product.stock);
      const estimatedDaysRemaining = product.averageDailySales > 0
        ? Math.floor(product.stock / product.averageDailySales)
        : null;
      return {
        productId: product.id,
        name: product.name,
        currentStock: product.stock,
        recommendedQuantity,
        estimatedDaysRemaining,
      };
    });
  }

  async requestReport(
    context: AgentContext,
    date: string,
    format: "PDF" | "CSV",
  ): Promise<{ jobId: string; status: "QUEUED" }> {
    const jobId = randomUUID();
    await this.db
      .collection("stores")
      .doc(context.storeId)
      .collection("reportJobs")
      .doc(jobId)
      .create({
        date,
        format,
        status: "QUEUED",
        requestedBy: context.userId,
        whatsappMessageId: context.whatsappMessageId,
        createdAt: FieldValue.serverTimestamp(),
      });
    return { jobId, status: "QUEUED" };
  }

  async auditAction(input: {
    context: AgentContext;
    actionId: string;
    tool: string;
    parameters: unknown;
    status: "SUCCESS" | "DENIED" | "FAILED";
    resultSummary: string;
  }): Promise<void> {
    await this.db
      .collection("stores")
      .doc(input.context.storeId)
      .collection("agentActions")
      .doc(input.actionId)
      .set({
        phoneHash: createHash("sha256").update(input.context.phone).digest("hex"),
        userId: input.context.userId,
        tool: input.tool,
        parameters: input.parameters,
        status: input.status,
        resultSummary: input.resultSummary.slice(0, 500),
        confirmationId: null,
        whatsappMessageId: input.context.whatsappMessageId,
        createdAt: FieldValue.serverTimestamp(),
      });
  }

  private products(storeId: string) {
    return this.db.collection("stores").doc(storeId).collection("products");
  }

  private successfulTransactions(storeId: string, range: DateRange) {
    return this.db
      .collection("stores")
      .doc(storeId)
      .collection("transactions")
      .where("status", "==", "SUCCESS")
      .where("occurredAt", ">=", Timestamp.fromDate(range.from))
      .where("occurredAt", "<=", Timestamp.fromDate(range.to))
      .orderBy("occurredAt", "desc")
      .limit(5_000)
      .get();
  }
}

function productFrom(doc: FirebaseFirestore.QueryDocumentSnapshot): ProductRecord {
  const data = doc.data();
  return {
    id: doc.id,
    name: stringField(data.name, "Produk tanpa nama"),
    stock: integerField(data.stock),
    minimumStock: integerField(data.minimumStock),
    shelfLocation: typeof data.shelfLocation === "string" ? data.shelfLocation : null,
    averageDailySales: Math.max(0, numberField(data.averageDailySales)),
  };
}

function transactionItems(value: unknown): TransactionItem[] {
  if (!Array.isArray(value)) return [];
  return value.flatMap((raw) => {
    if (!raw || typeof raw !== "object") return [];
    const item = raw as Record<string, unknown>;
    if (typeof item.productId !== "string") return [];
    return [{
      productId: item.productId,
      productName: stringField(item.productName ?? item.productNameSnapshot, "Produk"),
      quantity: integerField(item.quantity),
    }];
  });
}

function numberField(value: unknown): number {
  return typeof value === "number" && Number.isFinite(value) ? value : 0;
}

function integerField(value: unknown): number {
  return Math.max(0, Math.trunc(numberField(value)));
}

function stringField(value: unknown, fallback: string): string {
  return typeof value === "string" && value.trim() ? value : fallback;
}

function isRole(value: unknown): value is UserRole {
  return value === "OWNER" || value === "CASHIER";
}
