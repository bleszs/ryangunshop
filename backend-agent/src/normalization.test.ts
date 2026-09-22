import assert from "node:assert/strict";
import test from "node:test";
import { normalizePhone, parsePeriod } from "./normalization.js";

test("normalisasi nomor ke E.164", () => {
  assert.equal(normalizePhone("62 812-3456-7890"), "+6281234567890");
  assert.throws(() => normalizePhone("123"));
});

test("periode hari ini memakai batas WIB", () => {
  const range = parsePeriod("hari ini", new Date("2026-09-07T12:00:00.000Z"));
  assert.equal(range.from.toISOString(), "2026-09-06T17:00:00.000Z");
  assert.equal(range.to.toISOString(), "2026-09-07T16:59:59.999Z");
});
