import type { DateRange } from "./types.js";

export function normalizePhone(input: string): string {
  const digits = input.replace(/\D/g, "");
  if (digits.length < 8 || digits.length > 15) {
    throw new Error("Nomor WhatsApp tidak valid");
  }
  return `+${digits}`;
}

export function normalizeSearch(input: string): string {
  return input
    .normalize("NFKD")
    .replace(/\p{Diacritic}/gu, "")
    .trim()
    .toLocaleLowerCase("id-ID");
}

export function parsePeriod(period: string, now = new Date()): DateRange {
  const jakartaOffsetMs = 7 * 60 * 60 * 1_000;
  const jakartaNow = new Date(now.getTime() + jakartaOffsetMs);
  const todayUtc = Date.UTC(
    jakartaNow.getUTCFullYear(),
    jakartaNow.getUTCMonth(),
    jakartaNow.getUTCDate(),
  ) - jakartaOffsetMs;

  const key = period.trim().toLocaleLowerCase("id-ID");
  if (["hari ini", "today"].includes(key)) {
    return {
      from: new Date(todayUtc),
      to: new Date(todayUtc + 86_400_000 - 1),
      label: "hari ini",
    };
  }
  if (["7 hari", "7d", "minggu ini"].includes(key)) {
    return {
      from: new Date(todayUtc - 6 * 86_400_000),
      to: new Date(todayUtc + 86_400_000 - 1),
      label: "7 hari terakhir",
    };
  }

  const date = /^(\d{4})-(\d{2})-(\d{2})$/.exec(key);
  if (date) {
    const year = Number(date[1]);
    const month = Number(date[2]);
    const day = Number(date[3]);
    const start = Date.UTC(year, month - 1, day) - jakartaOffsetMs;
    const check = new Date(start + jakartaOffsetMs);
    if (
      check.getUTCFullYear() !== year ||
      check.getUTCMonth() !== month - 1 ||
      check.getUTCDate() !== day
    ) {
      throw new Error("Tanggal tidak valid");
    }
    return {
      from: new Date(start),
      to: new Date(start + 86_400_000 - 1),
      label: key,
    };
  }
  throw new Error("Periode harus 'hari ini', '7 hari', atau YYYY-MM-DD");
}

