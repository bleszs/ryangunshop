# Arsitektur Teknis Flutter/Dart

```text
features (Widget + ChangeNotifier ViewModel)
                    │
                    ▼
domain (entity, repository contract, use case)
                    ▲
                    │ implements
data (Drift/SQLite, Firestore, mapper, sync)

core/camera ── RGB frame ──▶ core/ml ── top-3 ──▶ recognition coordinator
                                               └─▶ ML Kit barcode/manual fallback
```

Plugin `camera_android_camerax` membuat implementasi kamera Android tetap berbasis CameraX,
sementara kode aplikasi ditulis dalam Dart. `tflite_flutter` menjalankan model di perangkat.
`drift` menggantikan Room sebagai typed SQLite layer yang idiomatis untuk Flutter.

## Checkout atomik

```text
validasi input
  → database.transaction
      → baca ulang harga/stok lokal terbaru
      → hitung subtotal dan laba dari snapshot DB
      → insert transaksi SUCCESS + semua item
      → update stok dengan syarat stock >= quantity
      → commit atau rollback seluruhnya
  → terbitkan struk
```

## Keputusan AI

Model menghasilkan maksimal tiga kandidat. Coordinator hanya menghasilkan `RecognizedProduct`
bila top confidence melewati threshold dan `aiLabel` ditemukan pada produk aktif. ViewModel
tetap menunggu aksi `confirmPrediction`; hasil AI tidak pernah langsung masuk keranjang.
Timeout, model rusak, confidence rendah, atau label asing menghasilkan fallback barcode/manual.

## Struk PDF

Setelah checkout berhasil, `TransactionViewModel` mempertahankan `CompletedCheckout` sebagai
snapshot nama produk, harga, kuantitas, metode pembayaran, dan identitas kasir. Snapshot ini
terpisah dari katalog yang dapat berubah dan hanya dibuat setelah transaksi database sukses.

`ReceiptPdfService` membuat struk 80 mm, menulisnya lebih dahulu ke file sementara, lalu mengganti
file tujuan di direktori privat `documents/receipts`. `ReceiptShareService` menyerahkan file PDF
tersebut ke Android share sheet sehingga kasir dapat memilih WhatsApp atau aplikasi lain. Error
pembuatan atau berbagi struk hanya ditampilkan pada UI dan tidak membatalkan transaksi yang sudah
tersimpan.

## Offline-first dan sinkronisasi

UI membaca stream Drift. Setiap mutation lokal ditandai `syncState=pending`. Worker sinkronisasi
mengirim mutation idempoten ke `stores/{storeId}`. `workmanager` mendaftarkan satu pekerjaan
startup dan satu pekerjaan periodik 15 menit dengan constraint jaringan, baterai, dan storage.
Kegagalan registrasi worker tidak menghalangi transaksi offline.

Untuk denah, `StoreLayoutOutboxSyncProcessor` mengambil event `storeLayout.upsert` yang sudah
jatuh tempo, memvalidasi tenant pada payload, lalu mengirim snapshot layout melalui
`StoreLayoutRemoteRepository`. Keberhasilan menghapus event dan menandai layout beserta fixture
sebagai `synced` dalam satu transaksi Drift. Bila masih ada event yang lebih baru, state lokal
tetap `pending`. Kegagalan menyimpan pesan error yang telah dibatasi dan menjadwalkan percobaan
berikutnya dengan exponential backoff 30 detik sampai maksimum 6 jam.

Checkout menulis event `productStock.adjust` ke outbox dalam transaksi SQLite yang sama dengan
transaksi dan pengurangan stok. `InventoryStockOutboxSyncProcessor` mengirim delta stok, bukan
snapshot absolut. Firestore menerapkan delta dalam transaction dan menyimpan mutation ID pada
`inventoryMutations`, sehingga retry tidak mengurangi stok dua kali. Stok pusat yang tidak cukup
menjadi konflik permanen: event diubah menjadi `conflict`, dipertahankan untuk audit, produk lokal
ditandai `failed`, dan worker berhenti mengulang sampai dilakukan rekonsiliasi.

`ProductCatalogOutboxSyncProcessor` menangani upsert/soft-delete katalog. Upsert produk yang sudah
ada hanya memperbarui metadata; field stok tidak pernah ditimpa snapshot. Perubahan stok manual
diterjemahkan menjadi event delta terpisah sehingga memakai mekanisme konflik yang sama.

## WhatsApp agent

```text
WhatsApp → webhook HTTPS → verifikasi HMAC → dedup message ID → whitelist nomor
  → Ollama memilih schema tool → registry cek role/parameter/storeId
  → Firestore tenant → audit log → hasil kembali ke Ollama → Graph API reply
```

Ollama tidak memiliki kredensial database dan tidak boleh menentukan tenant. Tool registry
merupakan satu-satunya jalan ke angka bisnis; jawaban tanpa tool yang mengandung angka diblokir.
