'use strict';

const childProcess = require('child_process');
const crypto = require('crypto');
const fs = require('fs');
const path = require('path');

const projectId = 'ryangunshop-pos-2026';
const storeId = 'firebase-verification-store';
const productId = `probe-${Date.now()}`;
const email = `firebase-probe-${crypto.randomUUID()}@example.invalid`;
const password = `Rg!${crypto.randomBytes(18).toString('base64url')}9a`;

const npmRoot = childProcess
  .execFileSync(process.env.ComSpec, ['/d', '/s', '/c', 'npm root -g'], {
    encoding: 'utf8',
  })
  .trim();
const firebaseTools = path.join(npmRoot, 'firebase-tools', 'lib');
const auth = require(path.join(firebaseTools, 'auth.js'));
const api = require(path.join(firebaseTools, 'apiv2.js'));
const firebaseAuthApi = require(path.join(firebaseTools, 'gcp', 'auth.js'));

function readAndroidApiKey() {
  const configPath = path.join(
    __dirname,
    '..',
    'mobile',
    'android',
    'app',
    'google-services.json',
  );
  const config = JSON.parse(fs.readFileSync(configPath, 'utf8'));
  const client = config.client.find(
    (item) =>
      item.client_info?.android_client_info?.package_name ===
      'id.ryangunshop.ryangunshop',
  );
  const key = client?.api_key?.[0]?.current_key;
  if (!key) throw new Error('API key Android tidak ditemukan');
  return key;
}

async function identityRequest(apiKey, operation, body) {
  const response = await fetch(
    `https://identitytoolkit.googleapis.com/v1/accounts:${operation}?key=${encodeURIComponent(apiKey)}`,
    {
      method: 'POST',
      headers: {'content-type': 'application/json'},
      body: JSON.stringify(body),
    },
  );
  const payload = await response.json();
  if (!response.ok) {
    throw new Error(
      `Identity Toolkit ${operation} gagal (${response.status}): ${payload.error?.message || 'unknown'}`,
    );
  }
  return payload;
}

async function firestoreRequest(idToken, method, documentPath, body) {
  const response = await fetch(
    `https://firestore.googleapis.com/v1/projects/${projectId}/databases/(default)/documents/${documentPath}`,
    {
      method,
      headers: {
        authorization: `Bearer ${idToken}`,
        'content-type': 'application/json',
      },
      body: body ? JSON.stringify(body) : undefined,
    },
  );
  return response;
}

async function main() {
  const account = auth.getGlobalDefaultAccount();
  if (!account) throw new Error('Firebase CLI belum login');
  auth.setRefreshToken(account.tokens.refresh_token);

  const apiKey = readAndroidApiKey();
  const adminClient = new api.Client({
    urlPrefix: 'https://identitytoolkit.googleapis.com',
    auth: true,
  });
  let localId;
  let idToken;

  try {
    const created = await identityRequest(apiKey, 'signUp', {
      email,
      password,
      returnSecureToken: true,
    });
    localId = created.localId;
    await firebaseAuthApi.setCustomClaim(
      projectId,
      localId,
      {storeId, role: 'OWNER', active: true},
      {merge: false},
    );

    const signedIn = await identityRequest(apiKey, 'signInWithPassword', {
      email,
      password,
      returnSecureToken: true,
    });
    idToken = signedIn.idToken;

    const ownPath = `stores/${storeId}/products/${productId}`;
    const createdDocument = await firestoreRequest(idToken, 'PATCH', ownPath, {
      fields: {
        name: {stringValue: 'Firebase rule probe'},
        normalizedName: {stringValue: 'firebase rule probe'},
        active: {booleanValue: true},
        stock: {integerValue: '1'},
        minimumStock: {integerValue: '1'},
        isLowStock: {booleanValue: true},
      },
    });
    if (!createdDocument.ok) {
      throw new Error(`Write Firestore ditolak (${createdDocument.status})`);
    }

    const readDocument = await firestoreRequest(idToken, 'GET', ownPath);
    if (!readDocument.ok) {
      throw new Error(`Read Firestore ditolak (${readDocument.status})`);
    }

    const crossTenant = await firestoreRequest(
      idToken,
      'GET',
      `stores/other-store/products/${productId}`,
    );
    if (crossTenant.status !== 403) {
      throw new Error(
        `Isolasi tenant tidak bekerja (status ${crossTenant.status}, expected 403)`,
      );
    }

    const removed = await firestoreRequest(idToken, 'DELETE', ownPath);
    if (!removed.ok) {
      throw new Error(`Cleanup dokumen gagal (${removed.status})`);
    }
    console.log(
      'Firebase Auth, custom claims, Firestore read/write, dan isolasi tenant terverifikasi.',
    );
  } finally {
    if (localId) {
      await adminClient.post('/v1/accounts:delete', {
        targetProjectId: projectId,
        localId,
      });
    }
  }
}

main().catch((error) => {
  console.error(error.message);
  process.exitCode = 1;
});
