import '../entities/entities.dart';
import '../entities/dashboard_entities.dart';
import '../entities/inventory_planning_entities.dart';
import '../entities/panorama_entities.dart';
import '../entities/sales_report_entities.dart';
import '../entities/store_layout_entities.dart';

abstract interface class ProductRepository {
  Stream<List<ProductEntity>> watchProducts(String storeId);
  Future<ProductEntity?> getById(String storeId, String productId);
  Future<ProductEntity?> getByAiLabel(String storeId, String label);
  Future<ProductEntity?> getByBarcode(String storeId, String barcode);
  Future<List<ProductEntity>> search(String storeId, String query);
  Future<bool> isBarcodeAvailable(
    String storeId,
    String barcode, {
    String? excludingProductId,
  });
  Future<void> saveProduct(ProductEntity product);
  Future<void> deleteProduct(String storeId, String productId);
}

class DuplicateProductBarcode implements Exception {
  const DuplicateProductBarcode(this.barcode);
  final String barcode;

  @override
  String toString() => 'Barcode $barcode sudah dipakai produk lain.';
}

abstract interface class CheckoutRepository {
  Future<CheckoutReceipt> checkout(CheckoutRequest request);
}

abstract interface class BusinessDashboardRepository {
  Stream<BusinessDashboardSnapshot> watchSnapshot({
    required String storeId,
    required DateTime fromInclusive,
    required DateTime toExclusive,
  });
}

abstract interface class InventoryPlanningRepository {
  Stream<List<RestockRecommendation>> watchRecommendations({
    required String storeId,
    int historyDays = 28,
    int reviewPeriodDays = 7,
  });
}

class EmptyBusinessDashboardRepository implements BusinessDashboardRepository {
  const EmptyBusinessDashboardRepository();

  @override
  Stream<BusinessDashboardSnapshot> watchSnapshot({
    required String storeId,
    required DateTime fromInclusive,
    required DateTime toExclusive,
  }) => Stream.value(const BusinessDashboardSnapshot.empty());
}

abstract interface class SalesReportRepository {
  Future<SalesReportData> loadReport({
    required String storeId,
    required DateTime fromInclusive,
    required DateTime toExclusive,
  });
}

abstract interface class TransactionManagementRepository {
  Stream<List<TransactionEntity>> watchTransactions({
    required String storeId,
    int limit = 50,
  });

  Future<VoidTransactionResult> voidTransaction(VoidTransactionRequest request);
}

class EmptyTransactionManagementRepository
    implements TransactionManagementRepository {
  const EmptyTransactionManagementRepository();

  @override
  Stream<List<TransactionEntity>> watchTransactions({
    required String storeId,
    int limit = 50,
  }) => Stream.value(const []);

  @override
  Future<VoidTransactionResult> voidTransaction(
    VoidTransactionRequest request,
  ) => throw UnsupportedError('Pengelolaan transaksi belum tersedia.');
}

class EmptySalesReportRepository implements SalesReportRepository {
  const EmptySalesReportRepository();

  @override
  Future<SalesReportData> loadReport({
    required String storeId,
    required DateTime fromInclusive,
    required DateTime toExclusive,
  }) async => SalesReportData(
    storeId: storeId,
    fromInclusive: fromInclusive,
    toExclusive: toExclusive,
    transactions: const [],
  );
}

abstract interface class PredictionRepository {
  Future<void> saveCorrection(PredictionCorrection correction);
}

abstract interface class StoreLayoutRepository {
  Stream<StoreLayoutEntity?> watchLayout(String storeId);
  Future<void> saveLayout(StoreLayoutEntity layout);
}

abstract interface class PanoramaRepository {
  Future<List<PanoramaZoneEntity>> loadZones(String storeId);

  Future<PanoramaZoneEntity> importZone({
    required String storeId,
    required String name,
    required String sourceImagePath,
  });

  Future<void> saveZone(PanoramaZoneEntity zone);

  Future<void> deleteZone(PanoramaZoneEntity zone);
}

class EmptyPanoramaRepository implements PanoramaRepository {
  const EmptyPanoramaRepository();

  @override
  Future<void> deleteZone(PanoramaZoneEntity zone) async {}

  @override
  Future<PanoramaZoneEntity> importZone({
    required String storeId,
    required String name,
    required String sourceImagePath,
  }) => throw UnsupportedError('Penyimpanan panorama belum tersedia.');

  @override
  Future<List<PanoramaZoneEntity>> loadZones(String storeId) async => const [];

  @override
  Future<void> saveZone(PanoramaZoneEntity zone) async {}
}

/// Port remote untuk sinkronisasi denah. Implementasi harus idempotent terhadap
/// [mutationId] karena event outbox dapat dikirim ulang setelah timeout.
abstract interface class StoreLayoutRemoteRepository {
  Future<void> upsertStoreLayout(
    StoreLayoutEntity layout, {
    required String mutationId,
  });
}

abstract interface class ProductRemoteRepository {
  Future<void> upsertProduct(
    ProductEntity product, {
    required String mutationId,
    required DateTime clientUpdatedAt,
  });

  Future<void> deleteProduct({
    required String storeId,
    required String productId,
    required String mutationId,
    required DateTime deletedAt,
  });
}

/// Port remote untuk mutasi stok berbasis delta. Implementasi wajib idempoten
/// terhadap [mutationId] agar pengiriman ulang tidak mengurangi stok dua kali.
abstract interface class InventoryStockRemoteRepository {
  Future<void> applyStockMutation({
    required String storeId,
    required String productId,
    required int delta,
    required String transactionId,
    required String mutationId,
    required DateTime occurredAt,
  });
}

/// Konflik permanen: delta valid, tetapi tidak dapat diterapkan pada stok pusat.
/// Event dipertahankan untuk audit dan tidak dicoba ulang tanpa rekonsiliasi.
class RemoteStockConflict implements Exception {
  const RemoteStockConflict({
    required this.productId,
    required this.available,
    required this.requestedReduction,
  });

  final String productId;
  final int available;
  final int requestedReduction;

  @override
  String toString() =>
      'Konflik stok $productId: tersedia $available, pengurangan $requestedReduction';
}

abstract interface class ProductClassifier {
  Future<ClassificationResult> classify(RgbFrame frame);
  Future<void> close();
}

abstract interface class BarcodeScanner {
  Future<String?> scanFile(String imagePath);
  Future<void> close();
}
