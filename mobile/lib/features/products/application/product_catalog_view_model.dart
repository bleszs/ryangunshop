import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../../domain/entities/entities.dart';
import '../../../domain/repositories/repositories.dart';

enum ProductStockFilter { all, lowStock }

class ProductCatalogViewModel extends ChangeNotifier {
  ProductCatalogViewModel({
    required ProductRepository repository,
    required String storeId,
  }) : _repository = repository,
       _storeId = storeId;

  final ProductRepository _repository;
  final String _storeId;
  StreamSubscription<List<ProductEntity>>? _subscription;
  List<ProductEntity> _products = const [];
  String _query = '';
  ProductStockFilter _filter = ProductStockFilter.all;
  bool _isLoading = true;
  String? _errorMessage;
  String? _deletingProductId;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  ProductStockFilter get filter => _filter;
  int get totalProducts => _products.length;
  int get lowStockCount => _products
      .where((product) => product.stock <= product.minimumStock)
      .length;
  String? get deletingProductId => _deletingProductId;

  List<ProductEntity> get visibleProducts {
    final query = _query.trim().toLowerCase();
    return _products
        .where((product) {
          if (_filter == ProductStockFilter.lowStock &&
              product.stock > product.minimumStock) {
            return false;
          }
          if (query.isEmpty) return true;
          return [
            product.name,
            product.category,
            product.barcode ?? '',
            product.shelfLocation ?? '',
          ].join(' ').toLowerCase().contains(query);
        })
        .toList(growable: false);
  }

  void initialize() {
    _subscription?.cancel();
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    _subscription = _repository
        .watchProducts(_storeId)
        .listen(
          (products) {
            _products = products;
            _isLoading = false;
            _errorMessage = null;
            notifyListeners();
          },
          onError: (Object error) {
            _isLoading = false;
            _errorMessage = 'Katalog lokal gagal dimuat.';
            notifyListeners();
          },
        );
  }

  void search(String value) {
    final normalized = value.trim().toLowerCase();
    if (_query == normalized) return;
    _query = normalized;
    notifyListeners();
  }

  void setFilter(ProductStockFilter value) {
    if (_filter == value) return;
    _filter = value;
    notifyListeners();
  }

  Future<bool> delete(ProductEntity product) async {
    if (_deletingProductId != null) return false;
    _deletingProductId = product.id;
    _errorMessage = null;
    notifyListeners();
    try {
      await _repository.deleteProduct(product.storeId, product.id);
      return true;
    } catch (_) {
      _errorMessage = 'Produk gagal dihapus. Coba lagi.';
      return false;
    } finally {
      _deletingProductId = null;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
