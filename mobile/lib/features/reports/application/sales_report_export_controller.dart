import 'dart:io';

import 'package:flutter/foundation.dart';

import '../../../domain/entities/sales_report_entities.dart';
import '../../../domain/repositories/repositories.dart';
import 'sales_report_export_service.dart';

enum SalesReportFormat { pdf, csv }

typedef ReportFileSaver = Future<File> Function(SalesReportData report);
typedef ReportFileSharer =
    Future<void> Function(File file, {required bool isPdf});

class SalesReportExportController extends ChangeNotifier {
  SalesReportExportController({
    required SalesReportRepository repository,
    required String storeId,
    SalesReportDocumentService documentService =
        const SalesReportDocumentService(),
    SalesReportShareService shareService = const SalesReportShareService(),
    ReportFileSaver? pdfSaver,
    ReportFileSaver? csvSaver,
    ReportFileSharer? fileSharer,
  }) : _repository = repository,
       _storeId = storeId,
       _pdfSaver = pdfSaver ?? documentService.savePdf,
       _csvSaver = csvSaver ?? documentService.saveCsv,
       _fileSharer = fileSharer ?? shareService.share;

  final SalesReportRepository _repository;
  final String _storeId;
  final ReportFileSaver _pdfSaver;
  final ReportFileSaver _csvSaver;
  final ReportFileSharer _fileSharer;

  SalesReportFormat? _activeFormat;
  String? _errorMessage;
  String? _lastSavedFilename;

  SalesReportFormat? get activeFormat => _activeFormat;
  bool get isExporting => _activeFormat != null;
  String? get errorMessage => _errorMessage;
  String? get lastSavedFilename => _lastSavedFilename;

  Future<bool> exportAndShare({
    required SalesReportFormat format,
    required DateTime fromInclusive,
    required DateTime toExclusive,
  }) async {
    if (isExporting) return false;
    _activeFormat = format;
    _errorMessage = null;
    notifyListeners();
    try {
      final report = await _repository.loadReport(
        storeId: _storeId,
        fromInclusive: fromInclusive,
        toExclusive: toExclusive,
      );
      if (report.transactions.isEmpty) {
        _errorMessage = 'Belum ada transaksi berhasil untuk diekspor.';
        return false;
      }
      final isPdf = format == SalesReportFormat.pdf;
      final file = await (isPdf ? _pdfSaver(report) : _csvSaver(report));
      _lastSavedFilename = file.uri.pathSegments.last;
      await _fileSharer(file, isPdf: isPdf);
      return true;
    } catch (_) {
      _errorMessage =
          'Laporan gagal dibuat atau dibagikan. Periksa ruang penyimpanan lalu coba lagi.';
      return false;
    } finally {
      _activeFormat = null;
      notifyListeners();
    }
  }

  void clearError() {
    if (_errorMessage == null) return;
    _errorMessage = null;
    notifyListeners();
  }
}
