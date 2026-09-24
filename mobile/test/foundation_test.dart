import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ryangunshop/core/camera/camera_permission_gateway.dart';
import 'package:ryangunshop/core/theme/app_theme.dart';
import 'package:ryangunshop/data/local/app_database.dart';
import 'package:ryangunshop/data/repositories/drift_repositories.dart';
import 'package:ryangunshop/domain/entities/entities.dart';
import 'package:ryangunshop/domain/entities/store_layout_entities.dart';
import 'package:ryangunshop/domain/repositories/repositories.dart';
import 'package:ryangunshop/domain/usecases/checkout_calculator.dart';
import 'package:ryangunshop/domain/usecases/product_recognition_coordinator.dart';
import 'package:ryangunshop/features/dashboard/application/store_layout_view_model.dart';
import 'package:ryangunshop/features/onboarding/data/onboarding_store.dart';
import 'package:ryangunshop/features/payment/presentation/cart_checkout_page.dart';
import 'package:ryangunshop/features/products/presentation/product_catalog_page.dart';
import 'package:ryangunshop/features/transaction/presentation/product_scanner_page.dart';
import 'package:ryangunshop/features/transaction/presentation/transaction_view_model.dart';
import 'package:ryangunshop/main.dart';

void main() {
  late AppDatabase database;
  late DriftStoreLayoutRepository layoutRepository;

  setUp(() {
    database = AppDatabase.forTesting(NativeDatabase.memory());
    layoutRepository = DriftStoreLayoutRepository(database);
  });

  tearDown(() => database.close());

  testWidgets('menampilkan dashboard denah warung', (tester) async {
    await tester.pumpWidget(
      RyanGunshopApp(
        layoutRepository: _MemoryStoreLayoutRepository(),
        onboardingStore: _MemoryOnboardingStore(completed: true),
      ),
    );
    expect(find.byKey(const ValueKey('splash-logo')), findsOneWidget);
    expect(find.text('Warung rapi, transaksi pasti.'), findsOneWidget);
    await tester.pump(const Duration(milliseconds: 1600));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('dashboard-logo')), findsOneWidget);
    expect(find.text('RyanGunshop'), findsOneWidget);
    expect(find.text('Mulai pindai'), findsOneWidget);
    await tester.drag(find.byType(ListView).first, const Offset(0, -360));
    await tester.pumpAndSettle();
    expect(find.text('Peta warung'), findsOneWidget);
    expect(find.text('Denah'), findsOneWidget);
    expect(find.text('Rak A'), findsOneWidget);
  });

  testWidgets('build rilis gagal tertutup saat autentikasi tidak tersedia', (
    tester,
  ) async {
    await tester.pumpWidget(
      RyanGunshopApp(
        layoutRepository: _MemoryStoreLayoutRepository(),
        onboardingStore: _MemoryOnboardingStore(completed: true),
        allowUnauthenticatedLocalMode: false,
      ),
    );
    await tester.pump(const Duration(milliseconds: 1600));
    await tester.pumpAndSettle();

    expect(find.text('Layanan akun belum tersedia'), findsOneWidget);
    expect(find.byKey(const ValueKey('dashboard-logo')), findsNothing);
  });

  testWidgets('onboarding dapat dilanjutkan dan dilewati', (tester) async {
    final onboardingStore = _MemoryOnboardingStore();
    await tester.pumpWidget(
      RyanGunshopApp(
        layoutRepository: _MemoryStoreLayoutRepository(),
        onboardingStore: onboardingStore,
      ),
    );
    await tester.pump(const Duration(milliseconds: 1600));
    await tester.pumpAndSettle();

    expect(find.text('Pindai barang, lanjut transaksi'), findsOneWidget);
    expect(find.text('Lewati'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('next-onboarding')));
    await tester.pumpAndSettle();
    expect(find.text('Susun warung sesuai tempatnya'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('skip-onboarding')));
    await tester.pumpAndSettle();
    await tester.drag(find.byType(ListView).first, const Offset(0, -360));
    await tester.pumpAndSettle();
    expect(find.text('Peta warung'), findsOneWidget);
    expect(onboardingStore.completed, isTrue);
  });

  testWidgets('onboarding tetap muat pada layar Android kecil', (tester) async {
    tester.view.physicalSize = const Size(360, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      RyanGunshopApp(
        layoutRepository: _MemoryStoreLayoutRepository(),
        onboardingStore: _MemoryOnboardingStore(),
      ),
    );
    await tester.pump(const Duration(milliseconds: 1600));
    await tester.pumpAndSettle();

    expect(find.text('Pindai barang, lanjut transaksi'), findsOneWidget);
    expect(tester.takeException(), equals(null));
  });

  testWidgets('owner dapat menautkan produk dari editor denah', (tester) async {
    await tester.pumpWidget(
      RyanGunshopApp(
        layoutRepository: _MemoryStoreLayoutRepository(),
        productRepository: _MemoryProductRepository(),
        canEditLayout: true,
        onboardingStore: _MemoryOnboardingStore(completed: true),
      ),
    );
    await tester.pump(const Duration(milliseconds: 1600));
    await tester.pumpAndSettle();

    await tester.drag(find.byType(ListView).first, const Offset(0, -360));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Atur'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Rak A'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Rak A'));
    await tester.pumpAndSettle();
    await tester.drag(find.byType(ListView).first, const Offset(0, -700));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Produk (0)'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Produk (0)'));
    await tester.pumpAndSettle();

    expect(find.text('Produk di Rak A'), findsOneWidget);
    expect(find.text('Air mineral 600 ml'), findsOneWidget);
    await tester.tap(find.text('Air mineral 600 ml'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Simpan 1 produk'));
    await tester.pumpAndSettle();

    expect(find.text('Produk (1)'), findsOneWidget);
  });

  testWidgets('katalog produk membuka formulir mobile dan menyimpan data', (
    tester,
  ) async {
    final repository = _MemoryProductRepository();
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: ProductCatalogPage(
          repository: repository,
          storeId: 'local-preview-store',
          canManageProducts: true,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Inventori lokal warung'), findsOneWidget);
    expect(find.text('Air mineral 600 ml'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('add-product')));
    await tester.pumpAndSettle();
    expect(find.text('Produk baru'), findsOneWidget);

    await tester.drag(find.byType(ListView).last, const Offset(0, -220));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const ValueKey('product-name')),
      'Kopi susu',
    );
    await tester.drag(find.byType(ListView).last, const Offset(0, -260));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const ValueKey('purchase-price')),
      '4000',
    );
    await tester.enterText(find.byKey(const ValueKey('selling-price')), '6000');
    await tester.tap(find.byKey(const ValueKey('save-product')));
    await tester.pumpAndSettle();

    expect(repository.savedProduct?.name, 'Kopi susu');
    expect(repository.savedProduct?.sellingPrice, 6000);
    expect(find.text('Inventori lokal warung'), findsOneWidget);
  });

  testWidgets(
    'scanner menangani izin kamera dan menyediakan pencarian manual',
    (tester) async {
      final products = _MemoryProductRepository();
      final transaction = TransactionViewModel(
        storeId: 'local-preview-store',
        cashierId: 'cashier-1',
        recognition: ProductRecognitionCoordinator(
          classifier: const _TestClassifier(),
          products: products,
          predictions: const _MemoryPredictionRepository(),
        ),
        barcodeScanner: const _MemoryBarcodeScanner(),
        products: products,
        checkoutRepository: const _MemoryCheckoutRepository(),
      );

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: ProductScannerPage(
            createViewModel: () async => transaction,
            permissionGateway: const _DeniedCameraPermissionGateway(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Izinkan akses kamera'), findsOneWidget);
      expect(find.text('Coba lagi'), findsOneWidget);
      expect(find.text('Cari produk manual'), findsOneWidget);

      await tester.tap(find.text('Cari produk manual'));
      await tester.pumpAndSettle();
      expect(find.text('Cari produk'), findsOneWidget);
      expect(
        find.text('Ketik nama produk untuk mulai mencari.'),
        findsOneWidget,
      );
    },
  );

  testWidgets('checkout tunai menghitung kembalian dan menyimpan transaksi', (
    tester,
  ) async {
    final checkout = _SuccessfulCheckoutRepository();
    final transaction = _buildTransactionViewModel(checkout);
    addTearDown(() async {
      await transaction.close();
      transaction.dispose();
    });
    transaction
      ..addToCart(_MemoryProductRepository.product)
      ..addToCart(_MemoryProductRepository.product);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: CartCheckoutPage(viewModel: transaction),
      ),
    );
    // Keep the initial pump bounded; no continuous animation is expected here.
    await tester.pump();

    expect(find.text('2 barang'), findsOneWidget);
    expect(find.text('Rp7.000'), findsWidgets);
    await tester.tap(find.byKey(const ValueKey('cash-preset-7000')));
    await tester.pump();
    await tester.tap(find.byKey(const ValueKey('submit-payment')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 250));

    expect(find.text('Pembayaran berhasil'), findsOneWidget);
    expect(checkout.lastRequest?.paymentType, PaymentType.cash);
    expect(checkout.lastRequest?.receivedAmount, 7000);
    expect(checkout.lastRequest?.lines.single.quantity, 2);
    expect(transaction.cart, isEmpty);
    expect(transaction.completedCheckout?.items.single.quantity, 2);
    expect(transaction.completedCheckout?.paymentType, PaymentType.cash);
    expect(find.text('Bagikan struk PDF'), findsOneWidget);
  });

  testWidgets('QRIS manual wajib diverifikasi kasir sebelum checkout', (
    tester,
  ) async {
    final checkout = _SuccessfulCheckoutRepository();
    final transaction = _buildTransactionViewModel(checkout)
      ..addToCart(_MemoryProductRepository.product);
    addTearDown(() async {
      await transaction.close();
      transaction.dispose();
    });

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: CartCheckoutPage(viewModel: transaction),
      ),
    );
    await tester.tap(find.text('QRIS'));
    await tester.pumpAndSettle();

    var submit = tester.widget<FilledButton>(
      find.byKey(const ValueKey('submit-payment')),
    );
    expect(submit.onPressed, equals(null));
    await tester.tap(find.byKey(const ValueKey('qris-verification')));
    await tester.pump();
    submit = tester.widget<FilledButton>(
      find.byKey(const ValueKey('submit-payment')),
    );
    expect(submit.onPressed, isNot(equals(null)));

    await tester.tap(find.byKey(const ValueKey('submit-payment')));
    await tester.pumpAndSettle();

    expect(find.text('Pembayaran berhasil'), findsOneWidget);
    expect(checkout.lastRequest?.paymentType, PaymentType.qrisManual);
    expect(checkout.lastRequest?.receivedAmount, 3500);
  });

  test('fixture tidak dapat keluar dari batas denah', () {
    final viewModel = StoreLayoutViewModel(
      repository: layoutRepository,
      storeId: 'store-1',
      canEditLayout: true,
    );
    viewModel.toggleEditing();
    viewModel.selectFixture('shelf-a');
    viewModel.moveFixture('shelf-a', 2, -2);

    final shelf = viewModel.selectedFixture!;
    expect(shelf.x, closeTo(1 - shelf.width, .0001));
    expect(shelf.y, 0);
    expect(viewModel.hasUnsavedChanges, isTrue);
  });

  test('dapat menambah objek dari template', () {
    final viewModel = StoreLayoutViewModel(
      repository: layoutRepository,
      storeId: 'store-1',
      canEditLayout: true,
    );
    viewModel.toggleEditing();
    final before = viewModel.fixtures.length;
    viewModel.addFixture(StoreFixtureType.display);

    expect(viewModel.fixtures.length, before + 1);
    expect(viewModel.selectedFixture?.type, StoreFixtureType.display);
  });

  test('editor mendukung rename, resize, duplikasi, hapus, dan undo', () {
    final repository = _MemoryStoreLayoutRepository();
    final viewModel = StoreLayoutViewModel(
      repository: repository,
      storeId: 'store-1',
      canEditLayout: true,
    );
    viewModel.toggleEditing();
    viewModel.selectFixture('shelf-a');
    final initialWidth = viewModel.selectedFixture!.width;

    viewModel.renameSelected('Rak minuman');
    viewModel.resizeSelected(.04);
    expect(viewModel.selectedFixture?.label, 'Rak minuman');
    expect(viewModel.selectedFixture!.width, greaterThan(initialWidth));

    final beforeDuplicate = viewModel.fixtures.length;
    viewModel.duplicateSelected();
    expect(viewModel.fixtures, hasLength(beforeDuplicate + 1));
    viewModel.deleteSelected();
    expect(viewModel.fixtures, hasLength(beforeDuplicate));
    viewModel.undo();
    expect(viewModel.fixtures, hasLength(beforeDuplicate + 1));
  });

  test('hanya owner yang dapat masuk dan memutasi mode edit', () {
    final viewModel = StoreLayoutViewModel(
      repository: layoutRepository,
      storeId: 'store-1',
    );
    final before = viewModel.fixtures.length;

    viewModel.toggleEditing();
    viewModel.addFixture(StoreFixtureType.display);

    expect(viewModel.isEditing, isFalse);
    expect(viewModel.fixtures, hasLength(before));
    expect(viewModel.errorMessage, contains('owner'));
  });

  test('owner dapat menautkan produk ke fixture dan mengurungkannya', () {
    final viewModel = StoreLayoutViewModel(
      repository: layoutRepository,
      storeId: 'store-1',
      canEditLayout: true,
    );
    viewModel.toggleEditing();
    viewModel.selectFixture('shelf-a');

    viewModel.setSelectedProductIds(['product-2', 'product-1', 'product-2']);
    expect(viewModel.selectedFixture?.productIds, ['product-1', 'product-2']);
    expect(viewModel.hasUnsavedChanges, isTrue);

    viewModel.undo();
    expect(viewModel.selectedFixture?.productIds, isEmpty);
  });

  test('view model menyimpan perubahan ke repository', () async {
    final repository = _MemoryStoreLayoutRepository();
    final viewModel = StoreLayoutViewModel(
      repository: repository,
      storeId: 'store-1',
      canEditLayout: true,
    );
    viewModel.toggleEditing();
    viewModel.selectFixture('shelf-a');
    viewModel.renameSelected('Rak kebutuhan harian');

    expect(await viewModel.saveLayout(), isTrue);
    expect(repository.layout?.storeId, 'store-1');
    expect(repository.layout?.fixtures.first.label, 'Meja kasir');
    expect(viewModel.hasUnsavedChanges, isFalse);
  });

  test('menyimpan dan membaca layout serta membuat outbox', () async {
    final updatedAt = DateTime.utc(2026, 9, 8);
    const fixture = StoreFixture(
      id: 'fixture-1',
      type: StoreFixtureType.refrigerator,
      label: 'Kulkas minuman',
      x: .1,
      y: .2,
      width: .25,
      height: .4,
      productIds: ['product-1'],
    );
    await layoutRepository.saveLayout(
      StoreLayoutEntity(
        id: 'layout-1',
        storeId: 'store-1',
        name: 'Layout utama',
        canvasAspectRatio: .78,
        templateVersion: 1,
        fixtures: const [fixture],
        updatedAt: updatedAt,
      ),
    );

    final saved = await layoutRepository.watchLayout('store-1').first;
    expect(saved?.fixtures.single.label, 'Kulkas minuman');
    expect(saved?.fixtures.single.productIds, ['product-1']);
    expect(await database.select(database.syncOutbox).get(), hasLength(1));
  });

  test('CRUD produk menjaga barcode unik dan menulis outbox', () async {
    final repository = DriftProductRepository(database);
    final product = ProductEntity(
      id: 'product-kopi',
      storeId: 'store-1',
      name: 'Kopi susu',
      category: 'Minuman',
      purchasePrice: 4000,
      sellingPrice: 6000,
      stock: 12,
      minimumStock: 3,
      barcode: '899100000001',
      shelfLocation: 'Rak A2',
    );

    await repository.saveProduct(product);
    final saved = await repository.watchProducts('store-1').first;
    expect(saved.single.name, 'Kopi susu');
    expect(saved.single.shelfLocation, 'Rak A2');

    final duplicate = ProductEntity(
      id: 'product-duplikat',
      storeId: 'store-1',
      name: 'Kopi lain',
      category: 'Minuman',
      purchasePrice: 3500,
      sellingPrice: 5500,
      stock: 5,
      minimumStock: 1,
      barcode: '899100000001',
    );
    await expectLater(
      repository.saveProduct(duplicate),
      throwsA(isA<DuplicateProductBarcode>()),
    );

    await repository.deleteProduct('store-1', product.id);
    expect(await repository.watchProducts('store-1').first, isEmpty);

    final events = await database.select(database.syncOutbox).get();
    expect(events, hasLength(2));
    expect(events.map((event) => event.operation).toSet(), {
      'upsert',
      'delete',
    });
  });

  test('checkout me-rollback stok dan transaksi saat update gagal', () async {
    final products = DriftProductRepository(database);
    final checkout = DriftCheckoutRepository(database);
    const productA = ProductEntity(
      id: 'rollback-a',
      storeId: 'store-rollback',
      name: 'Produk A',
      category: 'Tes',
      purchasePrice: 1000,
      sellingPrice: 2000,
      stock: 5,
      minimumStock: 1,
    );
    const productB = ProductEntity(
      id: 'rollback-b',
      storeId: 'store-rollback',
      name: 'Produk B',
      category: 'Tes',
      purchasePrice: 2000,
      sellingPrice: 3000,
      stock: 5,
      minimumStock: 1,
    );
    await products.saveProduct(productA);
    await products.saveProduct(productB);
    await database.customStatement('''
      CREATE TRIGGER force_second_stock_update_failure
      BEFORE UPDATE OF stock ON products
      WHEN NEW.id = 'rollback-b'
      BEGIN
        SELECT RAISE(ABORT, 'forced stock failure');
      END;
    ''');

    await expectLater(
      checkout.checkout(
        const CheckoutRequest(
          storeId: 'store-rollback',
          cashierId: 'cashier-test',
          lines: [
            CartLineRequest(productId: 'rollback-a', quantity: 1),
            CartLineRequest(productId: 'rollback-b', quantity: 1),
          ],
          paymentType: PaymentType.cash,
          receivedAmount: 5000,
          clientMutationId: 'rollback-mutation',
        ),
      ),
      throwsA(anything),
    );

    expect((await products.getById('store-rollback', 'rollback-a'))?.stock, 5);
    expect((await products.getById('store-rollback', 'rollback-b'))?.stock, 5);
    expect(await database.select(database.salesTransactions).get(), isEmpty);
    expect(await database.select(database.transactionItems).get(), isEmpty);
  });

  test(
    'migrasi versi 1 membuat tabel denah, outbox, ledger, dan audit',
    () async {
      await database.close();
      final tempDirectory = await Directory.systemTemp.createTemp(
        'ryangunshop_migration_',
      );
      final file = File('${tempDirectory.path}/migration.sqlite');
      final oldExecutor = NativeDatabase(file);
      await oldExecutor.ensureOpen(_VersionOneExecutorUser());
      await oldExecutor.runCustom('PRAGMA user_version = 1', const []);
      await oldExecutor.close();

      final migrated = AppDatabase.forTesting(NativeDatabase(file));
      addTearDown(() async {
        await migrated.close();
        await tempDirectory.delete(recursive: true);
      });

      final tables = await migrated
          .customSelect(
            "SELECT name FROM sqlite_master WHERE type = 'table' ORDER BY name",
          )
          .get();
      final names = tables.map((row) => row.read<String>('name')).toSet();
      expect(
        names,
        containsAll([
          'store_layouts',
          'store_fixtures',
          'sync_outbox',
          'inventory_stock_ledger',
          'transaction_audits',
        ]),
      );
    },
  );

  test('migrasi versi 2 membuat ledger penjualan lama', () async {
    final tempDirectory = await Directory.systemTemp.createTemp(
      'ryangunshop_v2_migration_',
    );
    final file = File('${tempDirectory.path}/migration.sqlite');
    final oldExecutor = NativeDatabase(file);
    await oldExecutor.ensureOpen(_VersionTwoExecutorUser());
    await oldExecutor.runCustom('''
      CREATE TABLE sales_transactions (
        id TEXT PRIMARY KEY NOT NULL,
        store_id TEXT NOT NULL,
        cashier_id TEXT NOT NULL,
        status TEXT NOT NULL,
        occurred_at INTEGER NOT NULL
      )
    ''', const []);
    await oldExecutor.runCustom('''
      CREATE TABLE transaction_items (
        transaction_id TEXT NOT NULL,
        product_id TEXT NOT NULL,
        quantity INTEGER NOT NULL
      )
    ''', const []);
    await oldExecutor.runCustom(
      "INSERT INTO sales_transactions VALUES "
      "('transaction-old', 'store-old', 'cashier-old', 'success', 1789990000)",
      const [],
    );
    await oldExecutor.runCustom(
      "INSERT INTO transaction_items VALUES "
      "('transaction-old', 'product-old', 3)",
      const [],
    );
    await oldExecutor.runCustom('PRAGMA user_version = 2', const []);
    await oldExecutor.close();

    final migrated = AppDatabase.forTesting(NativeDatabase(file));
    addTearDown(() async {
      await migrated.close();
      await tempDirectory.delete(recursive: true);
    });

    final ledger = await migrated
        .customSelect(
          'SELECT store_id, product_id, transaction_id, delta, action, '
          'actor_id, reason FROM inventory_stock_ledger',
        )
        .getSingle();
    expect(ledger.read<String>('store_id'), 'store-old');
    expect(ledger.read<String>('product_id'), 'product-old');
    expect(ledger.read<String>('transaction_id'), 'transaction-old');
    expect(ledger.read<int>('delta'), -3);
    expect(ledger.read<String>('action'), 'sale');
    expect(ledger.read<String>('actor_id'), 'cashier-old');
    expect(ledger.read<String>('reason'), 'Backfill migration v3');
  });

  test(
    'migrasi versi 3 menambah lead time produk dengan default aman',
    () async {
      final tempDirectory = await Directory.systemTemp.createTemp(
        'ryangunshop_v3_migration_',
      );
      final file = File('${tempDirectory.path}/migration.sqlite');
      final oldExecutor = NativeDatabase(file);
      await oldExecutor.ensureOpen(_VersionThreeExecutorUser());
      await oldExecutor.runCustom('''
      CREATE TABLE products (
        id TEXT PRIMARY KEY NOT NULL,
        store_id TEXT NOT NULL,
        name TEXT NOT NULL,
        normalized_name TEXT NOT NULL,
        category TEXT NOT NULL,
        purchase_price INTEGER NOT NULL,
        selling_price INTEGER NOT NULL,
        stock INTEGER NOT NULL,
        minimum_stock INTEGER NOT NULL,
        barcode TEXT,
        photo_uri TEXT,
        shelf_location TEXT,
        ai_label TEXT,
        active INTEGER NOT NULL DEFAULT 1,
        updated_at INTEGER NOT NULL,
        deleted_at INTEGER,
        sync_state TEXT NOT NULL DEFAULT 'pending'
      )
    ''', const []);
      await oldExecutor.runCustom('''
      INSERT INTO products (
        id, store_id, name, normalized_name, category, purchase_price,
        selling_price, stock, minimum_stock, updated_at
      ) VALUES (
        'legacy-product', 'store-1', 'Produk lama', 'produk lama', 'Lainnya',
        1000, 2000, 5, 2, 1789990000
      )
    ''', const []);
      await oldExecutor.runCustom('PRAGMA user_version = 3', const []);
      await oldExecutor.close();

      final migrated = AppDatabase.forTesting(NativeDatabase(file));
      addTearDown(() async {
        await migrated.close();
        await tempDirectory.delete(recursive: true);
      });

      final row = await migrated
          .customSelect(
            "SELECT lead_time_days FROM products WHERE id = 'legacy-product'",
          )
          .getSingle();
      expect(row.read<int>('lead_time_days'), 3);
    },
  );

  test('migrasi versi 4 menambah retention foto koreksi', () async {
    final tempDirectory = await Directory.systemTemp.createTemp(
      'ryangunshop_v4_migration_',
    );
    final file = File('${tempDirectory.path}/migration.sqlite');
    final oldExecutor = NativeDatabase(file);
    await oldExecutor.ensureOpen(_VersionFourExecutorUser());
    await oldExecutor.runCustom('''
      CREATE TABLE predictions (
        id TEXT PRIMARY KEY NOT NULL,
        store_id TEXT NOT NULL,
        captured_at INTEGER NOT NULL,
        ai_label TEXT,
        confidence REAL,
        selected_product_id TEXT,
        corrected INTEGER NOT NULL,
        correction_photo_uri TEXT,
        cashier_id TEXT NOT NULL,
        model_version TEXT NOT NULL,
        consent_to_training INTEGER NOT NULL DEFAULT 0,
        updated_at INTEGER NOT NULL,
        sync_state TEXT NOT NULL DEFAULT 'pending'
      )
    ''', const []);
    await oldExecutor.runCustom('PRAGMA user_version = 4', const []);
    await oldExecutor.close();

    final migrated = AppDatabase.forTesting(NativeDatabase(file));
    addTearDown(() async {
      await migrated.close();
      await tempDirectory.delete(recursive: true);
    });

    final columns = await migrated
        .customSelect('PRAGMA table_info(predictions)')
        .get();
    expect(
      columns.map((column) => column.read<String>('name')),
      contains('correction_photo_expires_at'),
    );
  });

  test('menghitung total dan laba dalam rupiah', () {
    const aqua = ProductEntity(
      id: 'aqua',
      storeId: 'store-1',
      name: 'Aqua',
      category: 'Minuman',
      purchasePrice: 3000,
      sellingPrice: 4000,
      stock: 10,
      minimumStock: 2,
    );
    const mie = ProductEntity(
      id: 'mie',
      storeId: 'store-1',
      name: 'Mi Instan',
      category: 'Makanan',
      purchasePrice: 8000,
      sellingPrice: 10000,
      stock: 10,
      minimumStock: 2,
    );

    final result = CheckoutCalculator.calculate(const [
      CartLine(product: aqua, quantity: 2),
      CartLine(product: mie, quantity: 1),
    ]);
    expect(result.total, 18000);
    expect(result.grossProfit, 4000);
  });

  test('menolak keranjang kosong', () {
    expect(() => CheckoutCalculator.calculate(const []), throwsArgumentError);
  });
}

class _MemoryStoreLayoutRepository implements StoreLayoutRepository {
  StoreLayoutEntity? layout;

  @override
  Future<void> saveLayout(StoreLayoutEntity layout) async {
    this.layout = layout;
  }

  @override
  Stream<StoreLayoutEntity?> watchLayout(String storeId) =>
      Stream.value(layout);
}

class _MemoryOnboardingStore implements OnboardingStore {
  _MemoryOnboardingStore({this.completed = false});

  bool completed;

  @override
  Future<bool> isCompleted() async => completed;

  @override
  Future<void> markCompleted() async => completed = true;
}

class _MemoryProductRepository implements ProductRepository {
  static const product = ProductEntity(
    id: 'product-1',
    storeId: 'local-preview-store',
    name: 'Air mineral 600 ml',
    category: 'Minuman',
    purchasePrice: 2500,
    sellingPrice: 3500,
    stock: 12,
    minimumStock: 3,
    barcode: '899000000001',
  );

  ProductEntity? savedProduct;

  @override
  Future<ProductEntity?> getByAiLabel(String storeId, String label) async =>
      null;

  @override
  Future<ProductEntity?> getByBarcode(String storeId, String barcode) async =>
      barcode == product.barcode ? product : null;

  @override
  Future<ProductEntity?> getById(String storeId, String productId) async =>
      productId == product.id ? product : null;

  @override
  Future<bool> isBarcodeAvailable(
    String storeId,
    String barcode, {
    String? excludingProductId,
  }) async => barcode != product.barcode || excludingProductId == product.id;

  @override
  Future<void> saveProduct(ProductEntity product) async {
    savedProduct = product;
  }

  @override
  Future<void> deleteProduct(String storeId, String productId) async {}

  @override
  Future<List<ProductEntity>> search(String storeId, String query) async => [
    product,
  ];

  @override
  Stream<List<ProductEntity>> watchProducts(String storeId) =>
      Stream.value(const [product]);
}

class _DeniedCameraPermissionGateway implements CameraPermissionGateway {
  const _DeniedCameraPermissionGateway();

  @override
  Future<bool> openSettings() async => false;

  @override
  Future<CameraPermissionState> request() async => CameraPermissionState.denied;
}

class _TestClassifier implements ProductClassifier {
  const _TestClassifier();

  @override
  Future<ClassificationResult> classify(RgbFrame frame) async =>
      const ClassificationResult(
        candidates: [],
        inferenceTime: Duration.zero,
        modelVersion: 'test-model',
      );

  @override
  Future<void> close() async {}
}

class _MemoryPredictionRepository implements PredictionRepository {
  const _MemoryPredictionRepository();

  @override
  Future<void> saveCorrection(PredictionCorrection correction) async {}
}

class _MemoryBarcodeScanner implements BarcodeScanner {
  const _MemoryBarcodeScanner();

  @override
  Future<void> close() async {}

  @override
  Future<String?> scanFile(String imagePath) async => null;
}

class _MemoryCheckoutRepository implements CheckoutRepository {
  const _MemoryCheckoutRepository();

  @override
  Future<CheckoutReceipt> checkout(CheckoutRequest request) {
    throw UnimplementedError();
  }
}

TransactionViewModel _buildTransactionViewModel(
  CheckoutRepository checkoutRepository,
) {
  final products = _MemoryProductRepository();
  return TransactionViewModel(
    storeId: 'local-preview-store',
    cashierId: 'cashier-1',
    recognition: ProductRecognitionCoordinator(
      classifier: const _TestClassifier(),
      products: products,
      predictions: const _MemoryPredictionRepository(),
    ),
    barcodeScanner: const _MemoryBarcodeScanner(),
    products: products,
    checkoutRepository: checkoutRepository,
  );
}

class _SuccessfulCheckoutRepository implements CheckoutRepository {
  CheckoutRequest? lastRequest;

  @override
  Future<CheckoutReceipt> checkout(CheckoutRequest request) async {
    lastRequest = request;
    final total = request.lines.fold<int>(
      0,
      (sum, line) => sum + (3500 * line.quantity),
    );
    return CheckoutReceipt(
      transactionId: 'transaction-1234',
      totalAmount: total,
      grossProfitAmount: request.lines.fold<int>(
        0,
        (sum, line) => sum + (1000 * line.quantity),
      ),
      receivedAmount: request.receivedAmount,
      changeAmount: request.receivedAmount - total,
      occurredAt: DateTime(2026, 9, 20),
    );
  }
}

class _VersionOneExecutorUser extends QueryExecutorUser {
  @override
  int get schemaVersion => 1;

  @override
  Future<void> beforeOpen(
    QueryExecutor executor,
    OpeningDetails details,
  ) async {}
}

class _VersionTwoExecutorUser extends QueryExecutorUser {
  @override
  int get schemaVersion => 2;

  @override
  Future<void> beforeOpen(
    QueryExecutor executor,
    OpeningDetails details,
  ) async {}
}

class _VersionThreeExecutorUser extends QueryExecutorUser {
  @override
  int get schemaVersion => 3;

  @override
  Future<void> beforeOpen(
    QueryExecutor executor,
    OpeningDetails details,
  ) async {}
}

class _VersionFourExecutorUser extends QueryExecutorUser {
  @override
  int get schemaVersion => 4;

  @override
  Future<void> beforeOpen(
    QueryExecutor executor,
    OpeningDetails details,
  ) async {}
}
