class ProductSalesMetric {
  const ProductSalesMetric({
    required this.productId,
    required this.productName,
    required this.unitsSold,
    required this.revenue,
  });

  final String productId;
  final String productName;
  final int unitsSold;
  final int revenue;
}

class LowStockMetric {
  const LowStockMetric({
    required this.productId,
    required this.productName,
    required this.stock,
    required this.minimumStock,
    this.shelfLocation,
  });

  final String productId;
  final String productName;
  final int stock;
  final int minimumStock;
  final String? shelfLocation;
}

class BusinessDashboardSnapshot {
  const BusinessDashboardSnapshot({
    required this.totalRevenue,
    required this.grossProfit,
    required this.transactionCount,
    required this.productSales,
    required this.lowStockProducts,
  });

  const BusinessDashboardSnapshot.empty()
    : totalRevenue = 0,
      grossProfit = 0,
      transactionCount = 0,
      productSales = const [],
      lowStockProducts = const [];

  final int totalRevenue;
  final int grossProfit;
  final int transactionCount;
  final List<ProductSalesMetric> productSales;
  final List<LowStockMetric> lowStockProducts;

  int get averageTransaction =>
      transactionCount == 0 ? 0 : totalRevenue ~/ transactionCount;

  List<ProductSalesMetric> get bestSellingProducts {
    final values = productSales.where((item) => item.unitsSold > 0).toList()
      ..sort((a, b) {
        final byUnits = b.unitsSold.compareTo(a.unitsSold);
        return byUnits != 0 ? byUnits : b.revenue.compareTo(a.revenue);
      });
    return values;
  }

  List<ProductSalesMetric> get slowSellingProducts {
    final values = productSales.toList()
      ..sort((a, b) {
        final byUnits = a.unitsSold.compareTo(b.unitsSold);
        return byUnits != 0 ? byUnits : a.productName.compareTo(b.productName);
      });
    return values;
  }
}
