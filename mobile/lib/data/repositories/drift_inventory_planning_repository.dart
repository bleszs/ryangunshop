import 'dart:math' as math;

import 'package:drift/drift.dart';

import '../../domain/entities/inventory_planning_entities.dart';
import '../../domain/repositories/repositories.dart';
import '../local/app_database.dart';

final class DriftInventoryPlanningRepository
    implements InventoryPlanningRepository {
  DriftInventoryPlanningRepository(this._database, {DateTime Function()? clock})
    : _clock = clock ?? DateTime.now;

  final AppDatabase _database;
  final DateTime Function() _clock;

  @override
  Stream<List<RestockRecommendation>> watchRecommendations({
    required String storeId,
    int historyDays = 28,
    int reviewPeriodDays = 7,
  }) {
    if (historyDays < 1 || reviewPeriodDays < 1) {
      throw ArgumentError('Periode perhitungan harus lebih dari nol');
    }
    final toExclusive = _clock();
    final fromInclusive = toExclusive.subtract(Duration(days: historyDays));
    final query = _database.customSelect(
      _query,
      variables: [
        Variable<String>(storeId),
        Variable<DateTime>(fromInclusive),
        Variable<DateTime>(toExclusive),
      ],
      readsFrom: {
        _database.products,
        _database.salesTransactions,
        _database.transactionItems,
      },
    );
    return query.watch().map(
      (rows) => _buildRecommendations(
        rows,
        historyDays: historyDays,
        reviewPeriodDays: reviewPeriodDays,
      ),
    );
  }

  List<RestockRecommendation> _buildRecommendations(
    List<QueryRow> rows, {
    required int historyDays,
    required int reviewPeriodDays,
  }) {
    final recommendations = rows
        .map((row) {
          final currentStock = row.read<int>('stock');
          final safetyStock = row.read<int>('minimum_stock');
          final leadTimeDays = row.read<int>('lead_time_days');
          final unitsSold = row.read<int>('units_sold');
          final averageDailySales = unitsSold / historyDays;
          final reorderPoint =
              (averageDailySales * leadTimeDays).ceil() + safetyStock;
          final targetStock = math.max(
            safetyStock,
            (averageDailySales * (leadTimeDays + reviewPeriodDays)).ceil() +
                safetyStock,
          );
          final suggestedOrderQuantity = currentStock <= reorderPoint
              ? math.max(0, targetStock - currentStock)
              : 0;
          return RestockRecommendation(
            productId: row.read<String>('product_id'),
            productName: row.read<String>('product_name'),
            currentStock: currentStock,
            safetyStock: safetyStock,
            leadTimeDays: leadTimeDays,
            unitsSold: unitsSold,
            historyDays: historyDays,
            averageDailySales: averageDailySales,
            reorderPoint: reorderPoint,
            suggestedOrderQuantity: suggestedOrderQuantity,
          );
        })
        .toList(growable: false);
    recommendations.sort((left, right) {
      final priority = right.suggestedOrderQuantity.compareTo(
        left.suggestedOrderQuantity,
      );
      return priority != 0
          ? priority
          : left.productName.compareTo(right.productName);
    });
    return recommendations;
  }

  static const _query = '''
SELECT
  products.id AS product_id,
  products.name AS product_name,
  products.stock AS stock,
  products.minimum_stock AS minimum_stock,
  products.lead_time_days AS lead_time_days,
  COALESCE(SUM(
    CASE WHEN sales.id IS NULL THEN 0 ELSE items.quantity END
  ), 0) AS units_sold
FROM products
LEFT JOIN transaction_items AS items
  ON items.product_id = products.id
LEFT JOIN sales_transactions AS sales
  ON sales.id = items.transaction_id
  AND sales.store_id = products.store_id
  AND sales.status = 'success'
  AND sales.occurred_at >= ?2
  AND sales.occurred_at < ?3
WHERE products.store_id = ?1
  AND products.active = 1
  AND products.deleted_at IS NULL
GROUP BY
  products.id,
  products.name,
  products.stock,
  products.minimum_stock,
  products.lead_time_days
''';
}
