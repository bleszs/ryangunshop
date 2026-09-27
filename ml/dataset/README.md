# Dataset lokal (tidak masuk Git)

Susun foto per label yang sama dengan `ProductEntity.aiLabel`:

```text
ml/dataset/
  __unknown__/
    bukan_produk_001.jpg
  aqua_600ml/
    depan_001.jpg
  indomie_goreng/
    depan_001.jpg
```

Gunakan minimal 40 foto per kelas, sedikitnya dua SKU, dan kelas
`__unknown__`. Ambil variasi sudut, jarak, pencahayaan, latar, serta kondisi
kemasan. Jangan memasukkan wajah, struk, nomor telepon, atau data pelanggan.

Isi folder ini diabaikan Git agar dataset privat tidak bocor. Hanya README ini
yang dilacak.
