import assert from "node:assert/strict";
import test from "node:test";
import type { ChatRequest, ChatResponse } from "ollama";
import { AgentService, type AgentToolRegistry, type OllamaChatClient } from "./agent.js";
import type { AgentContext } from "./types.js";

const context: AgentContext = {
  phone: "628123456789",
  userId: "owner-a",
  storeId: "store-a",
  role: "OWNER",
  whatsappMessageId: "wamid-1",
};

test("agent memakai hasil tool sebelum menjawab angka stok", async () => {
  const requests: ChatRequest[] = [];
  const responses = [
    response({
      role: "assistant",
      content: "",
      tool_calls: [{ function: { name: "getProductStock", arguments: { productName: "Kopi" } } }],
    }),
    response({ role: "assistant", content: "Stok Kopi saat ini 7 unit." }),
  ];
  const ollama: OllamaChatClient = {
    async chat(request) {
      requests.push(request);
      const next = responses.shift();
      assert.ok(next, "mock Ollama menerima terlalu banyak request");
      return next;
    },
  };
  const executed: Array<{ name: string; arguments: unknown; storeId: string }> = [];
  const registry: AgentToolRegistry = {
    definitions: () => [{
      type: "function",
      function: { name: "getProductStock", description: "stok", parameters: { type: "object" } },
    }],
    async execute(name, rawArguments, agentContext) {
      executed.push({ name, arguments: rawArguments, storeId: agentContext.storeId });
      return { actionId: "audit-1", data: { productName: "Kopi", stock: 7 } };
    },
  };

  const agent = new AgentService("http://ollama.invalid", "test-model", registry, ollama);
  const answer = await agent.answer(context, "Stok kopi berapa?");

  assert.equal(answer, "Stok Kopi saat ini 7 unit.");
  assert.deepEqual(executed, [{
    name: "getProductStock",
    arguments: { productName: "Kopi" },
    storeId: "store-a",
  }]);
  assert.equal(requests.length, 2);
  const toolMessage = requests[1]?.messages?.find((message) => message.role === "tool");
  assert.ok(toolMessage);
  assert.match(toolMessage.content, /audit-1/);
});

test("agent menolak angka bisnis yang tidak berasal dari tool", async () => {
  const ollama: OllamaChatClient = {
    async chat() {
      return response({ role: "assistant", content: "Omzet hari ini Rp500.000." });
    },
  };
  const registry: AgentToolRegistry = {
    definitions: () => [],
    async execute() {
      throw new Error("tidak boleh dipanggil");
    },
  };

  const agent = new AgentService("http://ollama.invalid", "test-model", registry, ollama);
  const answer = await agent.answer(context, "Berapa omzet hari ini?");

  assert.match(answer, /tidak dapat memverifikasi angka/i);
});

function response(message: ChatResponse["message"]): ChatResponse {
  return {
    model: "test-model",
    created_at: new Date(),
    message,
    done: true,
    done_reason: "stop",
    total_duration: 0,
    load_duration: 0,
    prompt_eval_count: 0,
    prompt_eval_duration: 0,
    eval_count: 0,
    eval_duration: 0,
  };
}
