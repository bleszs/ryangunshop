import '../entities/auth_session.dart';

abstract interface class AuthSessionRepository {
  Stream<AuthSessionSnapshot> watchSession();

  Future<void> signIn({required String email, required String password});

  Future<AuthSessionSnapshot> refreshSession();

  Future<void> signOut();
}
