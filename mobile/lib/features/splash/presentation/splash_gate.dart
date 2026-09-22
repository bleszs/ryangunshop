import 'dart:async';
import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_loading.dart';
import '../../../core/widgets/ryan_app_logo.dart';

class SplashGate extends StatefulWidget {
  const SplashGate({required this.child, super.key});
  final Widget child;
  @override
  State<SplashGate> createState() => _SplashGateState();
}

class _SplashGateState extends State<SplashGate>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  Timer? _timer;
  bool _started = false;
  bool _showApp = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) return;
    _started = true;
    if (MediaQuery.disableAnimationsOf(context)) {
      _controller.value = 1;
      _timer = Timer(const Duration(milliseconds: 80), _enterApp);
    } else {
      _controller.forward();
      _timer = Timer(const Duration(milliseconds: 1450), _enterApp);
    }
  }

  void _enterApp() {
    if (mounted) setState(() => _showApp = true);
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    return AnimatedSwitcher(
      duration: reduceMotion
          ? Duration.zero
          : const Duration(milliseconds: 280),
      switchInCurve: Curves.easeOutQuart,
      switchOutCurve: Curves.easeInCubic,
      transitionBuilder: (child, animation) => reduceMotion
          ? child
          : FadeTransition(
              opacity: animation,
              child: ScaleTransition(
                scale: Tween<double>(begin: .985, end: 1).animate(animation),
                child: child,
              ),
            ),
      child: _showApp
          ? KeyedSubtree(key: const ValueKey('app'), child: widget.child)
          : _SplashScreen(
              key: const ValueKey('splash'),
              animation: _controller,
            ),
    );
  }
}

class _SplashScreen extends StatelessWidget {
  const _SplashScreen({required this.animation, super.key});
  final Animation<double> animation;

  @override
  Widget build(BuildContext context) {
    final logoAnimation = CurvedAnimation(
      parent: animation,
      curve: const Interval(0, .68, curve: Curves.easeOutQuart),
    );
    final copyAnimation = CurvedAnimation(
      parent: animation,
      curve: const Interval(.38, .82, curve: Curves.easeOutCubic),
    );
    final statusAnimation = CurvedAnimation(
      parent: animation,
      curve: const Interval(.62, 1, curve: Curves.easeOutCubic),
    );
    final logoSize = (MediaQuery.sizeOf(context).width * .72).clamp(
      232.0,
      292.0,
    );
    return Scaffold(
      backgroundColor: AppColors.slate900,
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment(-.25, -.55),
            radius: 1.25,
            colors: [AppColors.slate700, AppColors.slate900, Color(0xFF0A0B12)],
            stops: [0, .48, 1],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
            child: Column(
              children: [
                const Spacer(flex: 3),
                FadeTransition(
                  opacity: logoAnimation,
                  child: ScaleTransition(
                    scale: Tween<double>(
                      begin: .86,
                      end: 1,
                    ).animate(logoAnimation),
                    child: Container(
                      key: const ValueKey('splash-logo'),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(logoSize * .16),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x338B91D4),
                            blurRadius: 28,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: RyanAppLogo(size: logoSize),
                    ),
                  ),
                ),
                const SizedBox(height: 22),
                FadeTransition(
                  opacity: copyAnimation,
                  child: const Column(
                    children: [
                      Text(
                        'Kasir cerdas untuk warung Anda',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          height: 1.25,
                          letterSpacing: -.2,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Warung rapi, transaksi pasti.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: AppColors.slate200,
                          fontSize: 14,
                          height: 1.4,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(flex: 2),
                FadeTransition(
                  opacity: statusAnimation,
                  child: const Column(
                    children: [
                      AppSpinner(size: 22, color: Colors.white),
                      SizedBox(height: 12),
                      Text(
                        'Menyiapkan ruang kerja',
                        style: TextStyle(
                          color: AppColors.slate200,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
