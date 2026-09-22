import '../core/barcode/mlkit_barcode_scanner.dart';
import '../core/ml/tflite_product_classifier.dart';
import '../core/ml/unavailable_product_classifier.dart';
import '../data/local/app_database.dart';
import '../data/repositories/drift_repositories.dart';
import '../domain/repositories/repositories.dart';
import '../domain/usecases/product_recognition_coordinator.dart';
import '../features/transaction/presentation/transaction_view_model.dart';

class AppContainer {
  AppContainer._(this.database, this.products);

  factory AppContainer() {
    final database = AppDatabase();
    return AppContainer._(database, DriftProductRepository(database));
  }

  final AppDatabase database;
  final DriftProductRepository products;

  Future<TransactionViewModel> createTransactionViewModel({
    required String storeId,
    required String cashierId,
  }) async {
    final classifier = await _loadClassifier();
    final predictions = DriftPredictionRepository(database);
    return TransactionViewModel(
      storeId: storeId,
      cashierId: cashierId,
      recognition: ProductRecognitionCoordinator(
        classifier: classifier,
        products: products,
        predictions: predictions,
      ),
      barcodeScanner: MlKitBarcodeScanner(),
      products: products,
      checkoutRepository: DriftCheckoutRepository(database),
    );
  }

  Future<ProductClassifier> _loadClassifier() async {
    try {
      return await TfliteProductClassifier.load();
    } catch (_) {
      return const UnavailableProductClassifier();
    }
  }

  Future<void> dispose() => database.close();
}
