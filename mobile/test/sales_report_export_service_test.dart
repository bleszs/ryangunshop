import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:ryangunshop/domain/entities/entities.dart';
import 'package:ryangunshop/domain/entities/sales_report_entities.dart';
import 'package:ryangunshop/domain/repositories/repositories.dart';
import 'package:ryangunshop/features/reports/application/sales_report_export_controller.dart';
import 'package:ryangunshop/features/reports/application/sales_report_export_service.dart';

void main() {
  test(
    'menyimpan laporan PDF dan CSV secara atomik di direktori privat',
    () async {
      final directory = await Directory.systemTemp.createTemp(
        'ryangunshop-report-',
      );
      addTearDown(() => directory.delete(recursive: true));
      final service = SalesReportDocumentService(
        directoryProvider: () async => directory,
      );
      final report = _report();

      final pdf = await service.savePdf(report);
      final csv = await service.saveCsv(report);
      final pdfBytes = await pdf.readAsBytes();
      final csvBytes = await csv.readAsBytes();
      final csvText = String.fromCharCodes(csvBytes.skip(3));

      expect(pdf.path, contains('${Platform.pathSeparator}reports'));
      expect(pdf.path, endsWith('laporan_ryangunshop_20260901_20260930.pdf'));
      expect(String.fromCharCodes(pdfBytes.take(4)), '%PDF');
      expect(pdfBytes.length, greaterThan(1000));
      expect(csv.path, endsWith('laporan_ryangunshop_20260901_20260930.csv'));
      expect(csvBytes.take(3), [0xEF, 0xBB, 0xBF]);
      expect(csvText, contains('"transaction_id","tanggal"'));
      expect(csvText, contains('"\'=Kopi, promo"'));
      expect(csvText, contains('"success","cash"'));
    },
  );

  test('controller membuat dan membagikan format yang dipilih', () async {
    final directory = await Directory.systemTemp.createTemp(
      'ryangunshop-report-controller-',
    );
    addTearDown(() => directory.delete(recursive: true));
    final sharedFormats = <bool>[];
    final controller = SalesReportExportController(
      repository: _ReportRepository(_report()),
      storeId: 'store-1',
      pdfSaver: (report) async =>
          File('${directory.path}/report.pdf')..writeAsBytesSync([1, 2, 3]),
      csvSaver: (report) async =>
          File('${directory.path}/report.csv')..writeAsStringSync('csv'),
      fileSharer: (file, {required isPdf}) async {
        sharedFormats.add(isPdf);
      },
    );

    final success = await controller.exportAndShare(
      format: SalesReportFormat.csv,
      fromInclusive: DateTime(2026, 9),
      toExclusive: DateTime(2026, 10),
    );

    expect(success, isTrue);
    expect(sharedFormats, [false]);
    expect(controller.lastSavedFilename, 'report.csv');
    expect(controller.isExporting, isFalse);
    expect(controller.errorMessage, isNull);
  });

  test('controller menolak ekspor periode tanpa transaksi berhasil', () async {
    final report = SalesReportData(
      storeId: 'store-1',
      fromInclusive: DateTime(2026, 9),
      toExclusive: DateTime(2026, 10),
      transactions: const [],
    );
    var saverCalled = false;
    final controller = SalesReportExportController(
      repository: _ReportRepository(report),
      storeId: 'store-1',
      pdfSaver: (report) async {
        saverCalled = true;
        return File('unused.pdf');
      },
      csvSaver: (report) async {
        saverCalled = true;
        return File('unused.csv');
      },
      fileSharer: (file, {required isPdf}) async {},
    );

    final success = await controller.exportAndShare(
      format: SalesReportFormat.pdf,
      fromInclusive: report.fromInclusive,
      toExclusive: report.toExclusive,
    );

    expect(success, isFalse);
    expect(saverCalled, isFalse);
    expect(controller.errorMessage, contains('Belum ada transaksi'));
  });
}

SalesReportData _report() => SalesReportData(
  storeId: 'store-1',
  fromInclusive: DateTime(2026, 9),
  toExclusive: DateTime(2026, 10),
  transactions: [
    TransactionEntity(
      id: 'trx-001',
      storeId: 'store-1',
      occurredAt: DateTime(2026, 9, 20, 14, 30),
      items: const [
        TransactionItemEntity(
          productId: 'product-1',
          productName: '=Kopi, promo',
          quantity: 2,
          purchasePrice: 3000,
          sellingPrice: 5000,
        ),
      ],
      totalAmount: 10000,
      grossProfitAmount: 4000,
      paymentType: PaymentType.cash,
      receivedAmount: 10000,
      changeAmount: 0,
      cashierId: 'cashier-1',
      status: TransactionStatus.success,
    ),
  ],
);

class _ReportRepository implements SalesReportRepository {
  const _ReportRepository(this.report);
  final SalesReportData report;

  @override
  Future<SalesReportData> loadReport({
    required String storeId,
    required DateTime fromInclusive,
    required DateTime toExclusive,
  }) async => report;
}
