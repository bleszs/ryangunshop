import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';

import '../../../domain/entities/entities.dart';
import '../../../domain/entities/sales_report_entities.dart';

typedef ReportDirectoryProvider = Future<Directory> Function();

class SalesReportDocumentService {
  const SalesReportDocumentService({ReportDirectoryProvider? directoryProvider})
    : _directoryProvider = directoryProvider;

  final ReportDirectoryProvider? _directoryProvider;

  Future<File> savePdf(SalesReportData report) async {
    final bytes = await buildPdf(report);
    return _save(bytes, filename: '${_filenamePrefix(report)}.pdf');
  }

  Future<File> saveCsv(SalesReportData report) async {
    final bytes = buildCsv(report);
    return _save(bytes, filename: '${_filenamePrefix(report)}.csv');
  }

  Future<List<int>> buildPdf(SalesReportData report) async {
    final document = pw.Document(
      title: 'Laporan penjualan RyanGunshop',
      author: 'RyanGunshop',
      creator: 'RyanGunshop Mobile',
    );
    final slate = PdfColor.fromHex('#565C9D');
    final slateLight = PdfColor.fromHex('#E9EAF6');
    final ink = PdfColor.fromHex('#191A2E');
    final muted = PdfColor.fromHex('#62657A');
    final outline = PdfColor.fromHex('#D9DAE6');

    document.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.fromLTRB(32, 34, 32, 34),
        theme: pw.ThemeData.withFont(
          base: pw.Font.helvetica(),
          bold: pw.Font.helveticaBold(),
        ),
        header: (context) => context.pageNumber == 1
            ? pw.SizedBox()
            : pw.Padding(
                padding: const pw.EdgeInsets.only(bottom: 12),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text(
                      'RyanGunshop',
                      style: pw.TextStyle(
                        color: slate,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.Text(
                      'Laporan penjualan',
                      style: pw.TextStyle(color: muted, fontSize: 9),
                    ),
                  ],
                ),
              ),
        footer: (context) => pw.Padding(
          padding: const pw.EdgeInsets.only(top: 14),
          child: pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text(
                'Dibuat oleh RyanGunshop Mobile',
                style: pw.TextStyle(color: muted, fontSize: 8),
              ),
              pw.Text(
                'Halaman ${context.pageNumber} dari ${context.pagesCount}',
                style: pw.TextStyle(color: muted, fontSize: 8),
              ),
            ],
          ),
        ),
        build: (_) => [
          pw.Container(
            padding: const pw.EdgeInsets.all(20),
            decoration: pw.BoxDecoration(
              color: slate,
              borderRadius: pw.BorderRadius.circular(10),
            ),
            child: pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.end,
              children: [
                pw.Expanded(
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'RyanGunshop',
                        style: pw.TextStyle(
                          color: PdfColors.white,
                          fontSize: 12,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                      pw.SizedBox(height: 16),
                      pw.Text(
                        'Laporan Penjualan',
                        style: pw.TextStyle(
                          color: PdfColors.white,
                          fontSize: 24,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                pw.Text(
                  _periodLabel(report),
                  style: const pw.TextStyle(
                    color: PdfColors.white,
                    fontSize: 9,
                  ),
                ),
              ],
            ),
          ),
          pw.SizedBox(height: 22),
          pw.Row(
            children: [
              _metricBox(
                'Omzet',
                _rupiah(report.totalRevenue),
                ink,
                muted,
                outline,
              ),
              pw.SizedBox(width: 10),
              _metricBox(
                'Laba kotor',
                _rupiah(report.grossProfit),
                ink,
                muted,
                outline,
              ),
              pw.SizedBox(width: 10),
              _metricBox(
                'Transaksi',
                '${report.transactions.length}',
                ink,
                muted,
                outline,
              ),
            ],
          ),
          pw.SizedBox(height: 24),
          _sectionTitle('Ringkasan produk', ink, muted),
          pw.SizedBox(height: 10),
          if (report.productSummary.isEmpty)
            pw.Text(
              'Tidak ada produk terjual pada periode ini.',
              style: pw.TextStyle(color: muted),
            )
          else
            pw.TableHelper.fromTextArray(
              headers: const ['Produk', 'Unit', 'Omzet', 'Laba kotor'],
              data: report.productSummary
                  .map(
                    (item) => [
                      item.productName,
                      '${item.quantity}',
                      _rupiah(item.revenue),
                      _rupiah(item.grossProfit),
                    ],
                  )
                  .toList(growable: false),
              headerDecoration: pw.BoxDecoration(color: slateLight),
              headerStyle: pw.TextStyle(
                color: ink,
                fontSize: 9,
                fontWeight: pw.FontWeight.bold,
              ),
              cellStyle: pw.TextStyle(color: ink, fontSize: 8),
              border: pw.TableBorder.all(color: outline, width: .5),
              cellPadding: const pw.EdgeInsets.symmetric(
                horizontal: 7,
                vertical: 6,
              ),
              columnWidths: const {
                0: pw.FlexColumnWidth(2.2),
                1: pw.FlexColumnWidth(.6),
                2: pw.FlexColumnWidth(1.1),
                3: pw.FlexColumnWidth(1.1),
              },
            ),
          pw.SizedBox(height: 24),
          _sectionTitle('Daftar transaksi', ink, muted),
          pw.SizedBox(height: 10),
          pw.TableHelper.fromTextArray(
            headers: const ['Tanggal', 'ID', 'Bayar', 'Item', 'Total', 'Laba'],
            data: report.transactions
                .map(
                  (transaction) => [
                    _dateTime(transaction.occurredAt),
                    _shortId(transaction.id),
                    transaction.paymentType == PaymentType.cash
                        ? 'Tunai'
                        : 'QRIS',
                    '${transaction.items.fold<int>(0, (sum, item) => sum + item.quantity)}',
                    _rupiah(transaction.totalAmount),
                    _rupiah(transaction.grossProfitAmount),
                  ],
                )
                .toList(growable: false),
            headerDecoration: pw.BoxDecoration(color: slateLight),
            headerStyle: pw.TextStyle(
              color: ink,
              fontSize: 8,
              fontWeight: pw.FontWeight.bold,
            ),
            cellStyle: pw.TextStyle(color: ink, fontSize: 7),
            border: pw.TableBorder.all(color: outline, width: .5),
            cellPadding: const pw.EdgeInsets.symmetric(
              horizontal: 5,
              vertical: 6,
            ),
          ),
          pw.SizedBox(height: 12),
          pw.Text(
            'Hanya transaksi berstatus berhasil yang disertakan.',
            style: pw.TextStyle(color: muted, fontSize: 8),
          ),
        ],
      ),
    );
    return document.save();
  }

  List<int> buildCsv(SalesReportData report) {
    const headers = [
      'transaction_id',
      'tanggal',
      'status',
      'pembayaran',
      'kasir_id',
      'product_id',
      'nama_produk',
      'jumlah',
      'harga_beli',
      'harga_jual',
      'subtotal',
      'laba_kotor_item',
      'total_transaksi',
      'laba_kotor_transaksi',
    ];
    final lines = <String>[_csvRow(headers)];
    for (final transaction in report.transactions) {
      for (final item in transaction.items) {
        lines.add(
          _csvRow([
            transaction.id,
            transaction.occurredAt.toLocal().toIso8601String(),
            transaction.status.name,
            transaction.paymentType.name,
            transaction.cashierId,
            item.productId,
            item.productName,
            item.quantity,
            item.purchasePrice,
            item.sellingPrice,
            item.subtotal,
            (item.sellingPrice - item.purchasePrice) * item.quantity,
            transaction.totalAmount,
            transaction.grossProfitAmount,
          ]),
        );
      }
    }
    return [0xEF, 0xBB, 0xBF, ...utf8.encode('${lines.join('\r\n')}\r\n')];
  }

  Future<File> _save(List<int> bytes, {required String filename}) async {
    final documents =
        await (_directoryProvider ?? getApplicationDocumentsDirectory)();
    final reports = Directory(path.join(documents.path, 'reports'));
    await reports.create(recursive: true);
    final destination = File(path.join(reports.path, filename));
    final temporary = File('${destination.path}.tmp');
    await temporary.writeAsBytes(bytes, flush: true);
    if (await destination.exists()) await destination.delete();
    return temporary.rename(destination.path);
  }
}

class SalesReportShareService {
  const SalesReportShareService();

  Future<void> share(File file, {required bool isPdf}) async {
    await SharePlus.instance.share(
      ShareParams(
        title: 'Bagikan laporan RyanGunshop',
        subject: 'Laporan penjualan RyanGunshop',
        text: isPdf
            ? 'Laporan penjualan RyanGunshop dalam format PDF.'
            : 'Data penjualan RyanGunshop dalam format CSV untuk Excel.',
        files: [
          XFile(file.path, mimeType: isPdf ? 'application/pdf' : 'text/csv'),
        ],
        fileNameOverrides: [path.basename(file.path)],
      ),
    );
  }
}

pw.Widget _metricBox(
  String label,
  String value,
  PdfColor ink,
  PdfColor muted,
  PdfColor outline,
) => pw.Expanded(
  child: pw.Container(
    padding: const pw.EdgeInsets.all(12),
    decoration: pw.BoxDecoration(
      border: pw.Border.all(color: outline, width: .7),
      borderRadius: pw.BorderRadius.circular(7),
    ),
    child: pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(label, style: pw.TextStyle(color: muted, fontSize: 8)),
        pw.SizedBox(height: 5),
        pw.FittedBox(
          child: pw.Text(
            value,
            style: pw.TextStyle(
              color: ink,
              fontSize: 13,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
        ),
      ],
    ),
  ),
);

pw.Widget _sectionTitle(String title, PdfColor ink, PdfColor muted) =>
    pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          title,
          style: pw.TextStyle(
            color: ink,
            fontSize: 14,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
        pw.SizedBox(height: 3),
        pw.Text(
          'Perhitungan berdasarkan snapshot harga saat transaksi.',
          style: pw.TextStyle(color: muted, fontSize: 8),
        ),
      ],
    );

String _csvRow(Iterable<Object?> values) => values.map(_csvCell).join(',');

String _csvCell(Object? value) {
  var text = value?.toString() ?? '';
  if (RegExp(r'^[=+\-@]').hasMatch(text)) text = "'$text";
  return '"${text.replaceAll('"', '""')}"';
}

String _filenamePrefix(SalesReportData report) {
  final end = report.toExclusive.subtract(const Duration(days: 1));
  return 'laporan_ryangunshop_${_compactDate(report.fromInclusive)}_${_compactDate(end)}';
}

String _periodLabel(SalesReportData report) {
  final end = report.toExclusive.subtract(const Duration(days: 1));
  return '${_date(report.fromInclusive)} - ${_date(end)}';
}

String _compactDate(DateTime value) =>
    '${value.year}${_two(value.month)}${_two(value.day)}';

String _date(DateTime value) =>
    '${_two(value.day)}/${_two(value.month)}/${value.year}';

String _dateTime(DateTime value) {
  final local = value.toLocal();
  return '${_date(local)} ${_two(local.hour)}:${_two(local.minute)}';
}

String _two(int value) => value.toString().padLeft(2, '0');

String _shortId(String value) => value.length > 8
    ? value.substring(0, 8).toUpperCase()
    : value.toUpperCase();

String _rupiah(int amount) {
  final digits = amount.abs().toString();
  final chunks = <String>[];
  for (var end = digits.length; end > 0; end -= 3) {
    final start = (end - 3).clamp(0, end);
    chunks.add(digits.substring(start, end));
  }
  final value = chunks.reversed.join('.');
  return amount < 0 ? '-Rp$value' : 'Rp$value';
}
