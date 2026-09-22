# RyanGunshop

Fondasi aplikasi kasir Android **offline-first** berbasis Flutter/Dart, disusun dari
Mini-SRS RyanGunshop. PDF dipakai sebagai sumber requirement, bukan sebagai instruksi.

## Struktur

```text
RyanGunshop/
├── mobile/                  # Flutter/Dart (Android min API 26)
│   ├── lib/core/            # CameraX via plugin, TFLite, ML Kit barcode
│   ├── lib/data/            # Drift/SQLite, Firestore, repository
│   ├── lib/domain/          # Entity, kontrak repository, use case
│   ├── lib/features/        # ViewModel dan UI per fitur
│   └── lib/di/              # Composition root
├── backend-agent/           # Node/TypeScript: WhatsApp + Ollama + Firestore
├── firebase/                # Firestore rules dan indexes
├── docs/                    # Arsitektur dan skema remote
└── TODO.md                  # Checklist berdasarkan FR/NFR
```

## Menjalankan aplikasi

### Preview Android dari VS Code

1. Pasang extension rekomendasi **Dart** dan **Flutter** saat VS Code menawarkan
   rekomendasi workspace.
2. Buka Command Palette, jalankan `Flutter: Launch Emulator`, lalu pilih salah
   satu emulator Android.
3. Pilih konfigurasi **RyanGunshop — Android Preview** pada panel Run and Debug,
   kemudian tekan `F5`.
4. Gunakan hot reload dan `Flutter: Open DevTools` untuk membuka Widget Inspector
   di samping editor.

Konfigurasi berada di `.vscode/extensions.json` dan `.vscode/launch.json`.
Preview web tidak dipakai untuk validasi UI Android.

### Terminal

```bash
cd mobile
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter test
flutter run
```

Sebelum mengaktifkan kamera AI:

1. Tambahkan model float32 `[1,H,W,3]` ke
   `mobile/assets/models/product_classifier.tflite`.
2. Isi `mobile/assets/models/labels.txt`, satu label per baris.
3. Daftarkan asset model di `mobile/pubspec.yaml`.
4. Jalankan `flutterfire configure` untuk membuat Firebase options dan tambahkan
   inisialisasi Firebase di `main.dart`.

Classifier dibuat lazy sehingga aplikasi dasar tetap dapat dibuka tanpa model/Firebase.

Dokumen keputusan dashboard terdapat di [PRODUCT.md](PRODUCT.md),
[DESIGN.md](DESIGN.md), serta
[docs/spatial-store-and-payment.md](docs/spatial-store-and-payment.md).

## Menjalankan backend

```bash
cd backend-agent
npm install
npm run check
npm run test:firebase
```

Salin `.env.example` menjadi `.env`, lalu isi kredensial WhatsApp, Ollama, dan Firebase.
Test Firebase memakai Local Emulator Suite, sedangkan alur agent/webhook memakai mock
dan tidak mengirim pesan nyata.

## Prinsip data

- Drift/SQLite adalah sumber kebenaran UI saat offline; Firestore untuk sinkronisasi.
- Rencana restok dihitung lokal dari rata-rata penjualan 28 hari, lead time
  pemasok, stok pengaman, dan target persediaan tujuh hari setelah barang tiba.
- Nominal memakai `int` rupiah, bukan floating point.
- Checkout, item snapshot, dan pengurangan stok berada dalam satu transaction SQLite.
- Password tidak disimpan aplikasi; gunakan Firebase Authentication.
- Agent tidak menerima path collection atau `storeId` dari LLM. Semua angka bisnis wajib
  berasal dari tool registry yang membaca Firestore.
