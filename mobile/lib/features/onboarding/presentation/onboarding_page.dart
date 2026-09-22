import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/theme/app_theme.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({required this.onFinished, super.key});

  final Future<void> Function() onFinished;

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  static const _pages = <_OnboardingContent>[
    _OnboardingContent(
      title: 'Pindai barang, lanjut transaksi',
      description:
          'Arahkan kamera ke satu produk. Konfirmasi hasilnya, lalu barang langsung masuk keranjang.',
      semantics: 'Ilustrasi ponsel memindai satu produk',
      illustration: _IllustrationType.scan,
    ),
    _OnboardingContent(
      title: 'Susun warung sesuai tempatnya',
      description:
          'Atur posisi rak, lemari, dan kulkas agar lokasi barang mudah ditemukan oleh kasir.',
      semantics: 'Ilustrasi denah warung dengan rak dan kulkas',
      illustration: _IllustrationType.layout,
    ),
    _OnboardingContent(
      title: 'Bayar dengan cara yang dipilih',
      description:
          'Terima pembayaran tunai atau QRIS dinamis, kemudian simpan transaksi dan stok otomatis.',
      semantics: 'Ilustrasi pembayaran QRIS dan tunai',
      illustration: _IllustrationType.payment,
    ),
  ];

  late final PageController _controller;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _controller = PageController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _next() async {
    HapticFeedback.selectionClick();
    if (_currentPage == _pages.length - 1) {
      await widget.onFinished();
      return;
    }
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    if (reduceMotion) {
      _controller.jumpToPage(_currentPage + 1);
    } else {
      await _controller.nextPage(
        duration: const Duration(milliseconds: 240),
        curve: Curves.easeOutQuart,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLastPage = _currentPage == _pages.length - 1;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        key: const ValueKey('onboarding-page'),
        backgroundColor: AppColors.surface,
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: PageView.builder(
                  key: const ValueKey('onboarding-carousel'),
                  controller: _controller,
                  itemCount: _pages.length,
                  onPageChanged: (page) => setState(() => _currentPage = page),
                  itemBuilder: (context, index) =>
                      _OnboardingSlide(content: _pages[index], index: index),
                ),
              ),
              Semantics(
                label: 'Halaman ${_currentPage + 1} dari ${_pages.length}',
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    _pages.length,
                    (index) => AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      curve: Curves.easeOutCubic,
                      width: index == _currentPage ? 24 : 8,
                      height: 8,
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      decoration: BoxDecoration(
                        color: index == _currentPage
                            ? AppColors.slate600
                            : AppColors.slate200,
                        borderRadius: BorderRadius.circular(99),
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 22, 16, 16),
                child: Row(
                  children: [
                    TextButton(
                      key: const ValueKey('skip-onboarding'),
                      onPressed: widget.onFinished,
                      child: const Text('Lewati'),
                    ),
                    const Spacer(),
                    FilledButton.icon(
                      key: const ValueKey('next-onboarding'),
                      onPressed: _next,
                      iconAlignment: IconAlignment.end,
                      icon: Icon(
                        isLastPage
                            ? Icons.check_rounded
                            : Icons.arrow_forward_rounded,
                      ),
                      label: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 160),
                        child: Text(
                          isLastPage ? 'Mulai' : 'Lanjut',
                          key: ValueKey(isLastPage),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OnboardingSlide extends StatelessWidget {
  const _OnboardingSlide({required this.content, required this.index});

  final _OnboardingContent content;
  final int index;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxHeight < 630;
        final illustrationHeight = compact ? 300.0 : 390.0;
        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight - 24),
            child: Column(
              children: [
                Semantics(
                  image: true,
                  label: content.semantics,
                  child: ExcludeSemantics(
                    child: _FeatureIllustration(
                      type: content.illustration,
                      height: illustrationHeight,
                    ),
                  ),
                ),
                SizedBox(height: compact ? 20 : 28),
                Text(
                  content.title,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontSize: compact ? 22 : 25,
                    letterSpacing: -.35,
                  ),
                ),
                const SizedBox(height: 12),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 410),
                  child: Text(
                    content.description,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: AppColors.muted,
                      fontSize: 15,
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

enum _IllustrationType { scan, layout, payment }

class _OnboardingContent {
  const _OnboardingContent({
    required this.title,
    required this.description,
    required this.semantics,
    required this.illustration,
  });

  final String title;
  final String description;
  final String semantics;
  final _IllustrationType illustration;
}

class _FeatureIllustration extends StatelessWidget {
  const _FeatureIllustration({required this.type, required this.height});

  final _IllustrationType type;
  final double height;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: double.infinity,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: AppColors.slate50,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            const Positioned(
              top: 30,
              left: 22,
              child: _AccentCircle(size: 78, color: AppColors.slate200),
            ),
            const Positioned(
              right: 30,
              bottom: 32,
              child: _AccentCircle(size: 56, color: Color(0xFFDDF1EB)),
            ),
            switch (type) {
              _IllustrationType.scan => const _ScanIllustration(),
              _IllustrationType.layout => const _LayoutIllustration(),
              _IllustrationType.payment => const _PaymentIllustration(),
            },
          ],
        ),
      ),
    );
  }
}

class _AccentCircle extends StatelessWidget {
  const _AccentCircle({required this.size, required this.color});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
    width: size,
    height: size,
    decoration: BoxDecoration(color: color, shape: BoxShape.circle),
  );
}

class _ScanIllustration extends StatelessWidget {
  const _ScanIllustration();

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          width: 174,
          height: 244,
          decoration: BoxDecoration(
            color: AppColors.slate900,
            borderRadius: BorderRadius.circular(28),
            boxShadow: const [
              BoxShadow(
                color: Color(0x2644497E),
                offset: Offset(0, 8),
                blurRadius: 8,
              ),
            ],
          ),
          child: const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.qr_code_scanner_rounded,
                color: Colors.white,
                size: 92,
              ),
              SizedBox(height: 16),
              Text(
                '92% cocok',
                style: TextStyle(
                  color: AppColors.slate200,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
        const Positioned(
          right: 48,
          bottom: 47,
          child: _FloatingBadge(
            icon: Icons.inventory_2_rounded,
            label: 'Produk',
          ),
        ),
      ],
    );
  }
}

class _LayoutIllustration extends StatelessWidget {
  const _LayoutIllustration();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 270,
      height: 248,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x2644497E),
            offset: Offset(0, 8),
            blurRadius: 8,
          ),
        ],
      ),
      child: const Stack(
        children: [
          Positioned(
            left: 0,
            top: 0,
            bottom: 58,
            child: _FixtureBlock(width: 66, label: 'Rak A'),
          ),
          Positioned(
            left: 82,
            top: 30,
            bottom: 58,
            child: _FixtureBlock(width: 66, label: 'Rak B'),
          ),
          Positioned(
            right: 0,
            top: 0,
            height: 112,
            child: _FixtureBlock(width: 62, label: 'Kulkas', cool: true),
          ),
          Positioned(left: 0, right: 0, bottom: 0, child: _CounterBlock()),
        ],
      ),
    );
  }
}

class _PaymentIllustration extends StatelessWidget {
  const _PaymentIllustration();

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          width: 230,
          height: 250,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: const [
              BoxShadow(
                color: Color(0x2644497E),
                offset: Offset(0, 8),
                blurRadius: 8,
              ),
            ],
          ),
          child: const Column(
            children: [
              Row(
                children: [
                  Icon(Icons.receipt_long_rounded, color: AppColors.slate600),
                  Spacer(),
                  Text(
                    'Rp42.500',
                    style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
                  ),
                ],
              ),
              Divider(height: 32),
              Expanded(
                child: Icon(
                  Icons.qr_code_2_rounded,
                  size: 112,
                  color: AppColors.slate900,
                ),
              ),
              Text(
                'QRIS siap dibayar',
                style: TextStyle(
                  color: AppColors.muted,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        const Positioned(
          left: 41,
          bottom: 43,
          child: _FloatingBadge(icon: Icons.payments_rounded, label: 'Tunai'),
        ),
      ],
    );
  }
}

class _FloatingBadge extends StatelessWidget {
  const _FloatingBadge({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      boxShadow: const [
        BoxShadow(
          color: Color(0x2644497E),
          offset: Offset(0, 4),
          blurRadius: 6,
        ),
      ],
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 18, color: AppColors.slate600),
        const SizedBox(width: 7),
        Text(label, style: const TextStyle(fontWeight: FontWeight.w700)),
      ],
    ),
  );
}

class _FixtureBlock extends StatelessWidget {
  const _FixtureBlock({
    required this.width,
    required this.label,
    this.cool = false,
  });

  final double width;
  final String label;
  final bool cool;

  @override
  Widget build(BuildContext context) => Container(
    width: width,
    decoration: BoxDecoration(
      color: cool ? const Color(0xFFDCEEF5) : AppColors.slate100,
      borderRadius: BorderRadius.circular(10),
    ),
    alignment: Alignment.center,
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          cool ? Icons.kitchen_rounded : Icons.shelves,
          color: AppColors.slate700,
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
        ),
      ],
    ),
  );
}

class _CounterBlock extends StatelessWidget {
  const _CounterBlock();

  @override
  Widget build(BuildContext context) => Container(
    height: 44,
    decoration: BoxDecoration(
      color: AppColors.slate700,
      borderRadius: BorderRadius.circular(10),
    ),
    alignment: Alignment.center,
    child: const Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.point_of_sale_rounded, size: 19, color: Colors.white),
        SizedBox(width: 8),
        Text(
          'Meja kasir',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
        ),
      ],
    ),
  );
}
