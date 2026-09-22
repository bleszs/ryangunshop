import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart'
    as mlkit;
import 'package:google_mlkit_commons/google_mlkit_commons.dart';

import '../../domain/repositories/repositories.dart' as domain;

class MlKitBarcodeScanner implements domain.BarcodeScanner {
  MlKitBarcodeScanner()
    : _scanner = mlkit.BarcodeScanner(
        formats: const [
          mlkit.BarcodeFormat.ean13,
          mlkit.BarcodeFormat.ean8,
          mlkit.BarcodeFormat.upca,
          mlkit.BarcodeFormat.upce,
          mlkit.BarcodeFormat.code128,
        ],
      );

  final mlkit.BarcodeScanner _scanner;

  @override
  Future<String?> scanFile(String imagePath) async {
    final image = InputImage.fromFilePath(imagePath);
    final barcodes = await _scanner.processImage(image);
    for (final barcode in barcodes) {
      final value = barcode.rawValue?.trim();
      if (value != null && value.isNotEmpty) return value;
    }
    return null;
  }

  @override
  Future<void> close() => _scanner.close();
}
