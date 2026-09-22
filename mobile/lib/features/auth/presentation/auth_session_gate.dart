import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_loading.dart';
import '../../../core/widgets/ryan_app_logo.dart';
import '../../../domain/entities/auth_session.dart';
import '../../../domain/repositories/auth_session_repository.dart';
import '../application/auth_session_controller.dart';

typedef AuthenticatedContentBuilder =
    Widget Function(
      BuildContext context,
      AuthenticatedSession session,
      Future<void> Function() signOut,
    );

class AuthSessionGate extends StatefulWidget {
  const AuthSessionGate({
    required this.repository,
    required this.builder,
    this.allowLocalPreview = kDebugMode,
    super.key,
  });

  final AuthSessionRepository repository;
  final AuthenticatedContentBuilder builder;
  final bool allowLocalPreview;

  @override
  State<AuthSessionGate> createState() => _AuthSessionGateState();
}

class _AuthSessionGateState extends State<AuthSessionGate> {
  late final AuthSessionController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AuthSessionController(repository: widget.repository)
      ..initialize();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _controller,
      builder: (context, _) {
        final child = switch (_controller.status) {
          AuthGateStatus.checking => const Scaffold(
            key: ValueKey('auth-checking'),
            body: AppLoadingView(label: 'Memeriksa sesi aman…'),
          ),
          AuthGateStatus.signedOut => _LoginPage(
            key: const ValueKey('auth-login'),
            controller: _controller,
            allowLocalPreview: widget.allowLocalPreview,
          ),
          AuthGateStatus.accessDenied => _AccessPendingPage(
            key: const ValueKey('auth-access-denied'),
            controller: _controller,
          ),
          AuthGateStatus.authenticated => widget.builder(
            context,
            _controller.session!,
            _controller.signOut,
          ),
        };
        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          switchInCurve: Curves.easeOutCubic,
          switchOutCurve: Curves.easeInCubic,
          child: child,
        );
      },
    );
  }
}

class _LoginPage extends StatefulWidget {
  const _LoginPage({
    required this.controller,
    required this.allowLocalPreview,
    super.key,
  });

  final AuthSessionController controller;
  final bool allowLocalPreview;

  @override
  State<_LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<_LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    FocusManager.instance.primaryFocus?.unfocus();
    if (!(_formKey.currentState?.validate() ?? false)) return;
    await widget.controller.signIn(
      email: _emailController.text,
      password: _passwordController.text,
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = widget.controller;
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: AutofillGroup(
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Align(
                        alignment: Alignment.centerLeft,
                        child: RyanAppLogo(size: 72, cacheSize: 180),
                      ),
                      const SizedBox(height: 28),
                      Text(
                        'Masuk ke warung',
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Gunakan akun pemilik atau kasir yang sudah ditautkan.',
                        style: TextStyle(color: AppColors.muted, fontSize: 15),
                      ),
                      const SizedBox(height: 28),
                      TextFormField(
                        key: const ValueKey('auth-email'),
                        controller: _emailController,
                        enabled: !controller.isSubmitting,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        autofillHints: const [AutofillHints.username],
                        autocorrect: false,
                        decoration: const InputDecoration(
                          labelText: 'Email',
                          hintText: 'nama@warung.com',
                          prefixIcon: Icon(Icons.alternate_email_rounded),
                        ),
                        validator: (value) {
                          final email = value?.trim() ?? '';
                          if (email.isEmpty) return 'Email wajib diisi.';
                          if (!email.contains('@') || !email.contains('.')) {
                            return 'Masukkan format email yang benar.';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 14),
                      TextFormField(
                        key: const ValueKey('auth-password'),
                        controller: _passwordController,
                        enabled: !controller.isSubmitting,
                        obscureText: _obscurePassword,
                        textInputAction: TextInputAction.done,
                        autofillHints: const [AutofillHints.password],
                        onFieldSubmitted: (_) => _submit(),
                        decoration: InputDecoration(
                          labelText: 'Kata sandi',
                          prefixIcon: const Icon(Icons.lock_outline_rounded),
                          suffixIcon: IconButton(
                            tooltip: _obscurePassword
                                ? 'Tampilkan kata sandi'
                                : 'Sembunyikan kata sandi',
                            onPressed: () => setState(
                              () => _obscurePassword = !_obscurePassword,
                            ),
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                            ),
                          ),
                        ),
                        validator: (value) {
                          if ((value ?? '').isEmpty) {
                            return 'Kata sandi wajib diisi.';
                          }
                          return null;
                        },
                      ),
                      if (controller.actionError != null) ...[
                        const SizedBox(height: 14),
                        _InlineError(message: controller.actionError!),
                      ],
                      const SizedBox(height: 20),
                      FilledButton(
                        key: const ValueKey('auth-submit'),
                        onPressed: controller.isSubmitting ? null : _submit,
                        child: controller.isSubmitting
                            ? const AppSpinner(size: 22, color: Colors.white)
                            : const Text('Masuk'),
                      ),
                      if (widget.allowLocalPreview) ...[
                        const SizedBox(height: 12),
                        TextButton.icon(
                          key: const ValueKey('auth-local-preview'),
                          onPressed: controller.isSubmitting
                              ? null
                              : controller.useLocalPreview,
                          icon: const Icon(Icons.offline_bolt_outlined),
                          label: const Text('Gunakan mode lokal'),
                        ),
                        const Text(
                          'Khusus debug · data tidak disinkronkan ke Firebase',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: AppColors.muted,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _AccessPendingPage extends StatelessWidget {
  const _AccessPendingPage({required this.controller, super.key});

  final AuthSessionController controller;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Column(
                children: [
                  const RyanAppLogo(size: 68, cacheSize: 160),
                  const SizedBox(height: 24),
                  Text(
                    'Akses belum siap',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    controller.accessMessage ??
                        'Minta pemilik warung mengatur akses akun ini.',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: AppColors.muted),
                  ),
                  if (controller.accountEmail?.isNotEmpty ?? false) ...[
                    const SizedBox(height: 8),
                    Text(
                      controller.accountEmail!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ],
                  if (controller.actionError != null) ...[
                    const SizedBox(height: 16),
                    _InlineError(message: controller.actionError!),
                  ],
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: controller.isSubmitting
                          ? null
                          : controller.refreshClaims,
                      icon: controller.isSubmitting
                          ? const AppSpinner(size: 20, color: Colors.white)
                          : const Icon(Icons.refresh_rounded),
                      label: const Text('Periksa akses lagi'),
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: controller.isSubmitting
                        ? null
                        : controller.signOut,
                    child: const Text('Keluar dari akun'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _InlineError extends StatelessWidget {
  const _InlineError({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      liveRegion: true,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.errorContainer,
          borderRadius: BorderRadius.circular(AppRadii.control),
        ),
        child: Row(
          children: [
            Icon(
              Icons.error_outline_rounded,
              color: Theme.of(context).colorScheme.onErrorContainer,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onErrorContainer,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
