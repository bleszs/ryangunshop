import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_loading.dart';
import '../../../domain/entities/entities.dart';
import '../../transaction/presentation/transaction_view_model.dart';
import '../application/receipt_pdf_service.dart';

class CartCheckoutPage extends StatefulWidget {
  const CartCheckoutPage({
    required this.viewModel,
    this.receiptPdfService = const ReceiptPdfService(),
    this.receiptShareService = const ReceiptShareService(),
    super.key,
  });

  final TransactionViewModel viewModel;
  final ReceiptPdfService receiptPdfService;
  final ReceiptShareService receiptShareService;

  @override
  State<CartCheckoutPage> createState() => _CartCheckoutPageState();
}

class _CartCheckoutPageState extends State<CartCheckoutPage> {
  final _cashController = TextEditingController();
  final _cashFocusNode = FocusNode();
  PaymentType _paymentType = PaymentType.cash;
  bool _qrisVerified = false;
  int _receivedAmount = 0;
  bool _isSharingReceipt = false;

  TransactionViewModel get _viewModel => widget.viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel.addListener(_refresh);
  }

  @override
  void dispose() {
    _viewModel.removeListener(_refresh);
    _cashController.dispose();
    _cashFocusNode.dispose();
    super.dispose();
  }

  void _refresh() {
    if (mounted) setState(() {});
  }

  void _selectPayment(PaymentType type) {
    FocusScope.of(context).unfocus();
    setState(() {
      _paymentType = type;
      _qrisVerified = false;
    });
    _viewModel.clearMessage();
  }

  void _setCashAmount(int amount) {
    _cashController.text = _formatDigits(amount);
    _cashController.selection = TextSelection.collapsed(
      offset: _cashController.text.length,
    );
    setState(() => _receivedAmount = amount);
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    final received = _paymentType == PaymentType.cash
        ? _receivedAmount
        : _viewModel.totalAmount;
    await _viewModel.checkout(_paymentType, received);
  }

  Future<void> _shareReceipt() async {
    final checkout = _viewModel.completedCheckout;
    if (checkout == null || _isSharingReceipt) return;
    setState(() => _isSharingReceipt = true);
    try {
      final file = await widget.receiptPdfService.save(checkout);
      if (!mounted) return;
      await widget.receiptShareService.share(file, checkout);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Struk belum dapat dibuat. Transaksi tetap tersimpan dan bisa dicoba lagi.',
          ),
        ),
      );
    } finally {
      if (mounted) setState(() => _isSharingReceipt = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final receipt = _viewModel.receipt;
    return PopScope(
      canPop: !_viewModel.isCheckingOut,
      child: Scaffold(
        appBar: AppBar(
          title: Text(receipt == null ? 'Keranjang' : 'Transaksi selesai'),
          leading: IconButton(
            tooltip: 'Kembali',
            onPressed: _viewModel.isCheckingOut
                ? null
                : () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back_rounded),
          ),
        ),
        body: SafeArea(
          top: false,
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            switchInCurve: Curves.easeOutCubic,
            switchOutCurve: Curves.easeInCubic,
            child: receipt != null
                ? _CheckoutSuccess(
                    key: const ValueKey('checkout-success'),
                    receipt: receipt,
                    paymentType:
                        _viewModel.completedCheckout?.paymentType ??
                        _paymentType,
                    sharingReceipt: _isSharingReceipt,
                    onShareReceipt: _shareReceipt,
                    onDone: () => Navigator.pop(context, true),
                  )
                : _viewModel.cart.isEmpty
                ? _EmptyCart(
                    key: const ValueKey('empty-cart'),
                    onScan: () => Navigator.pop(context, false),
                  )
                : _buildCheckout(context),
          ),
        ),
      ),
    );
  }

  Widget _buildCheckout(BuildContext context) {
    final total = _viewModel.totalAmount;
    final canPay = _paymentType == PaymentType.cash
        ? _receivedAmount >= total
        : _qrisVerified;
    return Column(
      key: const ValueKey('checkout-form'),
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
            children: [
              _CartSummary(viewModel: _viewModel),
              const SizedBox(height: 24),
              Text(
                'Metode pembayaran',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: _PaymentChoice(
                      icon: Icons.payments_outlined,
                      label: 'Tunai',
                      supportingText: 'Hitung kembalian',
                      selected: _paymentType == PaymentType.cash,
                      onTap: () => _selectPayment(PaymentType.cash),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _PaymentChoice(
                      icon: Icons.qr_code_2_rounded,
                      label: 'QRIS',
                      supportingText: 'Konfirmasi manual',
                      selected: _paymentType == PaymentType.qrisManual,
                      onTap: () => _selectPayment(PaymentType.qrisManual),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 180),
                child: _paymentType == PaymentType.cash
                    ? _CashPayment(
                        key: const ValueKey('cash-payment'),
                        controller: _cashController,
                        focusNode: _cashFocusNode,
                        total: total,
                        received: _receivedAmount,
                        onAmountChanged: (value) => setState(
                          () => _receivedAmount = _parseCurrency(value),
                        ),
                        onPresetSelected: _setCashAmount,
                      )
                    : _QrisManualPayment(
                        key: const ValueKey('qris-payment'),
                        total: total,
                        verified: _qrisVerified,
                        onVerified: (value) =>
                            setState(() => _qrisVerified = value),
                      ),
              ),
              if (_viewModel.message != null) ...[
                const SizedBox(height: 14),
                _CheckoutError(message: _viewModel.message!),
              ],
            ],
          ),
        ),
        _CheckoutBar(
          total: total,
          enabled: canPay && !_viewModel.isCheckingOut,
          loading: _viewModel.isCheckingOut,
          paymentType: _paymentType,
          onPay: _submit,
        ),
      ],
    );
  }
}

class _CartSummary extends StatelessWidget {
  const _CartSummary({required this.viewModel});

  final TransactionViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final lines = viewModel.cart;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                '${viewModel.cartQuantity} barang',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            Text(
              _rupiah(viewModel.totalAmount),
              style: const TextStyle(
                color: AppColors.slate700,
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Material(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadii.surface),
          clipBehavior: Clip.antiAlias,
          child: Column(
            children: [
              for (var index = 0; index < lines.length; index++) ...[
                _CartLineTile(
                  line: lines[index],
                  onChanged: (quantity) =>
                      viewModel.setQuantity(lines[index].product.id, quantity),
                ),
                if (index < lines.length - 1)
                  const Divider(height: 1, indent: 64),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _CartLineTile extends StatelessWidget {
  const _CartLineTile({required this.line, required this.onChanged});

  final CartLine line;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 14, 10, 14),
      child: Row(
        children: [
          DecoratedBox(
            decoration: BoxDecoration(
              color: AppColors.slate100,
              borderRadius: BorderRadius.circular(AppRadii.control),
            ),
            child: const SizedBox.square(
              dimension: 42,
              child: Icon(
                Icons.inventory_2_outlined,
                color: AppColors.slate700,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  line.product.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 2),
                Text(
                  '${_rupiah(line.product.sellingPrice)} · stok ${line.product.stock}',
                  style: const TextStyle(color: AppColors.muted, fontSize: 12),
                ),
                const SizedBox(height: 8),
                Text(
                  _rupiah(line.subtotal),
                  style: const TextStyle(
                    color: AppColors.slate700,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          _QuantityStepper(
            productId: line.product.id,
            quantity: line.quantity,
            atMaximum: line.quantity >= line.product.stock,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}

class _QuantityStepper extends StatelessWidget {
  const _QuantityStepper({
    required this.productId,
    required this.quantity,
    required this.atMaximum,
    required this.onChanged,
  });

  final String productId;
  final int quantity;
  final bool atMaximum;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Jumlah $quantity',
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: AppColors.slate50,
          borderRadius: BorderRadius.circular(AppRadii.control),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              key: ValueKey('decrease-$productId'),
              tooltip: quantity == 1 ? 'Hapus barang' : 'Kurangi jumlah',
              visualDensity: VisualDensity.compact,
              onPressed: () => onChanged(quantity - 1),
              icon: Icon(
                quantity == 1
                    ? Icons.delete_outline_rounded
                    : Icons.remove_rounded,
                size: 19,
              ),
            ),
            SizedBox(
              width: 24,
              child: Text(
                '$quantity',
                textAlign: TextAlign.center,
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
            ),
            IconButton(
              key: ValueKey('increase-$productId'),
              tooltip: atMaximum ? 'Stok maksimum tercapai' : 'Tambah jumlah',
              visualDensity: VisualDensity.compact,
              onPressed: atMaximum ? null : () => onChanged(quantity + 1),
              icon: const Icon(Icons.add_rounded, size: 19),
            ),
          ],
        ),
      ),
    );
  }
}

class _PaymentChoice extends StatelessWidget {
  const _PaymentChoice({
    required this.icon,
    required this.label,
    required this.supportingText,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final String supportingText;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      child: Material(
        color: selected ? AppColors.slate100 : AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.control),
          side: BorderSide(
            color: selected ? AppColors.slate600 : AppColors.outline,
            width: selected ? 1.5 : 1,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(13),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(icon, color: AppColors.slate700, size: 22),
                    const Spacer(),
                    Icon(
                      selected
                          ? Icons.check_circle_rounded
                          : Icons.circle_outlined,
                      color: selected ? AppColors.slate600 : AppColors.muted,
                      size: 19,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  label,
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 2),
                Text(
                  supportingText,
                  style: const TextStyle(color: AppColors.muted, fontSize: 11),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CashPayment extends StatelessWidget {
  const _CashPayment({
    required this.controller,
    required this.focusNode,
    required this.total,
    required this.received,
    required this.onAmountChanged,
    required this.onPresetSelected,
    super.key,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final int total;
  final int received;
  final ValueChanged<String> onAmountChanged;
  final ValueChanged<int> onPresetSelected;

  @override
  Widget build(BuildContext context) {
    final change = received > total ? received - total : 0;
    final insufficient = received > 0 && received < total;
    final presets = _cashPresets(total);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          key: const ValueKey('cash-received-field'),
          controller: controller,
          focusNode: focusNode,
          keyboardType: TextInputType.number,
          textInputAction: TextInputAction.done,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          onChanged: onAmountChanged,
          decoration: InputDecoration(
            labelText: 'Uang diterima',
            hintText: '0',
            prefixText: 'Rp ',
            helperText: insufficient
                ? 'Masih kurang ${_rupiah(total - received)}'
                : received >= total
                ? 'Kembalian ${_rupiah(change)}'
                : 'Masukkan nominal atau pilih uang cepat.',
            helperStyle: TextStyle(
              color: insufficient ? AppColors.error : AppColors.muted,
              fontWeight: received >= total ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final amount in presets)
              ActionChip(
                key: ValueKey('cash-preset-$amount'),
                label: Text(amount == total ? 'Uang pas' : _rupiah(amount)),
                onPressed: () => onPresetSelected(amount),
              ),
          ],
        ),
      ],
    );
  }
}

class _QrisManualPayment extends StatelessWidget {
  const _QrisManualPayment({
    required this.total,
    required this.verified,
    required this.onVerified,
    super.key,
  });

  final int total;
  final bool verified;
  final ValueChanged<bool> onVerified;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.slate50,
        borderRadius: BorderRadius.circular(AppRadii.surface),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Row(
              children: [
                Icon(Icons.storefront_outlined, color: AppColors.slate700),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Gunakan QRIS merchant warung',
                    style: TextStyle(fontWeight: FontWeight.w800),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Minta pelanggan membayar ${_rupiah(total)} melalui QRIS merchant yang terdaftar. Periksa notifikasi atau mutasi sebelum menyelesaikan transaksi.',
              style: const TextStyle(color: AppColors.muted, height: 1.45),
            ),
            const SizedBox(height: 12),
            CheckboxListTile(
              key: const ValueKey('qris-verification'),
              value: verified,
              onChanged: (value) => onVerified(value ?? false),
              contentPadding: EdgeInsets.zero,
              controlAffinity: ListTileControlAffinity.leading,
              title: const Text(
                'Pembayaran sudah diterima',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
              subtitle: const Text('Diverifikasi manual oleh kasir'),
            ),
          ],
        ),
      ),
    );
  }
}

class _CheckoutError extends StatelessWidget {
  const _CheckoutError({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      liveRegion: true,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.errorContainer,
          borderRadius: BorderRadius.circular(AppRadii.control),
        ),
        child: Padding(
          padding: const EdgeInsets.all(13),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
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
      ),
    );
  }
}

class _CheckoutBar extends StatelessWidget {
  const _CheckoutBar({
    required this.total,
    required this.enabled,
    required this.loading,
    required this.paymentType,
    required this.onPay,
  });

  final int total;
  final bool enabled;
  final bool loading;
  final PaymentType paymentType;
  final VoidCallback onPay;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.outline)),
      ),
      child: SafeArea(
        top: false,
        minimum: const EdgeInsets.fromLTRB(16, 12, 16, 12),
        child: Row(
          children: [
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Total',
                    style: TextStyle(color: AppColors.muted, fontSize: 12),
                  ),
                  Text(
                    _rupiah(total),
                    style: const TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
            ),
            FilledButton(
              key: const ValueKey('submit-payment'),
              onPressed: enabled ? onPay : null,
              child: loading
                  ? const AppSpinner(size: 20, color: Colors.white)
                  : Text(
                      paymentType == PaymentType.cash
                          ? 'Bayar tunai'
                          : 'Selesaikan QRIS',
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CheckoutSuccess extends StatelessWidget {
  const _CheckoutSuccess({
    required this.receipt,
    required this.paymentType,
    required this.sharingReceipt,
    required this.onShareReceipt,
    required this.onDone,
    super.key,
  });

  final CheckoutReceipt receipt;
  final PaymentType paymentType;
  final bool sharingReceipt;
  final VoidCallback onShareReceipt;
  final VoidCallback onDone;

  @override
  Widget build(BuildContext context) {
    final transactionCode = receipt.transactionId.length > 8
        ? receipt.transactionId.substring(0, 8).toUpperCase()
        : receipt.transactionId.toUpperCase();
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 28, 20, 24),
      children: [
        const Center(
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: Color(0xFFDDF1EB),
              shape: BoxShape.circle,
            ),
            child: SizedBox.square(
              dimension: 72,
              child: Icon(
                Icons.check_rounded,
                color: AppColors.success,
                size: 38,
              ),
            ),
          ),
        ),
        const SizedBox(height: 20),
        Text(
          'Pembayaran berhasil',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 6),
        const Text(
          'Stok sudah diperbarui dan transaksi tersimpan di perangkat.',
          textAlign: TextAlign.center,
          style: TextStyle(color: AppColors.muted, height: 1.45),
        ),
        const SizedBox(height: 24),
        DecoratedBox(
          decoration: BoxDecoration(
            color: AppColors.slate900,
            borderRadius: BorderRadius.circular(AppRadii.surface),
          ),
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              children: [
                _ReceiptRow(
                  label: 'Total transaksi',
                  value: _rupiah(receipt.totalAmount),
                  emphasized: true,
                ),
                const Divider(color: AppColors.slate700, height: 24),
                _ReceiptRow(
                  label: 'Uang diterima',
                  value: _rupiah(receipt.receivedAmount),
                ),
                const SizedBox(height: 10),
                _ReceiptRow(
                  label: 'Kembalian',
                  value: _rupiah(receipt.changeAmount),
                ),
                const SizedBox(height: 10),
                _ReceiptRow(
                  label: 'Pembayaran',
                  value: paymentType == PaymentType.cash ? 'Tunai' : 'QRIS',
                ),
                const SizedBox(height: 10),
                _ReceiptRow(label: 'ID transaksi', value: transactionCode),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),
        OutlinedButton.icon(
          key: const ValueKey('share-receipt'),
          onPressed: sharingReceipt ? null : onShareReceipt,
          icon: sharingReceipt
              ? const AppSpinner(size: 18)
              : const Icon(Icons.ios_share_rounded),
          label: Text(sharingReceipt ? 'Menyiapkan PDF…' : 'Bagikan struk PDF'),
        ),
        const SizedBox(height: 8),
        const Text(
          'PDF disimpan di penyimpanan privat aplikasi, lalu dapat dipilih untuk WhatsApp atau aplikasi lain.',
          textAlign: TextAlign.center,
          style: TextStyle(color: AppColors.muted, fontSize: 12, height: 1.4),
        ),
        const SizedBox(height: 16),
        FilledButton.icon(
          key: const ValueKey('finish-checkout'),
          onPressed: onDone,
          icon: const Icon(Icons.done_rounded),
          label: const Text('Selesai'),
        ),
      ],
    );
  }
}

class _ReceiptRow extends StatelessWidget {
  const _ReceiptRow({
    required this.label,
    required this.value,
    this.emphasized = false,
  });

  final String label;
  final String value;
  final bool emphasized;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              color: emphasized ? AppColors.slate200 : AppColors.slate300,
            ),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: Colors.white,
            fontSize: emphasized ? 20 : 14,
            fontWeight: emphasized ? FontWeight.w900 : FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _EmptyCart extends StatelessWidget {
  const _EmptyCart({required this.onScan, super.key});

  final VoidCallback onScan;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.shopping_bag_outlined,
              size: 54,
              color: AppColors.slate500,
            ),
            const SizedBox(height: 16),
            Text(
              'Keranjang masih kosong',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 6),
            const Text(
              'Pindai atau cari produk terlebih dahulu untuk memulai transaksi.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.muted, height: 1.45),
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: onScan,
              icon: const Icon(Icons.document_scanner_outlined),
              label: const Text('Pindai produk'),
            ),
          ],
        ),
      ),
    );
  }
}

List<int> _cashPresets(int total) {
  int roundUp(int unit) => ((total + unit - 1) ~/ unit) * unit;
  return <int>{
    total,
    roundUp(5000),
    roundUp(10000),
    roundUp(50000),
  }.where((amount) => amount >= total).take(3).toList(growable: false);
}

int _parseCurrency(String value) =>
    int.tryParse(value.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;

String _formatDigits(int amount) {
  final digits = amount.toString();
  final buffer = StringBuffer();
  for (var index = 0; index < digits.length; index++) {
    if (index > 0 && (digits.length - index) % 3 == 0) buffer.write('.');
    buffer.write(digits[index]);
  }
  return buffer.toString();
}

String _rupiah(int amount) => 'Rp${_formatDigits(amount)}';
