import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import '../../../domain/entities/entities.dart';
import '../../../domain/repositories/repositories.dart';
import '../../../domain/usecases/checkout_calculator.dart';
import '../../../domain/usecases/product_recognition_coordinator.dart';

class PendingRecognition {
  const PendingRecognition({
    required this.product,
    required this.candidates,
    required this.capturedAt,
    required this.modelVersion,
  });
  final ProductEntity product;
  final List<AiCandidate> candidates;
  final DateTime capturedAt;
  final String modelVersion;
}

class TransactionViewModel extends ChangeNotifier {
  TransactionViewModel({
    required String storeId,
    required String cashierId,
    required ProductRecognitionCoordinator recognition,
    required BarcodeScanner barcodeScanner,
    required ProductRepository products,
    required CheckoutRepository checkoutRepository,
    Uuid uuid = const Uuid(),
  }) : _storeId = storeId,
       _cashierId = cashierId,
       _recognition = recognition,
       _barcodeScanner = barcodeScanner,
       _products = products,
       _checkoutRepository = checkoutRepository,
       _uuid = uuid;

  final String _storeId;
  final String _cashierId;
  final ProductRecognitionCoordinator _recognition;
  final BarcodeScanner _barcodeScanner;
  final ProductRepository _products;
  final CheckoutRepository _checkoutRepository;
  final Uuid _uuid;
  bool _isAnalyzing = false;
  bool _isCheckingOut = false;
  PendingRecognition? _pendingRecognition;
  RecognitionFailureReason? _fallbackReason;
  final Map<String, CartLine> _cart = {};
  List<ProductEntity> _searchResults = const [];
  CheckoutReceipt? _receipt;
  CompletedCheckout? _completedCheckout;
  String? _message;
  String? _checkoutMutationId;

  bool get isAnalyzing => _isAnalyzing;
  bool get isCheckingOut => _isCheckingOut;
  PendingRecognition? get pendingRecognition => _pendingRecognition;
  RecognitionFailureReason? get fallbackReason => _fallbackReason;
  List<CartLine> get cart => List.unmodifiable(_cart.values);
  List<ProductEntity> get searchResults => _searchResults;
  CheckoutReceipt? get receipt => _receipt;
  CompletedCheckout? get completedCheckout => _completedCheckout;
  String? get message => _message;
  int get totalAmount =>
      _cart.isEmpty ? 0 : CheckoutCalculator.calculate(_cart.values).total;

  int get cartQuantity =>
      _cart.values.fold(0, (total, line) => total + line.quantity);
  String get storeId => _storeId;

  Future<void> analyzeFrame(RgbFrame frame) async {
    if (_isAnalyzing || _pendingRecognition != null) return;
    _isAnalyzing = true;
    _fallbackReason = null;
    _message = null;
    notifyListeners();
    try {
      final outcome = await _recognition.recognize(_storeId, frame);
      switch (outcome) {
        case RecognizedProduct():
          _pendingRecognition = PendingRecognition(
            product: outcome.product,
            candidates: outcome.candidates,
            capturedAt: frame.capturedAt,
            modelVersion: outcome.modelVersion,
          );
        case RecognitionFallback():
          _fallbackReason = outcome.reason;
          _message =
              'Produk tidak dikenali. Gunakan barcode atau pencarian manual.';
      }
    } finally {
      _isAnalyzing = false;
      notifyListeners();
    }
  }

  /// BR-02: hanya aksi eksplisit ini yang memasukkan prediksi ke keranjang.
  Future<void> confirmPrediction() async {
    final pending = _pendingRecognition;
    if (pending == null) return;
    await _recordDecision(pending, pending.product, corrected: false);
    addToCart(pending.product);
    _pendingRecognition = null;
    notifyListeners();
  }

  Future<void> correctPrediction(
    ProductEntity selected, {
    String? correctionPhotoUri,
    DateTime? correctionPhotoExpiresAt,
    bool consentToTraining = false,
  }) async {
    final pending = _pendingRecognition;
    if (pending == null) return;
    await _recordDecision(
      pending,
      selected,
      corrected: selected.id != pending.product.id,
      correctionPhotoUri: correctionPhotoUri,
      correctionPhotoExpiresAt: correctionPhotoExpiresAt,
      consentToTraining: consentToTraining,
    );
    addToCart(selected);
    _pendingRecognition = null;
    _message = 'Koreksi disimpan';
    notifyListeners();
  }

  Future<void> scanBarcodeFile(String imagePath) async {
    try {
      final barcode = await _barcodeScanner.scanFile(imagePath);
      final product = barcode == null
          ? null
          : await _products.getByBarcode(_storeId, barcode);
      if (product == null) {
        _message = 'Barcode tidak ditemukan. Cari produk manual.';
      } else {
        addToCart(product);
        _fallbackReason = null;
        _message = null;
      }
    } catch (error) {
      _message = 'Pemindaian barcode gagal: ${_safeMessage(error)}';
    }
    notifyListeners();
  }

  Future<void> search(String query) async {
    _searchResults = query.trim().isEmpty
        ? const []
        : await _products.search(_storeId, query);
    notifyListeners();
  }

  void resumeRecognition() {
    _pendingRecognition = null;
    _fallbackReason = null;
    _message = null;
    notifyListeners();
  }

  void addToCart(ProductEntity product) {
    _resetCompletedCheckout();
    final old = _cart[product.id];
    final quantity = (old?.quantity ?? 0) + 1;
    if (quantity > product.stock) {
      _message = 'Stok ${product.name} tidak cukup';
    } else {
      _cart[product.id] = CartLine(product: product, quantity: quantity);
      _message = null;
    }
    notifyListeners();
  }

  void setQuantity(String productId, int quantity) {
    final old = _cart[productId];
    if (old == null) return;
    _resetCompletedCheckout();
    if (quantity <= 0) {
      _cart.remove(productId);
    } else if (quantity > old.product.stock) {
      _message = 'Jumlah melebihi stok';
    } else {
      _cart[productId] = CartLine(product: old.product, quantity: quantity);
      _message = null;
    }
    notifyListeners();
  }

  Future<bool> checkout(PaymentType paymentType, int receivedAmount) async {
    if (_cart.isEmpty || _isCheckingOut) return false;
    _isCheckingOut = true;
    _message = null;
    _checkoutMutationId ??= _uuid.v4();
    notifyListeners();
    try {
      final itemSnapshot = _cart.values
          .map(
            (line) => TransactionItemEntity(
              productId: line.product.id,
              productName: line.product.name,
              quantity: line.quantity,
              purchasePrice: line.product.purchasePrice,
              sellingPrice: line.product.sellingPrice,
            ),
          )
          .toList(growable: false);
      final receipt = await _checkoutRepository.checkout(
        CheckoutRequest(
          storeId: _storeId,
          cashierId: _cashierId,
          lines: _cart.values
              .map(
                (line) => CartLineRequest(
                  productId: line.product.id,
                  quantity: line.quantity,
                ),
              )
              .toList(growable: false),
          paymentType: paymentType,
          receivedAmount: receivedAmount,
          clientMutationId: _checkoutMutationId!,
        ),
      );
      _receipt = receipt;
      _completedCheckout = CompletedCheckout(
        receipt: receipt,
        storeId: _storeId,
        cashierId: _cashierId,
        paymentType: paymentType,
        items: itemSnapshot,
      );
      _cart.clear();
      _checkoutMutationId = null;
      return true;
    } catch (error) {
      _message = _safeMessage(error);
      return false;
    } finally {
      _isCheckingOut = false;
      notifyListeners();
    }
  }

  void clearMessage() {
    if (_message == null) return;
    _message = null;
    notifyListeners();
  }

  void startNewTransaction() {
    _receipt = null;
    _completedCheckout = null;
    _message = null;
    _checkoutMutationId = null;
    notifyListeners();
  }

  void _resetCompletedCheckout() {
    _receipt = null;
    _completedCheckout = null;
    _checkoutMutationId = null;
  }

  Future<void> _recordDecision(
    PendingRecognition pending,
    ProductEntity selected, {
    required bool corrected,
    String? correctionPhotoUri,
    DateTime? correctionPhotoExpiresAt,
    bool consentToTraining = false,
  }) => _recognition.recordDecision(
    PredictionCorrection(
      storeId: _storeId,
      cashierId: _cashierId,
      capturedAt: pending.capturedAt,
      initialLabel: pending.candidates.firstOrNull?.label,
      initialConfidence: pending.candidates.firstOrNull?.confidence,
      selectedProductId: selected.id,
      corrected: corrected,
      correctionPhotoUri: correctionPhotoUri,
      correctionPhotoExpiresAt: correctionPhotoExpiresAt,
      modelVersion: pending.modelVersion,
      consentToTraining: consentToTraining,
    ),
  );

  Future<void> close() async {
    await _recognition.close();
    await _barcodeScanner.close();
  }
}

String _safeMessage(Object error) {
  final text = error.toString();
  return text.length <= 160 ? text : text.substring(0, 160);
}
