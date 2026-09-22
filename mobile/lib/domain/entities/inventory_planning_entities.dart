class RestockRecommendation {
  const RestockRecommendation({
    required this.productId,
    required this.productName,
    required this.currentStock,
    required this.safetyStock,
    required this.leadTimeDays,
    required this.unitsSold,
    required this.historyDays,
    required this.averageDailySales,
    required this.reorderPoint,
    required this.suggestedOrderQuantity,
  });

  final String productId;
  final String productName;
  final int currentStock;

  /// Stok minimum yang dipertahankan untuk meredam variasi permintaan.
  final int safetyStock;
  final int leadTimeDays;
  final int unitsSold;
  final int historyDays;
  final double averageDailySales;
  final int reorderPoint;
  final int suggestedOrderQuantity;

  bool get hasSalesHistory => unitsSold > 0;
  bool get needsRestock => currentStock <= reorderPoint;

  double? get estimatedDaysRemaining =>
      averageDailySales <= 0 ? null : currentStock / averageDailySales;
}
