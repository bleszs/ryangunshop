import 'dart:typed_data';

enum UserRole { owner, cashier }

enum PaymentType { cash, qrisManual }

enum TransactionStatus { success, cancelled }

enum SyncState { pending, synced, failed }

class UserEntity {
  const UserEntity({
    required this.id,
    required this.storeId,
    required this.name,
    required this.email,
    required this.role,
    this.passwordHash,
    this.active = true,
  });

  final String id;
  final String storeId;
  final String name;
  final String email;
  final UserRole role;
  // Hanya untuk migrasi autentikasi legacy; jangan pernah berisi plaintext.
  final String? passwordHash;
  final bool active;
}

class ProductEntity {
  const ProductEntity({
    required this.id,
    required this.storeId,
    required this.name,
    required this.category,
    required this.purchasePrice,
    required this.sellingPrice,
    required this.stock,
    required this.minimumStock,
    this.leadTimeDays = 3,
    this.barcode,
    this.photoUri,
    this.shelfLocation,
    this.aiLabel,
  });

  final String id;
  final String storeId;
  final String name;
  final String category;
  final int purchasePrice;
  final int sellingPrice;
  final int stock;
  final int minimumStock;
  final int leadTimeDays;
  final String? barcode;
  final String? photoUri;
  final String? shelfLocation;
  final String? aiLabel;
}

class TransactionItemEntity {
  const TransactionItemEntity({
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.purchasePrice,
    required this.sellingPrice,
  });

  final String productId;
  final String productName;
  final int quantity;
  final int purchasePrice;
  final int sellingPrice;

  int get subtotal => sellingPrice * quantity;
}

class TransactionEntity {
  const TransactionEntity({
    required this.id,
    required this.storeId,
    required this.occurredAt,
    required this.items,
    required this.totalAmount,
    required this.grossProfitAmount,
    required this.paymentType,
    required this.receivedAmount,
    required this.changeAmount,
    required this.cashierId,
    required this.status,
  });

  final String id;
  final String storeId;
  final DateTime occurredAt;
  final List<TransactionItemEntity> items;
  final int totalAmount;
  final int grossProfitAmount;
  final PaymentType paymentType;
  final int receivedAmount;
  final int changeAmount;
  final String cashierId;
  final TransactionStatus status;
}

class VoidTransactionRequest {
  const VoidTransactionRequest({
    required this.storeId,
    required this.transactionId,
    required this.actorId,
    required this.reason,
    required this.clientMutationId,
  });

  final String storeId;
  final String transactionId;
  final String actorId;
  final String reason;
  final String clientMutationId;
}

class VoidTransactionResult {
  const VoidTransactionResult({
    required this.transactionId,
    required this.restoredUnits,
    required this.voidedAt,
    required this.alreadyProcessed,
  });

  final String transactionId;
  final int restoredUnits;
  final DateTime voidedAt;
  final bool alreadyProcessed;
}

class PredictionEntity {
  const PredictionEntity({
    required this.id,
    required this.storeId,
    required this.capturedAt,
    required this.aiLabel,
    required this.confidence,
    required this.selectedProductId,
    required this.corrected,
    required this.correctionPhotoUri,
    required this.correctionPhotoExpiresAt,
    required this.cashierId,
    required this.modelVersion,
    required this.consentToTraining,
  });

  final String id;
  final String storeId;
  final DateTime capturedAt;
  final String? aiLabel;
  final double? confidence;
  final String? selectedProductId;
  final bool corrected;
  final String? correctionPhotoUri;
  final DateTime? correctionPhotoExpiresAt;
  final String cashierId;
  final String modelVersion;
  final bool consentToTraining;
}

class CartLine {
  const CartLine({required this.product, required this.quantity})
    : assert(quantity > 0);

  final ProductEntity product;
  final int quantity;

  int get subtotal => product.sellingPrice * quantity;
  int get grossProfit =>
      (product.sellingPrice - product.purchasePrice) * quantity;
}

class CartLineRequest {
  const CartLineRequest({required this.productId, required this.quantity});
  final String productId;
  final int quantity;
}

class CheckoutRequest {
  const CheckoutRequest({
    required this.storeId,
    required this.cashierId,
    required this.lines,
    required this.paymentType,
    required this.receivedAmount,
    required this.clientMutationId,
  });

  final String storeId;
  final String cashierId;
  final List<CartLineRequest> lines;
  final PaymentType paymentType;
  final int receivedAmount;
  final String clientMutationId;
}

class CheckoutReceipt {
  const CheckoutReceipt({
    required this.transactionId,
    required this.totalAmount,
    required this.grossProfitAmount,
    required this.receivedAmount,
    required this.changeAmount,
    required this.occurredAt,
  });

  final String transactionId;
  final int totalAmount;
  final int grossProfitAmount;
  final int receivedAmount;
  final int changeAmount;
  final DateTime occurredAt;
}

/// Snapshot lengkap setelah checkout. Nilai harga dan nama produk tidak lagi
/// bergantung pada katalog yang dapat berubah, sehingga struk bisa dibuat ulang
/// secara deterministik setelah transaksi tersimpan.
class CompletedCheckout {
  const CompletedCheckout({
    required this.receipt,
    required this.storeId,
    required this.cashierId,
    required this.paymentType,
    required this.items,
  });

  final CheckoutReceipt receipt;
  final String storeId;
  final String cashierId;
  final PaymentType paymentType;
  final List<TransactionItemEntity> items;
}

class RgbFrame {
  const RgbFrame({
    required this.bytes,
    required this.width,
    required this.height,
    required this.rotationDegrees,
    required this.capturedAt,
  });

  final Uint8List bytes;
  final int width;
  final int height;
  final int rotationDegrees;
  final DateTime capturedAt;
}

class AiCandidate {
  const AiCandidate({required this.label, required this.confidence});
  final String label;
  final double confidence;
}

class ClassificationResult {
  const ClassificationResult({
    required this.candidates,
    required this.inferenceTime,
    required this.modelVersion,
  });

  final List<AiCandidate> candidates;
  final Duration inferenceTime;
  final String modelVersion;
}

enum RecognitionFailureReason {
  lowConfidence,
  unknownLabel,
  modelUnavailable,
  timeout,
  inferenceError,
}

sealed class RecognitionOutcome {
  const RecognitionOutcome();
}

class RecognizedProduct extends RecognitionOutcome {
  const RecognizedProduct({
    required this.product,
    required this.candidates,
    required this.inferenceTime,
    required this.modelVersion,
  });

  final ProductEntity product;
  final List<AiCandidate> candidates;
  final Duration inferenceTime;
  final String modelVersion;
}

class RecognitionFallback extends RecognitionOutcome {
  const RecognitionFallback(this.reason, [this.candidates = const []]);
  final RecognitionFailureReason reason;
  final List<AiCandidate> candidates;
}

class PredictionCorrection {
  const PredictionCorrection({
    required this.storeId,
    required this.cashierId,
    required this.capturedAt,
    required this.initialLabel,
    required this.initialConfidence,
    required this.selectedProductId,
    required this.corrected,
    required this.correctionPhotoUri,
    required this.correctionPhotoExpiresAt,
    required this.modelVersion,
    required this.consentToTraining,
  });

  final String storeId;
  final String cashierId;
  final DateTime capturedAt;
  final String? initialLabel;
  final double? initialConfidence;
  final String? selectedProductId;
  final bool corrected;
  final String? correctionPhotoUri;
  final DateTime? correctionPhotoExpiresAt;
  final String modelVersion;
  final bool consentToTraining;
}
