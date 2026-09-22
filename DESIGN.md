# RyanGunshop — Design System

## Visual Direction

Antarmuka bertema “operational calm”: slate blue yang percaya diri, latar netral
dingin, denah seperti blueprint yang ringan, dan objek ruang dengan siluet serta
label jelas. Referensi pengalaman Fore diterjemahkan menjadi splash berani,
brand mark sederhana, ikon outline konsisten, satu aksi utama yang dominan, dan
navigasi bersih—tanpa menyalin logo, aset, atau warna mereknya.

Bahasa UI produksi menggabungkan minimalisme ala shadcn, perilaku dan state
Material 3 Expressive, judul editorial yang hemat, serta komposisi bento yang
asimetris namun tetap mudah dipindai. Slate Blue hanya menandai aksi, pilihan,
dan status; permukaan pasif tetap netral agar kasir dapat bekerja cepat.

## Color Roles

- Primary `#565C9D`: tindakan utama dan pilihan aktif.
- Primary dark `#34385F`: splash, app bar kontras, dan state tekan.
- Primary light `#E9EAF6`: pilihan sekunder dan latar ikon.
- Accent `#8B91D4`: fokus, progress, dan aksen motion.
- Canvas `#F7F7FB`: latar aplikasi.
- Surface `#FFFFFF`: lembar kerja dan sheet.
- Ink `#191A2E`: teks utama.
- Muted `#62657A`: teks pendukung.
- Success `#287A66`: tersimpan atau tersinkron.
- Warning `#A86616`: stok menipis atau tindakan belum selesai.
- Error `#B44252`: gagal bayar, gagal sinkron, atau stok tidak cukup.

Ramp lengkap dan aturan kontras ada di `docs/COLOR_PALETTE.md`.

## Typography

Gunakan font sistem Android untuk startup cepat dan keterbacaan konsisten.
Hierarki utama: 28 sp untuk judul halaman, 20 sp untuk judul bagian, 16 sp untuk
label penting, dan 14 sp untuk metadata. Bobot 600–700 hanya untuk hierarki dan
tindakan penting.

Judul halaman dan angka total dapat memakai serif sistem sebagai aksen
editorial. Label, input, tombol, metadata, dan seluruh teks operasional tetap
memakai sans-serif sistem. Dengan begitu karakter premium muncul di hierarki,
bukan mengurangi keterbacaan kontrol.

## Layout

- Spacing dasar 4 dp; jarak lazim 8, 12, 16, 24, dan 32 dp.
- Padding layar ponsel 16 dp.
- Radius kecil 10–14 dp pada kontrol dan sheet; objek denah memakai radius 6–10
  dp agar tetap terasa seperti komponen tata ruang.
- Dashboard mengutamakan kanvas denah. Informasi ringkas diletakkan di luar
  kanvas, bukan menutupi area kerja.
- Bento hanya dipakai untuk kumpulan tindakan dengan bobot berbeda: aksi kasir
  utama berukuran lebih besar, sedangkan produk dan tata letak menjadi shortcut
  ringkas. Tidak semua konten dipaksa menjadi kartu.

## Components

- `StoreFloorPlan`: kanvas zoomable pada mode lihat dan draggable pada mode edit.
- `FixtureTile`: ikon, nama, dan jumlah produk; pola/ikon membedakan jenis objek.
- `ModeSwitch`: pilihan Denah dan 360°. Mode 360° hanya aktif jika panorama zona
  sudah tersedia.
- `SyncPill`: status offline, antre sinkronisasi, atau tersinkron dengan ikon dan
  teks.
- `RyanAppLogo`: logo resmi milik pengguna, dipakai pada splash, launcher icon,
  dan identitas app bar.
- `BrandSpinner`: spinner slate blue dengan label status yang jujur.
- `PrimaryAction`: satu CTA utama per konteks, misalnya “Mulai pindai”.
- `PaymentSheet`: total selalu terlihat; tunai dan QRIS dipisahkan secara tegas.
- `OnboardingCarousel`: tiga langkah singkat untuk scan, tata letak, dan bayar;
  dapat dilewati dan hanya muncul pada penggunaan pertama.
- `ProductCatalog`: pencarian dan filter stok menipis berada di bagian atas,
  daftar memakai kartu ringkas, dan empty state selalu menyediakan CTA tambah.
- `ProductForm`: formulir mobile satu kolom dengan section bertahap (foto,
  identitas, harga/stok, dan lokasi), validasi inline, serta tombol simpan yang
  tetap terjangkau di bagian bawah layar.
- `ProductScanner`: preview kamera layar penuh dengan bingkai panduan, satu panel
  hasil di bagian bawah, konfirmasi eksplisit, indikator confidence, lampu,
  barcode, dan pencarian manual. Permission/error state selalu menyediakan
  jalan keluar tanpa kamera.
- `CartCheckout`: daftar barang dengan stepper kuantitas, total sticky,
  pembayaran tunai dengan uang cepat/kembalian, konfirmasi QRIS manual, serta
  status berhasil. Kamera dilepas selama checkout dan disiapkan ulang bila
  kasir kembali memindai.

## Interaction Rules

- Mode lihat: tap objek membuka daftar produk; pinch/pan mengubah viewport.
- Mode edit: drag memindahkan objek; tombol khusus menangani rotasi, ukuran,
  duplikasi, dan hapus agar gesture tidak ambigu.
- Mode edit hanya dapat dibuka oleh owner. Pilihan produk per fixture memakai
  bottom sheet yang dapat dicari, menampilkan stok lokal, dan tetap memberi
  empty/error state yang jelas saat katalog belum tersedia.
- Perubahan layout disimpan lokal lebih dahulu dan diberi indikator sync.
- Perubahan produk disimpan ke Drift terlebih dahulu, barcode divalidasi unik,
  dan operasi upsert/delete ditulis ke outbox pada transaksi yang sama.
- Scan AI tidak pernah otomatis menambah produk; kasir harus mengonfirmasi.
- Stream analisis berhenti setelah satu hasil atau fallback, dilepas ketika app
  masuk background, dan dimulai kembali saat lifecycle aktif atau kasir memilih
  pindai ulang.
- QRIS menampilkan state `creating`, `awaitingPayment`, `paid`, `expired`, dan
  `failed`. Hanya `paid` dari webhook tervalidasi yang menyelesaikan transaksi.
- Splash Flutter menampilkan satu signature motion selama sekitar 1,45 detik:
  logo resmi melakukan scale/fade dengan kurva ease-out, copy dan status muncul
  berurutan, lalu dashboard masuk lewat crossfade 280 ms. `disableAnimations`
  menghasilkan transisi instan.
- Setelah splash, pengguna baru melihat onboarding tiga halaman bergaya ilustrasi
  geometris. Swipe, indikator progres, tombol Lewati/Lanjut/Mulai, dan reduced
  motion wajib tersedia.

## Accessibility

- Semua objek denah memiliki semantic label yang menyebut jenis, nama, dan jumlah
  produk.
- Ikon selalu didampingi tooltip atau label pada tindakan yang tidak universal.
- Target sentuh minimum 48×48 dp.
- Status memakai kombinasi ikon, teks, dan warna.
- Layout harus tetap dapat dipakai pada text scale 1.3 dan lebar 360 dp.

## Brand Asset Workflow

Logo produksi berada di `mobile/assets/branding/ryangunshop_logo.png`. Turunan
launcher dan native splash dapat dibuat ulang dari PNG sumber tanpa mengubah
proporsinya melalui:

```bash
cd mobile
dart run tool/generate_brand_assets.dart "path/ke/logo.png"
```
