# TODO RyanGunshop — Flutter/Dart

Status: `[x]` fondasi tersedia, `[ ]` masih harus diimplementasikan/dikonfigurasi.

## P0 — Fondasi selesai

- [x] Proyek Flutter Android min API 26 dan struktur Clean Architecture + MVVM.
- [x] Entity domain Pengguna/Produk/Transaksi/Prediksi dan tabel Drift/SQLite (FR-01, FR-02, FR-07, FR-13).
- [x] Repository checkout atomik: snapshot harga, insert transaksi, dan stok berkurang dalam satu transaction (BR-01, NFR-03).
- [x] Camera stream memakai implementasi CameraX Flutter dan konversi YUV420 → RGB (FR-03).
- [x] TFLite classifier top-3, confidence threshold, konfirmasi kasir, dan error fallback (FR-03–05).
- [x] ML Kit barcode scanning serta pencarian manual sebagai fallback (FR-05, NFR-04).
- [x] `ChangeNotifier` ViewModel untuk prediksi, koreksi, keranjang, dan checkout (FR-04, FR-06, FR-07, FR-13).
- [x] Firestore adapter tenant-scoped dan rules/index awal.
- [x] Backend WhatsApp: HMAC, whitelist, dedup, Ollama tool registry, schema validation, dan audit (FR-14, FR-15).
- [x] Test dasar kalkulasi Dart dan keamanan webhook backend.

## P0 — Agar MVP bisa dipakai

- [x] Tetapkan konsep dashboard denah warung dan batas MVP 2D/360°.
- [x] Buat prototype dashboard Flutter: denah responsif, pilih objek, mode edit,
  drag, rotasi, tambah fixture, dan placeholder panorama yang jujur.
- [x] Rombak design system ke Slate Blue, termasuk dashboard, komponen, state,
  ikon brand orisinal, serta dokumentasi color palette.
- [x] Tambahkan native splash Android dan Flutter splash dengan animasi masuk,
  reduced-motion fallback, serta spinner untuk loading konten dan aksi simpan.
- [x] Validasi UI di emulator Pixel 7 dan build debug Android x64.
- [x] Terapkan logo resmi RyanGunshop pada launcher, splash native/Flutter, dan
  app bar serta tambahkan signature entrance animation.
- [x] Tambahkan onboarding tiga halaman setelah splash untuk scan produk, denah
  warung, dan pembayaran; dapat dilewati dan disimpan sebagai first-run state.
- [x] Simpan `StoreLayout`/fixture ke Drift dan buat migration test versi 1→2.
- [x] Tulis event `storeLayout.upsert` ke outbox dalam transaksi SQLite yang sama.
- [x] Proses outbox layout ke Firestore, tandai `synced`, dan terapkan retry/backoff.
- [x] Lengkapi editor: resize, rename, duplicate/delete, undo, template awal,
  tautkan produk, serta pembatasan edit khusus owner.
- [ ] Masukkan `product_classifier.tflite` + labels dan kalibrasi normalisasi/threshold pada perangkat target (NFR-01, NFR-05).
- [x] Aktifkan Firebase Auth, deploy rules/index, dan verifikasi koneksi
  Firestore beserta isolasi lintas tenant pada proyek
  `ryangunshop-pos-2026` (FR-01–02).
- [x] Buat login serta session `storeId` dari custom claims, bukan input pengguna
  (FR-01, NFR-02).
- [ ] Buat akun owner produksi pertama dan tetapkan custom claims `storeId`,
  `role: OWNER`, serta `active: true` setelah kredensial ditentukan pemilik.
- [x] Buat layar CRUD produk termasuk barcode unik, foto, stok minimum, dan lokasi rak (FR-02).
- [x] Hubungkan preview kamera, permission, lifecycle, overlay area panduan, dan ViewModel (FR-03–04).
- [x] Buat layar keranjang/pembayaran tunai dan konfirmasi QRIS manual (FR-06–07).
- [ ] Pilih payment gateway QRIS, aktifkan merchant sandbox, lalu implementasikan
  dynamic QR + signature webhook + idempotency + status expiry/refund.
- [x] Tambahkan SQLite migration test untuk tabel denah dan outbox.
- [x] Tambahkan integration test rollback stok (NFR-03).
- [x] Implementasikan outbox WorkManager-equivalent (`workmanager`) dan resolusi konflik stok.

## P1 — Operasional warung

- [x] Viewer foto equirectangular 360° lokal per zona, hotspot fixture, kompresi,
  cache privat, serta fallback preview hemat daya untuk perangkat kelas bawah.
- [ ] Sinkronkan/upload foto panorama ke Firebase Storage setelah konfigurasi
  Firebase aktif; metadata zona tetap tenant-scoped di Firestore.
- [x] Buat struk PDF, simpan aman, dan share sheet ke WhatsApp (FR-08, FR-11).
- [x] Dashboard omzet, laba kotor, produk terlaris/kurang laku, dan stok menipis (FR-09).
- [x] Laporan PDF + CSV berdasarkan transaksi `success` untuk periode terpilih (FR-10, BR-04).
- [x] Tambahkan cancel/void transaction via compensating stock ledger dan audit.
- [x] Tambahkan secure storage, redaksi log/outbox, larangan cleartext/backup,
  serta bootstrap fail-safe Firebase App Check + Crashlytics.
- [x] Jalankan `flutterfire configure`, daftarkan Play Integrity/SHA-256, dan
  daftarkan App Check debug token emulator tanpa menyimpannya di repository.
- [ ] Kirim satu test crash build internal, pantau metrik App Check, lalu aktifkan
  enforcement Firestore/Storage setelah request sah sudah stabil.
- [ ] Benchmark halaman transaksi <3 detik dan inferensi <5 detik di perangkat kelas bawah (NFR-01).

## P2 — Prediksi dan agent

- [x] Moving average penjualan 28 hari, lead time pemasok, safety stock, titik
  pemesanan ulang, dan rekomendasi jumlah restok lokal (FR-12).
- [ ] Upload foto koreksi setelah consent, hapus EXIF, dan tetapkan retention (FR-13).
- [ ] Deploy backend/Ollama private network + TLS + health monitoring 24/7 (NFR-08).
- [ ] Konfigurasi webhook Meta serta `whatsappUsers` whitelist (FR-15).
- [ ] Pindahkan proses webhook ke queue durable dan dead-letter queue.
- [ ] Worker laporan + signed URL singkat untuk tool `generateReport`.
- [ ] Flow confirmation token dua langkah sebelum tool mutasi ditambahkan.
- [ ] Integration test Firebase Emulator + mock Ollama/WhatsApp.

## Definition of Done

- [ ] Happy path, empty state, timeout, offline, retry, dan permission denied teruji.
- [ ] Semua akses data dibatasi `storeId`; tidak ada cross-tenant read/write.
- [ ] Tidak ada stok/omzet buatan LLM; tiap tool call memiliki audit action ID.
- [ ] UI Bahasa Indonesia, aksesibel, dan tervalidasi di Android 8.0/API 26.
