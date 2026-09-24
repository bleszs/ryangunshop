import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import '../../../domain/entities/entities.dart';
import '../../../domain/repositories/repositories.dart';

class TransactionHistoryViewModel extends ChangeNotifier {
  TransactionHistoryViewModel({
    required TransactionManagementRepository repository,
    required String storeId,
    required String actorId,
    Uuid uuid = const Uuid(),
  }) : _repository = repository,
       _storeId = storeId,
       _actorId = actorId,
       _uuid = uuid;

  final TransactionManagementRepository _repository;
  final String _storeId;
  final String _actorId;
  final Uuid _uuid;
  StreamSubscription<List<TransactionEntity>>? _subscription;

  List<TransactionEntity> _transactions = const [];
  bool _isLoading = true;
  String? _voidingTransactionId;
  String? _errorMessage;

  List<TransactionEntity> get transactions => List.unmodifiable(_transactions);
  bool get isLoading => _isLoading;
  String? get voidingTransactionId => _voidingTransactionId;
  String? get errorMessage => _errorMessage;

  Future<void> initialize() async {
    await _subscription?.cancel();
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    _subscription = _repository
        .watchTransactions(storeId: _storeId)
        .listen(
          (transactions) {
            _transactions = transactions;
            _isLoading = false;
            _errorMessage = null;
            notifyListeners();
          },
          onError: (_) {
            _isLoading = false;
            _errorMessage = 'Riwayat transaksi lokal gagal dimuat.';
            notifyListeners();
          },
        );
  }

  Future<VoidTransactionResult?> voidTransaction(
    TransactionEntity transaction,
    String reason,
  ) async {
    if (_voidingTransactionId != null) return null;
    _voidingTransactionId = transaction.id;
    _errorMessage = null;
    notifyListeners();
    try {
      return await _repository.voidTransaction(
        VoidTransactionRequest(
          storeId: _storeId,
          transactionId: transaction.id,
          actorId: _actorId,
          reason: reason,
          clientMutationId: _uuid.v4(),
        ),
      );
    } catch (error) {
      _errorMessage = error.toString();
      return null;
    } finally {
      _voidingTransactionId = null;
      notifyListeners();
    }
  }

  void clearError() {
    if (_errorMessage == null) return;
    _errorMessage = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
