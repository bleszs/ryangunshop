import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

part 'app_database.g.dart';

@DataClassName('UserRow')
class Users extends Table {
  TextColumn get id => text()();
  TextColumn get storeId => text()();
  TextColumn get name => text()();
  TextColumn get email => text()();
  // Nullable untuk migrasi legacy. Jangan pernah simpan password plaintext.
  TextColumn get passwordHash => text().nullable()();
  TextColumn get role => text()();
  BoolColumn get active => boolean().withDefault(const Constant(true))();
  DateTimeColumn get updatedAt => dateTime()();
  TextColumn get syncState => text().withDefault(const Constant('pending'))();

  @override
  Set<Column<Object>> get primaryKey => {id};

  @override
  List<Set<Column<Object>>> get uniqueKeys => [
    {storeId, email},
  ];
}

@DataClassName('ProductRow')
class Products extends Table {
  TextColumn get id => text()();
  TextColumn get storeId => text()();
  TextColumn get name => text()();
  TextColumn get normalizedName => text()();
  TextColumn get category => text()();
  IntColumn get purchasePrice => integer()();
  IntColumn get sellingPrice => integer()();
  IntColumn get stock => integer()();
  IntColumn get minimumStock => integer()();
  IntColumn get leadTimeDays => integer().withDefault(const Constant(3))();
  TextColumn get barcode => text().nullable()();
  TextColumn get photoUri => text().nullable()();
  TextColumn get shelfLocation => text().nullable()();
  TextColumn get aiLabel => text().nullable()();
  BoolColumn get active => boolean().withDefault(const Constant(true))();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get deletedAt => dateTime().nullable()();
  TextColumn get syncState => text().withDefault(const Constant('pending'))();

  @override
  Set<Column<Object>> get primaryKey => {id};

  @override
  List<Set<Column<Object>>> get uniqueKeys => [
    {storeId, barcode},
    {storeId, aiLabel},
  ];
}

@DataClassName('TransactionRow')
class SalesTransactions extends Table {
  TextColumn get id => text()();
  TextColumn get storeId => text()();
  TextColumn get clientMutationId => text()();
  DateTimeColumn get occurredAt => dateTime()();
  IntColumn get totalAmount => integer()();
  IntColumn get grossProfitAmount => integer()();
  TextColumn get paymentMethod => text()();
  IntColumn get receivedAmount => integer()();
  IntColumn get changeAmount => integer()();
  TextColumn get cashierId => text()();
  TextColumn get status => text()();
  DateTimeColumn get updatedAt => dateTime()();
  TextColumn get syncState => text().withDefault(const Constant('pending'))();

  @override
  Set<Column<Object>> get primaryKey => {id};

  @override
  List<Set<Column<Object>>> get uniqueKeys => [
    {storeId, clientMutationId},
  ];
}

@DataClassName('TransactionItemRow')
class TransactionItems extends Table {
  TextColumn get transactionId =>
      text().references(SalesTransactions, #id, onDelete: KeyAction.cascade)();
  TextColumn get productId => text()();
  TextColumn get productNameSnapshot => text()();
  IntColumn get quantity => integer()();
  IntColumn get purchasePriceSnapshot => integer()();
  IntColumn get sellingPriceSnapshot => integer()();
  IntColumn get subtotalAmount => integer()();
  IntColumn get grossProfitAmount => integer()();

  @override
  Set<Column<Object>> get primaryKey => {transactionId, productId};
}

@DataClassName('PredictionRow')
class Predictions extends Table {
  TextColumn get id => text()();
  TextColumn get storeId => text()();
  DateTimeColumn get capturedAt => dateTime()();
  TextColumn get aiLabel => text().nullable()();
  RealColumn get confidence => real().nullable()();
  TextColumn get selectedProductId => text().nullable()();
  BoolColumn get corrected => boolean()();
  TextColumn get correctionPhotoUri => text().nullable()();
  TextColumn get cashierId => text()();
  TextColumn get modelVersion => text()();
  BoolColumn get consentToTraining =>
      boolean().withDefault(const Constant(false))();
  DateTimeColumn get updatedAt => dateTime()();
  TextColumn get syncState => text().withDefault(const Constant('pending'))();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DataClassName('StoreLayoutRow')
class StoreLayouts extends Table {
  TextColumn get id => text()();
  TextColumn get storeId => text()();
  TextColumn get name => text()();
  RealColumn get canvasAspectRatio => real()();
  IntColumn get templateVersion => integer().withDefault(const Constant(1))();
  DateTimeColumn get updatedAt => dateTime()();
  TextColumn get syncState => text().withDefault(const Constant('pending'))();

  @override
  Set<Column<Object>> get primaryKey => {id};

  @override
  List<Set<Column<Object>>> get uniqueKeys => [
    {storeId},
  ];
}

@DataClassName('StoreFixtureRow')
class StoreFixtures extends Table {
  TextColumn get id => text()();
  TextColumn get layoutId =>
      text().references(StoreLayouts, #id, onDelete: KeyAction.cascade)();
  TextColumn get storeId => text()();
  TextColumn get type => text()();
  TextColumn get label => text()();
  RealColumn get x => real()();
  RealColumn get y => real()();
  RealColumn get fixtureWidth => real()();
  RealColumn get fixtureHeight => real()();
  IntColumn get rotationQuarterTurns =>
      integer().withDefault(const Constant(0))();
  TextColumn get productIdsJson => text().withDefault(const Constant('[]'))();
  TextColumn get panoramaZoneId => text().nullable()();
  DateTimeColumn get updatedAt => dateTime()();
  TextColumn get syncState => text().withDefault(const Constant('pending'))();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DataClassName('SyncOutboxRow')
class SyncOutbox extends Table {
  TextColumn get id => text()();
  TextColumn get storeId => text()();
  TextColumn get aggregateType => text()();
  TextColumn get aggregateId => text()();
  TextColumn get operation => text()();
  TextColumn get payloadJson => text()();
  DateTimeColumn get createdAt => dateTime()();
  IntColumn get attemptCount => integer().withDefault(const Constant(0))();
  DateTimeColumn get nextAttemptAt => dateTime().nullable()();
  TextColumn get lastError => text().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DataClassName('InventoryStockLedgerRow')
class InventoryStockLedger extends Table {
  TextColumn get id => text()();
  TextColumn get storeId => text()();
  TextColumn get productId => text()();
  TextColumn get transactionId => text()();
  IntColumn get delta => integer()();
  TextColumn get action => text()();
  TextColumn get actorId => text()();
  TextColumn get reason => text().nullable()();
  DateTimeColumn get occurredAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DataClassName('TransactionAuditRow')
class TransactionAudits extends Table {
  TextColumn get id => text()();
  TextColumn get storeId => text()();
  TextColumn get transactionId => text()();
  TextColumn get mutationId => text()();
  TextColumn get action => text()();
  TextColumn get actorId => text()();
  TextColumn get reason => text()();
  DateTimeColumn get occurredAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {id};

  @override
  List<Set<Column<Object>>> get uniqueKeys => [
    {storeId, mutationId},
  ];
}

@DriftDatabase(
  tables: [
    Users,
    Products,
    SalesTransactions,
    TransactionItems,
    Predictions,
    StoreLayouts,
    StoreFixtures,
    SyncOutbox,
    InventoryStockLedger,
    TransactionAudits,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());
  AppDatabase.forTesting(super.executor);

  @override
  int get schemaVersion => 4;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (migrator) async => migrator.createAll(),
    onUpgrade: (migrator, from, to) async {
      if (from < 2) {
        await migrator.createTable(storeLayouts);
        await migrator.createTable(storeFixtures);
        await migrator.createTable(syncOutbox);
      }
      if (from < 3) {
        await migrator.createTable(inventoryStockLedger);
        await migrator.createTable(transactionAudits);
        final legacyTables = await customSelect(
          "SELECT name FROM sqlite_master WHERE type = 'table' "
          "AND name IN ('sales_transactions', 'transaction_items')",
        ).get();
        if (legacyTables.length == 2) {
          await customStatement('''
            INSERT INTO inventory_stock_ledger (
              id,
              store_id,
              product_id,
              transaction_id,
              delta,
              action,
              actor_id,
              reason,
              occurred_at
            )
            SELECT
              'legacy-sale-' || transactions.id || '-' || items.product_id,
              transactions.store_id,
              items.product_id,
              transactions.id,
              -items.quantity,
              'sale',
              transactions.cashier_id,
              'Backfill migration v3',
              transactions.occurred_at
            FROM transaction_items AS items
            INNER JOIN sales_transactions AS transactions
              ON transactions.id = items.transaction_id
            WHERE transactions.status = 'success'
          ''');
        }
      }
      if (from < 4) {
        final productTable = await customSelect(
          "SELECT name FROM sqlite_master WHERE type = 'table' "
          "AND name = 'products'",
        ).getSingleOrNull();
        if (productTable != null) {
          await migrator.addColumn(products, products.leadTimeDays);
        }
      }
    },
    beforeOpen: (details) async {
      await customStatement('PRAGMA foreign_keys = ON');
    },
  );
}

LazyDatabase _openConnection() => LazyDatabase(() async {
  final directory = await getApplicationDocumentsDirectory();
  final file = File(path.join(directory.path, 'ryangunshop.sqlite'));
  return NativeDatabase.createInBackground(file);
});
