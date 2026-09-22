import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';

class PaymentPreviewSheet extends StatefulWidget {
  const PaymentPreviewSheet({this.onScan, super.key});

  final VoidCallback? onScan;

  static Future<void> show(BuildContext context, {VoidCallback? onScan}) =>
      showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        showDragHandle: true,
        builder: (_) => PaymentPreviewSheet(onScan: onScan),
      );

  @override
  State<PaymentPreviewSheet> createState() => _PaymentPreviewSheetState();
}

class _PaymentPreviewSheetState extends State<PaymentPreviewSheet> {
  int _selectedMethod = 0;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('Pembayaran', style: AppTextStyles.editorialTitle),
            const SizedBox(height: 6),
            const Text(
              'Keranjang belum berisi produk.',
              style: TextStyle(color: AppColors.muted),
            ),
            const SizedBox(height: 20),
            DecoratedBox(
              decoration: BoxDecoration(
                color: AppColors.slate900,
                borderRadius: BorderRadius.circular(AppRadii.hero),
              ),
              child: const Padding(
                padding: EdgeInsets.all(20),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Total belanja',
                            style: TextStyle(color: AppColors.slate200),
                          ),
                          SizedBox(height: 5),
                          Text(
                            'Rp0',
                            style: TextStyle(
                              fontFamily: 'serif',
                              color: Colors.white,
                              fontSize: 32,
                              height: 1.05,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      '0 barang',
                      style: TextStyle(
                        color: AppColors.slate200,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Metode pembayaran',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _PaymentMethodCard(
                    icon: Icons.payments_outlined,
                    label: 'Tunai',
                    selected: _selectedMethod == 0,
                    onTap: () => setState(() => _selectedMethod = 0),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _PaymentMethodCard(
                    icon: Icons.qr_code_2_rounded,
                    label: 'QRIS',
                    selected: _selectedMethod == 1,
                    onTap: () => setState(() => _selectedMethod = 1),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            DecoratedBox(
              decoration: BoxDecoration(
                color: AppColors.slate50,
                borderRadius: BorderRadius.circular(AppRadii.control),
              ),
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Row(
                  children: [
                    Icon(
                      _selectedMethod == 0
                          ? Icons.calculate_outlined
                          : Icons.verified_user_outlined,
                      color: AppColors.slate600,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _selectedMethod == 0
                            ? 'Uang diterima dan kembalian muncul setelah keranjang terisi.'
                            : 'QR dinamis tersedia setelah merchant gateway dikonfigurasi.',
                        style: const TextStyle(fontSize: 13, height: 1.4),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: () {
                Navigator.pop(context);
                final onScan = widget.onScan;
                if (onScan != null) {
                  WidgetsBinding.instance.addPostFrameCallback((_) => onScan());
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Pindai produk terlebih dahulu.'),
                    ),
                  );
                }
              },
              icon: const Icon(Icons.document_scanner_outlined),
              label: const Text('Mulai pindai barang'),
            ),
          ],
        ),
      ),
    );
  }
}

class _PaymentMethodCard extends StatelessWidget {
  const _PaymentMethodCard({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      label: 'Pembayaran $label',
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
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
            child: Row(
              children: [
                Icon(icon, color: AppColors.slate700),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    label,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
                Icon(
                  selected ? Icons.check_circle_rounded : Icons.circle_outlined,
                  size: 20,
                  color: selected ? AppColors.slate600 : AppColors.muted,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
