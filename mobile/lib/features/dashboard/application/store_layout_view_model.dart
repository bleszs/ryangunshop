import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import '../../../domain/entities/store_layout_entities.dart';
import '../../../domain/repositories/repositories.dart';

enum StoreViewMode { floorPlan, panorama }

class StoreLayoutViewModel extends ChangeNotifier {
  StoreLayoutViewModel({
    required StoreLayoutRepository repository,
    required String storeId,
    this.canEditLayout = false,
    Uuid uuid = const Uuid(),
  }) : _repository = repository,
       _storeId = storeId,
       _uuid = uuid;

  final StoreLayoutRepository _repository;
  final String _storeId;
  final Uuid _uuid;
  final bool canEditLayout;
  StreamSubscription<StoreLayoutEntity?>? _layoutSubscription;
  bool _isEditing = false;
  bool _hasUnsavedChanges = false;
  bool _isLoading = true;
  bool _isSaving = false;
  String? _errorMessage;
  StoreViewMode _viewMode = StoreViewMode.floorPlan;
  String? _selectedFixtureId;
  final List<List<StoreFixture>> _history = [];

  final List<StoreFixture> _fixtures = [
    const StoreFixture(
      id: 'cashier',
      type: StoreFixtureType.cashier,
      label: 'Meja kasir',
      x: .07,
      y: .78,
      width: .38,
      height: .13,
    ),
    const StoreFixture(
      id: 'shelf-a',
      type: StoreFixtureType.shelf,
      label: 'Rak A',
      x: .08,
      y: .12,
      width: .22,
      height: .45,
    ),
    const StoreFixture(
      id: 'shelf-b',
      type: StoreFixtureType.shelf,
      label: 'Rak B',
      x: .39,
      y: .12,
      width: .22,
      height: .45,
    ),
    const StoreFixture(
      id: 'fridge',
      type: StoreFixtureType.refrigerator,
      label: 'Kulkas',
      x: .72,
      y: .10,
      width: .20,
      height: .31,
    ),
    const StoreFixture(
      id: 'cabinet',
      type: StoreFixtureType.cabinet,
      label: 'Lemari',
      x: .69,
      y: .54,
      width: .24,
      height: .16,
    ),
  ];

  bool get isEditing => _isEditing;
  bool get hasUnsavedChanges => _hasUnsavedChanges;
  bool get isLoading => _isLoading;
  bool get isSaving => _isSaving;
  bool get canUndo => _history.isNotEmpty;
  String? get errorMessage => _errorMessage;
  StoreViewMode get viewMode => _viewMode;
  List<StoreFixture> get fixtures => List.unmodifiable(_fixtures);
  StoreFixture? get selectedFixture {
    for (final fixture in _fixtures) {
      if (fixture.id == _selectedFixtureId) return fixture;
    }
    return null;
  }

  Future<void> initialize() async {
    await _layoutSubscription?.cancel();
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    _layoutSubscription = _repository
        .watchLayout(_storeId)
        .listen(
          (layout) {
            if (layout != null && !_hasUnsavedChanges) {
              _fixtures
                ..clear()
                ..addAll(layout.fixtures);
              _history.clear();
            }
            _isLoading = false;
            _errorMessage = null;
            notifyListeners();
          },
          onError: (Object error) {
            _isLoading = false;
            _errorMessage = 'Denah lokal gagal dimuat.';
            notifyListeners();
          },
        );
  }

  void setViewMode(StoreViewMode mode) {
    if (_viewMode == mode) return;
    _viewMode = mode;
    notifyListeners();
  }

  void toggleEditing() {
    if (!canEditLayout) {
      _errorMessage = 'Hanya owner yang dapat mengubah tata letak warung.';
      notifyListeners();
      return;
    }
    _isEditing = !_isEditing;
    _selectedFixtureId = null;
    _errorMessage = null;
    notifyListeners();
  }

  void selectFixture(String id) {
    _selectedFixtureId = id;
    notifyListeners();
  }

  void moveFixture(String id, double deltaX, double deltaY) {
    final index = _fixtures.indexWhere((fixture) => fixture.id == id);
    if (index < 0 || !_canMutate) return;
    final fixture = _fixtures[index];
    _fixtures[index] = fixture.copyWith(
      x: (fixture.x + deltaX).clamp(0, 1 - fixture.width),
      y: (fixture.y + deltaY).clamp(0, 1 - fixture.height),
    );
    _hasUnsavedChanges = true;
    notifyListeners();
  }

  void beginFixtureMove() {
    if (!_canMutate) return;
    _pushHistory();
  }

  void rotateSelected() {
    final index = _fixtures.indexWhere(
      (fixture) => fixture.id == _selectedFixtureId,
    );
    if (index < 0 || !_canMutate) return;
    _pushHistory();
    final fixture = _fixtures[index];
    final nextWidth = fixture.height.clamp(0.10, 1 - fixture.x);
    final nextHeight = fixture.width.clamp(0.08, 1 - fixture.y);
    _fixtures[index] = fixture.copyWith(
      width: nextWidth,
      height: nextHeight,
      rotationQuarterTurns: (fixture.rotationQuarterTurns + 1) % 4,
    );
    _hasUnsavedChanges = true;
    notifyListeners();
  }

  void addFixture(StoreFixtureType type) {
    if (!_canMutate) return;
    _pushHistory();
    final number =
        _fixtures.where((fixture) => fixture.type == type).length + 1;
    _fixtures.add(
      StoreFixture(
        id: _uuid.v4(),
        type: type,
        label: '${_defaultLabel(type)} $number',
        x: .35,
        y: .38,
        width: type == StoreFixtureType.refrigerator ? .20 : .28,
        height: type == StoreFixtureType.shelf ? .30 : .16,
      ),
    );
    _selectedFixtureId = _fixtures.last.id;
    _hasUnsavedChanges = true;
    notifyListeners();
  }

  void renameSelected(String name) {
    final normalized = name.trim();
    if (normalized.isEmpty || normalized.length > 40) return;
    final index = _selectedIndex;
    if (index < 0 || !_canMutate || _fixtures[index].label == normalized) {
      return;
    }
    _pushHistory();
    _fixtures[index] = _fixtures[index].copyWith(label: normalized);
    _hasUnsavedChanges = true;
    notifyListeners();
  }

  void resizeSelected(double scaleDelta) {
    final index = _selectedIndex;
    if (index < 0 || !_canMutate) return;
    final fixture = _fixtures[index];
    final width = (fixture.width + scaleDelta).clamp(.10, 1 - fixture.x);
    final height = (fixture.height + scaleDelta).clamp(.08, 1 - fixture.y);
    if (width == fixture.width && height == fixture.height) return;
    _pushHistory();
    _fixtures[index] = fixture.copyWith(width: width, height: height);
    _hasUnsavedChanges = true;
    notifyListeners();
  }

  void duplicateSelected() {
    final index = _selectedIndex;
    if (index < 0 || !_canMutate) return;
    _pushHistory();
    final source = _fixtures[index];
    final copy = source.copyWith(
      id: _uuid.v4(),
      label: '${source.label} salinan',
      x: (source.x + .04).clamp(0, 1 - source.width),
      y: (source.y + .04).clamp(0, 1 - source.height),
      productIds: const [],
    );
    _fixtures.add(copy);
    _selectedFixtureId = copy.id;
    _hasUnsavedChanges = true;
    notifyListeners();
  }

  void deleteSelected() {
    final index = _selectedIndex;
    if (index < 0 || !_canMutate) return;
    _pushHistory();
    _fixtures.removeAt(index);
    _selectedFixtureId = null;
    _hasUnsavedChanges = true;
    notifyListeners();
  }

  void undo() {
    if (_history.isEmpty || !_canMutate) return;
    final previous = _history.removeLast();
    _fixtures
      ..clear()
      ..addAll(previous);
    if (!_fixtures.any((fixture) => fixture.id == _selectedFixtureId)) {
      _selectedFixtureId = null;
    }
    _hasUnsavedChanges = true;
    notifyListeners();
  }

  void setSelectedProductIds(Iterable<String> productIds) {
    final index = _selectedIndex;
    if (index < 0 || !_canMutate) return;
    final normalized =
        productIds
            .map((id) => id.trim())
            .where((id) => id.isNotEmpty)
            .toSet()
            .toList(growable: false)
          ..sort();
    if (listEquals(_fixtures[index].productIds, normalized)) return;
    _pushHistory();
    _fixtures[index] = _fixtures[index].copyWith(productIds: normalized);
    _hasUnsavedChanges = true;
    notifyListeners();
  }

  Future<bool> saveLayout() async {
    if (_isSaving || !_hasUnsavedChanges || !_canMutate) return false;
    _isSaving = true;
    _errorMessage = null;
    notifyListeners();
    try {
      await _repository.saveLayout(
        StoreLayoutEntity(
          id: '$_storeId-main-layout',
          storeId: _storeId,
          name: 'Tata letak utama',
          canvasAspectRatio: .78,
          templateVersion: 1,
          fixtures: List.unmodifiable(_fixtures),
          updatedAt: DateTime.now(),
        ),
      );
      _hasUnsavedChanges = false;
      _history.clear();
      return true;
    } catch (_) {
      _errorMessage = 'Denah gagal disimpan. Coba lagi.';
      return false;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _layoutSubscription?.cancel();
    super.dispose();
  }

  int get _selectedIndex =>
      _fixtures.indexWhere((fixture) => fixture.id == _selectedFixtureId);

  bool get _canMutate => canEditLayout && _isEditing;

  void _pushHistory() {
    _history.add(List<StoreFixture>.of(_fixtures));
    if (_history.length > 20) _history.removeAt(0);
  }
}

String _defaultLabel(StoreFixtureType type) => switch (type) {
  StoreFixtureType.shelf => 'Rak',
  StoreFixtureType.cabinet => 'Lemari',
  StoreFixtureType.refrigerator => 'Kulkas',
  StoreFixtureType.cashier => 'Kasir',
  StoreFixtureType.display => 'Etalase',
};
