import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../../domain/entities/dashboard_entities.dart';
import '../../../domain/repositories/repositories.dart';

enum DashboardPeriod { today, sevenDays, thirtyDays }

class BusinessDashboardViewModel extends ChangeNotifier {
  BusinessDashboardViewModel({
    required BusinessDashboardRepository repository,
    required String storeId,
    DateTime Function()? clock,
  }) : _repository = repository,
       _storeId = storeId,
       _clock = clock ?? DateTime.now;

  final BusinessDashboardRepository _repository;
  final String _storeId;
  final DateTime Function() _clock;
  StreamSubscription<BusinessDashboardSnapshot>? _subscription;

  DashboardPeriod _period = DashboardPeriod.today;
  BusinessDashboardSnapshot _snapshot = const BusinessDashboardSnapshot.empty();
  bool _isLoading = true;
  String? _errorMessage;

  DashboardPeriod get period => _period;
  BusinessDashboardSnapshot get snapshot => _snapshot;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  DateTimeRange get activeRange => _rangeFor(_period, _clock());

  Future<void> initialize() => _subscribe();

  Future<void> selectPeriod(DashboardPeriod period) async {
    if (_period == period && _subscription != null) return;
    _period = period;
    await _subscribe();
  }

  Future<void> retry() => _subscribe();

  Future<void> _subscribe() async {
    await _subscription?.cancel();
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    final range = activeRange;
    _subscription = _repository
        .watchSnapshot(
          storeId: _storeId,
          fromInclusive: range.start,
          toExclusive: range.end,
        )
        .listen(
          (snapshot) {
            _snapshot = snapshot;
            _isLoading = false;
            _errorMessage = null;
            notifyListeners();
          },
          onError: (_) {
            _isLoading = false;
            _errorMessage =
                'Ringkasan usaha gagal dimuat dari penyimpanan lokal.';
            notifyListeners();
          },
        );
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}

@immutable
class DateTimeRange {
  const DateTimeRange({required this.start, required this.end});
  final DateTime start;
  final DateTime end;
}

DateTimeRange _rangeFor(DashboardPeriod period, DateTime now) {
  final today = DateTime(now.year, now.month, now.day);
  final days = switch (period) {
    DashboardPeriod.today => 1,
    DashboardPeriod.sevenDays => 7,
    DashboardPeriod.thirtyDays => 30,
  };
  return DateTimeRange(
    start: today.subtract(Duration(days: days - 1)),
    end: today.add(const Duration(days: 1)),
  );
}
