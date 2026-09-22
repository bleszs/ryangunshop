import 'package:flutter/foundation.dart';

import '../../../domain/entities/panorama_entities.dart';
import '../../../domain/repositories/repositories.dart';

class StorePanoramaController extends ChangeNotifier {
  StorePanoramaController({
    required PanoramaRepository repository,
    required String storeId,
  }) : _repository = repository,
       _storeId = storeId;

  final PanoramaRepository _repository;
  final String _storeId;

  List<PanoramaZoneEntity> _zones = const [];
  String? _selectedZoneId;
  bool _isLoading = true;
  bool _isImporting = false;
  bool _useStaticPreview = false;
  String? _errorMessage;

  List<PanoramaZoneEntity> get zones => List.unmodifiable(_zones);
  bool get isLoading => _isLoading;
  bool get isImporting => _isImporting;
  bool get useStaticPreview => _useStaticPreview;
  String? get errorMessage => _errorMessage;

  PanoramaZoneEntity? get selectedZone {
    if (_zones.isEmpty) return null;
    return _zones.firstWhere(
      (zone) => zone.id == _selectedZoneId,
      orElse: () => _zones.first,
    );
  }

  Future<void> initialize() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      _zones = await _repository.loadZones(_storeId);
      _selectedZoneId = _zones.isEmpty ? null : _zones.first.id;
    } catch (_) {
      _errorMessage = 'Foto 360\u00b0 lokal gagal dimuat.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void selectZone(String zoneId) {
    if (_selectedZoneId == zoneId) return;
    _selectedZoneId = zoneId;
    _useStaticPreview = false;
    _errorMessage = null;
    notifyListeners();
  }

  void setStaticPreview(bool enabled) {
    if (_useStaticPreview == enabled) return;
    _useStaticPreview = enabled;
    notifyListeners();
  }

  void showRendererFallback() {
    _useStaticPreview = true;
    _errorMessage =
        'Mode 360\u00b0 tidak dapat dimuat. Preview hemat daya diaktifkan.';
    notifyListeners();
  }

  void clearError() {
    if (_errorMessage == null) return;
    _errorMessage = null;
    notifyListeners();
  }

  Future<bool> importZone({
    required String name,
    required String sourceImagePath,
  }) async {
    if (_isImporting) return false;
    _isImporting = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final zone = await _repository.importZone(
        storeId: _storeId,
        name: name,
        sourceImagePath: sourceImagePath,
      );
      _zones = [zone, ..._zones.where((item) => item.id != zone.id)];
      _selectedZoneId = zone.id;
      _useStaticPreview = false;
      return true;
    } catch (error) {
      _errorMessage = error.toString();
      return false;
    } finally {
      _isImporting = false;
      notifyListeners();
    }
  }

  Future<void> placeHotspot({
    required String fixtureId,
    required double longitude,
    required double latitude,
  }) async {
    final zone = selectedZone;
    if (zone == null) return;
    final hotspots =
        zone.hotspots
            .where((hotspot) => hotspot.fixtureId != fixtureId)
            .toList()
          ..add(
            PanoramaHotspotEntity(
              fixtureId: fixtureId,
              longitude: longitude,
              latitude: latitude,
            ),
          );
    await _saveZone(
      zone.copyWith(hotspots: hotspots, updatedAt: DateTime.now()),
    );
  }

  Future<void> removeHotspot(String fixtureId) async {
    final zone = selectedZone;
    if (zone == null) return;
    await _saveZone(
      zone.copyWith(
        hotspots: zone.hotspots
            .where((hotspot) => hotspot.fixtureId != fixtureId)
            .toList(growable: false),
        updatedAt: DateTime.now(),
      ),
    );
  }

  Future<bool> deleteSelectedZone() async {
    final zone = selectedZone;
    if (zone == null) return false;
    _errorMessage = null;
    notifyListeners();
    try {
      await _repository.deleteZone(zone);
      _zones = _zones.where((item) => item.id != zone.id).toList();
      _selectedZoneId = _zones.isEmpty ? null : _zones.first.id;
      _useStaticPreview = false;
      return true;
    } catch (_) {
      _errorMessage = 'Zona gagal dihapus. Coba lagi.';
      return false;
    } finally {
      notifyListeners();
    }
  }

  Future<void> _saveZone(PanoramaZoneEntity updated) async {
    _errorMessage = null;
    try {
      await _repository.saveZone(updated);
      _zones = _zones
          .map((zone) => zone.id == updated.id ? updated : zone)
          .toList(growable: false);
    } catch (_) {
      _errorMessage = 'Hotspot gagal disimpan. Coba lagi.';
    }
    notifyListeners();
  }
}
