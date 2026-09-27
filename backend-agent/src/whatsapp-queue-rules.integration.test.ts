import assert from "node:assert/strict";
import test from "node:test";
import { deleteApp, initializeApp } from "firebase-admin/app";
import { getFirestore } from "firebase-admin/firestore";
import {
  FirestoreWhatsAppQueue,
  queueIdFor,
} from "./whatsapp-queue.js";

test("Firestore queue deduplikasi, lease, retry, dan dead-letter bersifat durable", {
  skip: !process.env.FIRESTORE_EMULATOR_HOST,
}, async () => {
  const app = initializeApp(
    { projectId: "demo-ryangunshop" },
    `whatsapp-queue-${Date.now()}`,
  );
  const firestore = getFirestore(app);
  let now = new Date("2026-09-27T12:00:00Z");
  const queue = new FirestoreWhatsAppQueue(firestore, () => now);
  const message = {
    id: `wamid-queue-${Date.now()}`,
    from: "628123456789",
    text: "stok kopi?",
  };
  const queueId = queueIdFor(message.id);
  const recoveryMessage = {
    id: `wamid-recovery-${Date.now()}`,
    from: "628123456780",
    text: "laporan hari ini",
  };
  const recoveryQueueId = queueIdFor(recoveryMessage.id);

  try {
    assert.equal(await queue.enqueue(message), true);
    assert.equal(await queue.enqueue(message), false);

    const firstClaim = await queue.claimDue({
      workerId: "worker-a",
      now,
      leaseMs: 120_000,
      limit: 10,
    });
    assert.equal(firstClaim.length, 1);
    assert.equal(firstClaim[0]?.attemptCount, 1);

    const retryAt = new Date(now.getTime() + 30_000);
    await queue.retry({
      queueId,
      workerId: "worker-a",
      now,
      availableAt: retryAt,
      lastError: "Ollama offline",
    });
    assert.deepEqual(await queue.claimDue({
      workerId: "worker-a",
      now,
      leaseMs: 120_000,
      limit: 10,
    }), []);

    now = retryAt;
    const secondClaim = await queue.claimDue({
      workerId: "worker-b",
      now,
      leaseMs: 120_000,
      limit: 10,
    });
    assert.equal(secondClaim[0]?.attemptCount, 2);
    await queue.deadLetter({
      queueId,
      workerId: "worker-b",
      now,
      lastError: "Ollama tetap offline",
    });

    const [job, deadLetter] = await Promise.all([
      firestore.collection("whatsappJobs").doc(queueId).get(),
      firestore.collection("whatsappDeadLetters").doc(queueId).get(),
    ]);
    assert.equal(job.data()?.status, "DEAD_LETTER");
    assert.equal(deadLetter.data()?.status, "DEAD_LETTER");
    assert.equal(await queue.enqueue(message), false);

    assert.equal(await queue.enqueue(recoveryMessage), true);
    const abandoned = await queue.claimDue({
      workerId: "worker-crashed",
      now,
      leaseMs: 10_000,
      limit: 10,
    });
    assert.equal(abandoned[0]?.attemptCount, 1);
    assert.deepEqual(await queue.claimDue({
      workerId: "worker-replacement",
      now,
      leaseMs: 10_000,
      limit: 10,
    }), []);

    now = new Date(now.getTime() + 10_000);
    const recovered = await queue.claimDue({
      workerId: "worker-replacement",
      now,
      leaseMs: 10_000,
      limit: 10,
    });
    assert.equal(recovered[0]?.attemptCount, 2);
    await queue.complete({
      queueId: recoveryQueueId,
      workerId: "worker-replacement",
      now,
    });
    assert.equal(
      (await firestore.collection("whatsappJobs").doc(recoveryQueueId).get())
        .data()?.status,
      "COMPLETED",
    );
    assert.equal(await queue.enqueue(recoveryMessage), false);
  } finally {
    await Promise.all([
      firestore.collection("whatsappJobs").doc(queueId).delete(),
      firestore.collection("whatsappDeadLetters").doc(queueId).delete(),
      firestore.collection("whatsappJobs").doc(recoveryQueueId).delete(),
    ]);
    await deleteApp(app);
  }
});
