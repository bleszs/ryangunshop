import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ryangunshop/core/theme/app_theme.dart';
import 'package:ryangunshop/domain/entities/auth_session.dart';
import 'package:ryangunshop/domain/repositories/auth_session_repository.dart';
import 'package:ryangunshop/features/auth/presentation/auth_session_gate.dart';

void main() {
  testWidgets('login memvalidasi input dan meneruskan kredensial', (
    tester,
  ) async {
    final repository = _FakeAuthSessionRepository();
    addTearDown(repository.dispose);
    await _pumpGate(tester, repository);

    repository.emit(const AuthSessionSnapshot.signedOut());
    await tester.pumpAndSettle();
    expect(find.text('Masuk ke warung'), findsOneWidget);
    expect(find.byKey(const ValueKey('auth-local-preview')), findsNothing);

    await tester.tap(find.byKey(const ValueKey('auth-submit')));
    await tester.pump();
    expect(find.text('Email wajib diisi.'), findsOneWidget);
    expect(find.text('Kata sandi wajib diisi.'), findsOneWidget);

    await tester.enterText(
      find.byKey(const ValueKey('auth-email')),
      'owner@ryangunshop.id',
    );
    await tester.enterText(
      find.byKey(const ValueKey('auth-password')),
      'rahasia-kuat',
    );
    await tester.tap(find.byKey(const ValueKey('auth-submit')));
    await tester.pump();

    expect(repository.lastEmail, 'owner@ryangunshop.id');
    expect(repository.lastPassword, 'rahasia-kuat');
  });

  testWidgets('session tervalidasi membawa storeId ke konten aplikasi', (
    tester,
  ) async {
    final repository = _FakeAuthSessionRepository();
    addTearDown(repository.dispose);
    await _pumpGate(tester, repository);

    repository.emit(
      const AuthSessionSnapshot.authenticated(
        AuthenticatedSession(
          userId: 'owner-1',
          storeId: 'store-from-claims',
          role: AuthSessionRole.owner,
          email: 'owner@ryangunshop.id',
          displayName: 'Ryan',
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('store-from-claims'), findsOneWidget);
    expect(find.text('owner'), findsOneWidget);
  });

  testWidgets('akun tanpa claims menampilkan akses belum siap', (tester) async {
    final repository = _FakeAuthSessionRepository();
    addTearDown(repository.dispose);
    await _pumpGate(tester, repository);

    repository.emit(
      const AuthSessionSnapshot.accessDenied(
        email: 'kasir@ryangunshop.id',
        message: 'Akun belum ditautkan ke warung.',
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Akses belum siap'), findsOneWidget);
    expect(find.text('kasir@ryangunshop.id'), findsOneWidget);
    expect(find.text('Akun belum ditautkan ke warung.'), findsOneWidget);
  });
}

Future<void> _pumpGate(
  WidgetTester tester,
  _FakeAuthSessionRepository repository,
) async {
  tester.view.physicalSize = const Size(400, 800);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.pumpWidget(
    MaterialApp(
      theme: AppTheme.light,
      home: AuthSessionGate(
        repository: repository,
        allowLocalPreview: false,
        builder: (_, session, _) => Scaffold(
          body: Column(
            children: [Text(session.storeId), Text(session.role.name)],
          ),
        ),
      ),
    ),
  );
}

final class _FakeAuthSessionRepository implements AuthSessionRepository {
  final _controller = StreamController<AuthSessionSnapshot>.broadcast();

  String? lastEmail;
  String? lastPassword;
  AuthSessionSnapshot refreshResult = const AuthSessionSnapshot.signedOut();

  void emit(AuthSessionSnapshot snapshot) => _controller.add(snapshot);

  Future<void> dispose() => _controller.close();

  @override
  Future<AuthSessionSnapshot> refreshSession() async => refreshResult;

  @override
  Future<void> signIn({required String email, required String password}) async {
    lastEmail = email;
    lastPassword = password;
  }

  @override
  Future<void> signOut() async {
    emit(const AuthSessionSnapshot.signedOut());
  }

  @override
  Stream<AuthSessionSnapshot> watchSession() => _controller.stream;
}
