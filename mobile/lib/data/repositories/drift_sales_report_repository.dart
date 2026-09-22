import 'package:drift/drift.dart';

import '../../domain/entities/entities.dart';
import '../../domain/entities/sales_report_entities.dart';
import '../../domain/repositories/repositories.dart';
import '../local/app_database.dart';

class DriftSalesReportRepository implements SalesReportRepository {
  const DriftSalesReportRepository(this._database);

  final AppDatabase _database;

  @override
  Future<SalesReportData> loadReport({
    required String storeId,
    required DateTime fromInclusive,
    required DateTime toExclusive,
  }) async {
    final transactionQuery = _database.select(_database.salesTransactions)
      ..where(
        (table) =>
            table.storeId.equals(storeId) &
            table.status.equals(TransactionStatus.success.name) &
            table.occurredAt.isBiggerOrEqualValue(fromInclusive) &
            table.occurredAt.isSmallerThanValue(toExclusive),
      )
      ..orderBy([(table) => OrderingTerm.desc(table.occurredAt)]);
    final transactionRows = await transactionQuery.get();
    if (transactionRows.isEmpty) {
      return SalesReportData(
        storeId: storeId,
        fromInclusive: fromInclusive,
        toExclusive: toExclusive,
        transactions: const [],
      );
    }

    final transactionIds = transactionRows.map((row) => row.id).toList();
    final itemQuery = _database.select(_database.transactionItems)
      ..where((table) => table.transactionId.isIn(transactionIds))
      ..orderBy([
        (table) => OrderingTerm.asc(table.transactionId),
        (table) => OrderingTerm.asc(table.productNameSnapshot),
      ]);
    final itemRows = await itemQuery.get();
    final itemsByTransaction = <String, List<TransactionItemEntity>>{};
    for (final item in itemRows) {
      itemsByTransaction
          .putIfAbsent(item.transactionId, () => [])
          .add(
            TransactionItemEntity(
              productId: item.productId,
              productName: item.productNameSnapshot,
              quantity: item.quantity,
              purchasePrice: item.purchasePriceSnapshot,
              sellingPrice: item.sellingPriceSnapshot,
            ),
          );
    }

    return SalesReportData(
      storeId: storeId,
      fromInclusive: fromInclusive,
      toExclusive: toExclusive,
      transactions: transactionRows
          .map(
            (row) => TransactionEntity(
              id: row.id,
              storeId: row.storeId,
              occurredAt: row.occurredAt,
              items: List.unmodifiable(itemsByTransaction[row.id] ?? const []),
              totalAmount: row.totalAmount,
              grossProfitAmount: row.grossProfitAmount,
              paymentType: PaymentType.values.byName(row.paymentMethod),
              receivedAmount: row.receivedAmount,
              changeAmount: row.changeAmount,
              cashierId: row.cashierId,
              status: TransactionStatus.values.byName(row.status),
            ),
          )
          .toList(growable: false),
    );
  }
}
