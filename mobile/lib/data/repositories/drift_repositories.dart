import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../domain/entities/entities.dart';
import '../../domain/entities/store_layout_entities.dart';
import '../../domain/repositories/repositories.dart';
import '../../domain/usecases/checkout_calculator.dart';
import '../local/app_database.dart';

class DriftProductRepository implements ProductRepository {
  DriftProductRepository(
    this._database, {
    Uuid uuid = const Uuid(),
    DateTime Function()? clock,
  }) : _uuid = uuid,
       _clock = clock ?? DateTime.now;

  final AppDatabase _database;
  final Uuid _uuid;
  final DateTime Function() _clock;

  @override
  Stream<List<ProductEntity>> watchProducts(String storeId) {
    final query = _database.select(_database.products)
      ..where(
        (table) =>
            table.storeId.equals(storeId) &
            table.active.equals(true) &
            table.deletedAt.isNull(),
      )
      ..orderBy([(table) => OrderingTerm.asc(table.name)]);
    return query.watch().map((rows) => rows.map(_toDomain).toList());
  }

  @override
  Future<ProductEntity?> getById(String storeId, String productId) async {
    final query = _database.select(_database.products)
      ..where(
        (table) =>
            table.storeId.equals(storeId) &
            table.id.equals(productId) &
            table.active.equals(true) &
            table.deletedAt.isNull(),
      );
    return (await query.getSingleOrNull())?.let(_toDomain);
  }

  @override
  Future<ProductEntity?> getByAiLabel(String storeId, String label) async {
    final query = _database.select(_database.products)
      ..where(
        (table) =>
            table.storeId.equals(storeId) &
            table.aiLabel.equals(label) &
            table.active.equals(true) &
            table.deletedAt.isNull(),
      );
    return (await query.getSingleOrNull())?.let(_toDomain);
  }

  @override
  Future<ProductEntity?> getByBarcode(String storeId, String barcode) async {
    final query = _database.select(_database.products)
      ..where(
        (table) =>
            table.storeId.equals(storeId) &
            table.barcode.equals(barcode) &
            table.active.equals(true) &
            table.deletedAt.isNull(),
      );
    return (await query.getSingleOrNull())?.let(_toDomain);
  }

  @override
  Future<List<ProductEntity>> search(String storeId, String queryText) async {
    final normalized = normalizeForSearch(queryText).replaceAll('%', r'\%');
    final query = _database.select(_database.products)
      ..where(
        (table) =>
            table.storeId.equals(storeId) &
            table.normalizedName.like('%$normalized%') &
            table.active.equals(true) &
            table.deletedAt.isNull(),
      )
      ..orderBy([(table) => OrderingTerm.asc(table.name)])
      ..limit(25);
    return (await query.get()).map(_toDomain).toList();
  }

  @override
  Future<bool> isBarcodeAvailable(
    String storeId,
    String barcode, {
    String? excludingProductId,
  }) async {
    final normalized = barcode.trim();
    if (normalized.isEmpty) return true;
    final query = _database.select(_database.products)
      ..where((table) {
        var predicate =
            table.storeId.equals(storeId) &
            table.barcode.equals(normalized) &
            table.deletedAt.isNull();
        if (excludingProductId != null) {
          predicate = predicate & table.id.equals(excludingProductId).not();
        }
        return predicate;
      })
      ..limit(1);
    return await query.getSingleOrNull() == null;
  }

  @override
  Future<void> saveProduct(ProductEntity product) async {
    _validateProduct(product);
    final barcode = product.barcode?.trim();
    final normalizedBarcode = barcode == null || barcode.isEmpty
        ? null
        : barcode;
    final now = _clock();
    await _database.transaction(() async {
      final existing =
          await (_database.select(_database.products)..where(
                (table) =>
                    table.storeId.equals(product.storeId) &
                    table.id.equals(product.id),
              ))
              .getSingleOrNull();
      if (normalizedBarcode != null &&
          !await isBarcodeAvailable(
            product.storeId,
            normalizedBarcode,
            excludingProductId: product.id,
          )) {
        throw DuplicateProductBarcode(normalizedBarcode);
      }
      await _database
          .into(_database.products)
          .insertOnConflictUpdate(
            ProductsCompanion.insert(
              id: product.id,
              storeId: product.storeId,
              name: product.name.trim(),
              normalizedName: normalizeForSearch(product.name),
              category: product.category.trim(),
              purchasePrice: product.purchasePrice,
              sellingPrice: product.sellingPrice,
              stock: product.stock,
              minimumStock: product.minimumStock,
              leadTimeDays: Value(product.leadTimeDays),
              barcode: Value(normalizedBarcode),
              photoUri: Value(_nullIfBlank(product.photoUri)),
              shelfLocation: Value(_nullIfBlank(product.shelfLocation)),
              aiLabel: Value(_nullIfBlank(product.aiLabel)),
              active: const Value(true),
              updatedAt: now,
              deletedAt: const Value(null),
              syncState: const Value('pending'),
            ),
          );
      await _database
          .into(_database.syncOutbox)
          .insert(
            SyncOutboxCompanion.insert(
              id: _uuid.v4(),
              storeId: product.storeId,
              aggregateType: 'product',
              aggregateId: product.id,
              operation: 'upsert',
              payloadJson: jsonEncode(_productToJson(product, updatedAt: now)),
              createdAt: now,
            ),
          );
      final stockDelta = existing == null ? 0 : product.stock - existing.stock;
      if (stockDelta != 0) {
        final stockEventId = _uuid.v4();
        await _database
            .into(_database.syncOutbox)
            .insert(
              SyncOutboxCompanion.insert(
                id: stockEventId,
                storeId: product.storeId,
                aggregateType: 'productStock',
                aggregateId: product.id,
                operation: 'adjust',
                payloadJson: jsonEncode({
                  'productId': product.id,
                  'delta': stockDelta,
                  'transactionId': 'inventory-edit-$stockEventId',
                  'occurredAt': now.toUtc().toIso8601String(),
                }),
                createdAt: now,
              ),
            );
      }
    });
  }

  @override
  Future<void> deleteProduct(String storeId, String productId) async {
    final now = _clock();
    await _database.transaction(() async {
      final changed =
          await (_database.update(_database.products)..where(
                (table) =>
                    table.storeId.equals(storeId) & table.id.equals(productId),
              ))
              .write(
                ProductsCompanion(
                  active: const Value(false),
                  deletedAt: Value(now),
                  updatedAt: Value(now),
                  syncState: const Value('pending'),
                ),
              );
      if (changed == 0) throw ProductNotFound(productId);
      await _database
          .into(_database.syncOutbox)
          .insert(
            SyncOutboxCompanion.insert(
              id: _uuid.v4(),
              storeId: storeId,
              aggregateType: 'product',
              aggregateId: productId,
              operation: 'delete',
              payloadJson: jsonEncode({
                'id': productId,
                'storeId': storeId,
                'deletedAt': now.toUtc().toIso8601String(),
              }),
              createdAt: now,
            ),
          );
    });
  }
}

class DriftPredictionRepository implements PredictionRepository {
  DriftPredictionRepository(
    this._database, {
    Uuid uuid = const Uuid(),
    DateTime Function()? clock,
  }) : _uuid = uuid,
       _clock = clock ?? DateTime.now;

  final AppDatabase _database;
  final Uuid _uuid;
  final DateTime Function() _clock;

  @override
  Future<void> saveCorrection(PredictionCorrection correction) async {
    await _database
        .into(_database.predictions)
        .insert(
          PredictionsCompanion.insert(
            id: _uuid.v4(),
            storeId: correction.storeId,
            capturedAt: correction.capturedAt,
            aiLabel: Value(correction.initialLabel),
            confidence: Value(correction.initialConfidence),
            selectedProductId: Value(correction.selectedProductId),
            corrected: correction.corrected,
            correctionPhotoUri: Value(correction.correctionPhotoUri),
            cashierId: correction.cashierId,
            modelVersion: correction.modelVersion,
            consentToTraining: Value(correction.consentToTraining),
            updatedAt: _clock(),
          ),
        );
  }
}

class DriftStoreLayoutRepository implements StoreLayoutRepository {
  DriftStoreLayoutRepository(
    this._database, {
    Uuid uuid = const Uuid(),
    DateTime Function()? clock,
  }) : _uuid = uuid,
       _clock = clock ?? DateTime.now;

  final AppDatabase _database;
  final Uuid _uuid;
  final DateTime Function() _clock;

  @override
  Stream<StoreLayoutEntity?> watchLayout(String storeId) {
    final query = _database.select(_database.storeLayouts).join([
      leftOuterJoin(
        _database.storeFixtures,
        _database.storeFixtures.layoutId.equalsExp(_database.storeLayouts.id),
      ),
    ])..where(_database.storeLayouts.storeId.equals(storeId));

    return query.watch().map((rows) {
      if (rows.isEmpty) return null;
      final layout = rows.first.readTable(_database.storeLayouts);
      final fixtures = rows
          .map((row) => row.readTableOrNull(_database.storeFixtures))
          .whereType<StoreFixtureRow>()
          .map(_fixtureToDomain)
          .toList(growable: false);
      return StoreLayoutEntity(
        id: layout.id,
        storeId: layout.storeId,
        name: layout.name,
        canvasAspectRatio: layout.canvasAspectRatio,
        templateVersion: layout.templateVersion,
        fixtures: fixtures,
        updatedAt: layout.updatedAt,
      );
    });
  }

  @override
  Future<void> saveLayout(StoreLayoutEntity layout) async {
    _validateLayout(layout);
    final now = _clock();
    await _database.transaction(() async {
      await _database
          .into(_database.storeLayouts)
          .insertOnConflictUpdate(
            StoreLayoutsCompanion.insert(
              id: layout.id,
              storeId: layout.storeId,
              name: layout.name,
              canvasAspectRatio: layout.canvasAspectRatio,
              templateVersion: Value(layout.templateVersion),
              updatedAt: now,
              syncState: const Value('pending'),
            ),
          );

      await (_database.delete(
        _database.storeFixtures,
      )..where((table) => table.layoutId.equals(layout.id))).go();

      await _database.batch((batch) {
        batch.insertAll(
          _database.storeFixtures,
          layout.fixtures
              .map(
                (fixture) => StoreFixturesCompanion.insert(
                  id: fixture.id,
                  layoutId: layout.id,
                  storeId: layout.storeId,
                  type: fixture.type.name,
                  label: fixture.label,
                  x: fixture.x,
                  y: fixture.y,
                  fixtureWidth: fixture.width,
                  fixtureHeight: fixture.height,
                  rotationQuarterTurns: Value(fixture.rotationQuarterTurns),
                  productIdsJson: Value(jsonEncode(fixture.productIds)),
                  panoramaZoneId: Value(fixture.panoramaZoneId),
                  updatedAt: now,
                  syncState: const Value('pending'),
                ),
              )
              .toList(growable: false),
        );
      });

      await _database
          .into(_database.syncOutbox)
          .insert(
            SyncOutboxCompanion.insert(
              id: _uuid.v4(),
              storeId: layout.storeId,
              aggregateType: 'storeLayout',
              aggregateId: layout.id,
              operation: 'upsert',
              payloadJson: jsonEncode(_layoutToJson(layout, updatedAt: now)),
              createdAt: now,
            ),
          );
    });
  }
}

class DriftCheckoutRepository implements CheckoutRepository {
  DriftCheckoutRepository(
    this._database, {
    Uuid uuid = const Uuid(),
    DateTime Function()? clock,
  }) : _uuid = uuid,
       _clock = clock ?? DateTime.now;

  final AppDatabase _database;
  final Uuid _uuid;
  final DateTime Function() _clock;

  @override
  Future<CheckoutReceipt> checkout(CheckoutRequest request) async {
    if (request.storeId.trim().isEmpty || request.cashierId.trim().isEmpty) {
      throw ArgumentError('Toko dan kasir wajib diisi');
    }
    if (request.clientMutationId.trim().isEmpty || request.lines.isEmpty) {
      throw ArgumentError('Mutation ID dan keranjang wajib diisi');
    }
    final quantities = <String, int>{};
    for (final line in request.lines) {
      quantities.update(
        line.productId,
        (value) => value + line.quantity,
        ifAbsent: () => line.quantity,
      );
    }
    if (quantities.values.any((quantity) => quantity <= 0)) {
      throw ArgumentError('Jumlah barang harus lebih dari nol');
    }

    return _database.transaction(() async {
      final pricedLines = <CartLine>[];
      final productRows = <({ProductRow row, int quantity})>[];
      for (final entry in quantities.entries) {
        final query = _database.select(_database.products)
          ..where(
            (table) =>
                table.storeId.equals(request.storeId) &
                table.id.equals(entry.key) &
                table.active.equals(true) &
                table.deletedAt.isNull(),
          );
        final row = await query.getSingleOrNull();
        if (row == null) throw ProductNotFound(entry.key);
        if (row.stock < entry.value) {
          throw InsufficientStock(row.id, row.stock, entry.value);
        }
        productRows.add((row: row, quantity: entry.value));
        pricedLines.add(
          CartLine(product: _toDomain(row), quantity: entry.value),
        );
      }

      final totals = CheckoutCalculator.calculate(pricedLines);
      final received = switch (request.paymentType) {
        PaymentType.cash when request.receivedAmount < totals.total =>
          throw InsufficientPayment(totals.total, request.receivedAmount),
        PaymentType.cash => request.receivedAmount,
        PaymentType.qrisManual => totals.total,
      };
      final transactionId = _uuid.v4();
      final now = _clock();

      // Insert lebih dulu, lalu stok; semuanya baru terlihat setelah transaction commit.
      await _database
          .into(_database.salesTransactions)
          .insert(
            SalesTransactionsCompanion.insert(
              id: transactionId,
              storeId: request.storeId,
              clientMutationId: request.clientMutationId,
              occurredAt: now,
              totalAmount: totals.total,
              grossProfitAmount: totals.grossProfit,
              paymentMethod: request.paymentType.name,
              receivedAmount: received,
              changeAmount: received - totals.total,
              cashierId: request.cashierId,
              status: TransactionStatus.success.name,
              updatedAt: now,
            ),
          );

      await _database.batch((batch) {
        batch.insertAll(
          _database.transactionItems,
          productRows.map((item) {
            final subtotal = item.row.sellingPrice * item.quantity;
            final profit =
                (item.row.sellingPrice - item.row.purchasePrice) *
                item.quantity;
            return TransactionItemsCompanion.insert(
              transactionId: transactionId,
              productId: item.row.id,
              productNameSnapshot: item.row.name,
              quantity: item.quantity,
              purchasePriceSnapshot: item.row.purchasePrice,
              sellingPriceSnapshot: item.row.sellingPrice,
              subtotalAmount: subtotal,
              grossProfitAmount: profit,
            );
          }).toList(),
        );
      });

      for (final item in productRows) {
        final stockMutationId = _uuid.v4();
        final update = _database.update(_database.products)
          ..where(
            (table) =>
                table.storeId.equals(request.storeId) &
                table.id.equals(item.row.id) &
                table.stock.isBiggerOrEqualValue(item.quantity) &
                table.active.equals(true),
          );
        final changed = await update.write(
          ProductsCompanion(
            stock: Value(item.row.stock - item.quantity),
            updatedAt: Value(now),
            syncState: const Value('pending'),
          ),
        );
        if (changed != 1) throw ConcurrentStockChange(item.row.id);

        await _database
            .into(_database.inventoryStockLedger)
            .insert(
              InventoryStockLedgerCompanion.insert(
                id: stockMutationId,
                storeId: request.storeId,
                productId: item.row.id,
                transactionId: transactionId,
                delta: -item.quantity,
                action: 'sale',
                actorId: request.cashierId,
                reason: const Value(null),
                occurredAt: now,
              ),
            );

        await _database
            .into(_database.syncOutbox)
            .insert(
              SyncOutboxCompanion.insert(
                id: stockMutationId,
                storeId: request.storeId,
                aggregateType: 'productStock',
                aggregateId: item.row.id,
                operation: 'adjust',
                payloadJson: jsonEncode({
                  'productId': item.row.id,
                  'delta': -item.quantity,
                  'transactionId': transactionId,
                  'occurredAt': now.toUtc().toIso8601String(),
                }),
                createdAt: now,
              ),
            );
      }

      return CheckoutReceipt(
        transactionId: transactionId,
        totalAmount: totals.total,
        grossProfitAmount: totals.grossProfit,
        receivedAmount: received,
        changeAmount: received - totals.total,
        occurredAt: now,
      );
    });
  }
}

sealed class CheckoutFailure implements Exception {
  const CheckoutFailure(this.message);
  final String message;
  @override
  String toString() => message;
}

class ProductNotFound extends CheckoutFailure {
  ProductNotFound(String id) : super('Produk $id tidak ditemukan');
}

class InsufficientStock extends CheckoutFailure {
  InsufficientStock(String id, int available, int requested)
    : super('Stok produk $id hanya $available; diminta $requested');
}

class InsufficientPayment extends CheckoutFailure {
  InsufficientPayment(int total, int received)
    : super('Pembayaran Rp$received kurang dari total Rp$total');
}

class ConcurrentStockChange extends CheckoutFailure {
  ConcurrentStockChange(String id)
    : super('Stok produk $id berubah. Muat ulang keranjang.');
}

ProductEntity _toDomain(ProductRow row) => ProductEntity(
  id: row.id,
  storeId: row.storeId,
  name: row.name,
  category: row.category,
  purchasePrice: row.purchasePrice,
  sellingPrice: row.sellingPrice,
  stock: row.stock,
  minimumStock: row.minimumStock,
  leadTimeDays: row.leadTimeDays,
  barcode: row.barcode,
  photoUri: row.photoUri,
  shelfLocation: row.shelfLocation,
  aiLabel: row.aiLabel,
);

StoreFixture _fixtureToDomain(StoreFixtureRow row) => StoreFixture(
  id: row.id,
  type: StoreFixtureType.values.byName(row.type),
  label: row.label,
  x: row.x,
  y: row.y,
  width: row.fixtureWidth,
  height: row.fixtureHeight,
  rotationQuarterTurns: row.rotationQuarterTurns,
  productIds: (jsonDecode(row.productIdsJson) as List<dynamic>)
      .map((value) => value.toString())
      .toList(growable: false),
  panoramaZoneId: row.panoramaZoneId,
);

Map<String, Object?> _layoutToJson(
  StoreLayoutEntity layout, {
  required DateTime updatedAt,
}) => {
  'id': layout.id,
  'storeId': layout.storeId,
  'name': layout.name,
  'canvasAspectRatio': layout.canvasAspectRatio,
  'templateVersion': layout.templateVersion,
  'updatedAt': updatedAt.toUtc().toIso8601String(),
  'fixtures': layout.fixtures
      .map(
        (fixture) => {
          'id': fixture.id,
          'type': fixture.type.name,
          'label': fixture.label,
          'x': fixture.x,
          'y': fixture.y,
          'width': fixture.width,
          'height': fixture.height,
          'rotationQuarterTurns': fixture.rotationQuarterTurns,
          'productIds': fixture.productIds,
          'panoramaZoneId': fixture.panoramaZoneId,
        },
      )
      .toList(growable: false),
};

Map<String, Object?> _productToJson(
  ProductEntity product, {
  required DateTime updatedAt,
}) => {
  'id': product.id,
  'storeId': product.storeId,
  'name': product.name.trim(),
  'normalizedName': normalizeForSearch(product.name),
  'category': product.category.trim(),
  'purchasePrice': product.purchasePrice,
  'sellingPrice': product.sellingPrice,
  'stock': product.stock,
  'minimumStock': product.minimumStock,
  'leadTimeDays': product.leadTimeDays,
  'barcode': _nullIfBlank(product.barcode),
  'photoUri': _nullIfBlank(product.photoUri),
  'shelfLocation': _nullIfBlank(product.shelfLocation),
  'aiLabel': _nullIfBlank(product.aiLabel),
  'active': true,
  'updatedAt': updatedAt.toUtc().toIso8601String(),
};

void _validateProduct(ProductEntity product) {
  if (product.id.trim().isEmpty || product.storeId.trim().isEmpty) {
    throw ArgumentError('ID produk dan toko wajib diisi');
  }
  if (product.name.trim().isEmpty || product.category.trim().isEmpty) {
    throw ArgumentError('Nama dan kategori produk wajib diisi');
  }
  if (product.purchasePrice < 0 || product.sellingPrice <= 0) {
    throw ArgumentError('Harga produk tidak valid');
  }
  if (product.stock < 0 || product.minimumStock < 0) {
    throw ArgumentError('Stok produk tidak boleh negatif');
  }
  if (product.leadTimeDays < 1 || product.leadTimeDays > 365) {
    throw ArgumentError('Lead time harus 1 sampai 365 hari');
  }
}

String? _nullIfBlank(String? value) {
  final normalized = value?.trim();
  return normalized == null || normalized.isEmpty ? null : normalized;
}

void _validateLayout(StoreLayoutEntity layout) {
  if (layout.id.trim().isEmpty || layout.storeId.trim().isEmpty) {
    throw ArgumentError('ID layout dan toko wajib diisi');
  }
  final ids = <String>{};
  for (final fixture in layout.fixtures) {
    if (!ids.add(fixture.id)) {
      throw ArgumentError('ID fixture ${fixture.id} duplikat');
    }
    final validBounds =
        fixture.x >= 0 &&
        fixture.y >= 0 &&
        fixture.width > 0 &&
        fixture.height > 0 &&
        fixture.x + fixture.width <= 1.000001 &&
        fixture.y + fixture.height <= 1.000001;
    if (!validBounds) {
      throw ArgumentError('Fixture ${fixture.label} di luar batas denah');
    }
  }
}

String normalizeForSearch(String value) =>
    value.trim().toLowerCase().replaceAll(RegExp(r'\s+'), ' ');

extension _NullableLet<T> on T? {
  R? let<R>(R Function(T value) transform) {
    final value = this;
    return value == null ? null : transform(value);
  }
}
