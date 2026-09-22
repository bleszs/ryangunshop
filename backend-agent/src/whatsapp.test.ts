import assert from "node:assert/strict";
import { createHmac } from "node:crypto";
import test from "node:test";
import { extractTextMessages, verifyMetaSignature } from "./whatsapp.js";

test("signature webhook diverifikasi terhadap raw body", () => {
  const body = Buffer.from('{"ok":true}');
  const secret = "a-secure-app-secret";
  const signature = `sha256=${createHmac("sha256", secret).update(body).digest("hex")}`;
  assert.equal(verifyMetaSignature(body, signature, secret), true);
  assert.equal(verifyMetaSignature(Buffer.from("changed"), signature, secret), false);
});

test("hanya mengekstrak pesan teks yang valid", () => {
  const result = extractTextMessages({
    entry: [{ changes: [{ value: { messages: [
      { id: "wamid.1", from: "62812", text: { body: "cek stok Aqua" } },
      { id: "wamid.2", from: "62812", type: "image" },
    ] } }] }],
  });
  assert.deepEqual(result, [{ id: "wamid.1", from: "62812", text: "cek stok Aqua" }]);
});

