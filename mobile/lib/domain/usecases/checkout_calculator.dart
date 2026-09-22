import '../entities/entities.dart';

class CheckoutTotals {
  const CheckoutTotals({required this.total, required this.grossProfit});
  final int total;
  final int grossProfit;
}

abstract final class CheckoutCalculator {
  static CheckoutTotals calculate(Iterable<CartLine> lines) {
    final snapshot = lines.toList(growable: false);
    if (snapshot.isEmpty) throw ArgumentError('Keranjang tidak boleh kosong');

    var total = 0;
    var grossProfit = 0;
    for (final line in snapshot) {
      if (line.quantity <= 0) {
        throw ArgumentError('Jumlah barang harus lebih dari nol');
      }
      if (line.product.purchasePrice < 0 || line.product.sellingPrice < 0) {
        throw ArgumentError('Harga tidak boleh negatif');
      }
      total += line.subtotal;
      grossProfit += line.grossProfit;
    }
    return CheckoutTotals(total: total, grossProfit: grossProfit);
  }
}
