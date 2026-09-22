import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../domain/entities/entities.dart';
import '../../domain/repositories/repositories.dart';
import '../local/app_database.dart';

class DriftTransactionManagementRepository
    implements TransactionManagementRepository {
  DriftTransactionManagementRepository(
    this._database, {
    Uuid uuid = const Uuid(),
    DateTime Function()? clock,
  }) : _uuid = uuid,
       _clock = clock ?? DateTime.now;

  final AppDatabase _database;
  final Uuid _uuid;
  final DateTime Function() _clock;

  @override
  Stream<List<TransactionEntity>> watchTransactions({
    required String storeId,
    int limit = 50,
  }) {
    if (storeId.trim().isEmpty) {
      return Stream.error(ArgumentError('Store ID wajib diisi.'));
    }
    if (limit <= 0) {
      return Stream.error(ArgumentError.value(limit, 'limit'));
    }
    final query = _database.select(_database.salesTransactions)
      ..where((table) => table.storeId.equals(storeId))
      ..orderBy([(table) => OrderingTerm.desc(table.occurredAt)])
      ..limit(limit);
    return query.watch().asyncMap((transactions) async {
      if (transactions.isEmpty) return const <TransactionEntity>[];
      final ids = transactions.map((transaction) => transaction.id).toList();
      final itemQuery = _database.select(_database.transactionItems)
        ..where((table) => table.transactionId.isIn(ids))
        ..orderBy([(table) => OrderingTerm.asc(table.productNameSnapshot)]);
      final itemRows = await itemQuery.get();
      final itemsByTransaction = _groupItems(itemRows);
      return transactions
          .map(
            (row) => _transactionToDomain(
              row,
              itemsByTransaction[row.id] ?? const [],
            ),
          )
          .toList(growable: false);
    });
  }

  @override
  Future<VoidTransactionResult> voidTransaction(
    VoidTransactionRequest request,
  ) async {
    final storeId = request.storeId.trim();
    final transactionId = request.transactionId.trim();
    final actorId = request.actorId.trim();
    final reason = request.reason.trim();
    final mutationId = request.clientMutationId.trim();
    if (storeId.isEmpty || transactionId.isEmpty || actorId.isEmpty) {
      throw const InvalidVoidRequest('Toko, transaksi, dan aktor wajib diisi.');
    }
    if (reason.length < 5 || reason.length > 240) {
      throw const InvalidVoidRequest('Alasan pembatalan harus 5–240 karakter.');
    }
    if (mutationId.isEmpty) {
      throw const InvalidVoidRequest('Mutation ID wajib diisi.');
    }

    return _database.transaction(() async {
      final previousAudit =
          await (_database.select(_database.transactionAudits)..where(
                (table) =>
                    table.storeId.equals(storeId) &
                    table.mutationId.equals(mutationId),
              ))
              .getSingleOrNull();
      if (previousAudit != null) {
        if (previousAudit.transactionId != transactionId) {
          throw const VoidMutationConflict();
        }
        final restored = await _transactionQuantity(transactionId);
        return VoidTransactionResult(
          transactionId: transactionId,
          restoredUnits: restored,
          voidedAt: previousAudit.occurredAt,
          alreadyProcessed: true,
        );
      }

      final transaction =
          await (_database.select(_database.salesTransactions)..where(
                (table) =>
                    table.storeId.equals(storeId) &
                    table.id.equals(transactionId),
              ))
              .getSingleOrNull();
      if (transaction == null) throw TransactionNotFound(transactionId);
      if (transaction.status != TransactionStatus.success.name) {
        throw TransactionAlreadyVoided(transactionId);
      }

      final itemRows = await (_database.select(
        _database.transactionItems,
      )..where((table) => table.transactionId.equals(transactionId))).get();
      if (itemRows.isEmpty) throw TransactionItemsMissing(transactionId);
      final now = _clock();

      for (final item in itemRows) {
        final product =
            await (_database.select(_database.products)..where(
                  (table) =>
                      table.storeId.equals(storeId) &
                      table.id.equals(item.productId),
                ))
                .getSingleOrNull();
        if (product == null) throw VoidProductMissing(item.productId);

        final changed =
            await (_database.update(_database.products)..where(
                  (table) =>
                      table.storeId.equals(storeId) &
                      table.id.equals(item.productId),
                ))
                .write(
                  ProductsCompanion(
                    stock: Value(product.stock + item.quantity),
                    updatedAt: Value(now),
                    syncState: const Value('pending'),
                  ),
                );
        if (changed != 1) throw VoidConcurrentStockChange(item.productId);

        final stockMutationId = _uuid.v4();
        await _database
            .into(_database.inventoryStockLedger)
            .insert(
              InventoryStockLedgerCompanion.insert(
                id: stockMutationId,
                storeId: storeId,
                productId: item.productId,
                transactionId: transactionId,
                delta: item.quantity,
                action: 'void',
                actorId: actorId,
                reason: Value(reason),
                occurredAt: now,
              ),
            );
        await _database
            .into(_database.syncOutbox)
            .insert(
              SyncOutboxCompanion.insert(
                id: stockMutationId,
                storeId: storeId,
                aggregateType: 'productStock',
                aggregateId: item.productId,
                operation: 'adjust',
                payloadJson: jsonEncode({
                  'productId': item.productId,
                  'delta': item.quantity,
                  'transactionId': 'void-$transactionId',
                  'occurredAt': now.toUtc().toIso8601String(),
                }),
                createdAt: now,
              ),
            );
      }

      final transactionChanged =
          await (_database.update(_database.salesTransactions)..where(
                (table) =>
                    table.storeId.equals(storeId) &
                    table.id.equals(transactionId) &
                    table.status.equals(TransactionStatus.success.name),
              ))
              .write(
                SalesTransactionsCompanion(
                  status: Value(TransactionStatus.cancelled.name),
                  updatedAt: Value(now),
                  syncState: const Value('pending'),
                ),
              );
      if (transactionChanged != 1) {
        throw TransactionAlreadyVoided(transactionId);
      }

      await _database
          .into(_database.transactionAudits)
          .insert(
            TransactionAuditsCompanion.insert(
              id: _uuid.v4(),
              storeId: storeId,
              transactionId: transactionId,
              mutationId: mutationId,
              action: 'void',
              actorId: actorId,
              reason: reason,
              occurredAt: now,
            ),
          );

      return VoidTransactionResult(
        transactionId: transactionId,
        restoredUnits: itemRows.fold<int>(
          0,
          (sum, item) => sum + item.quantity,
        ),
        voidedAt: now,
        alreadyProcessed: false,
      );
    });
  }

  Future<int> _transactionQuantity(String transactionId) async {
    final rows = await (_database.select(
      _database.transactionItems,
    )..where((table) => table.transactionId.equals(transactionId))).get();
    return rows.fold<int>(0, (sum, item) => sum + item.quantity);
  }
}

Map<String, List<TransactionItemEntity>> _groupItems(
  List<TransactionItemRow> rows,
) {
  final result = <String, List<TransactionItemEntity>>{};
  for (final row in rows) {
    result
        .putIfAbsent(row.transactionId, () => [])
        .add(
          TransactionItemEntity(
            productId: row.productId,
            productName: row.productNameSnapshot,
            quantity: row.quantity,
            purchasePrice: row.purchasePriceSnapshot,
            sellingPrice: row.sellingPriceSnapshot,
          ),
        );
  }
  return result;
}

TransactionEntity _transactionToDomain(
  TransactionRow row,
  List<TransactionItemEntity> items,
) => TransactionEntity(
  id: row.id,
  storeId: row.storeId,
  occurredAt: row.occurredAt,
  items: List.unmodifiable(items),
  totalAmount: row.totalAmount,
  grossProfitAmount: row.grossProfitAmount,
  paymentType: PaymentType.values.byName(row.paymentMethod),
  receivedAmount: row.receivedAmount,
  changeAmount: row.changeAmount,
  cashierId: row.cashierId,
  status: TransactionStatus.values.byName(row.status),
);

sealed class VoidTransactionFailure implements Exception {
  const VoidTransactionFailure(this.message);
  final String message;

  @override
  String toString() => message;
}

class InvalidVoidRequest extends VoidTransactionFailure {
  const InvalidVoidRequest(super.message);
}

class TransactionNotFound extends VoidTransactionFailure {
  TransactionNotFound(String transactionId)
    : super('Transaksi $transactionId tidak ditemukan.');
}

class TransactionAlreadyVoided extends VoidTransactionFailure {
  TransactionAlreadyVoided(String transactionId)
    : super('Transaksi $transactionId sudah dibatalkan.');
}

class TransactionItemsMissing extends VoidTransactionFailure {
  TransactionItemsMissing(String transactionId)
    : super('Detail transaksi $transactionId tidak tersedia.');
}

class VoidProductMissing extends VoidTransactionFailure {
  VoidProductMissing(String productId)
    : super('Produk $productId tidak ditemukan untuk pengembalian stok.');
}

class VoidMutationConflict extends VoidTransactionFailure {
  const VoidMutationConflict()
    : super('Mutation ID sudah digunakan untuk transaksi lain.');
}

class VoidConcurrentStockChange extends VoidTransactionFailure {
  VoidConcurrentStockChange(String productId)
    : super('Stok produk $productId berubah saat pembatalan. Coba lagi.');
}
