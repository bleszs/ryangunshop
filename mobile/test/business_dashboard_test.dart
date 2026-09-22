import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ryangunshop/core/theme/app_theme.dart';
import 'package:ryangunshop/data/local/app_database.dart';
import 'package:ryangunshop/data/repositories/drift_business_dashboard_repository.dart';
import 'package:ryangunshop/data/repositories/drift_repositories.dart';
import 'package:ryangunshop/data/repositories/drift_sales_report_repository.dart';
import 'package:ryangunshop/domain/entities/dashboard_entities.dart';
import 'package:ryangunshop/domain/entities/entities.dart';
import 'package:ryangunshop/domain/entities/store_layout_entities.dart';
import 'package:ryangunshop/domain/repositories/repositories.dart';
import 'package:ryangunshop/features/dashboard/presentation/store_dashboard_page.dart';
import 'package:ryangunshop/features/reports/presentation/business_dashboard_page.dart';

void main() {
  group('DriftBusinessDashboardRepository', () {
    late AppDatabase database;

    setUp(() => database = AppDatabase.forTesting(NativeDatabase.memory()));
    tearDown(() => database.close());

    test(
      'menghitung transaksi sukses, produk kurang laku, dan stok menipis',
      () async {
        final now = DateTime(2026, 9, 21, 10);
        final products = DriftProductRepository(database, clock: () => now);
        final checkout = DriftCheckoutRepository(database, clock: () => now);
        await products.saveProduct(
          const ProductEntity(
            id: 'water',
            storeId: 'store-1',
            name: 'Air mineral',
            category: 'Minuman',
            purchasePrice: 3000,
            sellingPrice: 5000,
            stock: 10,
            minimumStock: 2,
          ),
        );
        await products.saveProduct(
          const ProductEntity(
            id: 'snack',
            storeId: 'store-1',
            name: 'Keripik',
            category: 'Makanan',
            purchasePrice: 2000,
            sellingPrice: 4000,
            stock: 1,
            minimumStock: 2,
            shelfLocation: 'Rak B',
          ),
        );
        await products.saveProduct(
          const ProductEntity(
            id: 'other-product',
            storeId: 'other-store',
            name: 'Produk toko lain',
            category: 'Lainnya',
            purchasePrice: 1,
            sellingPrice: 100000,
            stock: 0,
            minimumStock: 10,
          ),
        );
        await checkout.checkout(
          const CheckoutRequest(
            storeId: 'store-1',
            cashierId: 'owner',
            lines: [CartLineRequest(productId: 'water', quantity: 2)],
            paymentType: PaymentType.cash,
            receivedAmount: 10000,
            clientMutationId: 'checkout-1',
          ),
        );
        await database
            .into(database.salesTransactions)
            .insert(
              SalesTransactionsCompanion.insert(
                id: 'cancelled',
                storeId: 'store-1',
                clientMutationId: 'cancelled-1',
                occurredAt: now,
                totalAmount: 999999,
                grossProfitAmount: 999999,
                paymentMethod: PaymentType.cash.name,
                receivedAmount: 999999,
                changeAmount: 0,
                cashierId: 'owner',
                status: TransactionStatus.cancelled.name,
                updatedAt: now,
              ),
            );

        final snapshot = await DriftBusinessDashboardRepository(database)
            .watchSnapshot(
              storeId: 'store-1',
              fromInclusive: DateTime(2026, 9, 21),
              toExclusive: DateTime(2026, 9, 22),
            )
            .first;

        expect(snapshot.totalRevenue, 10000);
        expect(snapshot.grossProfit, 4000);
        expect(snapshot.transactionCount, 1);
        expect(snapshot.bestSellingProducts.single.productId, 'water');
        expect(snapshot.bestSellingProducts.single.unitsSold, 2);
        expect(snapshot.slowSellingProducts.first.productId, 'snack');
        expect(snapshot.lowStockProducts.single.productId, 'snack');
        expect(
          snapshot.productSales.any(
            (item) => item.productId == 'other-product',
          ),
          isFalse,
        );

        final report = await DriftSalesReportRepository(database).loadReport(
          storeId: 'store-1',
          fromInclusive: DateTime(2026, 9, 21),
          toExclusive: DateTime(2026, 9, 22),
        );
        expect(report.transactions, hasLength(1));
        expect(report.transactions.single.status, TransactionStatus.success);
        expect(report.transactions.single.items.single.productId, 'water');
        expect(report.totalRevenue, 10000);
        expect(report.grossProfit, 4000);
      },
    );
  });

  testWidgets('dashboard laporan tetap muat pada layar Android kecil', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(360, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: const BusinessDashboardPage(
          repository: _DashboardFixtureRepository(),
          storeId: 'store-1',
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Ringkasan usaha'), findsOneWidget);
    expect(find.text('Rp125.000'), findsOneWidget);
    expect(find.text('Produk terlaris'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('Stok menipis'),
      300,
      scrollable: find.byType(Scrollable).last,
    );
    expect(find.text('Stok menipis'), findsOneWidget);
    expect(find.text('Rak A'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('Ekspor laporan'),
      300,
      scrollable: find.byType(Scrollable).last,
    );
    expect(find.text('Ekspor laporan'), findsOneWidget);
    expect(find.byKey(const ValueKey('export-report-pdf')), findsOneWidget);
    expect(find.byKey(const ValueKey('export-report-csv')), findsOneWidget);
    expect(tester.takeException(), equals(null));
  });

  testWidgets('menu Laporan membuka dashboard usaha', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: const StoreDashboardPage(
          layoutRepository: _EmptyLayoutRepository(),
          dashboardRepository: _DashboardFixtureRepository(),
          storeId: 'store-1',
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Laporan'));
    await tester.pumpAndSettle();

    expect(find.text('Ringkasan usaha'), findsOneWidget);
    expect(find.text('Rp125.000'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('open-transaction-history')));
    await tester.pumpAndSettle();
    expect(find.text('Riwayat transaksi'), findsOneWidget);
    expect(find.text('Belum ada transaksi'), findsOneWidget);
  });
}

class _DashboardFixtureRepository implements BusinessDashboardRepository {
  const _DashboardFixtureRepository();

  @override
  Stream<BusinessDashboardSnapshot> watchSnapshot({
    required String storeId,
    required DateTime fromInclusive,
    required DateTime toExclusive,
  }) => Stream.value(
    const BusinessDashboardSnapshot(
      totalRevenue: 125000,
      grossProfit: 42000,
      transactionCount: 8,
      productSales: [
        ProductSalesMetric(
          productId: 'water',
          productName: 'Air mineral',
          unitsSold: 12,
          revenue: 60000,
        ),
        ProductSalesMetric(
          productId: 'snack',
          productName: 'Keripik',
          unitsSold: 0,
          revenue: 0,
        ),
      ],
      lowStockProducts: [
        LowStockMetric(
          productId: 'snack',
          productName: 'Keripik',
          stock: 1,
          minimumStock: 3,
          shelfLocation: 'Rak A',
        ),
      ],
    ),
  );
}

class _EmptyLayoutRepository implements StoreLayoutRepository {
  const _EmptyLayoutRepository();

  @override
  Stream<StoreLayoutEntity?> watchLayout(String storeId) => Stream.value(null);

  @override
  Future<void> saveLayout(StoreLayoutEntity layout) async {}
}
