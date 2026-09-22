import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';

import '../../core/security/secure_value_store.dart';
import '../../domain/entities/auth_session.dart';
import '../../domain/repositories/auth_session_repository.dart';

final class FirebaseAuthSessionRepository implements AuthSessionRepository {
  FirebaseAuthSessionRepository({
    FirebaseAuth? auth,
    SecureValueStore? secureStore,
  }) : _auth = auth ?? FirebaseAuth.instance,
       _secureStore = secureStore ?? PlatformSecureValueStore();

  static const _sessionCacheKey = 'auth.session.v1';

  final FirebaseAuth _auth;
  final SecureValueStore _secureStore;

  @override
  Stream<AuthSessionSnapshot> watchSession() =>
      _auth.userChanges().asyncMap(_resolveUser);

  @override
  Future<void> signIn({required String email, required String password}) async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
    } on FirebaseAuthException catch (error) {
      throw AuthSignInFailure(_messageFor(error.code));
    }
  }

  @override
  Future<AuthSessionSnapshot> refreshSession() async {
    final user = _auth.currentUser;
    if (user == null) return const AuthSessionSnapshot.signedOut();
    return _resolveUser(user, forceRefresh: true);
  }

  @override
  Future<void> signOut() async {
    await _auth.signOut();
    await _secureStore.delete(_sessionCacheKey);
  }

  Future<AuthSessionSnapshot> _resolveUser(
    User? user, {
    bool forceRefresh = false,
  }) async {
    if (user == null) {
      await _secureStore.delete(_sessionCacheKey);
      return const AuthSessionSnapshot.signedOut();
    }

    try {
      final token = await user.getIdTokenResult(forceRefresh);
      final claims = token.claims ?? const <String, dynamic>{};
      if (claims['active'] == false) {
        await _secureStore.delete(_sessionCacheKey);
        return AuthSessionSnapshot.accessDenied(
          email: user.email,
          message: 'Akun ini dinonaktifkan oleh pemilik warung.',
        );
      }
      final storeId = claims['storeId'];
      final role = _parseRole(claims['role']);
      if (storeId is! String || storeId.trim().isEmpty || role == null) {
        await _secureStore.delete(_sessionCacheKey);
        return AuthSessionSnapshot.accessDenied(
          email: user.email,
          message: 'Akun belum ditautkan ke warung atau perannya belum diatur.',
        );
      }
      final session = AuthenticatedSession(
        userId: user.uid,
        storeId: storeId.trim(),
        role: role,
        email: user.email ?? '',
        displayName: _displayName(user),
      );
      await _secureStore.write(_sessionCacheKey, jsonEncode(_toJson(session)));
      return AuthSessionSnapshot.authenticated(session);
    } on FirebaseAuthException catch (error) {
      if (error.code != 'network-request-failed') rethrow;
      return _offlineSnapshot(user);
    } on Object {
      return _offlineSnapshot(user);
    }
  }

  Future<AuthSessionSnapshot> _offlineSnapshot(User user) async {
    final cached = await _secureStore.read(_sessionCacheKey);
    if (cached != null) {
      try {
        final json = jsonDecode(cached);
        if (json is Map<String, dynamic> && json['userId'] == user.uid) {
          return AuthSessionSnapshot.authenticated(_fromJson(json));
        }
      } on Object {
        await _secureStore.delete(_sessionCacheKey);
      }
    }
    return AuthSessionSnapshot.accessDenied(
      email: user.email,
      message:
          'Session belum dapat diverifikasi. Sambungkan internet lalu coba lagi.',
    );
  }

  static AuthSessionRole? _parseRole(Object? value) {
    return switch (value?.toString().toUpperCase()) {
      'OWNER' => AuthSessionRole.owner,
      'CASHIER' => AuthSessionRole.cashier,
      _ => null,
    };
  }

  static String _displayName(User user) {
    final name = user.displayName?.trim();
    if (name != null && name.isNotEmpty) return name;
    final email = user.email ?? 'Pengguna';
    return email.split('@').first;
  }

  static Map<String, Object?> _toJson(AuthenticatedSession session) => {
    'userId': session.userId,
    'storeId': session.storeId,
    'role': session.role.name,
    'email': session.email,
    'displayName': session.displayName,
  };

  static AuthenticatedSession _fromJson(Map<String, dynamic> json) {
    final role = AuthSessionRole.values.byName(json['role'] as String);
    return AuthenticatedSession(
      userId: json['userId'] as String,
      storeId: json['storeId'] as String,
      role: role,
      email: json['email'] as String? ?? '',
      displayName: json['displayName'] as String? ?? 'Pengguna',
    );
  }

  static String _messageFor(String code) => switch (code) {
    'invalid-email' => 'Format email belum benar.',
    'user-disabled' => 'Akun ini dinonaktifkan.',
    'invalid-credential' ||
    'user-not-found' ||
    'wrong-password' => 'Email atau kata sandi tidak cocok.',
    'too-many-requests' => 'Terlalu banyak percobaan. Coba lagi beberapa saat.',
    'network-request-failed' =>
      'Tidak ada koneksi. Periksa internet lalu ulangi.',
    _ => 'Tidak dapat masuk sekarang. Silakan coba lagi.',
  };
}
