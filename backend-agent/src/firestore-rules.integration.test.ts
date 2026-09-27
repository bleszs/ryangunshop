import assert from "node:assert/strict";
import { readFile } from "node:fs/promises";
import test from "node:test";
import {
  assertFails,
  assertSucceeds,
  initializeTestEnvironment,
} from "@firebase/rules-unit-testing";
import { doc, getDoc, setDoc, Timestamp, updateDoc } from "firebase/firestore";

test("Firestore rules menjaga isolasi tenant dan batas akses kasir", {
  skip: !process.env.FIRESTORE_EMULATOR_HOST,
}, async () => {
  assert.ok(process.env.FIRESTORE_EMULATOR_HOST);
  const rules = await readFile(new URL("../../firebase/firestore.rules", import.meta.url), "utf8");
  const environment = await initializeTestEnvironment({
    projectId: "demo-ryangunshop",
    firestore: { rules },
  });

  try {
    await environment.withSecurityRulesDisabled(async (context) => {
      await setDoc(doc(context.firestore(), "stores/store-a/products/kopi"), {
        name: "Kopi",
        stock: 10,
        minimumStock: 3,
        isLowStock: false,
        updatedAt: "seed",
      });
      await setDoc(doc(context.firestore(), "stores/store-b/products/teh"), {
        name: "Teh",
        stock: 4,
        minimumStock: 2,
        isLowStock: false,
        updatedAt: "seed",
      });
    });

    const ownerA = environment.authenticatedContext("owner-a", {
      storeId: "store-a",
      role: "OWNER",
      active: true,
    }).firestore();
    const cashierA = environment.authenticatedContext("cashier-a", {
      storeId: "store-a",
      role: "CASHIER",
      active: true,
    }).firestore();
    const anonymous = environment.unauthenticatedContext().firestore();

    await assertSucceeds(getDoc(doc(ownerA, "stores/store-a/products/kopi")));
    await assertFails(getDoc(doc(ownerA, "stores/store-b/products/teh")));
    await assertFails(getDoc(doc(anonymous, "stores/store-a/products/kopi")));

    await assertSucceeds(updateDoc(doc(cashierA, "stores/store-a/products/kopi"), {
      stock: 7,
      isLowStock: false,
      updatedAt: "checkout",
    }));
    await assertFails(updateDoc(doc(cashierA, "stores/store-a/products/kopi"), {
      name: "Nama diubah kasir",
    }));
    await assertFails(setDoc(doc(ownerA, "stores/store-b/products/susu"), {
      name: "Susu",
      stock: 3,
      minimumStock: 1,
      isLowStock: false,
      updatedAt: "cross-tenant",
    }));

    const panorama = {
      name: "Rak depan",
      imageUri: "gs://demo/storePanoramas/store-a/zone-1/panorama.jpg",
      thumbnailUri: "gs://demo/storePanoramas/store-a/zone-1/preview.jpg",
      hotspots: [],
      clientMutationId: "mutation-1",
      clientUpdatedAt: Timestamp.fromDate(new Date("2026-09-27T08:00:00Z")),
      updatedAt: Timestamp.fromDate(new Date("2026-09-27T08:00:01Z")),
    };
    await assertSucceeds(setDoc(
      doc(ownerA, "stores/store-a/panoramaZones/zone-1"),
      panorama,
    ));
    await assertSucceeds(getDoc(
      doc(cashierA, "stores/store-a/panoramaZones/zone-1"),
    ));
    await assertFails(setDoc(
      doc(cashierA, "stores/store-a/panoramaZones/zone-2"),
      panorama,
    ));
    await assertFails(setDoc(
      doc(ownerA, "stores/store-a/panoramaZones/zone-2"),
      panorama,
    ));
    await assertFails(setDoc(
      doc(ownerA, "stores/store-b/panoramaZones/zone-1"),
      panorama,
    ));
    await assertFails(setDoc(
      doc(ownerA, "whatsappJobs/job-client-forbidden"),
      { status: "PENDING" },
    ));
    await assertFails(getDoc(
      doc(ownerA, "whatsappDeadLetters/job-client-forbidden"),
    ));
    await assertFails(setDoc(
      doc(ownerA, "paymentOrders/RG-client-forbidden"),
      { grossAmount: 1, status: "SETTLED" },
    ));
    await assertFails(getDoc(
      doc(ownerA, "paymentNotifications/event-client-forbidden"),
    ));
  } finally {
    await environment.cleanup();
  }
});
