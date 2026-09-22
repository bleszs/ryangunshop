import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_loading.dart';
import '../../../domain/entities/inventory_planning_entities.dart';
import '../../../domain/repositories/repositories.dart';

enum _RestockFilter { needsAction, all }

class RestockRecommendationPage extends StatefulWidget {
  const RestockRecommendationPage({
    required this.repository,
    required this.storeId,
    super.key,
  });

  final InventoryPlanningRepository repository;
  final String storeId;

  @override
  State<RestockRecommendationPage> createState() =>
      _RestockRecommendationPageState();
}

class _RestockRecommendationPageState extends State<RestockRecommendationPage> {
  static const _historyDays = 28;
  static const _reviewPeriodDays = 7;
  _RestockFilter _filter = _RestockFilter.needsAction;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 76,
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Rencana restok', style: AppTextStyles.editorialTitle),
            Text(
              'Berdasarkan penjualan lokal',
              style: TextStyle(
                color: AppColors.muted,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
      body: StreamBuilder<List<RestockRecommendation>>(
        stream: widget.repository.watchRecommendations(
          storeId: widget.storeId,
          historyDays: _historyDays,
          reviewPeriodDays: _reviewPeriodDays,
        ),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const AppLoadingView(label: 'Menghitung kebutuhan stok…');
          }
          if (snapshot.hasError) {
            return const _PlanningMessage(
              icon: Icons.sync_problem_outlined,
              title: 'Perhitungan belum tersedia',
              message:
                  'Data penjualan lokal belum dapat dibaca. Kembali lalu coba '
                  'lagi.',
            );
          }
          final recommendations = snapshot.data ?? const [];
          if (recommendations.isEmpty) {
            return const _PlanningMessage(
              icon: Icons.inventory_2_outlined,
              title: 'Belum ada produk',
              message:
                  'Tambahkan produk dan catat transaksi untuk mulai membuat '
                  'rencana restok.',
            );
          }
          final actionable = recommendations
              .where((item) => item.needsRestock)
              .toList(growable: false);
          final visible = _filter == _RestockFilter.needsAction
              ? actionable
              : recommendations;
          return Column(
            children: [
              _PlanningHeader(
                totalProducts: recommendations.length,
                actionCount: actionable.length,
                filter: _filter,
                onFilterChanged: (value) => setState(() => _filter = value),
              ),
              Expanded(
                child: visible.isEmpty
                    ? const _PlanningMessage(
                        icon: Icons.task_alt_rounded,
                        title: 'Stok masih aman',
                        message:
                            'Belum ada produk yang mencapai titik pemesanan '
                            'ulang.',
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(16, 4, 16, 32),
                        itemCount: visible.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 10),
                        itemBuilder: (_, index) =>
                            _RecommendationTile(item: visible[index]),
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _PlanningHeader extends StatelessWidget {
  const _PlanningHeader({
    required this.totalProducts,
    required this.actionCount,
    required this.filter,
    required this.onFilterChanged,
  });

  final int totalProducts;
  final int actionCount;
  final _RestockFilter filter;
  final ValueChanged<_RestockFilter> onFilterChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          DecoratedBox(
            decoration: BoxDecoration(
              color: AppColors.slate100,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const Icon(
                    Icons.insights_outlined,
                    color: AppColors.slate800,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      actionCount == 0
                          ? '$totalProducts produk sudah di atas titik restok.'
                          : '$actionCount dari $totalProducts produk perlu '
                                'ditinjau.',
                      style: const TextStyle(
                        color: AppColors.slate800,
                        fontWeight: FontWeight.w700,
                        height: 1.35,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          SegmentedButton<_RestockFilter>(
            showSelectedIcon: false,
            segments: [
              ButtonSegment(
                value: _RestockFilter.needsAction,
                icon: const Icon(Icons.priority_high_rounded, size: 18),
                label: Text('Perlu dipesan  $actionCount'),
              ),
              ButtonSegment(
                value: _RestockFilter.all,
                icon: const Icon(Icons.list_alt_rounded, size: 18),
                label: Text('Semua  $totalProducts'),
              ),
            ],
            selected: {filter},
            onSelectionChanged: (values) => onFilterChanged(values.first),
          ),
          const SizedBox(height: 10),
          const Text(
            'Rata-rata 28 hari · target persediaan 7 hari setelah barang tiba',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.muted, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class _RecommendationTile extends StatelessWidget {
  const _RecommendationTile({required this.item});

  final RestockRecommendation item;

  @override
  Widget build(BuildContext context) {
    final daysRemaining = item.estimatedDaysRemaining;
    final needsRestock = item.needsRestock;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    item.productName,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                const SizedBox(width: 12),
                _ActionPill(
                  needsRestock: needsRestock,
                  quantity: item.suggestedOrderQuantity,
                ),
              ],
            ),
            const SizedBox(height: 14),
            Wrap(
              spacing: 18,
              runSpacing: 10,
              children: [
                _Metric(label: 'Stok', value: '${item.currentStock}'),
                _Metric(label: 'Titik restok', value: '${item.reorderPoint}'),
                _Metric(
                  label: 'Rata-rata/hari',
                  value: item.averageDailySales.toStringAsFixed(1),
                ),
                _Metric(
                  label: 'Perkiraan habis',
                  value: daysRemaining == null
                      ? 'Belum cukup data'
                      : '${daysRemaining.ceil()} hari',
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Lead time ${item.leadTimeDays} hari · stok pengaman '
              '${item.safetyStock} · terjual ${item.unitsSold} unit dalam '
              '${item.historyDays} hari',
              style: const TextStyle(
                color: AppColors.muted,
                fontSize: 12,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionPill extends StatelessWidget {
  const _ActionPill({required this.needsRestock, required this.quantity});

  final bool needsRestock;
  final int quantity;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: needsRestock ? const Color(0xFFFFF0DD) : const Color(0xFFDDF1EB),
        borderRadius: BorderRadius.circular(99),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        child: Text(
          needsRestock ? 'Pesan $quantity' : 'Aman',
          style: TextStyle(
            color: needsRestock ? AppColors.warning : AppColors.success,
            fontSize: 12,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  const _Metric({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 132,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(color: AppColors.muted, fontSize: 11),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: AppColors.ink,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _PlanningMessage extends StatelessWidget {
  const _PlanningMessage({
    required this.icon,
    required this.title,
    required this.message,
  });

  final IconData icon;
  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(28),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 360),
          child: Column(
            children: [
              Icon(icon, size: 48, color: AppColors.slate500),
              const SizedBox(height: 16),
              Text(
                title,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.muted, height: 1.45),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
