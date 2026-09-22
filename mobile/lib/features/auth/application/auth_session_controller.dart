import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../../domain/entities/auth_session.dart';
import '../../../domain/repositories/auth_session_repository.dart';

enum AuthGateStatus { checking, signedOut, authenticated, accessDenied }

final class AuthSessionController extends ChangeNotifier {
  AuthSessionController({required AuthSessionRepository repository})
    : _repository = repository;

  final AuthSessionRepository _repository;
  StreamSubscription<AuthSessionSnapshot>? _subscription;

  AuthGateStatus status = AuthGateStatus.checking;
  AuthenticatedSession? session;
  String? accountEmail;
  String? accessMessage;
  String? actionError;
  bool isSubmitting = false;

  void initialize() {
    _subscription ??= _repository.watchSession().listen(
      _applySnapshot,
      onError: (_) {
        status = AuthGateStatus.signedOut;
        actionError = 'Session tidak dapat dibaca. Silakan masuk kembali.';
        notifyListeners();
      },
    );
  }

  Future<void> signIn({required String email, required String password}) async {
    if (isSubmitting) return;
    isSubmitting = true;
    actionError = null;
    notifyListeners();
    try {
      await _repository.signIn(email: email, password: password);
    } on AuthSignInFailure catch (error) {
      actionError = error.message;
    } on Object {
      actionError = 'Tidak dapat masuk sekarang. Silakan coba lagi.';
    } finally {
      isSubmitting = false;
      notifyListeners();
    }
  }

  Future<void> refreshClaims() async {
    if (isSubmitting) return;
    isSubmitting = true;
    actionError = null;
    notifyListeners();
    try {
      _applySnapshot(await _repository.refreshSession());
    } on Object {
      actionError = 'Gagal memperbarui akses. Periksa koneksi internet.';
    } finally {
      isSubmitting = false;
      notifyListeners();
    }
  }

  void useLocalPreview() {
    _applySnapshot(
      const AuthSessionSnapshot.authenticated(
        AuthenticatedSession(
          userId: 'local-owner',
          storeId: 'local-preview-store',
          role: AuthSessionRole.owner,
          email: '',
          displayName: 'Pemilik lokal',
          isLocalPreview: true,
        ),
      ),
    );
  }

  Future<void> signOut() async {
    if (session?.isLocalPreview ?? false) {
      _applySnapshot(const AuthSessionSnapshot.signedOut());
      return;
    }
    await _repository.signOut();
  }

  void _applySnapshot(AuthSessionSnapshot snapshot) {
    session = snapshot.session;
    accountEmail = snapshot.email;
    accessMessage = snapshot.message;
    status = switch (snapshot.status) {
      AuthSessionStatus.signedOut => AuthGateStatus.signedOut,
      AuthSessionStatus.authenticated => AuthGateStatus.authenticated,
      AuthSessionStatus.accessDenied => AuthGateStatus.accessDenied,
    };
    notifyListeners();
  }

  @override
  void dispose() {
    unawaited(_subscription?.cancel());
    super.dispose();
  }
}
