import { randomUUID } from "node:crypto";
import { execFileSync } from "node:child_process";
import { createRequire } from "node:module";
import { mkdtempSync, readFileSync, rmSync, writeFileSync } from "node:fs";
import { tmpdir } from "node:os";
import { join } from "node:path";

const require = createRequire(import.meta.url);
const firebaseBin = require.resolve("firebase-tools/lib/bin/firebase.js");
const firebaseAuth = require("firebase-tools/lib/auth.js");
const firebaseGcpAuth = require("firebase-tools/lib/gcp/auth.js");
const emailPattern = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
const safeIdPattern = /^[a-z0-9]+(?:-[a-z0-9]+)*$/;

const args = parseArguments(process.argv.slice(2));
const projectId = args.project ?? process.env.FIREBASE_PROJECT_ID ?? "ryangunshop-pos-2026";
const storeId = args.store ?? process.env.OWNER_STORE_ID ?? "warung-utama";
const email = args.email ?? process.env.OWNER_EMAIL;
const webApiKey = process.env.FIREBASE_WEB_API_KEY;

if (!email || !emailPattern.test(email)) {
  fail("Gunakan --email owner@contoh.id atau OWNER_EMAIL yang valid.");
}
if (!safeIdPattern.test(storeId)) {
  fail("Store ID hanya boleh berisi huruf kecil, angka, dan tanda hubung.");
}
if (!webApiKey && !args.skipResetEmail && !args.dryRun) {
  fail("FIREBASE_WEB_API_KEY wajib diisi agar email reset kata sandi dapat dikirim.");
}

const account = firebaseAuth.getGlobalDefaultAccount();
if (!account?.tokens?.refresh_token) {
  fail("Firebase CLI belum login. Jalankan `firebase login` terlebih dahulu.");
}

const temporaryDirectory = mkdtempSync(join(tmpdir(), "ryangunshop-owner-"));
const exportPath = join(temporaryDirectory, "auth-users.json");
const importPath = join(temporaryDirectory, "owner-import.json");

try {
  firebase(["auth:export", exportPath, "--project", projectId, "--format=json"]);
  const exported = JSON.parse(readFileSync(exportPath, "utf8"));
  const existing = (exported.users ?? []).find(
    (user) => user.email?.toLowerCase() === email.toLowerCase(),
  );
  const uid = existing?.localId ?? `owner-${randomUUID().replaceAll("-", "").slice(0, 22)}`;

  printPlan({ projectId, storeId, email, uid, existing: Boolean(existing) });
  if (args.dryRun) process.exit(0);

  if (!existing) {
    writeFileSync(
      importPath,
      JSON.stringify({
        users: [{
          localId: uid,
          email,
          emailVerified: false,
          disabled: false,
          customAttributes: JSON.stringify({
            storeId,
            role: "OWNER",
            active: true,
          }),
        }],
      }),
      { encoding: "utf8", mode: 0o600 },
    );
    firebase(["auth:import", importPath, "--project", projectId]);
  } else {
    firebaseAuth.setRefreshToken(account.tokens.refresh_token);
    await firebaseGcpAuth.setCustomClaim(
      projectId,
      uid,
      { storeId, role: "OWNER", active: true },
      { merge: true },
    );
  }

  await upsertStore({
    refreshToken: account.tokens.refresh_token,
    projectId,
    storeId,
    ownerUid: uid,
  });

  if (!args.skipResetEmail) {
    await sendPasswordReset({ email, webApiKey });
  }

  console.log("Owner produksi berhasil diprovisikan.");
  console.log(`Project: ${projectId}`);
  console.log(`Tenant: ${storeId}`);
  console.log(`Email: ${maskEmail(email)}`);
  console.log(args.skipResetEmail
    ? "Email reset dilewati; kirim reset dari Firebase Console sebelum login pertama."
    : "Email reset kata sandi telah diminta melalui Firebase Authentication.");
} finally {
  rmSync(temporaryDirectory, { recursive: true, force: true });
}

async function upsertStore({ refreshToken, projectId, storeId, ownerUid }) {
  const token = await firebaseAuth.getAccessToken(refreshToken, [
    "https://www.googleapis.com/auth/cloud-platform",
  ]);
  const documentUrl = new URL(
    `https://firestore.googleapis.com/v1/projects/${encodeURIComponent(projectId)}`
      + `/databases/(default)/documents/stores/${encodeURIComponent(storeId)}`,
  );
  for (const field of ["name", "ownerUid", "active", "updatedAt"]) {
    documentUrl.searchParams.append("updateMask.fieldPaths", field);
  }
  const response = await fetch(documentUrl, {
    method: "PATCH",
    headers: {
      authorization: `Bearer ${token.access_token}`,
      "content-type": "application/json",
      "x-goog-user-project": projectId,
    },
    body: JSON.stringify({
      fields: {
        name: { stringValue: "Warung Utama" },
        ownerUid: { stringValue: ownerUid },
        active: { booleanValue: true },
        updatedAt: { timestampValue: new Date().toISOString() },
      },
    }),
  });
  if (!response.ok) {
    throw new Error(`Gagal membuat tenant Firestore (${response.status}).`);
  }
}

async function sendPasswordReset({ email, webApiKey }) {
  const response = await fetch(
    `https://identitytoolkit.googleapis.com/v1/accounts:sendOobCode?key=${encodeURIComponent(webApiKey)}`,
    {
      method: "POST",
      headers: { "content-type": "application/json" },
      body: JSON.stringify({ requestType: "PASSWORD_RESET", email }),
    },
  );
  if (!response.ok) {
    const error = await response.json().catch(() => ({}));
    throw new Error(`Gagal mengirim reset password: ${error?.error?.message ?? response.status}.`);
  }
}

function firebase(arguments_) {
  execFileSync(process.execPath, [firebaseBin, ...arguments_], {
    cwd: new URL("..", import.meta.url),
    stdio: ["ignore", "inherit", "inherit"],
  });
}

function parseArguments(values) {
  const parsed = {
    dryRun: false,
    skipResetEmail: false,
  };
  for (let index = 0; index < values.length; index += 1) {
    const value = values[index];
    if (value === "--dry-run") parsed.dryRun = true;
    else if (value === "--skip-reset-email") parsed.skipResetEmail = true;
    else if (value === "--email") parsed.email = values[++index];
    else if (value === "--project") parsed.project = values[++index];
    else if (value === "--store") parsed.store = values[++index];
    else fail(`Argumen tidak dikenal: ${value}`);
  }
  return parsed;
}

function printPlan({ projectId, storeId, email, uid, existing }) {
  console.log("Rencana provisioning owner:");
  console.log(`- Project: ${projectId}`);
  console.log(`- Tenant: ${storeId}`);
  console.log(`- Email: ${maskEmail(email)}`);
  console.log(`- UID: ${uid}`);
  console.log(`- Akun: ${existing ? "perbarui claim" : "buat baru"}`);
  console.log("- Claim: role=OWNER, active=true");
}

function maskEmail(value) {
  const [name, domain] = value.split("@");
  return `${name.slice(0, 2)}***@${domain}`;
}

function fail(message) {
  console.error(message);
  process.exit(1);
}
