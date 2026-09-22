import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ryangunshop/core/theme/app_theme.dart';
import 'package:ryangunshop/data/local/app_database.dart';
import 'package:ryangunshop/data/repositories/drift_inventory_planning_repository.dart';
import 'package:ryangunshop/data/repositories/drift_repositories.dart';
import 'package:ryangunshop/domain/entities/entities.dart';
import 'package:ryangunshop/domain/entities/inventory_planning_entities.dart';
import 'package:ryangunshop/domain/repositories/repositories.dart';
import 'package:ryangunshop/features/products/presentation/restock_recommendation_page.dart';

void main() {
  group('DriftInventoryPlanningRepository', () {
    late AppDatabase database;

    setUp(() => database = AppDatabase.forTesting(NativeDatabase.memory()));
    tearDown(() => database.close());

    test(
      'menghitung moving average, titik restok, dan jumlah pesanan',
      () async {
        final now = DateTime(2026, 9, 23, 12);
        final products = DriftProductRepository(database, clock: () => now);
        await products.saveProduct(
          const ProductEntity(
            id: 'coffee',
            storeId: 'store-1',
            name: 'Kopi sachet',
            category: 'Minuman',
            purchasePrice: 1000,
            sellingPrice: 2000,
            stock: 35,
            minimumStock: 3,
            leadTimeDays: 5,
          ),
        );
        await products.saveProduct(
          const ProductEntity(
            id: 'soap',
            storeId: 'store-1',
            name: 'Sabun batang',
            category: 'Perawatan diri',
            purchasePrice: 2000,
            sellingPrice: 3500,
            stock: 1,
            minimumStock: 4,
            leadTimeDays: 3,
          ),
        );
        final checkout = DriftCheckoutRepository(
          database,
          clock: () => now.subtract(const Duration(hours: 1)),
        );
        await checkout.checkout(
          const CheckoutRequest(
            storeId: 'store-1',
            cashierId: 'owner-1',
            lines: [CartLineRequest(productId: 'coffee', quantity: 28)],
            paymentType: PaymentType.cash,
            receivedAmount: 56000,
            clientMutationId: 'sale-1',
          ),
        );

        final result = await DriftInventoryPlanningRepository(
          database,
          clock: () => now,
        ).watchRecommendations(storeId: 'store-1').first;

        final coffee = result.singleWhere((item) => item.productId == 'coffee');
        expect(coffee.currentStock, 7);
        expect(coffee.averageDailySales, 1);
        expect(coffee.reorderPoint, 8);
        expect(coffee.suggestedOrderQuantity, 8);
        expect(coffee.needsRestock, isTrue);

        final soap = result.singleWhere((item) => item.productId == 'soap');
        expect(soap.hasSalesHistory, isFalse);
        expect(soap.reorderPoint, 4);
        expect(soap.suggestedOrderQuantity, 3);
      },
    );
  });

  testWidgets('halaman restok muat pada layar Android kecil', (tester) async {
    tester.view.physicalSize = const Size(360, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: RestockRecommendationPage(
          repository: const _PlanningFixtureRepository(),
          storeId: 'store-1',
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Rencana restok'), findsOneWidget);
    expect(find.text('Pesan 8'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

class _PlanningFixtureRepository implements InventoryPlanningRepository {
  const _PlanningFixtureRepository();

  @override
  Stream<List<RestockRecommendation>> watchRecommendations({
    required String storeId,
    int historyDays = 28,
    int reviewPeriodDays = 7,
  }) => Stream.value(const [
    RestockRecommendation(
      productId: 'coffee',
      productName: 'Kopi sachet',
      currentStock: 7,
      safetyStock: 3,
      leadTimeDays: 5,
      unitsSold: 28,
      historyDays: 28,
      averageDailySales: 1,
      reorderPoint: 8,
      suggestedOrderQuantity: 8,
    ),
  ]);
}
