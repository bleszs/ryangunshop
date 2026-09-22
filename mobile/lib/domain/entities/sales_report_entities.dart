import 'entities.dart';

class SalesReportData {
  const SalesReportData({
    required this.storeId,
    required this.fromInclusive,
    required this.toExclusive,
    required this.transactions,
  });

  final String storeId;
  final DateTime fromInclusive;
  final DateTime toExclusive;
  final List<TransactionEntity> transactions;

  int get totalRevenue => transactions.fold(
    0,
    (total, transaction) => total + transaction.totalAmount,
  );

  int get grossProfit => transactions.fold(
    0,
    (total, transaction) => total + transaction.grossProfitAmount,
  );

  int get totalItems => transactions.fold(
    0,
    (total, transaction) =>
        total + transaction.items.fold(0, (sum, item) => sum + item.quantity),
  );

  List<SalesReportProductSummary> get productSummary {
    final values = <String, SalesReportProductSummary>{};
    for (final transaction in transactions) {
      for (final item in transaction.items) {
        final current = values[item.productId];
        values[item.productId] = SalesReportProductSummary(
          productId: item.productId,
          productName: item.productName,
          quantity: (current?.quantity ?? 0) + item.quantity,
          revenue: (current?.revenue ?? 0) + item.subtotal,
          grossProfit:
              (current?.grossProfit ?? 0) +
              ((item.sellingPrice - item.purchasePrice) * item.quantity),
        );
      }
    }
    final result = values.values.toList()
      ..sort((a, b) {
        final byQuantity = b.quantity.compareTo(a.quantity);
        return byQuantity != 0
            ? byQuantity
            : a.productName.compareTo(b.productName);
      });
    return result;
  }
}

class SalesReportProductSummary {
  const SalesReportProductSummary({
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.revenue,
    required this.grossProfit,
  });

  final String productId;
  final String productName;
  final int quantity;
  final int revenue;
  final int grossProfit;
}
