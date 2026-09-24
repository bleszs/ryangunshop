import 'dart:async';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

import '../../../core/camera/camera_permission_gateway.dart';
import '../../../core/camera/product_camera_service.dart';
import '../../../core/privacy/correction_photo_store.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_loading.dart';
import '../../../domain/entities/entities.dart';
import '../../payment/presentation/cart_checkout_page.dart';
import 'transaction_view_model.dart';

typedef TransactionViewModelFactory = Future<TransactionViewModel> Function();

class ProductScannerPage extends StatefulWidget {
  const ProductScannerPage({
    required this.createViewModel,
    this.cameraService,
    this.correctionPhotoStore,
    this.permissionGateway = const PermissionHandlerCameraPermissionGateway(),
    super.key,
  });

  final TransactionViewModelFactory createViewModel;
  final ProductCameraService? cameraService;
  final LocalCorrectionPhotoStore? correctionPhotoStore;
  final CameraPermissionGateway permissionGateway;

  @override
  State<ProductScannerPage> createState() => _ProductScannerPageState();
}

enum _ScannerState {
  preparing,
  ready,
  permissionDenied,
  permissionPermanentlyDenied,
  restricted,
  unavailable,
  paused,
  failed,
}

class _ProductScannerPageState extends State<ProductScannerPage>
    with WidgetsBindingObserver {
  late final ProductCameraService _camera;
  late final LocalCorrectionPhotoStore _correctionPhotos;
  TransactionViewModel? _transaction;
  _ScannerState _scannerState = _ScannerState.preparing;
  String? _cameraError;
  bool _isBarcodeScanning = false;
  bool _isPreparingCorrectionPhoto = false;
  bool _torchEnabled = false;
  bool _releasedForLifecycle = false;
  int _generation = 0;

  @override
  void initState() {
    super.initState();
    _camera = widget.cameraService ?? ProductCameraService();
    _correctionPhotos =
        widget.correctionPhotoStore ?? LocalCorrectionPhotoStore();
    unawaited(_correctionPhotos.purgeExpired());
    WidgetsBinding.instance.addObserver(this);
    unawaited(_prepare());
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      _releasedForLifecycle = true;
      unawaited(_releaseCamera(showPausedState: true));
    } else if (state == AppLifecycleState.resumed && _releasedForLifecycle) {
      _releasedForLifecycle = false;
      unawaited(_initializeCamera());
    }
  }

  Future<void> _prepare() async {
    try {
      final transaction = await widget.createViewModel();
      if (!mounted) {
        await transaction.close();
        transaction.dispose();
        return;
      }
      _transaction = transaction..addListener(_refresh);
      await _initializeCamera();
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _scannerState = _ScannerState.failed;
        _cameraError = 'Layanan pemindaian belum dapat disiapkan.';
      });
    }
  }

  Future<void> _initializeCamera() async {
    final generation = ++_generation;
    if (mounted) {
      setState(() {
        _scannerState = _ScannerState.preparing;
        _cameraError = null;
      });
    }
    try {
      final permission = await widget.permissionGateway.request();
      if (!mounted || generation != _generation) return;
      if (permission != CameraPermissionState.granted) {
        setState(() {
          _scannerState = switch (permission) {
            CameraPermissionState.denied => _ScannerState.permissionDenied,
            CameraPermissionState.permanentlyDenied =>
              _ScannerState.permissionPermanentlyDenied,
            CameraPermissionState.restricted => _ScannerState.restricted,
            CameraPermissionState.granted => _ScannerState.preparing,
          };
        });
        return;
      }
      await _camera.initialize();
      if (!mounted || generation != _generation) {
        await _camera.dispose();
        return;
      }
      setState(() => _scannerState = _ScannerState.ready);
      await _startAnalysis();
    } on CameraException catch (error) {
      if (!mounted || generation != _generation) return;
      setState(() {
        _scannerState = error.code.contains('Denied')
            ? _ScannerState.permissionDenied
            : _ScannerState.unavailable;
        _cameraError = _friendlyCameraError(error);
      });
    } catch (_) {
      if (!mounted || generation != _generation) return;
      setState(() {
        _scannerState = _ScannerState.unavailable;
        _cameraError =
            'Kamera tidak tersedia atau sedang digunakan aplikasi lain.';
      });
    }
  }

  Future<void> _startAnalysis() async {
    final transaction = _transaction;
    final controller = _camera.controller;
    if (transaction == null ||
        controller == null ||
        !controller.value.isInitialized) {
      return;
    }
    try {
      await _camera.startAnalysis(
        onFrame: (frame) async {
          await transaction.analyzeFrame(frame);
          if (transaction.pendingRecognition != null ||
              transaction.fallbackReason != null) {
            await _camera.stopAnalysis();
          }
        },
        onError: (error, stackTrace) {
          if (!mounted) return;
          setState(() {
            _cameraError = 'Frame kamera gagal dianalisis. Coba pindai ulang.';
          });
        },
      );
    } catch (_) {
      if (!mounted) return;
      setState(() => _cameraError = 'Analisis kamera belum dapat dimulai.');
    }
  }

  Future<void> _restartAnalysis() async {
    final transaction = _transaction;
    if (transaction == null || _scannerState != _ScannerState.ready) return;
    transaction.resumeRecognition();
    setState(() => _cameraError = null);
    await _camera.stopAnalysis();
    await _startAnalysis();
  }

  Future<void> _releaseCamera({required bool showPausedState}) async {
    _generation += 1;
    await _camera.dispose();
    if (mounted && showPausedState) {
      setState(() => _scannerState = _ScannerState.paused);
    }
  }

  Future<void> _toggleTorch() async {
    final controller = _camera.controller;
    if (controller == null) return;
    try {
      final enabled = !_torchEnabled;
      await controller.setFlashMode(enabled ? FlashMode.torch : FlashMode.off);
      if (mounted) setState(() => _torchEnabled = enabled);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lampu kamera tidak tersedia.')),
      );
    }
  }

  Future<void> _scanBarcode() async {
    final transaction = _transaction;
    if (transaction == null || _isBarcodeScanning) return;
    setState(() => _isBarcodeScanning = true);
    final before = transaction.cartQuantity;
    try {
      final path = await _camera.captureForBarcode();
      await transaction.scanBarcodeFile(path);
      if (!mounted) return;
      if (transaction.cartQuantity > before) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Produk barcode masuk ke keranjang.')),
        );
        await _restartAnalysis();
      }
    } catch (_) {
      if (!mounted) return;
      setState(() => _cameraError = 'Barcode belum dapat dipindai. Coba lagi.');
    } finally {
      if (mounted) setState(() => _isBarcodeScanning = false);
    }
  }

  Future<void> _confirmPrediction() async {
    final transaction = _transaction;
    final product = transaction?.pendingRecognition?.product;
    if (transaction == null || product == null) return;
    await transaction.confirmPrediction();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${product.name} masuk ke keranjang.')),
    );
    await _restartAnalysis();
  }

  Future<void> _openManualSearch() async {
    final transaction = _transaction;
    if (transaction == null) return;
    final product = await showModalBottomSheet<ProductEntity>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => _ManualProductSearch(transaction: transaction),
    );
    if (product == null || !mounted) return;
    final pending = transaction.pendingRecognition;
    if (pending != null) {
      final isCorrection = product.id != pending.product.id;
      final sharePhoto = isCorrection
          ? await showModalBottomSheet<bool>(
              context: context,
              isScrollControlled: true,
              showDragHandle: true,
              builder: (_) =>
                  _CorrectionConsentSheet(productName: product.name),
            )
          : false;
      if (!mounted) return;
      if (sharePhoto == true) {
        await _saveCorrectionWithPhoto(transaction, product);
      } else {
        await transaction.correctPrediction(product);
      }
    } else {
      transaction.addToCart(product);
    }
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${product.name} masuk ke keranjang.')),
    );
    await _restartAnalysis();
  }

  Future<void> _saveCorrectionWithPhoto(
    TransactionViewModel transaction,
    ProductEntity product,
  ) async {
    setState(() => _isPreparingCorrectionPhoto = true);
    String? sourcePath;
    try {
      sourcePath = await _camera.captureStillPhoto();
      final stored = await _correctionPhotos.sanitizeAndStore(
        storeId: transaction.storeId,
        sourceImagePath: sourcePath,
      );
      await transaction.correctPrediction(
        product,
        correctionPhotoUri: stored.path,
        correctionPhotoExpiresAt: stored.expiresAt,
        consentToTraining: true,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Koreksi dan foto privat masuk antrean sinkronisasi.'),
        ),
      );
    } on Object {
      await transaction.correctPrediction(product);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Produk tetap ditambahkan. Foto koreksi gagal disiapkan dan tidak disimpan.',
          ),
        ),
      );
    } finally {
      if (sourcePath != null) {
        try {
          final source = File(sourcePath);
          if (await source.exists()) await source.delete();
        } on Object {
          // Cache kamera akan dibersihkan sistem; jangan batalkan transaksi.
        }
      }
      if (mounted) setState(() => _isPreparingCorrectionPhoto = false);
    }
  }

  Future<void> _openCart() async {
    final transaction = _transaction;
    if (transaction == null || transaction.cart.isEmpty) return;
    await _releaseCamera(showPausedState: true);
    if (!mounted) return;
    final completed = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => CartCheckoutPage(viewModel: transaction),
      ),
    );
    if (!mounted) return;
    if (completed == true) {
      Navigator.pop(context, true);
      return;
    }
    _torchEnabled = false;
    await _initializeCamera();
  }

  void _refresh() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _generation += 1;
    final transaction = _transaction;
    transaction?.removeListener(_refresh);
    unawaited(_camera.dispose());
    if (transaction != null) {
      unawaited(transaction.close());
      transaction.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.slate900,
      body: switch (_scannerState) {
        _ScannerState.preparing => const _ScannerLoading(),
        _ScannerState.ready => _buildCamera(context),
        _ScannerState.permissionDenied => _ScannerUnavailable(
          icon: Icons.no_photography_outlined,
          title: 'Izinkan akses kamera',
          message:
              'Kamera diperlukan untuk mengenali produk dan membaca barcode.',
          primaryLabel: 'Coba lagi',
          onPrimary: _initializeCamera,
          onManual: _openManualSearch,
        ),
        _ScannerState.permissionPermanentlyDenied => _ScannerUnavailable(
          icon: Icons.settings_outlined,
          title: 'Kamera diblokir',
          message:
              'Aktifkan izin kamera dari Pengaturan Android, lalu kembali ke aplikasi.',
          primaryLabel: 'Buka pengaturan',
          onPrimary: widget.permissionGateway.openSettings,
          onManual: _openManualSearch,
        ),
        _ScannerState.restricted => _ScannerUnavailable(
          icon: Icons.admin_panel_settings_outlined,
          title: 'Kamera dibatasi',
          message:
              'Kebijakan perangkat membatasi kamera. Gunakan pencarian produk manual.',
          onManual: _openManualSearch,
        ),
        _ScannerState.unavailable ||
        _ScannerState.failed => _ScannerUnavailable(
          icon: Icons.camera_outlined,
          title: 'Kamera belum tersedia',
          message: _cameraError ?? 'Periksa kamera perangkat lalu coba lagi.',
          primaryLabel: 'Coba lagi',
          onPrimary: _initializeCamera,
          onManual: _openManualSearch,
        ),
        _ScannerState.paused => const _ScannerLoading(label: 'Menjeda kamera…'),
      },
    );
  }

  Widget _buildCamera(BuildContext context) {
    final controller = _camera.controller;
    if (controller == null || !controller.value.isInitialized) {
      return const _ScannerLoading();
    }
    final transaction = _transaction;
    return Stack(
      fit: StackFit.expand,
      children: [
        _CameraCover(controller: controller),
        const _ScanGuide(),
        SafeArea(
          child: Align(
            alignment: Alignment.topCenter,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
              child: Row(
                children: [
                  _CameraIconButton(
                    tooltip: 'Kembali',
                    icon: Icons.arrow_back_rounded,
                    onPressed: () => Navigator.pop(context),
                  ),
                  const Spacer(),
                  if (transaction != null && transaction.cartQuantity > 0)
                    _CartBadge(
                      quantity: transaction.cartQuantity,
                      onTap: _openCart,
                    ),
                  const SizedBox(width: 8),
                  _CameraIconButton(
                    tooltip: _torchEnabled ? 'Matikan lampu' : 'Nyalakan lampu',
                    icon: _torchEnabled
                        ? Icons.flashlight_on_rounded
                        : Icons.flashlight_off_outlined,
                    onPressed: _toggleTorch,
                  ),
                ],
              ),
            ),
          ),
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: SafeArea(
            minimum: const EdgeInsets.fromLTRB(12, 0, 12, 12),
            child: _ScannerResultPanel(
              transaction: transaction,
              cameraError: _cameraError,
              isBarcodeScanning: _isBarcodeScanning,
              isPreparingCorrectionPhoto: _isPreparingCorrectionPhoto,
              onConfirm: _confirmPrediction,
              onRetry: _restartAnalysis,
              onBarcode: _scanBarcode,
              onManual: _openManualSearch,
            ),
          ),
        ),
      ],
    );
  }
}

class _CameraCover extends StatelessWidget {
  const _CameraCover({required this.controller});
  final CameraController controller;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenAspect = constraints.maxWidth / constraints.maxHeight;
        final scale = 1 / (controller.value.aspectRatio * screenAspect);
        return ClipRect(
          child: Transform.scale(
            scale: scale < 1 ? 1 : scale,
            child: Center(child: CameraPreview(controller)),
          ),
        );
      },
    );
  }
}

class _ScanGuide extends StatelessWidget {
  const _ScanGuide();

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.only(bottom: 92),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: MediaQuery.sizeOf(context).width * .74,
                height: MediaQuery.sizeOf(context).width * .74,
                child: CustomPaint(painter: _GuidePainter()),
              ),
              const SizedBox(height: 14),
              const DecoratedBox(
                decoration: BoxDecoration(
                  color: Color(0xD925283F),
                  borderRadius: BorderRadius.all(Radius.circular(99)),
                ),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  child: Text(
                    'Posisikan satu produk di dalam bingkai',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GuidePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    const length = 32.0;
    final path = Path()
      ..moveTo(0, length)
      ..lineTo(0, 0)
      ..lineTo(length, 0)
      ..moveTo(size.width - length, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width, length)
      ..moveTo(size.width, size.height - length)
      ..lineTo(size.width, size.height)
      ..lineTo(size.width - length, size.height)
      ..moveTo(length, size.height)
      ..lineTo(0, size.height)
      ..lineTo(0, size.height - length);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _ScannerResultPanel extends StatelessWidget {
  const _ScannerResultPanel({
    required this.transaction,
    required this.cameraError,
    required this.isBarcodeScanning,
    required this.isPreparingCorrectionPhoto,
    required this.onConfirm,
    required this.onRetry,
    required this.onBarcode,
    required this.onManual,
  });

  final TransactionViewModel? transaction;
  final String? cameraError;
  final bool isBarcodeScanning;
  final bool isPreparingCorrectionPhoto;
  final VoidCallback onConfirm;
  final VoidCallback onRetry;
  final VoidCallback onBarcode;
  final VoidCallback onManual;

  @override
  Widget build(BuildContext context) {
    final pending = transaction?.pendingRecognition;
    final fallback = transaction?.fallbackReason;
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(AppRadii.surface),
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: isPreparingCorrectionPhoto
            ? const _CorrectionPhotoStatus()
            : pending != null
            ? _RecognitionResult(
                pending: pending,
                onConfirm: onConfirm,
                onManual: onManual,
              )
            : fallback != null || cameraError != null
            ? _FallbackActions(
                reason: fallback,
                message: cameraError ?? transaction?.message,
                isBarcodeScanning: isBarcodeScanning,
                onRetry: onRetry,
                onBarcode: onBarcode,
                onManual: onManual,
              )
            : _ScanningStatus(
                isAnalyzing: transaction?.isAnalyzing ?? true,
                onBarcode: onBarcode,
                onManual: onManual,
              ),
      ),
    );
  }
}

class _CorrectionPhotoStatus extends StatelessWidget {
  const _CorrectionPhotoStatus();

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        AppSpinner(size: 24),
        SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Mengamankan foto koreksi…',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
              SizedBox(height: 2),
              Text(
                'Metadata lokasi dihapus sebelum foto disimpan.',
                style: TextStyle(color: AppColors.muted, fontSize: 12),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _RecognitionResult extends StatelessWidget {
  const _RecognitionResult({
    required this.pending,
    required this.onConfirm,
    required this.onManual,
  });

  final PendingRecognition pending;
  final VoidCallback onConfirm;
  final VoidCallback onManual;

  @override
  Widget build(BuildContext context) {
    final confidence = pending.candidates.firstOrNull?.confidence ?? 0;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            const DecoratedBox(
              decoration: BoxDecoration(
                color: Color(0xFFDDF1EB),
                borderRadius: BorderRadius.all(Radius.circular(12)),
              ),
              child: SizedBox.square(
                dimension: 48,
                child: Icon(Icons.check_rounded, color: AppColors.success),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    pending.product.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 3),
                  Text(
                    'Keyakinan ${(confidence * 100).round()}% · stok ${pending.product.stock}',
                    style: const TextStyle(
                      color: AppColors.muted,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: onManual,
                child: const Text('Bukan ini'),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              flex: 2,
              child: FilledButton.icon(
                onPressed: onConfirm,
                icon: const Icon(Icons.add_shopping_cart_rounded),
                label: const Text('Masukkan'),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _FallbackActions extends StatelessWidget {
  const _FallbackActions({
    required this.reason,
    required this.message,
    required this.isBarcodeScanning,
    required this.onRetry,
    required this.onBarcode,
    required this.onManual,
  });

  final RecognitionFailureReason? reason;
  final String? message;
  final bool isBarcodeScanning;
  final VoidCallback onRetry;
  final VoidCallback onBarcode;
  final VoidCallback onManual;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          _fallbackTitle(reason),
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 4),
        Text(
          message ?? 'Gunakan barcode atau cari produk secara manual.',
          style: const TextStyle(color: AppColors.muted, height: 1.35),
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: isBarcodeScanning ? null : onBarcode,
                icon: isBarcodeScanning
                    ? const AppSpinner(size: 18)
                    : const Icon(Icons.qr_code_2_rounded),
                label: const Text('Barcode'),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: onManual,
                icon: const Icon(Icons.search_rounded),
                label: const Text('Cari'),
              ),
            ),
            const SizedBox(width: 8),
            IconButton.filledTonal(
              tooltip: 'Pindai ulang',
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
            ),
          ],
        ),
      ],
    );
  }
}

class _ScanningStatus extends StatelessWidget {
  const _ScanningStatus({
    required this.isAnalyzing,
    required this.onBarcode,
    required this.onManual,
  });

  final bool isAnalyzing;
  final VoidCallback onBarcode;
  final VoidCallback onManual;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const AppSpinner(size: 24),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isAnalyzing ? 'Mengenali produk…' : 'Arahkan kamera ke produk',
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 2),
              const Text(
                'Satu produk dalam satu waktu',
                style: TextStyle(color: AppColors.muted, fontSize: 12),
              ),
            ],
          ),
        ),
        IconButton(
          tooltip: 'Pindai barcode',
          onPressed: onBarcode,
          icon: const Icon(Icons.qr_code_2_rounded),
        ),
        IconButton(
          tooltip: 'Cari manual',
          onPressed: onManual,
          icon: const Icon(Icons.search_rounded),
        ),
      ],
    );
  }
}

class _ScannerLoading extends StatelessWidget {
  const _ScannerLoading({this.label = 'Menyiapkan kamera…'});
  final String label;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Stack(
        children: [
          Positioned(
            left: 12,
            top: 8,
            child: _CameraIconButton(
              tooltip: 'Kembali',
              icon: Icons.arrow_back_rounded,
              onPressed: () => Navigator.pop(context),
            ),
          ),
          Center(child: AppLoadingView(label: label, light: true)),
        ],
      ),
    );
  }
}

class _ScannerUnavailable extends StatelessWidget {
  const _ScannerUnavailable({
    required this.icon,
    required this.title,
    required this.message,
    required this.onManual,
    this.primaryLabel,
    this.onPrimary,
  });

  final IconData icon;
  final String title;
  final String message;
  final String? primaryLabel;
  final FutureOr<void> Function()? onPrimary;
  final VoidCallback onManual;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: _CameraIconButton(
                tooltip: 'Kembali',
                icon: Icons.arrow_back_rounded,
                onPressed: () => Navigator.pop(context),
              ),
            ),
            const Spacer(),
            DecoratedBox(
              decoration: BoxDecoration(
                color: AppColors.slate800,
                borderRadius: BorderRadius.circular(AppRadii.hero),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    Icon(icon, color: AppColors.slate200, size: 48),
                    const SizedBox(height: 18),
                    Text(
                      title,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontFamily: 'serif',
                        color: Colors.white,
                        fontSize: 26,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      message,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: AppColors.slate200,
                        height: 1.45,
                      ),
                    ),
                    const SizedBox(height: 22),
                    if (primaryLabel != null && onPrimary != null)
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton(
                          style: FilledButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: AppColors.slate900,
                          ),
                          onPressed: onPrimary,
                          child: Text(primaryLabel!),
                        ),
                      ),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      child: TextButton.icon(
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.slate100,
                        ),
                        onPressed: onManual,
                        icon: const Icon(Icons.search_rounded),
                        label: const Text('Cari produk manual'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const Spacer(flex: 2),
          ],
        ),
      ),
    );
  }
}

class _CameraIconButton extends StatelessWidget {
  const _CameraIconButton({
    required this.tooltip,
    required this.icon,
    required this.onPressed,
  });

  final String tooltip;
  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: tooltip,
      style: IconButton.styleFrom(
        backgroundColor: const Color(0xD925283F),
        foregroundColor: Colors.white,
      ),
      onPressed: onPressed,
      icon: Icon(icon),
    );
  }
}

class _CartBadge extends StatelessWidget {
  const _CartBadge({required this.quantity, required this.onTap});
  final int quantity;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Buka keranjang, $quantity barang',
      child: Material(
        color: const Color(0xE6FFFFFF),
        borderRadius: BorderRadius.circular(99),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          key: const ValueKey('open-cart'),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 8),
            child: Row(
              children: [
                const Icon(
                  Icons.shopping_bag_outlined,
                  color: AppColors.slate900,
                  size: 18,
                ),
                const SizedBox(width: 5),
                Text(
                  '$quantity',
                  style: const TextStyle(
                    color: AppColors.slate900,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CorrectionConsentSheet extends StatelessWidget {
  const _CorrectionConsentSheet({required this.productName});

  final String productName;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Align(
              alignment: Alignment.centerLeft,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: AppColors.slate100,
                  borderRadius: BorderRadius.all(
                    Radius.circular(AppRadii.control),
                  ),
                ),
                child: SizedBox.square(
                  dimension: 48,
                  child: Icon(
                    Icons.auto_awesome_outlined,
                    color: AppColors.slate700,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 18),
            const Text(
              'Bantu tingkatkan pengenalan?',
              style: AppTextStyles.editorialTitle,
            ),
            const SizedBox(height: 8),
            Text(
              'Pilihan yang benar: $productName. Jika Anda setuju, RyanGunshop '
              'akan mengambil satu foto baru sebagai contoh pelatihan.',
              style: const TextStyle(color: AppColors.muted, height: 1.45),
            ),
            const SizedBox(height: 18),
            const _PrivacyFact(
              icon: Icons.location_off_outlined,
              text: 'EXIF dan informasi lokasi dihapus sebelum disimpan.',
            ),
            const SizedBox(height: 10),
            const _PrivacyFact(
              icon: Icons.schedule_outlined,
              text: 'Foto disimpan maksimal 30 hari lalu dihapus.',
            ),
            const SizedBox(height: 10),
            const _PrivacyFact(
              icon: Icons.cloud_upload_outlined,
              text: 'Saat offline, upload menunggu koneksi yang aman.',
            ),
            const SizedBox(height: 22),
            FilledButton.icon(
              onPressed: () => Navigator.pop(context, true),
              icon: const Icon(Icons.camera_alt_outlined),
              label: const Text('Setuju & ambil foto'),
            ),
            const SizedBox(height: 8),
            OutlinedButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Lanjut tanpa foto'),
            ),
            const SizedBox(height: 8),
            const Text(
              'Menolak tidak memengaruhi transaksi atau akses aplikasi.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.muted, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}

class _PrivacyFact extends StatelessWidget {
  const _PrivacyFact({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 21, color: AppColors.slate600),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(color: AppColors.ink, height: 1.4),
          ),
        ),
      ],
    );
  }
}

class _ManualProductSearch extends StatefulWidget {
  const _ManualProductSearch({required this.transaction});
  final TransactionViewModel transaction;

  @override
  State<_ManualProductSearch> createState() => _ManualProductSearchState();
}

class _ManualProductSearchState extends State<_ManualProductSearch> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          20,
          4,
          20,
          20 + MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: SizedBox(
          height: MediaQuery.sizeOf(context).height * .62,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text('Cari produk', style: AppTextStyles.editorialTitle),
              const SizedBox(height: 6),
              const Text(
                'Cari berdasarkan nama, barcode, atau lokasi rak.',
                style: TextStyle(color: AppColors.muted),
              ),
              const SizedBox(height: 16),
              TextField(
                autofocus: true,
                textInputAction: TextInputAction.search,
                decoration: const InputDecoration(
                  hintText: 'Contoh: air mineral',
                  prefixIcon: Icon(Icons.search_rounded),
                ),
                onChanged: (value) {
                  setState(() => _query = value.trim());
                  unawaited(widget.transaction.search(value));
                },
              ),
              const SizedBox(height: 12),
              Expanded(
                child: AnimatedBuilder(
                  animation: widget.transaction,
                  builder: (context, _) {
                    if (_query.isEmpty) {
                      return const _SearchMessage(
                        icon: Icons.inventory_2_outlined,
                        message: 'Ketik nama produk untuk mulai mencari.',
                      );
                    }
                    final products = widget.transaction.searchResults;
                    if (products.isEmpty) {
                      return const _SearchMessage(
                        icon: Icons.search_off_rounded,
                        message: 'Produk tidak ditemukan di katalog lokal.',
                      );
                    }
                    return ListView.separated(
                      itemCount: products.length,
                      separatorBuilder: (_, _) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final product = products[index];
                        return ListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text(
                            product.name,
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                          subtitle: Text(
                            '${product.category} · stok ${product.stock}'
                            '${product.shelfLocation == null ? '' : ' · ${product.shelfLocation}'}',
                          ),
                          trailing: const Icon(
                            Icons.add_circle_outline_rounded,
                          ),
                          onTap: () => Navigator.pop(context, product),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SearchMessage extends StatelessWidget {
  const _SearchMessage({required this.icon, required this.message});
  final IconData icon;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: AppColors.slate500, size: 36),
          const SizedBox(height: 10),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppColors.muted),
          ),
        ],
      ),
    );
  }
}

String _fallbackTitle(RecognitionFailureReason? reason) => switch (reason) {
  RecognitionFailureReason.lowConfidence => 'Belum cukup yakin',
  RecognitionFailureReason.unknownLabel => 'Produk belum ada di katalog',
  RecognitionFailureReason.modelUnavailable => 'Model AI belum dipasang',
  RecognitionFailureReason.timeout => 'Analisis terlalu lama',
  RecognitionFailureReason.inferenceError => 'Produk belum dikenali',
  null => 'Pemindaian terganggu',
};

String _friendlyCameraError(CameraException error) => switch (error.code) {
  'CameraAccessDenied' => 'Izin kamera belum diberikan.',
  'CameraAccessDeniedWithoutPrompt' =>
    'Izin kamera dinonaktifkan dari pengaturan perangkat.',
  'CameraAccessRestricted' => 'Akses kamera dibatasi pada perangkat ini.',
  _ => 'Kamera tidak dapat dibuka. Coba lagi.',
};
