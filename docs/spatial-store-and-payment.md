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
  -> POST /payments/qris {transactionId, amount}
  -> Backend memverifikasi storeId + total transaksi
  -> Payment gateway membuat dynamic QR untuk merchant terdaftar
  <- qrPayload + expiresAt + providerReference

Payment gateway
  -> POST /webhooks/payment
  -> Backend memverifikasi signature + nominal + merchant + idempotency
  -> status payment = paid
  -> finalisasi transaksi dan outbox sinkronisasi
  -> aplikasi menerima update/polling
```

Nama dan rekening merchant tetap berasal dari konfigurasi backend per warung.
Nominal berubah mengikuti transaksi. QR tidak boleh dibangkitkan hanya dengan
menempelkan nominal ke gambar QR statis, dan status tidak boleh dipercaya dari
tombol “sudah bayar” di perangkat.

## Keputusan yang Masih Perlu Dipilih

- Payment gateway/acquirer QRIS yang digunakan dan dukungan sandbox-nya.
- Cara membuat denah awal: template manual, foto denah sebagai acuan, atau wizard
  pengukuran sederhana.
- Siapa yang boleh mengedit layout: hanya owner atau owner + kasir tertentu.
- Apakah panorama disimpan di Firebase Storage atau object storage terpisah.

