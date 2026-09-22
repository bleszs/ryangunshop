# RyanGunshop — Product Context

## Product

RyanGunshop adalah aplikasi kasir dan pengelolaan warung berbasis Flutter untuk
Android 8.0 ke atas. Produk bersifat offline-first: aktivitas kasir dan perubahan
stok tetap dapat berjalan melalui SQLite/Drift, kemudian disinkronkan ke
Firestore saat jaringan tersedia.

## Users

- Pemilik warung yang mengatur produk, tata letak, stok, laporan, merchant QRIS,
  serta akses kasir.
- Kasir yang harus menemukan, memindai, mengonfirmasi, dan menjual barang dengan
  sedikit langkah.

Pengguna bisa memakai perangkat kelas bawah dan tidak selalu memiliki koneksi
internet yang stabil. Antarmuka utama harus dapat dipahami tanpa pelatihan
teknis.

## Core Experience

Dashboard merepresentasikan tata letak warung. RyanGunshop menyediakan template
berisi area dinding, lorong, rak, lemari, kulkas, dan meja kasir. Pemilik dapat
menambah, memindahkan, memutar, mengubah ukuran, memberi nama, dan menghubungkan
produk ke setiap objek.

Denah adalah navigasi operasional, bukan dekorasi. Memilih suatu objek harus
menampilkan barang dan status stok di lokasi tersebut. Hasil scan produk dapat
menyorot lokasi raknya. Mode panorama 360 derajat adalah viewer tambahan yang
terhubung ke zona denah; transaksi tetap dapat dilakukan tanpa panorama.

Alur pembayaran dimulai setelah barang dikonfirmasi dan masuk keranjang:

1. aplikasi menghitung total dari harga lokal yang tersimpan;
2. kasir memilih tunai atau QRIS;
3. tunai mencatat jumlah diterima dan kembalian;
4. QRIS dinamis dibuat oleh payment gateway untuk nominal transaksi dan merchant
   yang telah didaftarkan;
5. transaksi QRIS baru dianggap berhasil setelah webhook provider tervalidasi;
6. penyimpanan transaksi dan pengurangan stok dilakukan secara atomik.

## Personality

Praktis, tenang, jelas, dan dapat dipercaya—seperti alat kerja warung yang
rapi. Visual tidak boleh terasa seperti aplikasi finansial korporat atau gim 3D.
Slate blue menjadi identitas utama untuk tindakan dan navigasi, didampingi
netral dingin agar denah mudah dibaca dalam kondisi warung yang terang.

## Design Principles

1. Denah dahulu, transaksi tetap dekat: dashboard fokus pada ruang, tetapi aksi
   pindai dan keranjang selalu mudah dijangkau.
2. Data nyata atau status jujur: jangan menampilkan pembayaran berhasil,
   ketersediaan stok, atau angka usaha yang belum dikonfirmasi sumber data.
3. Edit dan operasi adalah mode berbeda: objek tidak boleh bergeser saat kasir
   hanya ingin memilih rak.
4. Offline terlihat jelas: status sinkronisasi dan tindakan yang memerlukan
   internet harus mempunyai penjelasan dan retry.
5. Aksesibel di perangkat kecil: target sentuh minimal 48 dp, teks inti minimal
   14 sp, kontras memadai, dan makna tidak bergantung pada warna saja.

## Technical Boundaries

- Flutter/Dart untuk aplikasi Android; tidak memakai Jetpack Compose.
- Preview dan inspeksi UI dilakukan lewat Flutter extension di VS Code pada
  emulator atau perangkat Android.
- Denah MVP menggunakan koordinat relatif 2D agar responsif dan hemat resource.
- Panorama 360 memerlukan foto equirectangular per zona; digital twin 3D penuh
  bukan bagian MVP.
- QRIS dinamis memerlukan akun merchant dan API payment gateway resmi. Rahasia,
  pembuatan charge, signature, serta webhook tidak boleh berada di aplikasi.
- Tenant selalu ditentukan dari sesi/claim `storeId`, bukan input bebas pengguna.
