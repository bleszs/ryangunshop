enum AuthSessionRole { owner, cashier }

class AuthenticatedSession {
  const AuthenticatedSession({
    required this.userId,
    required this.storeId,
    required this.role,
    required this.email,
    required this.displayName,
    this.isLocalPreview = false,
  });

  final String userId;
  final String storeId;
  final AuthSessionRole role;
  final String email;
  final String displayName;
  final bool isLocalPreview;

  bool get isOwner => role == AuthSessionRole.owner;
}

enum AuthSessionStatus { signedOut, authenticated, accessDenied }

class AuthSessionSnapshot {
  const AuthSessionSnapshot._({
    required this.status,
    this.session,
    this.email,
    this.message,
  });

  const AuthSessionSnapshot.signedOut()
    : this._(status: AuthSessionStatus.signedOut);

  const AuthSessionSnapshot.authenticated(AuthenticatedSession session)
    : this._(status: AuthSessionStatus.authenticated, session: session);

  const AuthSessionSnapshot.accessDenied({String? email, String? message})
    : this._(
        status: AuthSessionStatus.accessDenied,
        email: email,
        message: message,
      );

  final AuthSessionStatus status;
  final AuthenticatedSession? session;
  final String? email;
  final String? message;
}

class AuthSignInFailure implements Exception {
  const AuthSignInFailure(this.message);

  final String message;

  @override
  String toString() => message;
}
