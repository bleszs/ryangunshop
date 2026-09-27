# Arsitektur Denah Warung dan Pembayaran

## Model Denah

```text
StoreLayout
 ├─ storeId
 ├─ templateVersion
 ├─ canvasRatio
 ├─ fixtures[]
 │   ├─ id, type, label
 │   ├─ x, y, width, height       (0.0–1.0, relatif terhadap kanvas)
 │   ├─ rotationQuarterTurns
 │   ├─ productIds[]
 │   └─ panoramaZoneId?
 └─ updatedAt, syncState
```

Koordinat relatif membuat denah yang sama tetap proporsional di berbagai ukuran
layar. Simpan layout ke Drift terlebih dahulu, masukkan perubahan ke outbox, lalu
sinkronkan dokumen tenant-scoped ke `stores/{storeId}/layouts/{layoutId}`.

## Tingkat Visualisasi

1. **MVP — denah 2D:** template dan editor drag/rotate/resize. Cepat, bisa
   offline, dan cukup untuk menghubungkan produk dengan lokasi.
2. **P1 — panorama 360 per zona:** pemilik mengunggah foto equirectangular;
   hotspot menghubungkan panorama dengan fixture dan produk.
3. **Opsional — digital twin 3D:** hanya jika pengukuran ruang, biaya pembuatan
   aset, dan manfaat operasionalnya sudah tervalidasi.

## QRIS Dinamis

```text
Flutter checkout
  -> POST /payments/qris {clientRequestId, items[]}
  -> Backend memverifikasi Firebase ID token dan menghitung ulang harga Firestore
  -> Midtrans Core API membuat QR dinamis untuk merchant terdaftar
  <- orderId + qrUrl + expiresAt + status

Midtrans
  -> POST /webhooks/midtrans
  -> Backend memverifikasi signature lalu GET status ke Midtrans
  -> event ID dan order ID dideduplikasi
  -> finalisasi transaksi + pengurangan stok dalam Firestore transaction
  -> aplikasi menerima update/polling
```

Nama dan rekening merchant tetap berasal dari konfigurasi backend per warung.
Nominal berubah mengikuti transaksi. QR tidak boleh dibangkitkan hanya dengan
menempelkan nominal ke gambar QR statis, dan status tidak boleh dipercaya dari
tombol “sudah bayar” di perangkat.

## Keputusan Produksi

- Gateway QRIS: Midtrans Core API, dimulai dari sandbox.
- Denah awal: template manual yang dapat diubah owner.
- Hak edit layout: hanya role `OWNER`.
- Panorama: Firebase Storage region Jakarta (`asia-southeast2`), mengikuti Firestore.

QRIS manual tetap menjadi fallback ketika internet/backend/gateway tidak tersedia, tetapi
kasir wajib memeriksa mutasi secara manual. Aplikasi tidak boleh menganggap pembayaran
berhasil hanya karena QR telah ditampilkan.
