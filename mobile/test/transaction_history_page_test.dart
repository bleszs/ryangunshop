import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ryangunshop/core/theme/app_theme.dart';
import 'package:ryangunshop/domain/entities/entities.dart';
import 'package:ryangunshop/domain/repositories/repositories.dart';
import 'package:ryangunshop/features/reports/presentation/transaction_history_page.dart';

void main() {
  testWidgets('owner dapat memberi alasan dan melakukan void dari riwayat', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(360, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final repository = _TransactionFixtureRepository();

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: TransactionHistoryPage(
          repository: repository,
          storeId: 'store-1',
          actorId: 'owner-1',
          canVoidTransactions: true,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Riwayat transaksi'), findsOneWidget);
    expect(find.text('Rp10.000'), findsOneWidget);
    await tester.tap(find.text('Rp10.000'));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('void-transaction-1')), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('void-transaction-1')));
    await tester.pumpAndSettle();
    expect(find.text('Batalkan transaksi?'), findsOneWidget);
    await tester.enterText(
      find.byKey(const ValueKey('void-reason')),
      'Barang dikembalikan pelanggan',
    );
    await tester.tap(find.byKey(const ValueKey('confirm-void')));
    await tester.pumpAndSettle();

    expect(repository.lastRequest?.transactionId, 'transaction-1');
    expect(repository.lastRequest?.actorId, 'owner-1');
    expect(repository.lastRequest?.reason, 'Barang dikembalikan pelanggan');
    expect(find.textContaining('2 unit kembali ke stok'), findsOneWidget);
    expect(tester.takeException(), equals(null));
  });
}

class _TransactionFixtureRepository implements TransactionManagementRepository {
  VoidTransactionRequest? lastRequest;

  @override
  Stream<List<TransactionEntity>> watchTransactions({
    required String storeId,
    int limit = 50,
  }) => Stream.value([
    TransactionEntity(
      id: 'transaction-1',
      storeId: storeId,
      occurredAt: DateTime(2026, 9, 22, 10),
      items: const [
        TransactionItemEntity(
          productId: 'coffee',
          productName: 'Kopi susu',
          quantity: 2,
          purchasePrice: 3000,
          sellingPrice: 5000,
        ),
      ],
      totalAmount: 10000,
      grossProfitAmount: 4000,
      paymentType: PaymentType.cash,
      receivedAmount: 10000,
      changeAmount: 0,
      cashierId: 'cashier-1',
      status: TransactionStatus.success,
    ),
  ]);

  @override
  Future<VoidTransactionResult> voidTransaction(
    VoidTransactionRequest request,
  ) async {
    lastRequest = request;
    return VoidTransactionResult(
      transactionId: request.transactionId,
      restoredUnits: 2,
      voidedAt: DateTime(2026, 9, 22, 11),
      alreadyProcessed: false,
    );
  }
}
