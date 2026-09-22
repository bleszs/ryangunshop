import 'dart:io';

import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';

import '../../../domain/entities/entities.dart';

typedef ReceiptDirectoryProvider = Future<Directory> Function();

class ReceiptPdfService {
  const ReceiptPdfService({ReceiptDirectoryProvider? directoryProvider})
    : _directoryProvider = directoryProvider;

  final ReceiptDirectoryProvider? _directoryProvider;

  Future<File> save(CompletedCheckout checkout) async {
    final bytes = await build(checkout);
    final documents =
        await (_directoryProvider ?? getApplicationDocumentsDirectory)();
    final receipts = Directory(path.join(documents.path, 'receipts'));
    await receipts.create(recursive: true);

    final safeId = checkout.receipt.transactionId.replaceAll(
      RegExp(r'[^a-zA-Z0-9_-]'),
      '_',
    );
    final destination = File(path.join(receipts.path, 'struk_$safeId.pdf'));
    final temporary = File('${destination.path}.tmp');

    await temporary.writeAsBytes(bytes, flush: true);
    if (await destination.exists()) await destination.delete();
    return temporary.rename(destination.path);
  }

  Future<List<int>> build(CompletedCheckout checkout) async {
    final receipt = checkout.receipt;
    final document = pw.Document(
      title: 'Struk ${receipt.transactionId}',
      author: 'RyanGunshop',
      creator: 'RyanGunshop Mobile',
    );
    final height = (118 + (checkout.items.length * 15)) * PdfPageFormat.mm;
    final slate = PdfColor.fromHex('#565C9D');
    final ink = PdfColor.fromHex('#191A2E');
    final muted = PdfColor.fromHex('#62657A');

    document.addPage(
      pw.Page(
        pageFormat: PdfPageFormat(
          80 * PdfPageFormat.mm,
          height,
          marginAll: 6 * PdfPageFormat.mm,
        ),
        theme: pw.ThemeData.withFont(
          base: pw.Font.helvetica(),
          bold: pw.Font.helveticaBold(),
        ),
        build: (_) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.stretch,
          children: [
            pw.Container(
              padding: const pw.EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 12,
              ),
              decoration: pw.BoxDecoration(
                color: slate,
                borderRadius: pw.BorderRadius.circular(8),
              ),
              child: pw.Column(
                children: [
                  pw.Text(
                    'RyanGunshop',
                    style: pw.TextStyle(
                      color: PdfColors.white,
                      fontSize: 18,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.SizedBox(height: 3),
                  pw.Text(
                    'Struk pembayaran',
                    style: const pw.TextStyle(
                      color: PdfColors.white,
                      fontSize: 9,
                    ),
                  ),
                ],
              ),
            ),
            pw.SizedBox(height: 12),
            _infoRow('Tanggal', _dateTime(receipt.occurredAt), ink, muted),
            _infoRow('Transaksi', _shortId(receipt.transactionId), ink, muted),
            _infoRow('Kasir', checkout.cashierId, ink, muted),
            _infoRow(
              'Pembayaran',
              checkout.paymentType == PaymentType.cash ? 'Tunai' : 'QRIS',
              ink,
              muted,
            ),
            pw.Padding(
              padding: const pw.EdgeInsets.symmetric(vertical: 9),
              child: pw.Divider(color: PdfColor.fromHex('#D9DAE6')),
            ),
            ...checkout.items.expand(
              (item) => [
                pw.Row(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Expanded(
                      child: pw.Text(
                        item.productName,
                        style: pw.TextStyle(
                          color: ink,
                          fontSize: 10,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                    ),
                    pw.SizedBox(width: 8),
                    pw.Text(
                      _rupiah(item.subtotal),
                      style: pw.TextStyle(color: ink, fontSize: 10),
                    ),
                  ],
                ),
                pw.SizedBox(height: 3),
                pw.Text(
                  '${item.quantity} x ${_rupiah(item.sellingPrice)}',
                  style: pw.TextStyle(color: muted, fontSize: 8),
                ),
                pw.SizedBox(height: 8),
              ],
            ),
            pw.Divider(color: PdfColor.fromHex('#D9DAE6')),
            pw.SizedBox(height: 7),
            _totalRow('Total', _rupiah(receipt.totalAmount), ink, bold: true),
            pw.SizedBox(height: 5),
            _totalRow('Diterima', _rupiah(receipt.receivedAmount), ink),
            pw.SizedBox(height: 5),
            _totalRow('Kembalian', _rupiah(receipt.changeAmount), ink),
            pw.Spacer(),
            pw.Text(
              'Terima kasih sudah berbelanja.',
              textAlign: pw.TextAlign.center,
              style: pw.TextStyle(
                color: slate,
                fontSize: 9,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
            pw.SizedBox(height: 3),
            pw.Text(
              'Struk ini dibuat oleh RyanGunshop.',
              textAlign: pw.TextAlign.center,
              style: pw.TextStyle(color: muted, fontSize: 7),
            ),
          ],
        ),
      ),
    );

    return document.save();
  }
}

class ReceiptShareService {
  const ReceiptShareService();

  Future<void> share(File file, CompletedCheckout checkout) async {
    final id = _shortId(checkout.receipt.transactionId);
    await SharePlus.instance.share(
      ShareParams(
        title: 'Bagikan struk RyanGunshop',
        subject: 'Struk transaksi $id',
        text:
            'Struk RyanGunshop $id - total ${_rupiah(checkout.receipt.totalAmount)}.',
        files: [XFile(file.path, mimeType: 'application/pdf')],
        fileNameOverrides: [path.basename(file.path)],
      ),
    );
  }
}

pw.Widget _infoRow(String label, String value, PdfColor ink, PdfColor muted) {
  return pw.Padding(
    padding: const pw.EdgeInsets.only(bottom: 4),
    child: pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.SizedBox(
          width: 50,
          child: pw.Text(label, style: pw.TextStyle(color: muted, fontSize: 8)),
        ),
        pw.Expanded(
          child: pw.Text(
            value,
            textAlign: pw.TextAlign.right,
            style: pw.TextStyle(color: ink, fontSize: 8),
          ),
        ),
      ],
    ),
  );
}

pw.Widget _totalRow(
  String label,
  String value,
  PdfColor ink, {
  bool bold = false,
}) {
  final style = pw.TextStyle(
    color: ink,
    fontSize: bold ? 12 : 9,
    fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal,
  );
  return pw.Row(
    children: [
      pw.Expanded(child: pw.Text(label, style: style)),
      pw.Text(value, style: style),
    ],
  );
}

String _shortId(String value) => value.length > 12
    ? value.substring(0, 12).toUpperCase()
    : value.toUpperCase();

String _dateTime(DateTime value) {
  String two(int number) => number.toString().padLeft(2, '0');
  final local = value.toLocal();
  return '${two(local.day)}/${two(local.month)}/${local.year} '
      '${two(local.hour)}:${two(local.minute)}';
}

String _rupiah(int amount) {
  final digits = amount.toString();
  final buffer = StringBuffer('Rp');
  for (var index = 0; index < digits.length; index++) {
    if (index > 0 && (digits.length - index) % 3 == 0) buffer.write('.');
    buffer.write(digits[index]);
  }
  return buffer.toString();
}
