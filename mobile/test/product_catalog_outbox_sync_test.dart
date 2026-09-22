import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ryangunshop/data/local/app_database.dart';
import 'package:ryangunshop/data/repositories/drift_repositories.dart';
import 'package:ryangunshop/data/sync/inventory_stock_outbox_sync.dart';
import 'package:ryangunshop/data/sync/product_catalog_outbox_sync.dart';
import 'package:ryangunshop/domain/entities/entities.dart';
import 'package:ryangunshop/domain/repositories/repositories.dart';

void main() {
  late AppDatabase database;
  late DriftProductRepository products;
  late _FakeCatalogRemote catalogRemote;
  late _FakeStockRemote stockRemote;
  late ProductCatalogOutboxSyncProcessor catalogProcessor;
  late InventoryStockOutboxSyncProcessor stockProcessor;
  final now = DateTime.utc(2026, 9, 20, 14);

  setUp(() {
    database = AppDatabase.forTesting(NativeDatabase.memory());
    products = DriftProductRepository(database, clock: () => now);
    catalogRemote = _FakeCatalogRemote();
    stockRemote = _FakeStockRemote();
    catalogProcessor = ProductCatalogOutboxSyncProcessor(
      database: database,
      remote: catalogRemote,
      clock: () => now,
    );
    stockProcessor = InventoryStockOutboxSyncProcessor(
      database: database,
      remote: stockRemote,
      clock: () => now,
    );
  });

  tearDown(() => database.close());

  test('worker mengirim upsert dan menandai produk synced', () async {
    await products.saveProduct(_product());

    final result = await catalogProcessor.processPending(storeId: 'store-1');
    final row = await database.select(database.products).getSingle();

    expect(result.synced, 1);
    expect(catalogRemote.upserts.single.product.name, 'Air mineral');
    expect(catalogRemote.upserts.single.clientUpdatedAt, now);
    expect(row.syncState, 'synced');
    expect(await database.select(database.syncOutbox).get(), isEmpty);
  });

  test(
    'edit stok menjadi delta dan status synced setelah kedua outbox selesai',
    () async {
      await products.saveProduct(_product());
      await catalogProcessor.processPending();
      await products.saveProduct(_product(stock: 14));

      final events = await database.select(database.syncOutbox).get();
      expect(events.map((event) => event.aggregateType).toSet(), {
        'product',
        'productStock',
      });

      expect((await catalogProcessor.processPending()).synced, 1);
      var row = await database.select(database.products).getSingle();
      expect(row.syncState, 'pending');

      expect((await stockProcessor.processPending()).synced, 1);
      expect(stockRemote.deltas.single, 4);
      row = await database.select(database.products).getSingle();
      expect(row.syncState, 'synced');
    },
  );

  test('hapus produk dikirim sebagai soft delete remote', () async {
    await products.saveProduct(_product());
    await catalogProcessor.processPending();
    await products.deleteProduct('store-1', 'product-1');

    expect((await catalogProcessor.processPending()).synced, 1);
    expect(catalogRemote.deletes.single.productId, 'product-1');
    expect(catalogRemote.deletes.single.deletedAt, now);
  });
}

ProductEntity _product({int stock = 10}) => ProductEntity(
  id: 'product-1',
  storeId: 'store-1',
  name: 'Air mineral',
  category: 'Minuman',
  purchasePrice: 2000,
  sellingPrice: 3500,
  stock: stock,
  minimumStock: 2,
);

class _ProductUpsertCall {
  const _ProductUpsertCall({
    required this.product,
    required this.clientUpdatedAt,
  });

  final ProductEntity product;
  final DateTime clientUpdatedAt;
}

class _ProductDeleteCall {
  const _ProductDeleteCall({required this.productId, required this.deletedAt});

  final String productId;
  final DateTime deletedAt;
}

class _FakeCatalogRemote implements ProductRemoteRepository {
  final upserts = <_ProductUpsertCall>[];
  final deletes = <_ProductDeleteCall>[];

  @override
  Future<void> upsertProduct(
    ProductEntity product, {
    required String mutationId,
    required DateTime clientUpdatedAt,
  }) async {
    upserts.add(
      _ProductUpsertCall(product: product, clientUpdatedAt: clientUpdatedAt),
    );
  }

  @override
  Future<void> deleteProduct({
    required String storeId,
    required String productId,
    required String mutationId,
    required DateTime deletedAt,
  }) async {
    deletes.add(_ProductDeleteCall(productId: productId, deletedAt: deletedAt));
  }
}

class _FakeStockRemote implements InventoryStockRemoteRepository {
  final deltas = <int>[];

  @override
  Future<void> applyStockMutation({
    required String storeId,
    required String productId,
    required int delta,
    required String transactionId,
    required String mutationId,
    required DateTime occurredAt,
  }) async {
    deltas.add(delta);
  }
}
