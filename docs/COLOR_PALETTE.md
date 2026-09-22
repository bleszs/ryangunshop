# RyanGunshop — Slate Blue Color Palette

Palet ini menggantikan tema teal lama. Strateginya **restrained**: slate blue
dipakai pada tindakan, pilihan aktif, dan satu permukaan hero; sebagian besar UI
tetap memakai netral dingin agar denah dan data produk mudah dibaca.

## Brand ramp

| Token | Hex | Pemakaian |
|---|---:|---|
| Slate 50 | `#F5F5FB` | Latar tint sangat ringan |
| Slate 100 | `#E9EAF6` | Selected state, icon well |
| Slate 200 | `#D4D6ED` | Divider atau border aktif lembut |
| Slate 300 | `#B1B5DB` | Disabled decoration |
| Slate 400 | `#8B91D4` | Progress dan focus accent |
| Slate 500 | `#6D73B8` | Secondary action |
| Slate 600 | `#565C9D` | Primary action |
| Slate 700 | `#44497E` | Pressed/hover dan teks pada tint |
| Slate 800 | `#34385F` | Splash dan permukaan kontras |
| Slate 900 | `#25283F` | Brand ink gelap |

## Neutral dan semantic

| Token | Hex | Pemakaian |
|---|---:|---|
| Canvas | `#F7F7FB` | Latar layar |
| Surface | `#FFFFFF` | Sheet dan area kerja |
| Ink | `#191A2E` | Teks utama |
| Muted | `#62657A` | Teks pendukung |
| Outline | `#D9DAE6` | Divider dan border |
| Success | `#287A66` | Sinkron/berhasil |
| Warning | `#A86616` | Stok menipis/pending |
| Error | `#B44252` | Error dan aksi destruktif |

## Aturan

- Teks utama di canvas/surface memakai `Ink`; `Muted` hanya untuk informasi
  sekunder dan tetap memenuhi target kontras body text.
- Tombol primary memakai Slate 600 dengan teks putih. State tekan memakai Slate
  700, bukan opacity acak.
- Slate 800 dengan teks putih diperbolehkan untuk splash dan satu hero utama.
- Success tidak menggantikan primary; warna ini hanya menyampaikan status.
- Makna tidak pernah disampaikan dengan warna saja: sertakan ikon dan label.
- Tidak memakai gradient, glassmorphism, atau shadow lebar dekoratif.

