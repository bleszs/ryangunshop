# Keputusan dan Aktivasi Produksi

Dokumen ini memisahkan keputusan teknis yang sudah final dari tindakan eksternal yang
memerlukan akun billing atau merchant.

## Owner pertama

- Firebase project: `ryangunshop-pos-2026`
- Tenant awal: `warung-utama`
- Claim: `storeId=warung-utama`, `role=OWNER`, `active=true`
- Kata sandi tidak dibuat atau disimpan di Git. Login pertama memakai tautan reset dari
  Firebase Authentication.

Provisioning idempoten dapat diulang oleh akun Firebase CLI yang berizin:

```powershell
$env:FIREBASE_WEB_API_KEY='<web-api-key Firebase>'
npm --prefix backend-agent run provision:owner -- --email owner@contoh.id
```

Script menutupi email di output, memperbarui custom claims bila akun sudah ada, dan
membuat dokumen tenant Firestore. Setelah claim berubah, pengguna harus login ulang agar
ID token baru memuat claim terbaru.

## Model produk

Model bawaan adalah baseline ImageNet untuk membuktikan integrasi dan mengukur performa,
bukan untuk menebak SKU. Build normal menolaknya. Dataset wajib berisi foto produk warung
dan kelas `__unknown__`; detail ada di `ml/README.md`. Quality gate produksi:

- test accuracy minimal 85%;
- precision pada prediksi yang diterima minimal 95%;
- coverage minimal 50%;
- inferensi maksimal 5 detik pada perangkat target.

## QRIS

Provider dipilih: **Midtrans Core API**. Mulai dari merchant sandbox. Konfigurasi backend:

```dotenv
MIDTRANS_SERVER_KEY=SB-Mid-server-...
MIDTRANS_IS_PRODUCTION=false
```

Atur notification URL ke `https://BACKEND/webhooks/midtrans`. Jangan pernah menaruh
server key dalam Flutter, Firestore, screenshot, atau Git. Sebelum mengubah
`MIDTRANS_IS_PRODUCTION=true`, lakukan uji pending, settlement, kedaluwarsa, cancel,
duplikasi webhook, stok habis setelah QR dibuat, dan refund.

## Firebase Storage

Bucket dipilih di region `asia-southeast2` agar sejajar dengan database Firestore.
Pembuatan bucket baru memerlukan paket Blaze dan metode pembayaran pada Firebase Console;
hal ini tidak dapat digantikan dengan kredensial fiktif. Sesudah billing aktif:

```powershell
firebase deploy --only storage --project ryangunshop-pos-2026
gcloud storage buckets update gs://ryangunshop-pos-2026.firebasestorage.app `
  --lifecycle-file=firebase/storage.lifecycle.json
```

Terakhir lakukan smoke test panorama dan foto koreksi, lalu pastikan objek
`predictionCorrections/` memiliki lifecycle hapus 30 hari sebelum mengaktifkan App Check
enforcement Storage.

Backend laporan juga memerlukan `FIREBASE_STORAGE_BUCKET`. Service account runtime harus
dapat membuat objek dan menandatangani URL V4 (`signBlob`). Uji bahwa link laporan hanya
berlaku sesuai `REPORT_LINK_TTL_MINUTES` (default 10 menit) dan lifecycle menghapus prefix
`reports/` setelah satu hari. Signed URL bersifat bearer link: siapa pun yang menerima link
dapat mengakses file sampai kedaluwarsa, jadi jangan meneruskannya ke pihak lain.
