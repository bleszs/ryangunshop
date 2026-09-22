import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_loading.dart';
import '../../../domain/entities/entities.dart';
import '../../../domain/repositories/repositories.dart';
import '../application/product_catalog_view_model.dart';
import 'product_form_page.dart';
import 'restock_recommendation_page.dart';

class ProductCatalogPage extends StatelessWidget {
  const ProductCatalogPage({
    required this.repository,
    required this.storeId,
    this.canManageProducts = false,
    this.inventoryPlanningRepository,
    super.key,
  });

  final ProductRepository repository;
  final String storeId;
  final bool canManageProducts;
  final InventoryPlanningRepository? inventoryPlanningRepository;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) =>
          ProductCatalogViewModel(repository: repository, storeId: storeId)
            ..initialize(),
      child: _ProductCatalogView(
        repository: repository,
        storeId: storeId,
        canManageProducts: canManageProducts,
        inventoryPlanningRepository: inventoryPlanningRepository,
      ),
    );
  }
}

class _ProductCatalogView extends StatelessWidget {
  const _ProductCatalogView({
    required this.repository,
    required this.storeId,
    required this.canManageProducts,
    required this.inventoryPlanningRepository,
  });

  final ProductRepository repository;
  final String storeId;
  final bool canManageProducts;
  final InventoryPlanningRepository? inventoryPlanningRepository;

  Future<void> _openForm(BuildContext context, {ProductEntity? product}) async {
    final saved = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => ProductFormPage(
          repository: repository,
          storeId: storeId,
          product: product,
        ),
      ),
    );
    if (saved == true && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            product == null
                ? 'Produk disimpan di perangkat.'
                : 'Perubahan produk disimpan.',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final catalog = context.watch<ProductCatalogViewModel>();
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 80,
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Produk', style: AppTextStyles.editorialTitle),
            Text(
              'Inventori lokal warung',
              style: TextStyle(
                color: AppColors.muted,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        actions: [
          if (canManageProducts && inventoryPlanningRepository != null)
            IconButton(
              key: const ValueKey('open-restock-plan'),
              tooltip: 'Rencana restok',
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => RestockRecommendationPage(
                    repository: inventoryPlanningRepository!,
                    storeId: storeId,
                  ),
                ),
              ),
              icon: const Icon(Icons.inventory_outlined),
            ),
          const SizedBox(width: 8),
        ],
      ),
      body: catalog.isLoading
          ? const AppLoadingView(label: 'Memuat katalog…')
          : Column(
              children: [
                _CatalogControls(catalog: catalog),
                if (catalog.errorMessage case final message?)
                  _CatalogError(message: message, onRetry: catalog.initialize),
                Expanded(
                  child: _ProductList(
                    products: catalog.visibleProducts,
                    hasAnyProduct: catalog.totalProducts > 0,
                    deletingProductId: catalog.deletingProductId,
                    canManageProducts: canManageProducts,
                    onAdd: () => _openForm(context),
                    onEdit: (product) => _openForm(context, product: product),
                    onDelete: (product) async {
                      final confirmed = await _confirmDelete(context, product);
                      if (!confirmed || !context.mounted) return;
                      final deleted = await catalog.delete(product);
                      if (deleted && context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('${product.name} dihapus.')),
                        );
                      }
                    },
                  ),
                ),
              ],
            ),
      floatingActionButton:
          canManageProducts && !catalog.isLoading && catalog.totalProducts > 0
          ? FloatingActionButton.extended(
              key: const ValueKey('add-product'),
              onPressed: () => _openForm(context),
              icon: const Icon(Icons.add_rounded),
              label: const Text('Produk baru'),
            )
          : null,
    );
  }
}

class _CatalogControls extends StatelessWidget {
  const _CatalogControls({required this.catalog});
  final ProductCatalogViewModel catalog;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            onChanged: catalog.search,
            textInputAction: TextInputAction.search,
            decoration: InputDecoration(
              hintText: 'Cari nama, barcode, atau rak',
              prefixIcon: const Icon(Icons.search_rounded),
              suffixIcon: Padding(
                padding: const EdgeInsets.only(right: 12),
                child: Center(
                  widthFactor: 1,
                  child: Text(
                    '${catalog.totalProducts}',
                    semanticsLabel: '${catalog.totalProducts} produk',
                    style: const TextStyle(
                      color: AppColors.slate700,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 14),
          SegmentedButton<ProductStockFilter>(
            showSelectedIcon: false,
            segments: [
              ButtonSegment(
                value: ProductStockFilter.all,
                icon: const Icon(Icons.inventory_2_outlined, size: 18),
                label: Text('Semua  ${catalog.totalProducts}'),
              ),
              ButtonSegment(
                value: ProductStockFilter.lowStock,
                icon: const Icon(Icons.warning_amber_rounded, size: 18),
                label: Text('Menipis  ${catalog.lowStockCount}'),
              ),
            ],
            selected: {catalog.filter},
            onSelectionChanged: (value) => catalog.setFilter(value.first),
          ),
        ],
      ),
    );
  }
}

class _ProductList extends StatelessWidget {
  const _ProductList({
    required this.products,
    required this.hasAnyProduct,
    required this.deletingProductId,
    required this.canManageProducts,
    required this.onAdd,
    required this.onEdit,
    required this.onDelete,
  });

  final List<ProductEntity> products;
  final bool hasAnyProduct;
  final String? deletingProductId;
  final bool canManageProducts;
  final VoidCallback onAdd;
  final ValueChanged<ProductEntity> onEdit;
  final ValueChanged<ProductEntity> onDelete;

  @override
  Widget build(BuildContext context) {
    if (products.isEmpty) {
      return _CatalogEmptyState(
        hasAnyProduct: hasAnyProduct,
        canManageProducts: canManageProducts,
        onAdd: onAdd,
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 104),
      itemCount: products.length,
      separatorBuilder: (_, _) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final product = products[index];
        return _ProductTile(
          product: product,
          isDeleting: deletingProductId == product.id,
          canManageProducts: canManageProducts,
          onTap: () => onEdit(product),
          onDelete: () => onDelete(product),
        );
      },
    );
  }
}

class _ProductTile extends StatelessWidget {
  const _ProductTile({
    required this.product,
    required this.isDeleting,
    required this.canManageProducts,
    required this.onTap,
    required this.onDelete,
  });

  final ProductEntity product;
  final bool isDeleting;
  final bool canManageProducts;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final lowStock = product.stock <= product.minimumStock;
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: canManageProducts ? onTap : null,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              _ProductThumbnail(product: product),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            product.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ),
                        const SizedBox(width: 8),
                        _StockPill(stock: product.stock, lowStock: lowStock),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${product.category} · ${_rupiah(product.sellingPrice)}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: AppColors.muted),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on_outlined,
                          size: 16,
                          color: AppColors.slate600,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            product.shelfLocation ?? 'Lokasi belum diatur',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: AppColors.slate700,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              if (canManageProducts) ...[
                const SizedBox(width: 4),
                isDeleting
                    ? const Padding(
                        padding: EdgeInsets.all(12),
                        child: AppSpinner(size: 20),
                      )
                    : PopupMenuButton<String>(
                        tooltip: 'Opsi produk',
                        onSelected: (value) {
                          if (value == 'edit') onTap();
                          if (value == 'delete') onDelete();
                        },
                        itemBuilder: (_) => const [
                          PopupMenuItem(
                            value: 'edit',
                            child: ListTile(
                              contentPadding: EdgeInsets.zero,
                              leading: Icon(Icons.edit_outlined),
                              title: Text('Edit produk'),
                            ),
                          ),
                          PopupMenuItem(
                            value: 'delete',
                            child: ListTile(
                              contentPadding: EdgeInsets.zero,
                              leading: Icon(
                                Icons.delete_outline,
                                color: AppColors.error,
                              ),
                              title: Text('Hapus produk'),
                            ),
                          ),
                        ],
                      ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _ProductThumbnail extends StatelessWidget {
  const _ProductThumbnail({required this.product});
  final ProductEntity product;

  @override
  Widget build(BuildContext context) {
    final photoUri = product.photoUri;
    final hasPhoto =
        photoUri != null && photoUri.isNotEmpty && File(photoUri).existsSync();
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: SizedBox(
        width: 68,
        height: 68,
        child: hasPhoto
            ? Image.file(File(photoUri), fit: BoxFit.cover)
            : const ColoredBox(
                color: AppColors.slate100,
                child: Icon(
                  Icons.inventory_2_outlined,
                  color: AppColors.slate600,
                  size: 28,
                ),
              ),
      ),
    );
  }
}

class _StockPill extends StatelessWidget {
  const _StockPill({required this.stock, required this.lowStock});
  final int stock;
  final bool lowStock;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: lowStock ? const Color(0xFFFFF0DD) : const Color(0xFFDDF1EB),
        borderRadius: BorderRadius.circular(99),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Text(
          'Stok $stock',
          style: TextStyle(
            color: lowStock ? AppColors.warning : AppColors.success,
            fontSize: 11,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}

class _CatalogEmptyState extends StatelessWidget {
  const _CatalogEmptyState({
    required this.hasAnyProduct,
    required this.canManageProducts,
    required this.onAdd,
  });

  final bool hasAnyProduct;
  final bool canManageProducts;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(28, 24, 28, 104),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 360),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.inventory_2_outlined,
                size: 52,
                color: AppColors.slate500,
              ),
              const SizedBox(height: 16),
              Text(
                hasAnyProduct
                    ? 'Tidak ada produk pada filter ini'
                    : 'Katalog masih kosong',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Text(
                hasAnyProduct
                    ? 'Coba kata kunci lain atau kembali ke filter Semua.'
                    : 'Tambahkan barang pertama agar kasir bisa mencari, memindai, dan memasukkannya ke transaksi.',
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.muted, height: 1.45),
              ),
              if (!hasAnyProduct && canManageProducts) ...[
                const SizedBox(height: 20),
                FilledButton.icon(
                  onPressed: onAdd,
                  icon: const Icon(Icons.add_rounded),
                  label: const Text('Tambah produk pertama'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _CatalogError extends StatelessWidget {
  const _CatalogError({required this.message, required this.onRetry});
  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: Material(
        color: colors.errorContainer,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            children: [
              Icon(Icons.error_outline, color: colors.onErrorContainer),
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

Future<bool> _confirmDelete(BuildContext context, ProductEntity product) async {
  final result = await showModalBottomSheet<bool>(
    context: context,
    showDragHandle: true,
    builder: (context) => SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Hapus ${product.name}?',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            const Text(
              'Produk disembunyikan dari katalog. Riwayat transaksi lama tidak ikut terhapus.',
              style: TextStyle(color: AppColors.muted, height: 1.4),
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.error,
                foregroundColor: Colors.white,
              ),
              onPressed: () => Navigator.pop(context, true),
              icon: const Icon(Icons.delete_outline),
              label: const Text('Hapus produk'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Batal'),
            ),
          ],
        ),
      ),
    ),
  );
  return result ?? false;
}

String _rupiah(int amount) {
  final digits = amount.toString();
  final buffer = StringBuffer('Rp');
  for (var index = 0; index < digits.length; index++) {
    if (index > 0 && (digits.length - index) % 3 == 0) buffer.write('.');
    buffer.write(digits[index]);
  }
  return buffer.toString();
}
