import { Ollama, type Message } from "ollama";
import { ToolRegistry } from "./tool-registry.js";
import type { AgentContext } from "./types.js";

const SYSTEM_PROMPT = `Anda adalah asisten operasional RyanGunshop berbahasa Indonesia.
Aturan wajib:
1. Untuk setiap fakta stok, penjualan, laba, produk terlaris, restok, atau laporan, panggil tool yang sesuai.
2. Jangan menebak angka, status, nama produk, atau hasil laporan.
3. storeId dan izin ditentukan backend; jangan meminta atau mengubahnya.
4. Jika tool gagal atau tidak menemukan data, katakan itu secara singkat dan sarankan pengguna mencoba lagi/mengecek aplikasi.
5. Jangan menyatakan laporan selesai jika tool hanya mengembalikan status QUEUED.
6. Jawab ringkas, jelas, dan jangan tampilkan reasoning internal.`;

export class AgentService {
  private readonly ollama: Ollama;

  constructor(
    host: string,
    private readonly model: string,
    private readonly registry: ToolRegistry,
  ) {
    this.ollama = new Ollama({ host });
  }

  async answer(context: AgentContext, userText: string): Promise<string> {
    const messages: Message[] = [
      { role: "system", content: SYSTEM_PROMPT },
      { role: "user", content: userText.slice(0, 2_000) },
    ];
    let groundedByTool = false;

    for (let round = 0; round < 4; round += 1) {
      const response = await this.ollama.chat({
        model: this.model,
        messages,
        tools: this.registry.definitions(),
        stream: false,
        think: false,
      });
      messages.push(response.message);
      const calls = response.message.tool_calls ?? [];

      if (calls.length === 0) {
        const answer = response.message.content.trim();
        if (!groundedByTool && containsBusinessNumber(answer)) {
          return "Saya tidak dapat memverifikasi angka itu dari database. Silakan ulangi pertanyaan atau cek aplikasi RyanGunshop.";
        }
        return answer || "Maaf, saya belum dapat memproses permintaan itu.";
      }

      for (const call of calls) {
        try {
          const result = await this.registry.execute(
            call.function.name,
            call.function.arguments,
            context,
          );
          groundedByTool = true;
          messages.push({
            role: "tool",
            tool_name: call.function.name,
            content: JSON.stringify(result),
          });
        } catch (error) {
          messages.push({
            role: "tool",
            tool_name: call.function.name,
            content: JSON.stringify({ ok: false, error: safeError(error) }),
          });
        }
      }
    }

    return "Permintaan terlalu kompleks untuk diproses dengan aman. Coba satu pertanyaan stok atau laporan pada satu waktu.";
  }
}

function containsBusinessNumber(text: string): boolean {
  return /(?:rp\s*)?\d[\d.,]*/i.test(text);
}

function safeError(error: unknown): string {
  if (error instanceof Error) return error.message.slice(0, 240);
  return "Tool gagal";
}
