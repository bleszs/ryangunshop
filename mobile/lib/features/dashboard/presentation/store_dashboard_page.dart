import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_loading.dart';
import '../../../core/widgets/ryan_app_logo.dart';
import '../../../domain/entities/entities.dart';
import '../../../domain/entities/store_layout_entities.dart';
import '../../../domain/repositories/repositories.dart';
import '../../payment/presentation/payment_preview_sheet.dart';
import '../../products/presentation/product_catalog_page.dart';
import '../../reports/presentation/business_dashboard_page.dart';
import '../../transaction/presentation/product_scanner_page.dart';
import '../application/store_layout_view_model.dart';
import '../application/store_panorama_controller.dart';
import 'widgets/store_floor_plan.dart';
import 'widgets/store_panorama_panel.dart';

class StoreDashboardPage extends StatelessWidget {
  const StoreDashboardPage({
    required this.layoutRepository,
    required this.storeId,
    this.dashboardRepository = const EmptyBusinessDashboardRepository(),
    this.salesReportRepository = const EmptySalesReportRepository(),
    this.transactionManagementRepository =
        const EmptyTransactionManagementRepository(),
    this.transactionActorId = 'local-owner',
    this.panoramaRepository = const EmptyPanoramaRepository(),
    this.productRepository,
    this.inventoryPlanningRepository,
    this.transactionViewModelFactory,
    this.accountName,
    this.accountRole,
    this.onSignOut,
    this.canEditLayout = false,
    super.key,
  });

  final StoreLayoutRepository layoutRepository;
  final BusinessDashboardRepository dashboardRepository;
  final SalesReportRepository salesReportRepository;
  final TransactionManagementRepository transactionManagementRepository;
  final String transactionActorId;
  final PanoramaRepository panoramaRepository;
  final ProductRepository? productRepository;
  final InventoryPlanningRepository? inventoryPlanningRepository;
  final TransactionViewModelFactory? transactionViewModelFactory;
  final String? accountName;
  final String? accountRole;
  final VoidCallback? onSignOut;
  final String storeId;
  final bool canEditLayout;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => StoreLayoutViewModel(
            repository: layoutRepository,
            storeId: storeId,
            canEditLayout: canEditLayout,
          )..initialize(),
        ),
        ChangeNotifierProvider(
          create: (_) => StorePanoramaController(
            repository: panoramaRepository,
            storeId: storeId,
          )..initialize(),
        ),
      ],
      child: _DashboardView(
        dashboardRepository: dashboardRepository,
        salesReportRepository: salesReportRepository,
        transactionManagementRepository: transactionManagementRepository,
        transactionActorId: transactionActorId,
        productRepository: productRepository,
        inventoryPlanningRepository: inventoryPlanningRepository,
        storeId: storeId,
        transactionViewModelFactory: transactionViewModelFactory,
        accountName: accountName,
        accountRole: accountRole,
        onSignOut: onSignOut,
      ),
    );
  }
}

class _DashboardView extends StatelessWidget {
  const _DashboardView({
    required this.dashboardRepository,
    required this.salesReportRepository,
    required this.transactionManagementRepository,
    required this.transactionActorId,
    required this.productRepository,
    required this.inventoryPlanningRepository,
    required this.storeId,
    required this.transactionViewModelFactory,
    required this.accountName,
    required this.accountRole,
    required this.onSignOut,
  });

  final BusinessDashboardRepository dashboardRepository;
  final SalesReportRepository salesReportRepository;
  final TransactionManagementRepository transactionManagementRepository;
  final String transactionActorId;
  final ProductRepository? productRepository;
  final InventoryPlanningRepository? inventoryPlanningRepository;
  final String storeId;
  final TransactionViewModelFactory? transactionViewModelFactory;
  final String? accountName;
  final String? accountRole;
  final VoidCallback? onSignOut;

  @override
  Widget build(BuildContext context) {
    final layout = context.watch<StoreLayoutViewModel>();
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 72,
        leadingWidth: 68,
        leading: const Padding(
          padding: EdgeInsets.only(left: 16),
          child: Center(
            child: RyanAppLogo(
              key: ValueKey('dashboard-logo'),
              size: 42,
              cacheSize: 128,
            ),
          ),
        ),
        titleSpacing: 8,
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'RyanGunshop',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
            ),
            Text(
              'Warung utama',
              style: TextStyle(
                fontSize: 12,
                color: AppColors.muted,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        actions: [
          const _SyncStatus(),
          IconButton(
            tooltip: onSignOut == null ? 'Pengaturan warung' : 'Akun',
            onPressed: onSignOut == null
                ? () => _showComingSoon(context, 'Pengaturan warung')
                : () => _showAccountSheet(
                    context,
                    accountName: accountName ?? 'Pengguna',
                    accountRole: accountRole ?? 'cashier',
                    onSignOut: onSignOut!,
                  ),
            icon: const Icon(Icons.account_circle_outlined),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: layout.isLoading
          ? const AppLoadingView(label: 'Memuat tata letak…')
          : _DashboardContent(
              layout: layout,
              productRepository: productRepository,
              inventoryPlanningRepository: inventoryPlanningRepository,
              storeId: storeId,
              transactionViewModelFactory: transactionViewModelFactory,
            ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: 0,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.storefront_outlined),
            label: 'Warung',
          ),
          NavigationDestination(
            icon: Icon(Icons.shopping_cart_outlined),
            label: 'Kasir',
          ),
          NavigationDestination(
            icon: Icon(Icons.inventory_2_outlined),
            label: 'Produk',
          ),
          NavigationDestination(
            icon: Icon(Icons.bar_chart_outlined),
            label: 'Laporan',
          ),
        ],
        onDestinationSelected: (index) {
          if (index == 1) {
            PaymentPreviewSheet.show(
              context,
              onScan: () => _openScanner(context, transactionViewModelFactory),
            );
          } else if (index == 2) {
            _openProducts(
              context,
              productRepository,
              inventoryPlanningRepository,
              storeId,
              layout.canEditLayout,
            );
          } else if (index == 3) {
            Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => BusinessDashboardPage(
                  repository: dashboardRepository,
                  reportRepository: salesReportRepository,
                  transactionRepository: transactionManagementRepository,
                  storeId: storeId,
                  actorId: transactionActorId,
                  canVoidTransactions: layout.canEditLayout,
                ),
              ),
            );
          }
        },
      ),
    );
  }
}

class _DashboardContent extends StatelessWidget {
  const _DashboardContent({
    required this.layout,
    required this.productRepository,
    required this.inventoryPlanningRepository,
    required this.storeId,
    required this.transactionViewModelFactory,
  });

  final StoreLayoutViewModel layout;
  final ProductRepository? productRepository;
  final InventoryPlanningRepository? inventoryPlanningRepository;
  final String storeId;
  final TransactionViewModelFactory? transactionViewModelFactory;

  @override
  Widget build(BuildContext context) {
    final panorama = context.watch<StorePanoramaController>();
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
      children: [
        const Text(
          'Warung siap\nmelayani.',
          style: AppTextStyles.editorialDisplay,
        ),
        const SizedBox(height: 8),
        const Text(
          'Kelola transaksi, stok, dan tata letak dari satu tempat.',
          style: TextStyle(color: AppColors.muted, height: 1.4),
        ),
        const SizedBox(height: 20),
        _TransactionHero(
          onScan: () => _openScanner(context, transactionViewModelFactory),
        ),
        const SizedBox(height: 12),
        _QuickActionBar(
          onCashier: () => PaymentPreviewSheet.show(
            context,
            onScan: () => _openScanner(context, transactionViewModelFactory),
          ),
          onProducts: () => _openProducts(
            context,
            productRepository,
            inventoryPlanningRepository,
            storeId,
            layout.canEditLayout,
          ),
          onLayout: layout.toggleEditing,
        ),
        const SizedBox(height: 32),
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Peta warung', style: AppTextStyles.editorialTitle),
                  const SizedBox(height: 3),
                  const Text(
                    'Temukan dan susun lokasi barang.',
                    style: TextStyle(color: AppColors.muted),
                  ),
                ],
              ),
            ),
            Tooltip(
              message: layout.canEditLayout
                  ? 'Atur tata letak warung'
                  : 'Hanya owner yang dapat mengatur denah',
              child: TextButton.icon(
                onPressed:
                    layout.viewMode == StoreViewMode.floorPlan &&
                        layout.canEditLayout
                    ? layout.toggleEditing
                    : null,
                icon: Icon(
                  layout.isEditing ? Icons.check_rounded : Icons.tune_rounded,
                ),
                label: Text(layout.isEditing ? 'Selesai' : 'Atur'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        SegmentedButton<StoreViewMode>(
          segments: const [
            ButtonSegment(
              value: StoreViewMode.floorPlan,
              icon: Icon(Icons.grid_view_rounded),
              label: Text('Denah'),
            ),
            ButtonSegment(
              value: StoreViewMode.panorama,
              icon: Icon(Icons.threesixty_rounded),
              label: Text('360°'),
            ),
          ],
          selected: {layout.viewMode},
          onSelectionChanged: (value) => layout.setViewMode(value.first),
        ),
        const SizedBox(height: 12),
        if (layout.isEditing) const _EditingNotice(),
        if (layout.errorMessage case final message?)
          _ErrorNotice(message: message, onRetry: layout.initialize),
        AnimatedSwitcher(
          duration: MediaQuery.disableAnimationsOf(context)
              ? Duration.zero
              : const Duration(milliseconds: 220),
          switchInCurve: Curves.easeOutCubic,
          transitionBuilder: (child, animation) => FadeTransition(
            opacity: animation,
            child: ScaleTransition(
              scale: Tween<double>(begin: .985, end: 1).animate(animation),
              child: child,
            ),
          ),
          child: layout.viewMode == StoreViewMode.floorPlan
              ? StoreFloorPlan(
                  key: const ValueKey('floor-plan'),
                  fixtures: layout.fixtures,
                  isEditing: layout.isEditing,
                  selectedFixtureId: layout.selectedFixture?.id,
                  onFixtureSelected: layout.selectFixture,
                  onFixtureMoveStarted: layout.beginFixtureMove,
                  onFixtureMoved: layout.moveFixture,
                )
              : StorePanoramaPanel(
                  key: const ValueKey('panorama'),
                  controller: panorama,
                  fixtures: layout.fixtures,
                  canManage: layout.canEditLayout,
                  onFixtureSelected: layout.selectFixture,
                ),
        ),
        const SizedBox(height: 14),
        if (layout.isEditing)
          _EditorActions(
            layout: layout,
            productRepository: productRepository,
            storeId: storeId,
          )
        else if (layout.selectedFixture case final selected?)
          _FixtureSummary(fixture: selected),
      ],
    );
  }
}

class _TransactionHero extends StatelessWidget {
  const _TransactionHero({required this.onScan});
  final VoidCallback onScan;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.slate800,
        borderRadius: BorderRadius.circular(AppRadii.hero),
      ),
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Transaksi lebih cepat',
                    style: TextStyle(
                      fontFamily: 'serif',
                      color: Colors.white,
                      fontSize: 25,
                      height: 1.1,
                      letterSpacing: -.35,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 7),
                  const Text(
                    'Pindai barang, konfirmasi, lalu bayar.',
                    style: TextStyle(color: AppColors.slate200, height: 1.4),
                  ),
                  const SizedBox(height: 18),
                  FilledButton.icon(
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: AppColors.slate800,
                    ),
                    onPressed: onScan,
                    icon: const Icon(Icons.qr_code_scanner_rounded),
                    label: const Text('Mulai pindai'),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            const DecoratedBox(
              decoration: BoxDecoration(
                color: Color(0xFF44497E),
                borderRadius: BorderRadius.all(Radius.circular(16)),
              ),
              child: SizedBox.square(
                dimension: 76,
                child: Icon(
                  Icons.point_of_sale_rounded,
                  color: AppColors.slate200,
                  size: 42,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickActionBar extends StatelessWidget {
  const _QuickActionBar({
    required this.onCashier,
    required this.onProducts,
    required this.onLayout,
  });
  final VoidCallback onCashier;
  final VoidCallback onProducts;
  final VoidCallback onLayout;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 136,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            flex: 6,
            child: _QuickAction(
              icon: Icons.shopping_bag_outlined,
              label: 'Kasir',
              description: 'Cek keranjang\n& pembayaran',
              onTap: onCashier,
              emphasized: true,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 5,
            child: Column(
              children: [
                Expanded(
                  child: _QuickAction(
                    icon: Icons.inventory_2_outlined,
                    label: 'Produk',
                    onTap: onProducts,
                    compact: true,
                  ),
                ),
                const SizedBox(height: 10),
                Expanded(
                  child: _QuickAction(
                    icon: Icons.space_dashboard_outlined,
                    label: 'Tata letak',
                    onTap: onLayout,
                    compact: true,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  const _QuickAction({
    required this.icon,
    required this.label,
    required this.onTap,
    this.description,
    this.emphasized = false,
    this.compact = false,
  });
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final String? description;
  final bool emphasized;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final foreground = emphasized ? Colors.white : AppColors.ink;
    return Material(
      color: emphasized ? AppColors.slate600 : AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadii.surface),
        side: emphasized
            ? BorderSide.none
            : const BorderSide(color: AppColors.outline),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: compact ? 14 : 16,
            vertical: compact ? 10 : 14,
          ),
          child: compact
              ? Row(
                  children: [
                    Icon(icon, size: 21, color: AppColors.slate600),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        label,
                        maxLines: 1,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const Icon(
                      Icons.arrow_forward_rounded,
                      size: 18,
                      color: AppColors.muted,
                    ),
                  ],
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(icon, color: foreground, size: 26),
                    const Spacer(),
                    Text(
                      label,
                      style: TextStyle(
                        color: foreground,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    if (description != null) ...[
                      const SizedBox(height: 3),
                      Text(
                        description!,
                        style: const TextStyle(
                          color: AppColors.slate100,
                          fontSize: 11,
                          height: 1.25,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ],
                ),
        ),
      ),
    );
  }
}

class _SyncStatus extends StatelessWidget {
  const _SyncStatus();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 12),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: AppColors.slate100,
          borderRadius: BorderRadius.all(Radius.circular(20)),
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 10),
          child: Row(
            children: [
              Icon(
                Icons.cloud_done_outlined,
                size: 16,
                color: AppColors.success,
              ),
              SizedBox(width: 5),
              Text(
                'Lokal',
                style: TextStyle(
                  color: AppColors.slate700,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EditingNotice extends StatelessWidget {
  const _EditingNotice();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Icon(Icons.open_with, size: 18, color: AppTheme.primary),
          SizedBox(width: 8),
          Expanded(
            child: Text('Geser objek untuk menyesuaikan posisi di warung.'),
          ),
        ],
      ),
    );
  }
}

class _ErrorNotice extends StatelessWidget {
  const _ErrorNotice({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.errorContainer,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            children: [
              Icon(
                Icons.error_outline,
                color: Theme.of(context).colorScheme.onErrorContainer,
              ),
              const SizedBox(width: 8),
              Expanded(child: Text(message)),
              TextButton(onPressed: onRetry, child: const Text('Coba lagi')),
            ],
          ),
        ),
      ),
    );
  }
}

class _EditorActions extends StatelessWidget {
  const _EditorActions({
    required this.layout,
    required this.productRepository,
    required this.storeId,
  });

  final StoreLayoutViewModel layout;
  final ProductRepository? productRepository;
  final String storeId;

  @override
  Widget build(BuildContext context) {
    final hasSelection = layout.selectedFixture != null;
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        OutlinedButton.icon(
          onPressed: () => _showFixturePicker(context, layout),
          icon: const Icon(Icons.add),
          label: const Text('Tambah objek'),
        ),
        IconButton.outlined(
          tooltip: 'Ubah nama',
          onPressed: hasSelection
              ? () => _renameFixture(context, layout)
              : null,
          icon: const Icon(Icons.drive_file_rename_outline),
        ),
        OutlinedButton.icon(
          onPressed: hasSelection && productRepository != null
              ? () => _showProductLinker(
                  context,
                  layout,
                  productRepository!,
                  storeId,
                )
              : null,
          icon: const Icon(Icons.link_rounded),
          label: Text(
            hasSelection
                ? 'Produk (${layout.selectedFixture!.productIds.length})'
                : 'Tautkan produk',
          ),
        ),
        IconButton.outlined(
          tooltip: 'Perkecil',
          onPressed: hasSelection ? () => layout.resizeSelected(-.04) : null,
          icon: const Icon(Icons.zoom_in_map_outlined),
        ),
        IconButton.outlined(
          tooltip: 'Perbesar',
          onPressed: hasSelection ? () => layout.resizeSelected(.04) : null,
          icon: const Icon(Icons.zoom_out_map_outlined),
        ),
        IconButton.outlined(
          tooltip: 'Putar 90 derajat',
          onPressed: hasSelection ? layout.rotateSelected : null,
          icon: const Icon(Icons.rotate_90_degrees_ccw_outlined),
        ),
        IconButton.outlined(
          tooltip: 'Duplikasi',
          onPressed: hasSelection ? layout.duplicateSelected : null,
          icon: const Icon(Icons.copy_outlined),
        ),
        IconButton.outlined(
          tooltip: 'Hapus',
          onPressed: hasSelection
              ? () => _deleteFixture(context, layout)
              : null,
          icon: const Icon(Icons.delete_outline),
        ),
        IconButton.outlined(
          tooltip: 'Urungkan',
          onPressed: layout.canUndo ? layout.undo : null,
          icon: const Icon(Icons.undo),
        ),
        FilledButton.icon(
          onPressed: layout.hasUnsavedChanges && !layout.isSaving
              ? () async {
                  final saved = await layout.saveLayout();
                  if (!context.mounted) return;
                  if (saved) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Denah disimpan di perangkat.'),
                      ),
                    );
                  }
                }
              : null,
          icon: layout.isSaving
              ? const AppSpinner(size: 18, color: Colors.white)
              : const Icon(Icons.save_outlined),
          label: Text(layout.isSaving ? 'Menyimpan…' : 'Simpan denah'),
        ),
      ],
    );
  }
}

class _FixtureSummary extends StatelessWidget {
  const _FixtureSummary({required this.fixture});

  final StoreFixture fixture;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFD5DAD7)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const Icon(Icons.location_on_outlined, color: AppTheme.primary),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    fixture.label,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  Text(
                    fixture.productIds.isEmpty
                        ? 'Belum ada produk yang ditautkan'
                        : '${fixture.productIds.length} produk di lokasi ini',
                    style: const TextStyle(color: AppTheme.muted),
                  ),
                ],
              ),
            ),
            IconButton(
              tooltip: 'Buka produk',
              onPressed: () =>
                  _showComingSoon(context, 'Produk ${fixture.label}'),
              icon: const Icon(Icons.chevron_right),
            ),
          ],
        ),
      ),
    );
  }
}

Future<void> _showProductLinker(
  BuildContext context,
  StoreLayoutViewModel layout,
  ProductRepository products,
  String storeId,
) async {
  final selected = layout.selectedFixture;
  if (selected == null) return;
  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (context) => FractionallySizedBox(
      heightFactor: .78,
      child: _ProductLinkSheet(
        repository: products,
        storeId: storeId,
        fixture: selected,
        onSave: layout.setSelectedProductIds,
      ),
    ),
  );
}

class _ProductLinkSheet extends StatefulWidget {
  const _ProductLinkSheet({
    required this.repository,
    required this.storeId,
    required this.fixture,
    required this.onSave,
  });

  final ProductRepository repository;
  final String storeId;
  final StoreFixture fixture;
  final ValueChanged<Iterable<String>> onSave;

  @override
  State<_ProductLinkSheet> createState() => _ProductLinkSheetState();
}

class _ProductLinkSheetState extends State<_ProductLinkSheet> {
  late final Stream<List<ProductEntity>> _products;
  late final Set<String> _selectedIds;
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void initState() {
    super.initState();
    _products = widget.repository.watchProducts(widget.storeId);
    _selectedIds = widget.fixture.productIds.toSet();
    _searchController.addListener(_updateQuery);
  }

  void _updateQuery() {
    final query = _searchController.text.trim().toLowerCase();
    if (query == _query) return;
    setState(() => _query = query);
  }

  @override
  void dispose() {
    _searchController
      ..removeListener(_updateQuery)
      ..dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          20,
          0,
          20,
          16 + MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Produk di ${widget.fixture.label}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 3),
                      Text(
                        '${_selectedIds.length} produk dipilih',
                        style: const TextStyle(color: AppColors.muted),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: 'Tutup',
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 14),
            TextField(
              controller: _searchController,
              textInputAction: TextInputAction.search,
              decoration: const InputDecoration(
                labelText: 'Cari produk',
                hintText: 'Nama, kategori, atau barcode',
                prefixIcon: Icon(Icons.search_rounded),
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: StreamBuilder<List<ProductEntity>>(
                stream: _products,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const AppLoadingView(label: 'Memuat produk…');
                  }
                  if (snapshot.hasError) {
                    return const _ProductPickerMessage(
                      icon: Icons.cloud_off_outlined,
                      title: 'Produk belum dapat dimuat',
                      message:
                          'Coba lagi setelah katalog lokal selesai disiapkan.',
                    );
                  }
                  final products = (snapshot.data ?? const <ProductEntity>[])
                      .where((product) {
                        if (_query.isEmpty) return true;
                        final searchable = [
                          product.name,
                          product.category,
                          product.barcode ?? '',
                        ].join(' ').toLowerCase();
                        return searchable.contains(_query);
                      })
                      .toList(growable: false);
                  if (products.isEmpty) {
                    return _ProductPickerMessage(
                      icon: _query.isEmpty
                          ? Icons.inventory_2_outlined
                          : Icons.search_off_rounded,
                      title: _query.isEmpty
                          ? 'Belum ada produk'
                          : 'Produk tidak ditemukan',
                      message: _query.isEmpty
                          ? 'Tambahkan produk terlebih dahulu, lalu kembali untuk menautkannya ke lokasi ini.'
                          : 'Periksa kata kunci atau cari dengan nama yang lebih singkat.',
                    );
                  }
                  return ListView.separated(
                    keyboardDismissBehavior:
                        ScrollViewKeyboardDismissBehavior.onDrag,
                    itemCount: products.length,
                    separatorBuilder: (_, _) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final product = products[index];
                      final selected = _selectedIds.contains(product.id);
                      return CheckboxListTile(
                        value: selected,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 4,
                        ),
                        controlAffinity: ListTileControlAffinity.trailing,
                        title: Text(
                          product.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        subtitle: Text(
                          '${product.category} · Stok ${product.stock}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        onChanged: (checked) {
                          setState(() {
                            if (checked ?? false) {
                              _selectedIds.add(product.id);
                            } else {
                              _selectedIds.remove(product.id);
                            }
                          });
                        },
                      );
                    },
                  );
                },
              ),
            ),
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: () {
                widget.onSave(_selectedIds);
                Navigator.pop(context);
              },
              icon: const Icon(Icons.link_rounded),
              label: Text('Simpan ${_selectedIds.length} produk'),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProductPickerMessage extends StatelessWidget {
  const _ProductPickerMessage({
    required this.icon,
    required this.title,
    required this.message,
  });

  final IconData icon;
  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 320),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 40, color: AppColors.slate500),
            const SizedBox(height: 12),
            Text(
              title,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 6),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.muted, height: 1.4),
            ),
          ],
        ),
      ),
    );
  }
}

Future<void> _showFixturePicker(
  BuildContext context,
  StoreLayoutViewModel layout,
) => showModalBottomSheet<void>(
  context: context,
  showDragHandle: true,
  builder: (context) => SafeArea(
    child: Padding(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Tambah ke denah',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 12),
          for (final type in StoreFixtureType.values)
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(_fixtureIcon(type)),
              title: Text(_fixtureName(type)),
              trailing: const Icon(Icons.add),
              onTap: () {
                layout.addFixture(type);
                Navigator.pop(context);
              },
            ),
        ],
      ),
    ),
  ),
);

Future<void> _renameFixture(
  BuildContext context,
  StoreLayoutViewModel layout,
) async {
  final selected = layout.selectedFixture;
  if (selected == null) return;
  final controller = TextEditingController(text: selected.label);
  final name = await showDialog<String>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Ubah nama objek'),
      content: TextField(
        controller: controller,
        autofocus: true,
        maxLength: 40,
        textInputAction: TextInputAction.done,
        decoration: const InputDecoration(
          labelText: 'Nama',
          hintText: 'Contoh: Rak minuman',
        ),
        onSubmitted: (value) => Navigator.pop(context, value),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Batal'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, controller.text),
          child: const Text('Simpan nama'),
        ),
      ],
    ),
  );
  controller.dispose();
  if (name != null) layout.renameSelected(name);
}

Future<void> _deleteFixture(
  BuildContext context,
  StoreLayoutViewModel layout,
) async {
  final selected = layout.selectedFixture;
  if (selected == null) return;
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text('Hapus ${selected.label}?'),
      content: const Text(
        'Objek akan dihapus dari denah. Produk tidak ikut terhapus.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Batal'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, true),
          child: const Text('Hapus objek'),
        ),
      ],
    ),
  );
  if (confirmed == true) layout.deleteSelected();
}

IconData _fixtureIcon(StoreFixtureType type) => switch (type) {
  StoreFixtureType.shelf => Icons.view_column_outlined,
  StoreFixtureType.cabinet => Icons.door_sliding_outlined,
  StoreFixtureType.refrigerator => Icons.kitchen_outlined,
  StoreFixtureType.cashier => Icons.point_of_sale_outlined,
  StoreFixtureType.display => Icons.inventory_2_outlined,
};

String _fixtureName(StoreFixtureType type) => switch (type) {
  StoreFixtureType.shelf => 'Rak',
  StoreFixtureType.cabinet => 'Lemari',
  StoreFixtureType.refrigerator => 'Kulkas',
  StoreFixtureType.cashier => 'Meja kasir',
  StoreFixtureType.display => 'Etalase',
};

void _openProducts(
  BuildContext context,
  ProductRepository? repository,
  InventoryPlanningRepository? inventoryPlanningRepository,
  String storeId,
  bool canManageProducts,
) {
  if (repository == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Katalog produk belum tersedia.')),
    );
    return;
  }
  Navigator.of(context).push(
    MaterialPageRoute(
      builder: (_) => ProductCatalogPage(
        repository: repository,
        inventoryPlanningRepository: inventoryPlanningRepository,
        storeId: storeId,
        canManageProducts: canManageProducts,
      ),
    ),
  );
}

void _showComingSoon(BuildContext context, String feature) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text('$feature ada di tahap TODO berikutnya.')),
  );
}

Future<void> _showAccountSheet(
  BuildContext context, {
  required String accountName,
  required String accountRole,
  required VoidCallback onSignOut,
}) {
  final roleLabel = accountRole.toLowerCase() == 'owner' ? 'Pemilik' : 'Kasir';
  return showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    builder: (sheetContext) => SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 4, 24, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(accountName, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 4),
            Text(
              '$roleLabel · session Firebase',
              style: const TextStyle(color: AppColors.muted),
            ),
            const SizedBox(height: 20),
            OutlinedButton.icon(
              key: const ValueKey('auth-sign-out'),
              onPressed: () {
                Navigator.pop(sheetContext);
                onSignOut();
              },
              icon: const Icon(Icons.logout_rounded),
              label: const Text('Keluar dari akun'),
            ),
          ],
        ),
      ),
    ),
  );
}

void _openScanner(
  BuildContext context,
  TransactionViewModelFactory? createViewModel,
) {
  if (createViewModel == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Layanan kamera belum tersedia.')),
    );
    return;
  }
  Navigator.of(context).push(
    MaterialPageRoute(
      builder: (_) => ProductScannerPage(createViewModel: createViewModel),
    ),
  );
}
