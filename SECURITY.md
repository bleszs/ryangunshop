# Keamanan aplikasi RyanGunshop

## Kontrol yang sudah diterapkan

- Rahasia kecil seperti token sesi dan konfigurasi merchant hanya boleh masuk
  melalui `SecureValueStore`, bukan Drift atau SharedPreferences.
- Implementasi Android `flutter_secure_storage` menggunakan penyimpanan kunci
  berbasis Android Keystore. Backup aplikasi dinonaktifkan agar material kunci
  tidak dipulihkan ke perangkat lain.
- Pesan error outbox, log lokal, dan error yang dikirim ke Crashlytics melewati
  `SensitiveDataRedactor` untuk menghapus token, authorization header, email,
  JWT, serta deretan nomor panjang.
- Cleartext HTTP dinonaktifkan melalui AndroidManifest. Endpoint produksi wajib
  menggunakan HTTPS/TLS.
- App Check memakai debug provider hanya pada debug build dan Play Integrity
  pada release build. Crashlytics debug nonaktif kecuali build diberi
  `--dart-define=ENABLE_CRASHLYTICS_IN_DEBUG=true`.
- Kegagalan inisialisasi Firebase bersifat fail-closed pada build rilis: data
  warung tidak dibuka tanpa session terverifikasi. Mode lokal tanpa autentikasi
  hanya tersedia pada build debug/emulator.
- Login Email/Password mengambil `storeId`, `role`, dan status `active` dari
  custom claims yang ditandatangani Firebase. Pengguna tidak dapat memilih
  `storeId` lewat form atau parameter lokal.
- Session tervalidasi boleh dicache di secure storage untuk akses offline oleh
  UID yang sama; session tanpa claims lengkap tidak diberi akses.

## Konfigurasi Firebase aktif

- Project ID: `ryangunshop-pos-2026`.
- Package Android: `id.ryangunshop.ryangunshop`.
- Firestore `(default)`: region Jakarta `asia-southeast2`, delete protection
  aktif, rules serta composite indexes sudah dideploy.
- Firebase Auth Email/Password aktif. Anonymous Auth nonaktif.
- SHA-1/SHA-256 debug, Play Integrity, dan debug token emulator sudah terdaftar.
- Script `scripts/verify_firebase_auth_firestore.js` membuat akun/dokumen uji
  sementara, memverifikasi custom claims dan isolasi tenant, lalu membersihkan
  keduanya tanpa menampilkan token atau password.

## Langkah keamanan sebelum rilis produksi

1. Buat akun owner pertama setelah pemilik menetapkan email dan password, lalu
   beri claims `storeId`, `role: OWNER`, dan `active: true` melalui Admin SDK.
2. Buat signing key release, daftarkan fingerprint release, dan uji Play
   Integrity menggunakan artefak distribusi sebenarnya.
3. Pantau metrik App Check sebelum enforcement Firestore/Storage diaktifkan.
4. Kirim satu test crash pada build internal, pastikan masuk ke Crashlytics,
   lalu hapus pemicu test crash sebelum rilis.
5. Jangan commit, mencetak, atau membagikan App Check debug token.

## Klasifikasi penyimpanan

| Data | Lokasi | Catatan |
|---|---|---|
| Token sesi/merchant secret | SecureValueStore | Tidak boleh dicatat ke log |
| Produk, stok, transaksi | Drift | Dibutuhkan untuk offline-first |
| Status onboarding | SharedPreferences | Bukan data sensitif |
| Foto panorama | Direktori privat aplikasi | Upload menunggu Firebase Storage |
