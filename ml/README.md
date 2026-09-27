# Pipeline model produk RyanGunshop

Model bawaan saat ini adalah MobileNetV2 ImageNet resmi untuk smoke test dan
benchmark perangkat. Manifest memasang `productionReady=false`, sehingga build
normal tetap memakai fallback barcode/pencarian manual dan tidak pernah
menganggap label ImageNet sebagai SKU warung.

Untuk menghasilkan model SKU:

```powershell
python -m venv D:\BuildTemp\ryangunshop-ml-venv
D:\BuildTemp\ryangunshop-ml-venv\Scripts\pip install -r ml\requirements.txt
D:\BuildTemp\ryangunshop-ml-venv\Scripts\python ml\train_product_classifier.py
```

Training memakai MobileNetV2 transfer learning, split per kelas yang
deterministik, kelas wajib `__unknown__`, float16 weight quantization, dan quality
gate berikut:

- minimal 40 foto per kelas;
- minimal dua kelas SKU dan satu kelas `__unknown__`;
- held-out test accuracy minimal 85%;
- precision prediksi yang diterima minimal 95%;
- coverage pada threshold terkalibrasi minimal 50%.

Jika gate gagal, model tetap diekspor untuk inspeksi tetapi manifest tetap
`productionReady=false` dan proses keluar dengan error. Setelah ekspor, jalankan
benchmark Android:

```powershell
flutter test integration_test/model_benchmark_test.dart -d emulator-5554 `
  --dart-define=RYANGUNSHOP_ENABLE_BASELINE_MODEL=true
```

Jangan menaikkan `productionReady` secara manual. Tambahkan variasi foto dan latih
ulang sampai quality gate lulus.
