import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ryangunshop/data/local/app_database.dart';
import 'package:ryangunshop/data/repositories/drift_repositories.dart';
import 'package:ryangunshop/data/repositories/drift_transaction_management_repository.dart';
import 'package:ryangunshop/domain/entities/entities.dart';

void main() {
  late AppDatabase database;
  late DriftProductRepository products;
  late DriftCheckoutRepository checkout;
  late DriftTransactionManagementRepository transactions;
  final now = DateTime(2026, 9, 22, 10);

  setUp(() {
    database = AppDatabase.forTesting(NativeDatabase.memory());
    products = DriftProductRepository(database, clock: () => now);
    checkout = DriftCheckoutRepository(database, clock: () => now);
    transactions = DriftTransactionManagementRepository(
      database,
      clock: () => now.add(const Duration(hours: 1)),
    );
  });

  tearDown(() => database.close());

  test(
    'void mengembalikan stok, menulis ledger dan audit secara idempoten',
    () async {
      await products.saveProduct(_product('product-a', stock: 10));
      final receipt = await checkout.checkout(
        const CheckoutRequest(
          storeId: 'store-1',
          cashierId: 'cashier-1',
          lines: [CartLineRequest(productId: 'product-a', quantity: 2)],
          paymentType: PaymentType.cash,
          receivedAmount: 10000,
          clientMutationId: 'checkout-1',
        ),
      );
      expect((await products.getById('store-1', 'product-a'))?.stock, 8);

      final result = await transactions.voidTransaction(
        VoidTransactionRequest(
          storeId: 'store-1',
          transactionId: receipt.transactionId,
          actorId: 'owner-1',
          reason: 'Barang dikembalikan pelanggan',
          clientMutationId: 'void-1',
        ),
      );

      expect(result.restoredUnits, 2);
      expect(result.alreadyProcessed, isFalse);
      expect((await products.getById('store-1', 'product-a'))?.stock, 10);
      final transaction = await database
          .select(database.salesTransactions)
          .getSingle();
      expect(transaction.status, TransactionStatus.cancelled.name);
      final ledger = await database.select(database.inventoryStockLedger).get();
      expect(ledger.map((entry) => entry.delta), containsAll([-2, 2]));
      expect(ledger.last.action, 'void');
      expect(ledger.last.reason, 'Barang dikembalikan pelanggan');
      final audit = await database
          .select(database.transactionAudits)
          .getSingle();
      expect(audit.actorId, 'owner-1');
      expect(audit.mutationId, 'void-1');

      final retry = await transactions.voidTransaction(
        VoidTransactionRequest(
          storeId: 'store-1',
          transactionId: receipt.transactionId,
          actorId: 'owner-1',
          reason: 'Barang dikembalikan pelanggan',
          clientMutationId: 'void-1',
        ),
      );
      expect(retry.alreadyProcessed, isTrue);
      expect((await products.getById('store-1', 'product-a'))?.stock, 10);
      expect(
        await database.select(database.transactionAudits).get(),
        hasLength(1),
      );
      expect(
        (await database.select(database.inventoryStockLedger).get()).where(
          (entry) => entry.action == 'void',
        ),
        hasLength(1),
      );
    },
  );

  test('kegagalan void me-rollback status, stok, ledger, dan audit', () async {
    await products.saveProduct(_product('product-a', stock: 5));
    await products.saveProduct(_product('product-b', stock: 5));
    final receipt = await checkout.checkout(
      const CheckoutRequest(
        storeId: 'store-1',
        cashierId: 'cashier-1',
        lines: [
          CartLineRequest(productId: 'product-a', quantity: 1),
          CartLineRequest(productId: 'product-b', quantity: 1),
        ],
        paymentType: PaymentType.cash,
        receivedAmount: 10000,
        clientMutationId: 'checkout-rollback',
      ),
    );
    await database.customStatement('''
      CREATE TRIGGER fail_void_ledger
      BEFORE INSERT ON inventory_stock_ledger
      WHEN NEW.product_id = 'product-b' AND NEW.action = 'void'
      BEGIN
        SELECT RAISE(ABORT, 'forced void failure');
      END;
    ''');

    await expectLater(
      transactions.voidTransaction(
        VoidTransactionRequest(
          storeId: 'store-1',
          transactionId: receipt.transactionId,
          actorId: 'owner-1',
          reason: 'Pembatalan untuk uji rollback',
          clientMutationId: 'void-rollback',
        ),
      ),
      throwsA(anything),
    );

    expect((await products.getById('store-1', 'product-a'))?.stock, 4);
    expect((await products.getById('store-1', 'product-b'))?.stock, 4);
    final transaction = await database
        .select(database.salesTransactions)
        .getSingle();
    expect(transaction.status, TransactionStatus.success.name);
    expect(await database.select(database.transactionAudits).get(), isEmpty);
    final voidEntries = await (database.select(
      database.inventoryStockLedger,
    )..where((table) => table.action.equals('void'))).get();
    expect(voidEntries, isEmpty);
  });
}

ProductEntity _product(String id, {required int stock}) => ProductEntity(
  id: id,
  storeId: 'store-1',
  name: id,
  category: 'Tes',
  purchasePrice: 2000,
  sellingPrice: 4000,
  stock: stock,
  minimumStock: 1,
);
