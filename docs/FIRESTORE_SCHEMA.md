# Skema Firestore

```text
stores/{storeId}
  products/{productId}
  inventoryMutations/{mutationId}
  layouts/{layoutId}
    fixtures/{fixtureId}
  panoramaZones/{zoneId}
  transactions/{transactionId}
  predictions/{predictionId}
  reportJobs/{jobId}
  agentActions/{actionId}

whatsappUsers/{e164Phone}
whatsappJobs/{sha256MessageId}
whatsappDeadLetters/{sha256MessageId}
paymentOrders/{deterministicOrderId}
paymentNotifications/{sha256GatewayEvent}
```

`paymentOrders` dan `paymentNotifications` hanya ditulis/dibaca backend Admin SDK.
Order ID deterministik dari tenant, kasir, dan `clientRequestId` membuat permintaan QRIS
aman diulang. Harga dan stok selalu dibaca ulang dari `stores/{storeId}/products`; klien
tidak menjadi sumber nominal. Notifikasi gateway dideduplikasi sebelum transaksi dan
pengurangan stok diselesaikan secara atomik.

`whatsappUsers` berisi `storeId`, `userId`, `role`, dan `active`. Dokumen ini hanya boleh
dibaca backend Admin SDK. Password tidak pernah disimpan di Firestore; gunakan Firebase Auth.

`whatsappJobs` adalah antrean Admin-only dengan status `PENDING`, `PROCESSING`,
`COMPLETED`, atau `DEAD_LETTER`. Field pentingnya `externalMessageId`, `from`, `text`,
`attemptCount`, `availableAt`, `leaseOwner`, `leaseUntil`, dan `expiresAt`. Webhook
Meta baru di-ACK setelah dokumen dibuat; hash message ID mencegah duplikat. Setelah
batas retry, snapshot job disalin ke `whatsappDeadLetters` untuk inspeksi/replay manual.

### products

Field utama: `name`, `normalizedName`, `category`, `purchasePrice`, `sellingPrice`, `stock`,
`minimumStock`, `leadTimeDays`, `isLowStock`, `barcode`, `photoUrl`, `shelfLocation`, `aiLabel`, `active`,
`updatedAt`, `updatedBy`, `version`.

### transactions

Field utama: `occurredAt`, `items[]` (snapshot id/nama/harga/modal/qty/subtotal), `total`,
`grossProfit`, `paymentMethod`, `receivedAmount`, `changeAmount`, `cashierId`, `status`,
`deviceId`, `clientMutationId`, `updatedAt`.

`clientMutationId` harus unik dan dipakai untuk idempotensi sinkronisasi. Untuk volume besar,
buat agregat harian melalui Cloud Function daripada membaca semua transaksi dari agent.

### inventoryMutations

Dokumen idempotensi untuk perubahan stok berisi `productId`, `delta`, `transactionId`,
`clientOccurredAt`, dan `appliedAt`. Dokumen dibuat dalam Firestore transaction yang sama dengan
update `products.stock`. Keberadaan `mutationId` membuat pengiriman ulang aman dan delta stok
mencegah perangkat offline saling menimpa dengan snapshot last-write-wins.

### layouts

Dokumen layout berisi `name`, `canvasAspectRatio`, `templateVersion`, `clientMutationId`,
`clientUpdatedAt`, dan `updatedAt` dari server.
Subcollection `fixtures` berisi `type`, `label`, koordinat relatif `x`/`y`, `width`,
`height`, `rotationQuarterTurns`, `productIds[]`, `panoramaZoneId`, `clientMutationId`,
`clientUpdatedAt`, dan `updatedAt`. Sinkronisasi upsert juga menghapus dokumen fixture remote
yang sudah tidak ada pada snapshot lokal sehingga hasil retry tetap idempoten.
Klien membaca layout milik `storeId` dari claim sesi; hanya role owner yang boleh menulis.

### panoramaZones

Metadata zona 360° berisi `name`, URI `gs://` untuk gambar utama dan preview,
`hotspots[]` (`fixtureId`, `longitude`, `latitude`), `clientMutationId`,
`clientUpdatedAt`, dan `updatedAt`. Gambar berada pada path deterministik
`storePanoramas/{storeId}/{zoneId}/`, sehingga retry bersifat idempoten. Semua role
aktif dalam tenant boleh membaca; hanya owner tenant yang boleh membuat, mengubah,
atau menghapus zona dan objek Storage.

### predictions

Field utama: `capturedAt`, `aiLabel`, `confidence`, `selectedProductId`, `corrected`,
`correctionPhotoUrl`, `cashierId`, `modelVersion`, `consentToTraining`, `retentionUntil`.

### agentActions

Field utama: `phoneHash`, `userId`, `tool`, `parameters`, `status`, `resultSummary`,
`confirmationId`, `whatsappMessageId`, `createdAt`. Jangan simpan token atau isi sensitif.
