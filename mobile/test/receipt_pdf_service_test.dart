import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:ryangunshop/domain/entities/entities.dart';
import 'package:ryangunshop/features/payment/application/receipt_pdf_service.dart';

void main() {
  test(
    'struk PDF tersimpan di direktori privat dengan snapshot transaksi',
    () async {
      final directory = await Directory.systemTemp.createTemp(
        'ryangunshop-receipt-',
      );
      addTearDown(() => directory.delete(recursive: true));
      final service = ReceiptPdfService(
        directoryProvider: () async => directory,
      );
      final checkout = CompletedCheckout(
        receipt: CheckoutReceipt(
          transactionId: 'trx/2026-09-20/001',
          totalAmount: 12500,
          grossProfitAmount: 3500,
          receivedAmount: 20000,
          changeAmount: 7500,
          occurredAt: DateTime(2026, 9, 20, 14, 35),
        ),
        storeId: 'store-1',
        cashierId: 'cashier-1',
        paymentType: PaymentType.cash,
        items: const [
          TransactionItemEntity(
            productId: 'product-1',
            productName: 'Kopi Susu',
            quantity: 2,
            purchasePrice: 3000,
            sellingPrice: 5000,
          ),
          TransactionItemEntity(
            productId: 'product-2',
            productName: 'Air Mineral',
            quantity: 1,
            purchasePrice: 1500,
            sellingPrice: 2500,
          ),
        ],
      );

      final file = await service.save(checkout);
      final bytes = await file.readAsBytes();

      expect(
        file.path,
        contains('${Platform.pathSeparator}receipts${Platform.pathSeparator}'),
      );
      expect(file.path, endsWith('struk_trx_2026-09-20_001.pdf'));
      expect(bytes.length, greaterThan(1000));
      expect(String.fromCharCodes(bytes.take(4)), '%PDF');
    },
  );
}
