import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ryangunshop/data/local/app_database.dart';
import 'package:ryangunshop/data/repositories/drift_repositories.dart';
import 'package:ryangunshop/data/sync/inventory_stock_outbox_sync.dart';
import 'package:ryangunshop/domain/entities/entities.dart';
import 'package:ryangunshop/domain/repositories/repositories.dart';

void main() {
  late AppDatabase database;
  late DriftProductRepository products;
  late DriftCheckoutRepository checkout;
  late _FakeInventoryRemote remote;
  late InventoryStockOutboxSyncProcessor processor;
  var now = DateTime.utc(2026, 9, 20, 12);

  setUp(() async {
    database = AppDatabase.forTesting(NativeDatabase.memory());
    products = DriftProductRepository(database, clock: () => now);
    checkout = DriftCheckoutRepository(database, clock: () => now);
    remote = _FakeInventoryRemote();
    processor = InventoryStockOutboxSyncProcessor(
      database: database,
      remote: remote,
      clock: () => now,
    );
    await products.saveProduct(_product);
  });

  tearDown(() => database.close());

  test('checkout menulis delta stok dan worker mengirimnya sekali', () async {
    final receipt = await checkout.checkout(_request());
    final stockEvents = await _stockEvents(database);

    expect(stockEvents, hasLength(1));
    expect(stockEvents.single.storeId, 'store-1');
    expect(stockEvents.single.aggregateId, _product.id);
    expect(stockEvents.single.operation, 'adjust');

    final result = await processor.processPending(storeId: 'store-1');

    expect(result.synced, 1);
    expect(remote.calls, hasLength(1));
    expect(remote.calls.single.productId, _product.id);
    expect(remote.calls.single.delta, -2);
    expect(remote.calls.single.transactionId, receipt.transactionId);
    expect(remote.calls.single.mutationId, stockEvents.single.id);
    expect(await _stockEvents(database), isEmpty);
  });

  test('kegagalan jaringan mengikuti backoff sebelum dicoba ulang', () async {
    await checkout.checkout(_request());
    remote.failure = StateError('offline');

    expect((await processor.processPending()).failed, 1);
    var event = (await _stockEvents(database)).single;
    expect(event.attemptCount, 1);
    expect(event.nextAttemptAt?.toUtc(), now.add(const Duration(seconds: 30)));

    expect((await processor.processPending()).attempted, 0);
    now = now.add(const Duration(seconds: 30));
    remote.failure = null;
    expect((await processor.processPending()).synced, 1);
    expect(await _stockEvents(database), isEmpty);
  });

  test('konflik stok dipertahankan untuk audit dan tidak diulang', () async {
    await checkout.checkout(_request());
    remote.failure = const RemoteStockConflict(
      productId: 'product-1',
      available: 1,
      requestedReduction: 2,
    );

    final result = await processor.processPending();
    final event =
        (await (database.select(database.syncOutbox)
              ..where((table) => table.aggregateType.equals('productStock')))
            .getSingle());
    final product = await (database.select(
      database.products,
    )..where((table) => table.id.equals('product-1'))).getSingle();

    expect(result.failed, 1);
    expect(event.operation, 'conflict');
    expect(event.lastError, contains('Konflik stok'));
    expect(product.syncState, 'failed');
    expect((await processor.processPending()).attempted, 0);
  });
}

const _product = ProductEntity(
  id: 'product-1',
  storeId: 'store-1',
  name: 'Air mineral',
  category: 'Minuman',
  purchasePrice: 2000,
  sellingPrice: 3500,
  stock: 10,
  minimumStock: 2,
);

CheckoutRequest _request() => const CheckoutRequest(
  storeId: 'store-1',
  cashierId: 'cashier-1',
  lines: [CartLineRequest(productId: 'product-1', quantity: 2)],
  paymentType: PaymentType.cash,
  receivedAmount: 7000,
  clientMutationId: 'checkout-mutation-1',
);

Future<List<SyncOutboxRow>> _stockEvents(AppDatabase database) =>
    (database.select(database.syncOutbox)..where(
          (table) =>
              table.aggregateType.equals('productStock') &
              table.operation.equals('adjust'),
        ))
        .get();

class _StockCall {
  const _StockCall({
    required this.productId,
    required this.delta,
    required this.transactionId,
    required this.mutationId,
  });

  final String productId;
  final int delta;
  final String transactionId;
  final String mutationId;
}

class _FakeInventoryRemote implements InventoryStockRemoteRepository {
  Object? failure;
  final calls = <_StockCall>[];

  @override
  Future<void> applyStockMutation({
    required String storeId,
    required String productId,
    required int delta,
    required String transactionId,
    required String mutationId,
    required DateTime occurredAt,
  }) async {
    final currentFailure = failure;
    if (currentFailure != null) throw currentFailure;
    calls.add(
      _StockCall(
        productId: productId,
        delta: delta,
        transactionId: transactionId,
        mutationId: mutationId,
      ),
    );
  }
}
