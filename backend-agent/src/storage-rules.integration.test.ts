import assert from "node:assert/strict";
import { readFile } from "node:fs/promises";
import test from "node:test";
import {
  assertFails,
  assertSucceeds,
  initializeTestEnvironment,
} from "@firebase/rules-unit-testing";
import { getBytes, ref, uploadBytes } from "firebase/storage";

test("Storage rules hanya menerima foto consent pada tenant pengguna", {
  skip: !process.env.FIREBASE_STORAGE_EMULATOR_HOST,
}, async () => {
  assert.ok(process.env.FIREBASE_STORAGE_EMULATOR_HOST);
  const rules = await readFile(new URL("../../firebase/storage.rules", import.meta.url), "utf8");
  const environment = await initializeTestEnvironment({
    projectId: "demo-ryangunshop",
    storage: { rules },
  });

  try {
    const cashierA = environment.authenticatedContext("cashier-a", {
      storeId: "store-a",
      role: "CASHIER",
      active: true,
    }).storage();
    const inactiveA = environment.authenticatedContext("inactive-a", {
      storeId: "store-a",
      role: "CASHIER",
      active: false,
    }).storage();
    const jpeg = new Uint8Array([0xff, 0xd8, 0xff, 0xd9]);
    const metadata = {
      contentType: "image/jpeg",
      customMetadata: {
        storeId: "store-a",
        predictionId: "prediction-1",
        selectedProductId: "product-1",
        modelVersion: "test-v1",
        initialLabel: "kopi_lama",
        initialConfidence: "0.64",
        consent: "true",
        expiresAt: "2026-10-25T00:00:00.000Z",
      },
    };

    const ownRef = ref(cashierA, "predictionCorrections/store-a/prediction-1.jpg");
    await assertSucceeds(uploadBytes(ownRef, jpeg, metadata));
    await assertFails(getBytes(ownRef));
    await assertFails(uploadBytes(
      ref(cashierA, "predictionCorrections/store-b/prediction-2.jpg"),
      jpeg,
      {
        ...metadata,
        customMetadata: {
          ...metadata.customMetadata,
          storeId: "store-b",
          predictionId: "prediction-2",
        },
      },
    ));
    await assertFails(uploadBytes(
      ref(inactiveA, "predictionCorrections/store-a/prediction-3.jpg"),
      jpeg,
      {
        ...metadata,
        customMetadata: {
          ...metadata.customMetadata,
          predictionId: "prediction-3",
        },
      },
    ));
    await assertFails(uploadBytes(
      ref(cashierA, "predictionCorrections/store-a/prediction-4.jpg"),
      jpeg,
      {
        ...metadata,
        contentType: "application/octet-stream",
        customMetadata: {
          ...metadata.customMetadata,
          predictionId: "prediction-4",
        },
      },
    ));
    await assertFails(uploadBytes(
      ref(cashierA, "predictionCorrections/store-a/prediction-5.jpg"),
      jpeg,
      {
        ...metadata,
        customMetadata: {
          storeId: "store-a",
          predictionId: "prediction-5",
          modelVersion: "test-v1",
          initialLabel: "kopi_lama",
          initialConfidence: "0.64",
          consent: "true",
          expiresAt: "2026-10-25T00:00:00.000Z",
        },
      },
    ));
  } finally {
    await environment.cleanup();
  }
});
