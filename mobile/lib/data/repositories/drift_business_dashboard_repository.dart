import 'package:drift/drift.dart';

import '../../domain/entities/dashboard_entities.dart';
import '../../domain/entities/entities.dart';
import '../../domain/repositories/repositories.dart';
import '../local/app_database.dart';

class DriftBusinessDashboardRepository implements BusinessDashboardRepository {
  const DriftBusinessDashboardRepository(this._database);

  final AppDatabase _database;

  @override
  Stream<BusinessDashboardSnapshot> watchSnapshot({
    required String storeId,
    required DateTime fromInclusive,
    required DateTime toExclusive,
  }) {
    final query = _database.customSelect(
      _dashboardSql,
      variables: [
        Variable.withString(storeId),
        Variable.withString(TransactionStatus.success.name),
        Variable.withDateTime(fromInclusive),
        Variable.withDateTime(toExclusive),
        Variable.withString(storeId),
      ],
      readsFrom: {
        _database.salesTransactions,
        _database.transactionItems,
        _database.products,
      },
    );
    return query.watch().map(_mapSnapshot);
  }

  BusinessDashboardSnapshot _mapSnapshot(List<QueryRow> rows) {
    final summary = rows.firstWhere(
      (row) => row.read<String>('row_type') == 'summary',
    );
    final sales = <ProductSalesMetric>[];
    final lowStock = <LowStockMetric>[];
    for (final row in rows) {
      if (row.read<String>('row_type') != 'product') continue;
      final productId = row.read<String>('product_id');
      final productName = row.read<String>('product_name');
      final stock = row.read<int>('stock');
      final minimumStock = row.read<int>('minimum_stock');
      sales.add(
        ProductSalesMetric(
          productId: productId,
          productName: productName,
          unitsSold: row.read<int>('units_sold'),
          revenue: row.read<int>('product_revenue'),
        ),
      );
      if (stock <= minimumStock) {
        lowStock.add(
          LowStockMetric(
            productId: productId,
            productName: productName,
            stock: stock,
            minimumStock: minimumStock,
            shelfLocation: row.readNullable<String>('shelf_location'),
          ),
        );
      }
    }
    lowStock.sort((a, b) {
      final byStock = a.stock.compareTo(b.stock);
      return byStock != 0 ? byStock : a.productName.compareTo(b.productName);
    });
    return BusinessDashboardSnapshot(
      totalRevenue: summary.read<int>('total_revenue'),
      grossProfit: summary.read<int>('total_profit'),
      transactionCount: summary.read<int>('transaction_count'),
      productSales: sales,
      lowStockProducts: lowStock,
    );
  }
}

const _dashboardSql = '''
WITH filtered_transactions AS (
  SELECT id, total_amount, gross_profit_amount
  FROM sales_transactions
  WHERE store_id = ?
    AND status = ?
    AND occurred_at >= ?
    AND occurred_at < ?
),
product_sales AS (
  SELECT
    items.product_id AS product_id,
    COALESCE(SUM(items.quantity), 0) AS units_sold,
    COALESCE(SUM(items.subtotal_amount), 0) AS product_revenue
  FROM transaction_items AS items
  INNER JOIN filtered_transactions AS transactions
    ON transactions.id = items.transaction_id
  GROUP BY items.product_id
)
SELECT
  'summary' AS row_type,
  NULL AS product_id,
  NULL AS product_name,
  NULL AS shelf_location,
  0 AS stock,
  0 AS minimum_stock,
  0 AS units_sold,
  0 AS product_revenue,
  COALESCE(SUM(total_amount), 0) AS total_revenue,
  COALESCE(SUM(gross_profit_amount), 0) AS total_profit,
  COUNT(*) AS transaction_count
FROM filtered_transactions
UNION ALL
SELECT
  'product' AS row_type,
  products.id AS product_id,
  products.name AS product_name,
  products.shelf_location AS shelf_location,
  products.stock AS stock,
  products.minimum_stock AS minimum_stock,
  COALESCE(product_sales.units_sold, 0) AS units_sold,
  COALESCE(product_sales.product_revenue, 0) AS product_revenue,
  0 AS total_revenue,
  0 AS total_profit,
  0 AS transaction_count
FROM products
LEFT JOIN product_sales ON product_sales.product_id = products.id
WHERE products.store_id = ?
  AND products.active = 1
  AND products.deleted_at IS NULL
''';
