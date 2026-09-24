import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_loading.dart';
import '../../../domain/entities/dashboard_entities.dart';
import '../../../domain/repositories/repositories.dart';
import '../application/business_dashboard_view_model.dart';
import '../application/sales_report_export_controller.dart';
import 'transaction_history_page.dart';

class BusinessDashboardPage extends StatelessWidget {
  const BusinessDashboardPage({
    required this.repository,
    required this.storeId,
    this.reportRepository = const EmptySalesReportRepository(),
    this.transactionRepository = const EmptyTransactionManagementRepository(),
    this.actorId = 'local-owner',
    this.canVoidTransactions = false,
    super.key,
  });

  final BusinessDashboardRepository repository;
  final SalesReportRepository reportRepository;
  final TransactionManagementRepository transactionRepository;
  final String storeId;
  final String actorId;
  final bool canVoidTransactions;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => BusinessDashboardViewModel(
            repository: repository,
            storeId: storeId,
          )..initialize(),
        ),
        ChangeNotifierProvider(
          create: (_) => SalesReportExportController(
            repository: reportRepository,
            storeId: storeId,
          ),
        ),
      ],
      child: _BusinessDashboardView(
        transactionRepository: transactionRepository,
        storeId: storeId,
        actorId: actorId,
        canVoidTransactions: canVoidTransactions,
      ),
    );
  }
}

class _BusinessDashboardView extends StatelessWidget {
  const _BusinessDashboardView({
    required this.transactionRepository,
    required this.storeId,
    required this.actorId,
    required this.canVoidTransactions,
  });

  final TransactionManagementRepository transactionRepository;
  final String storeId;
  final String actorId;
  final bool canVoidTransactions;

  @override
  Widget build(BuildContext context) {
    final model = context.watch<BusinessDashboardViewModel>();
    return Scaffold(
      appBar: AppBar(
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Laporan',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
            ),
            Text(
              'Data dari transaksi lokal',
              style: TextStyle(
                color: AppColors.muted,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            key: const ValueKey('open-transaction-history'),
            tooltip: 'Riwayat transaksi',
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => TransactionHistoryPage(
                  repository: transactionRepository,
                  storeId: storeId,
                  actorId: actorId,
                  canVoidTransactions: canVoidTransactions,
                ),
              ),
            ),
            icon: const Icon(Icons.history_rounded),
          ),
          const SizedBox(width: 6),
        ],
      ),
      body: AnimatedSwitcher(
        duration: MediaQuery.disableAnimationsOf(context)
            ? Duration.zero
            : const Duration(milliseconds: 180),
        child: model.isLoading
            ? const AppLoadingView(
                key: ValueKey('dashboard-loading'),
                label: 'Menghitung ringkasan usaha…',
              )
            : model.errorMessage != null
            ? _DashboardError(
                key: const ValueKey('dashboard-error'),
                message: model.errorMessage!,
                onRetry: model.retry,
              )
            : _DashboardBody(key: ValueKey(model.period), model: model),
      ),
    );
  }
}

class _DashboardBody extends StatelessWidget {
  const _DashboardBody({required this.model, super.key});
  final BusinessDashboardViewModel model;

  @override
  Widget build(BuildContext context) {
    final snapshot = model.snapshot;
    final exporter = context.watch<SalesReportExportController>();
    final bestSelling = snapshot.bestSellingProducts.take(4).toList();
    final slowSelling = snapshot.slowSellingProducts.take(4).toList();
    return RefreshIndicator(
      onRefresh: model.retry,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 36),
        children: [
          Text('Ringkasan usaha', style: AppTextStyles.editorialDisplay),
          const SizedBox(height: 7),
          Text(
            _rangeDescription(model),
            style: const TextStyle(color: AppColors.muted),
          ),
          const SizedBox(height: 20),
          _PeriodSelector(
            selected: model.period,
            onChanged: model.selectPeriod,
          ),
          const SizedBox(height: 18),
          _RevenuePanel(snapshot: snapshot),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _CompactMetric(
                  icon: Icons.trending_up_rounded,
                  label: 'Laba kotor',
                  value: _rupiah(snapshot.grossProfit),
                  semanticLabel: 'Laba kotor ${_rupiah(snapshot.grossProfit)}',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _CompactMetric(
                  icon: Icons.receipt_long_outlined,
                  label: 'Transaksi',
                  value: '${snapshot.transactionCount}',
                  semanticLabel:
                      '${snapshot.transactionCount} transaksi berhasil',
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          _SectionHeading(
            title: 'Produk terlaris',
            subtitle: 'Diurutkan dari jumlah unit yang terjual.',
          ),
          const SizedBox(height: 12),
          if (bestSelling.isEmpty)
            const _InlineEmpty(
              icon: Icons.query_stats_outlined,
              title: 'Belum ada penjualan',
              description:
                  'Transaksi berhasil pada periode ini akan muncul di sini.',
            )
          else
            _ProductRanking(items: bestSelling),
          const SizedBox(height: 30),
          _SectionHeading(
            title: 'Perlu perhatian',
            subtitle: 'Produk yang jarang terjual dan stok yang menipis.',
          ),
          const SizedBox(height: 14),
          _AttentionPanel(
            slowSelling: slowSelling,
            lowStock: snapshot.lowStockProducts.take(5).toList(),
          ),
          const SizedBox(height: 30),
          _ReportExportPanel(
            enabled: snapshot.transactionCount > 0,
            controller: exporter,
            onExport: (format) => _exportReport(context, format),
          ),
        ],
      ),
    );
  }

  Future<void> _exportReport(
    BuildContext context,
    SalesReportFormat format,
  ) async {
    final range = model.activeRange;
    final success = await context
        .read<SalesReportExportController>()
        .exportAndShare(
          format: format,
          fromInclusive: range.start,
          toExclusive: range.end,
        );
    if (!success || !context.mounted) return;
    final filename = context
        .read<SalesReportExportController>()
        .lastSavedFilename;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Laporan tersimpan: $filename')));
  }
}

class _ReportExportPanel extends StatelessWidget {
  const _ReportExportPanel({
    required this.enabled,
    required this.controller,
    required this.onExport,
  });

  final bool enabled;
  final SalesReportExportController controller;
  final ValueChanged<SalesReportFormat> onExport;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.slate100,
        borderRadius: BorderRadius.circular(AppRadii.surface),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.file_download_outlined, color: AppColors.slate700),
              SizedBox(width: 11),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Ekspor laporan',
                      style: TextStyle(fontWeight: FontWeight.w800),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'PDF untuk dibaca, CSV untuk diolah di Excel.',
                      style: TextStyle(color: AppColors.muted, height: 1.4),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (controller.errorMessage case final message?) ...[
            const SizedBox(height: 12),
            Material(
              color: Colors.white,
              borderRadius: BorderRadius.circular(AppRadii.control),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 8, 4, 8),
                child: Row(
                  children: [
                    const Icon(
                      Icons.info_outline_rounded,
                      color: AppColors.error,
                      size: 19,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        message,
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                    IconButton(
                      tooltip: 'Tutup pesan',
                      onPressed: controller.clearError,
                      icon: const Icon(Icons.close_rounded, size: 18),
                    ),
                  ],
                ),
              ),
            ),
          ],
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: FilledButton.icon(
                  key: const ValueKey('export-report-pdf'),
                  onPressed: enabled && !controller.isExporting
                      ? () => onExport(SalesReportFormat.pdf)
                      : null,
                  icon: controller.activeFormat == SalesReportFormat.pdf
                      ? const AppSpinner(size: 17, color: Colors.white)
                      : const Icon(Icons.picture_as_pdf_outlined),
                  label: const Text('PDF'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton.icon(
                  key: const ValueKey('export-report-csv'),
                  onPressed: enabled && !controller.isExporting
                      ? () => onExport(SalesReportFormat.csv)
                      : null,
                  icon: controller.activeFormat == SalesReportFormat.csv
                      ? const AppSpinner(size: 17)
                      : const Icon(Icons.table_view_outlined),
                  label: const Text('CSV'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 9),
          Text(
            enabled
                ? 'Berkas disimpan privat lalu dibuka melalui menu bagikan.'
                : 'Belum ada transaksi berhasil pada periode ini.',
            style: const TextStyle(color: AppColors.muted, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class _PeriodSelector extends StatelessWidget {
  const _PeriodSelector({required this.selected, required this.onChanged});
  final DashboardPeriod selected;
  final ValueChanged<DashboardPeriod> onChanged;

  @override
  Widget build(BuildContext context) {
    const options = [
      (DashboardPeriod.today, 'Hari ini'),
      (DashboardPeriod.sevenDays, '7 hari'),
      (DashboardPeriod.thirtyDays, '30 hari'),
    ];
    return Container(
      height: 48,
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadii.control),
        border: Border.all(color: AppColors.outline),
      ),
      child: Row(
        children: [
          for (final option in options)
            Expanded(
              child: Semantics(
                button: true,
                selected: selected == option.$1,
                child: Material(
                  color: selected == option.$1
                      ? AppColors.slate100
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(9),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(9),
                    onTap: () => onChanged(option.$1),
                    child: Center(
                      child: Text(
                        option.$2,
                        maxLines: 1,
                        style: TextStyle(
                          color: selected == option.$1
                              ? AppColors.slate800
                              : AppColors.muted,
                          fontWeight: selected == option.$1
                              ? FontWeight.w800
                              : FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _RevenuePanel extends StatelessWidget {
  const _RevenuePanel({required this.snapshot});
  final BusinessDashboardSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Omzet ${_rupiah(snapshot.totalRevenue)}',
      child: Container(
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          color: AppColors.slate900,
          borderRadius: BorderRadius.circular(AppRadii.surface),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(
                  Icons.payments_outlined,
                  color: AppColors.slate300,
                  size: 20,
                ),
                SizedBox(width: 8),
                Flexible(
                  child: Text(
                    'Omzet transaksi',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: AppColors.slate200,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 13),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                _rupiah(snapshot.totalRevenue),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 34,
                  height: 1.05,
                  letterSpacing: -.8,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            const SizedBox(height: 14),
            Text(
              snapshot.transactionCount == 0
                  ? 'Belum ada transaksi berhasil pada periode ini.'
                  : 'Rata-rata ${_rupiah(snapshot.averageTransaction)} per transaksi.',
              style: const TextStyle(color: AppColors.slate300, height: 1.4),
            ),
          ],
        ),
      ),
    );
  }
}

class _CompactMetric extends StatelessWidget {
  const _CompactMetric({
    required this.icon,
    required this.label,
    required this.value,
    required this.semanticLabel,
  });

  final IconData icon;
  final String label;
  final String value;
  final String semanticLabel;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: semanticLabel,
      child: Container(
        constraints: const BoxConstraints(minHeight: 112),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadii.surface),
          border: Border.all(color: AppColors.outline),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: AppColors.slate600, size: 21),
            const SizedBox(height: 16),
            Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: const TextStyle(color: AppColors.muted, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionHeading extends StatelessWidget {
  const _SectionHeading({required this.title, required this.subtitle});
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: AppTextStyles.editorialTitle),
        const SizedBox(height: 4),
        Text(subtitle, style: const TextStyle(color: AppColors.muted)),
      ],
    );
  }
}

class _ProductRanking extends StatelessWidget {
  const _ProductRanking({required this.items});
  final List<ProductSalesMetric> items;

  @override
  Widget build(BuildContext context) {
    final maximum = items
        .map((item) => item.unitsSold)
        .fold<int>(1, (value, item) => item > value ? item : value);
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadii.surface),
        border: Border.all(color: AppColors.outline),
      ),
      child: Column(
        children: [
          for (var index = 0; index < items.length; index++)
            _RankingRow(
              rank: index + 1,
              item: items[index],
              progress: items[index].unitsSold / maximum,
            ),
        ],
      ),
    );
  }
}

class _RankingRow extends StatelessWidget {
  const _RankingRow({
    required this.rank,
    required this.item,
    required this.progress,
  });

  final int rank;
  final ProductSalesMetric item;
  final double progress;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Semantics(
        label:
            'Peringkat $rank, ${item.productName}, ${item.unitsSold} unit, ${_rupiah(item.revenue)}',
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                SizedBox(
                  width: 28,
                  child: Text(
                    '$rank',
                    style: const TextStyle(
                      color: AppColors.slate600,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    item.productName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '${item.unitsSold} unit',
                  style: const TextStyle(
                    color: AppColors.muted,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 9),
            Row(
              children: [
                const SizedBox(width: 28),
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(3),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 7,
                      backgroundColor: AppColors.slate100,
                      color: AppColors.slate500,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                SizedBox(
                  width: 82,
                  child: Text(
                    _rupiahCompact(item.revenue),
                    textAlign: TextAlign.end,
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _AttentionPanel extends StatelessWidget {
  const _AttentionPanel({required this.slowSelling, required this.lowStock});

  final List<ProductSalesMetric> slowSelling;
  final List<LowStockMetric> lowStock;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadii.surface),
        border: Border.all(color: AppColors.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _AttentionHeader(
            icon: Icons.hourglass_bottom_rounded,
            title: 'Kurang laku',
            count: slowSelling.length,
          ),
          if (slowSelling.isEmpty)
            const _AttentionEmpty(label: 'Belum ada produk di katalog.')
          else
            for (final product in slowSelling)
              _AttentionRow(
                title: product.productName,
                detail: product.unitsSold == 0
                    ? 'Belum terjual'
                    : '${product.unitsSold} unit terjual',
                trailing: _rupiahCompact(product.revenue),
              ),
          const Divider(height: 25),
          _AttentionHeader(
            icon: Icons.inventory_2_outlined,
            title: 'Stok menipis',
            count: lowStock.length,
            warning: lowStock.isNotEmpty,
          ),
          if (lowStock.isEmpty)
            const _AttentionEmpty(label: 'Semua stok masih aman.')
          else
            for (final product in lowStock)
              _AttentionRow(
                title: product.productName,
                detail: product.shelfLocation?.trim().isNotEmpty == true
                    ? product.shelfLocation!
                    : 'Lokasi belum diatur',
                trailing: '${product.stock}/${product.minimumStock}',
                warning: true,
              ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

class _AttentionHeader extends StatelessWidget {
  const _AttentionHeader({
    required this.icon,
    required this.title,
    required this.count,
    this.warning = false,
  });

  final IconData icon;
  final String title;
  final int count;
  final bool warning;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 15, 16, 8),
      child: Row(
        children: [
          Icon(
            icon,
            size: 20,
            color: warning ? AppColors.warning : AppColors.slate600,
          ),
          const SizedBox(width: 9),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
          ),
          Text(
            '$count produk',
            style: const TextStyle(color: AppColors.muted, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class _AttentionRow extends StatelessWidget {
  const _AttentionRow({
    required this.title,
    required this.detail,
    required this.trailing,
    this.warning = false,
  });

  final String title;
  final String detail;
  final String trailing;
  final bool warning;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 2),
                Text(
                  detail,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: AppColors.muted, fontSize: 12),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Text(
            trailing,
            style: TextStyle(
              color: warning ? AppColors.warning : AppColors.ink,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _AttentionEmpty extends StatelessWidget {
  const _AttentionEmpty({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(45, 5, 16, 10),
      child: Text(label, style: const TextStyle(color: AppColors.muted)),
    );
  }
}

class _InlineEmpty extends StatelessWidget {
  const _InlineEmpty({
    required this.icon,
    required this.title,
    required this.description,
  });

  final IconData icon;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadii.surface),
        border: Border.all(color: AppColors.outline),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.slate500, size: 28),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 3),
                Text(
                  description,
                  style: const TextStyle(color: AppColors.muted, height: 1.4),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DashboardError extends StatelessWidget {
  const _DashboardError({
    required this.message,
    required this.onRetry,
    super.key,
  });

  final String message;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.cloud_off_outlined,
              size: 44,
              color: AppColors.slate500,
            ),
            const SizedBox(height: 14),
            const Text(
              'Laporan belum dapat dibuka',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 7),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.muted, height: 1.4),
            ),
            const SizedBox(height: 18),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Coba lagi'),
            ),
          ],
        ),
      ),
    );
  }
}

String _rangeDescription(BusinessDashboardViewModel model) {
  final range = model.activeRange;
  final inclusiveEnd = range.end.subtract(const Duration(days: 1));
  if (model.period == DashboardPeriod.today) {
    return 'Hari ini, ${_dateLabel(range.start)}';
  }
  return '${_dateLabel(range.start)} – ${_dateLabel(inclusiveEnd)}';
}

String _dateLabel(DateTime date) {
  const months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'Mei',
    'Jun',
    'Jul',
    'Agu',
    'Sep',
    'Okt',
    'Nov',
    'Des',
  ];
  return '${date.day} ${months[date.month - 1]} ${date.year}';
}

String _rupiah(int amount) => 'Rp${_digits(amount)}';

String _rupiahCompact(int amount) {
  if (amount >= 1000000) {
    final value = amount / 1000000;
    return 'Rp${value.toStringAsFixed(value == value.round() ? 0 : 1)} jt';
  }
  if (amount >= 1000) {
    final value = amount / 1000;
    return 'Rp${value.toStringAsFixed(value == value.round() ? 0 : 1)} rb';
  }
  return _rupiah(amount);
}

String _digits(int amount) {
  final digits = amount.abs().toString();
  final chunks = <String>[];
  for (var end = digits.length; end > 0; end -= 3) {
    final start = (end - 3).clamp(0, end);
    chunks.add(digits.substring(start, end));
  }
  final result = chunks.reversed.join('.');
  return amount < 0 ? '-$result' : result;
}
