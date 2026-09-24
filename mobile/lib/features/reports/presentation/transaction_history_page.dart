import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_loading.dart';
import '../../../domain/entities/entities.dart';
import '../../../domain/repositories/repositories.dart';
import '../application/transaction_history_view_model.dart';

class TransactionHistoryPage extends StatelessWidget {
  const TransactionHistoryPage({
    required this.repository,
    required this.storeId,
    required this.actorId,
    required this.canVoidTransactions,
    super.key,
  });

  final TransactionManagementRepository repository;
  final String storeId;
  final String actorId;
  final bool canVoidTransactions;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => TransactionHistoryViewModel(
        repository: repository,
        storeId: storeId,
        actorId: actorId,
      )..initialize(),
      child: _TransactionHistoryView(canVoidTransactions: canVoidTransactions),
    );
  }
}

class _TransactionHistoryView extends StatelessWidget {
  const _TransactionHistoryView({required this.canVoidTransactions});
  final bool canVoidTransactions;

  @override
  Widget build(BuildContext context) {
    final model = context.watch<TransactionHistoryViewModel>();
    return Scaffold(
      appBar: AppBar(
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Riwayat transaksi',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
            ),
            Text(
              '50 transaksi terakhir',
              style: TextStyle(
                color: AppColors.muted,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
      body: model.isLoading
          ? const AppLoadingView(label: 'Memuat riwayat transaksi…')
          : model.transactions.isEmpty
          ? const _EmptyHistory()
          : RefreshIndicator(
              onRefresh: model.initialize,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 32),
                children: [
                  if (model.errorMessage case final message?) ...[
                    _HistoryError(message: message, onClose: model.clearError),
                    const SizedBox(height: 12),
                  ],
                  if (!canVoidTransactions) ...[
                    const _OwnerNotice(),
                    const SizedBox(height: 12),
                  ],
                  for (final transaction in model.transactions) ...[
                    _TransactionTile(
                      transaction: transaction,
                      canVoid: canVoidTransactions,
                      isVoiding: model.voidingTransactionId == transaction.id,
                      onVoid: () => _requestVoid(context, transaction),
                    ),
                    const SizedBox(height: 10),
                  ],
                ],
              ),
            ),
    );
  }

  Future<void> _requestVoid(
    BuildContext context,
    TransactionEntity transaction,
  ) async {
    final reason = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) => _VoidConfirmationSheet(transaction: transaction),
    );
    if (reason == null || !context.mounted) return;
    final result = await context
        .read<TransactionHistoryViewModel>()
        .voidTransaction(transaction, reason);
    if (result == null || !context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Transaksi dibatalkan. ${result.restoredUnits} unit kembali ke stok.',
        ),
      ),
    );
  }
}

class _TransactionTile extends StatelessWidget {
  const _TransactionTile({
    required this.transaction,
    required this.canVoid,
    required this.isVoiding,
    required this.onVoid,
  });

  final TransactionEntity transaction;
  final bool canVoid;
  final bool isVoiding;
  final VoidCallback onVoid;

  @override
  Widget build(BuildContext context) {
    final success = transaction.status == TransactionStatus.success;
    return Material(
      color: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadii.surface),
        side: const BorderSide(color: AppColors.outline),
      ),
      clipBehavior: Clip.antiAlias,
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        leading: Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: success ? AppColors.slate100 : const Color(0xFFFFECEF),
            borderRadius: BorderRadius.circular(11),
          ),
          child: Icon(
            success ? Icons.receipt_long_outlined : Icons.block_outlined,
            color: success ? AppColors.slate700 : AppColors.error,
          ),
        ),
        title: Text(
          _rupiah(transaction.totalAmount),
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
        subtitle: Text(
          '${_dateTime(transaction.occurredAt)} · ${_shortId(transaction.id)}',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(color: AppColors.muted, fontSize: 12),
        ),
        trailing: _StatusPill(success: success),
        children: [
          const Divider(height: 1),
          const SizedBox(height: 12),
          for (final item in transaction.items)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      item.productName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Text(
                    '${item.quantity} × ${_rupiah(item.sellingPrice)}',
                    style: const TextStyle(
                      color: AppColors.muted,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 3),
          Row(
            children: [
              const Icon(
                Icons.payments_outlined,
                size: 18,
                color: AppColors.muted,
              ),
              const SizedBox(width: 7),
              Text(
                transaction.paymentType == PaymentType.cash ? 'Tunai' : 'QRIS',
                style: const TextStyle(color: AppColors.muted),
              ),
              const Spacer(),
              Text(
                '${transaction.items.fold<int>(0, (sum, item) => sum + item.quantity)} item',
                style: const TextStyle(color: AppColors.muted),
              ),
            ],
          ),
          if (success && canVoid) ...[
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                key: ValueKey('void-${transaction.id}'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.error,
                  side: const BorderSide(color: AppColors.error),
                ),
                onPressed: isVoiding ? null : onVoid,
                icon: isVoiding
                    ? const AppSpinner(size: 17, color: AppColors.error)
                    : const Icon(Icons.undo_rounded),
                label: const Text('Batalkan dan kembalikan stok'),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.success});
  final bool success;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: success ? const Color(0xFFDDF1EB) : const Color(0xFFFFECEF),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Text(
        success ? 'Berhasil' : 'Batal',
        style: TextStyle(
          color: success ? AppColors.success : AppColors.error,
          fontSize: 11,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _VoidConfirmationSheet extends StatefulWidget {
  const _VoidConfirmationSheet({required this.transaction});
  final TransactionEntity transaction;

  @override
  State<_VoidConfirmationSheet> createState() => _VoidConfirmationSheetState();
}

class _VoidConfirmationSheetState extends State<_VoidConfirmationSheet> {
  final _controller = TextEditingController();
  String? _validationMessage;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

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
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Batalkan transaksi?',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 7),
              Text(
                '${_rupiah(widget.transaction.totalAmount)} · '
                '${widget.transaction.items.fold<int>(0, (sum, item) => sum + item.quantity)} item akan dikembalikan ke stok.',
                style: const TextStyle(color: AppColors.muted, height: 1.4),
              ),
              const SizedBox(height: 16),
              TextField(
                key: const ValueKey('void-reason'),
                controller: _controller,
                autofocus: true,
                maxLength: 240,
                minLines: 2,
                maxLines: 4,
                textCapitalization: TextCapitalization.sentences,
                decoration: InputDecoration(
                  labelText: 'Alasan pembatalan',
                  hintText: 'Contoh: Barang dikembalikan pelanggan',
                  errorText: _validationMessage,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Tindakan ini dicatat pada audit dan tidak dapat dibatalkan ulang.',
                style: TextStyle(color: AppColors.muted, fontSize: 12),
              ),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  key: const ValueKey('confirm-void'),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.error,
                  ),
                  onPressed: _confirm,
                  child: const Text('Batalkan transaksi'),
                ),
              ),
              const SizedBox(height: 6),
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Kembali'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _confirm() {
    final reason = _controller.text.trim();
    if (reason.length < 5) {
      setState(() => _validationMessage = 'Tulis alasan minimal 5 karakter.');
      return;
    }
    Navigator.pop(context, reason);
  }
}

class _HistoryError extends StatelessWidget {
  const _HistoryError({required this.message, required this.onClose});
  final String message;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFFFFECEF),
      borderRadius: BorderRadius.circular(AppRadii.control),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 9, 4, 9),
        child: Row(
          children: [
            const Icon(Icons.info_outline, color: AppColors.error, size: 20),
            const SizedBox(width: 9),
            Expanded(child: Text(message)),
            IconButton(
              tooltip: 'Tutup pesan',
              onPressed: onClose,
              icon: const Icon(Icons.close_rounded, size: 19),
            ),
          ],
        ),
      ),
    );
  }
}

class _OwnerNotice extends StatelessWidget {
  const _OwnerNotice();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.slate100,
        borderRadius: BorderRadius.circular(AppRadii.control),
      ),
      child: const Row(
        children: [
          Icon(Icons.lock_outline_rounded, color: AppColors.slate700),
          SizedBox(width: 10),
          Expanded(
            child: Text('Hanya owner yang dapat membatalkan transaksi.'),
          ),
        ],
      ),
    );
  }
}

class _EmptyHistory extends StatelessWidget {
  const _EmptyHistory();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.receipt_long_outlined,
              size: 48,
              color: AppColors.slate500,
            ),
            SizedBox(height: 14),
            Text(
              'Belum ada transaksi',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
            ),
            SizedBox(height: 6),
            Text(
              'Transaksi yang selesai akan tersimpan dan muncul di halaman ini.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.muted, height: 1.4),
            ),
          ],
        ),
      ),
    );
  }
}

String _shortId(String id) =>
    id.length > 8 ? id.substring(0, 8).toUpperCase() : id.toUpperCase();

String _dateTime(DateTime value) {
  final local = value.toLocal();
  String two(int number) => number.toString().padLeft(2, '0');
  return '${two(local.day)}/${two(local.month)}/${local.year} '
      '${two(local.hour)}:${two(local.minute)}';
}

String _rupiah(int amount) {
  final digits = amount.abs().toString();
  final chunks = <String>[];
  for (var end = digits.length; end > 0; end -= 3) {
    final start = (end - 3).clamp(0, end);
    chunks.add(digits.substring(start, end));
  }
  final value = chunks.reversed.join('.');
  return amount < 0 ? '-Rp$value' : 'Rp$value';
}
