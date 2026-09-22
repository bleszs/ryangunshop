import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_loading.dart';
import '../data/onboarding_store.dart';
import 'onboarding_page.dart';

class OnboardingGate extends StatefulWidget {
  const OnboardingGate({required this.child, required this.store, super.key});

  final Widget child;
  final OnboardingStore store;

  @override
  State<OnboardingGate> createState() => _OnboardingGateState();
}

class _OnboardingGateState extends State<OnboardingGate> {
  bool _loading = true;
  bool _completed = false;

  @override
  void initState() {
    super.initState();
    _loadStatus();
  }

  Future<void> _loadStatus() async {
    try {
      final completed = await widget.store.isCompleted();
      if (mounted) setState(() => _completed = completed);
    } catch (_) {
      // Preference errors fall back to an optional, skippable onboarding.
      if (mounted) setState(() => _completed = false);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _finish() async {
    if (mounted) setState(() => _completed = true);
    try {
      await widget.store.markCompleted();
    } catch (_) {
      // Onboarding must never block access when preference storage is down.
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        backgroundColor: AppColors.canvas,
        body: SafeArea(
          child: AppLoadingView(label: 'Menyiapkan pengalaman pertama…'),
        ),
      );
    }
    return AnimatedSwitcher(
      duration: MediaQuery.disableAnimationsOf(context)
          ? Duration.zero
          : const Duration(milliseconds: 220),
      switchInCurve: Curves.easeOutQuart,
      child: _completed
          ? KeyedSubtree(key: const ValueKey('dashboard'), child: widget.child)
          : OnboardingPage(
              key: const ValueKey('onboarding'),
              onFinished: _finish,
            ),
    );
  }
}
