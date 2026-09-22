# WhatsApp AI Agent

Backend tambahan untuk FR-14/FR-15. Agent hanya memilih fungsi; angka stok/penjualan
selalu dibaca tool dari Firestore.

## Flow

1. Meta melakukan `GET /webhooks/whatsapp`; server mencocokkan verify token.
2. Meta mengirim `POST`; server memverifikasi `X-Hub-Signature-256` terhadap raw body.
3. Message ID diklaim di Firestore agar retry webhook tidak diproses dua kali.
4. Nomor E.164 dicari di `whatsappUsers/{phone}` dan harus `active=true`.
5. Ollama menerima system prompt dan schema tool tanpa kredensial database.
6. Registry memvalidasi nama tool, parameter Zod, role, dan `storeId` dari whitelist.
7. Hasil dan kegagalan dicatat di `stores/{storeId}/agentActions`.
8. Hasil tool dikirim kembali ke Ollama untuk disusun sebagai Bahasa Indonesia.
9. Jawaban dikirim melalui WhatsApp Graph API.

## Menjalankan lokal

```bash
npm install
cp .env.example .env
npm run check
npm run test:firebase
npm run dev
```

`npm run test:firebase` menyalakan Firestore Emulator sementara dan memverifikasi
isolasi tenant serta batas akses kasir. Test biasa memakai mock Ollama dan mock
pengirim WhatsApp, sehingga tidak membutuhkan token Meta maupun server model aktif.

Untuk menjalankan backend terhadap Firestore sungguhan, gunakan Application Default
Credentials. Untuk webhook lokal, gunakan tunnel HTTPS lalu masukkan
`/webhooks/whatsapp` ke konfigurasi Meta.

## Guardrail

- Model tidak dapat menentukan `storeId`, nomor pengguna, role, atau collection path.
- Tool yang tidak terdaftar dan parameter yang tidak sesuai schema ditolak.
- Tool mutasi harus memiliki confirmation token; belum ada tool mutasi pada fondasi ini.
- Balasan tanpa tool yang mengandung angka diblokir agar model tidak mengarang metrik.
- Signature dibandingkan secara constant-time dan error tidak membocorkan secret.
- Production perlu queue durable, retry/dead-letter, rate limit, App Secret rotation,
  signed URL singkat, serta retention/TTL untuk dedup dan audit.
