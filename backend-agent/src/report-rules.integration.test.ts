import assert from "node:assert/strict";
import test from "node:test";
import { deleteApp, initializeApp } from "firebase-admin/app";
import { getFirestore } from "firebase-admin/firestore";
import {
  FirestoreReportQueue,
  reportJobId,
} from "./report-queue.js";

test("antrean laporan deduplikasi, lease, dan mirror status owner", {
  skip: !process.env.FIRESTORE_EMULATOR_HOST,
}, async () => {
  const app = initializeApp(
    { projectId: "demo-ryangunshop" },
    `report-queue-${Date.now()}`,
  );
  const firestore = getFirestore(app);
  const now = new Date("2026-09-30T04:00:00Z");
  const queue = new FirestoreReportQueue(firestore, () => now);
  const context = {
    storeId: `store-report-${Date.now()}`,
    userId: "owner-a",
    phone: "628123456789",
    role: "OWNER" as const,
    whatsappMessageId: `wamid-report-${Date.now()}`,
  };
  const jobId = reportJobId(context, "2026-09-30", "CSV");
  const queueReference = firestore.collection("reportGenerationJobs").doc(jobId);
  const mirrorReference = firestore.collection("stores").doc(context.storeId)
    .collection("reportJobs").doc(jobId);

  try {
    assert.deepEqual(
      await queue.enqueue(context, "2026-09-30", "CSV"),
      { jobId, status: "QUEUED" },
    );
    await queue.enqueue(context, "2026-09-30", "CSV");
    assert.equal((await queueReference.get()).data()?.recipientPhone, context.phone);

    const claimed = await queue.claimDue({
      workerId: "worker-a",
      now,
      leaseMs: 180_000,
      limit: 3,
    });
    assert.equal(claimed.length, 1);
    assert.equal(claimed[0]?.attemptCount, 1);
    assert.equal((await mirrorReference.get()).data()?.status, "PROCESSING");

    await queue.complete({
      jobId,
      storeId: context.storeId,
      workerId: "worker-a",
      now,
      objectPath: `reports/${context.storeId}/${jobId}.csv`,
      expiresAt: new Date(now.getTime() + 600_000),
    });
    assert.equal((await queueReference.get()).data()?.status, "COMPLETED");
    assert.equal((await mirrorReference.get()).data()?.status, "COMPLETED");
    assert.deepEqual(
      await queue.claimDue({
        workerId: "worker-b",
        now,
        leaseMs: 180_000,
        limit: 3,
      }),
      [],
    );
  } finally {
    await Promise.all([queueReference.delete(), mirrorReference.delete()]);
    await deleteApp(app);
  }
});
