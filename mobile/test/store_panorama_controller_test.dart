import 'package:flutter_test/flutter_test.dart';
import 'package:ryangunshop/domain/entities/panorama_entities.dart';
import 'package:ryangunshop/domain/repositories/repositories.dart';
import 'package:ryangunshop/features/dashboard/application/store_panorama_controller.dart';

void main() {
  group('StorePanoramaController', () {
    test('memuat zona dan menyimpan hotspot fixture tanpa duplikat', () async {
      final repository = _MemoryPanoramaRepository([
        _zone('zone-1', 'Rak depan'),
      ]);
      final controller = StorePanoramaController(
        repository: repository,
        storeId: 'store-1',
      );

      await controller.initialize();
      await controller.placeHotspot(
        fixtureId: 'shelf-a',
        longitude: 30,
        latitude: 10,
      );
      await controller.placeHotspot(
        fixtureId: 'shelf-a',
        longitude: 45,
        latitude: 12,
      );

      expect(controller.isLoading, isFalse);
      expect(controller.selectedZone?.name, 'Rak depan');
      expect(controller.selectedZone?.hotspots, hasLength(1));
      expect(controller.selectedZone?.hotspots.single.longitude, 45);
      expect(repository.savedZones, hasLength(2));
    });

    test('mengimpor, memilih, dan menghapus zona', () async {
      final repository = _MemoryPanoramaRepository([
        _zone('zone-1', 'Rak depan'),
      ]);
      final controller = StorePanoramaController(
        repository: repository,
        storeId: 'store-1',
      );
      await controller.initialize();

      final imported = await controller.importZone(
        name: 'Area kulkas',
        sourceImagePath: 'source.jpg',
      );

      expect(imported, isTrue);
      expect(controller.selectedZone?.id, 'imported-zone');
      expect(controller.zones, hasLength(2));

      final deleted = await controller.deleteSelectedZone();
      expect(deleted, isTrue);
      expect(repository.deletedIds, ['imported-zone']);
      expect(controller.selectedZone?.id, 'zone-1');
    });

    test('beralih ke preview statis saat renderer gagal', () async {
      final controller = StorePanoramaController(
        repository: _MemoryPanoramaRepository([_zone('zone-1', 'Rak depan')]),
        storeId: 'store-1',
      );
      await controller.initialize();

      controller.showRendererFallback();

      expect(controller.useStaticPreview, isTrue);
      expect(controller.errorMessage, contains('hemat daya'));
    });
  });
}

PanoramaZoneEntity _zone(String id, String name) => PanoramaZoneEntity(
  id: id,
  storeId: 'store-1',
  name: name,
  imagePath: '$id.jpg',
  thumbnailPath: '${id}_preview.jpg',
  updatedAt: DateTime.utc(2026),
);

class _MemoryPanoramaRepository implements PanoramaRepository {
  _MemoryPanoramaRepository(List<PanoramaZoneEntity> zones)
    : _zones = zones.toList();

  final List<PanoramaZoneEntity> _zones;
  final List<PanoramaZoneEntity> savedZones = [];
  final List<String> deletedIds = [];

  @override
  Future<List<PanoramaZoneEntity>> loadZones(String storeId) async =>
      _zones.toList();

  @override
  Future<PanoramaZoneEntity> importZone({
    required String storeId,
    required String name,
    required String sourceImagePath,
  }) async {
    final zone = PanoramaZoneEntity(
      id: 'imported-zone',
      storeId: storeId,
      name: name,
      imagePath: sourceImagePath,
      thumbnailPath: 'preview.jpg',
      updatedAt: DateTime.utc(2026, 2),
    );
    _zones.add(zone);
    return zone;
  }

  @override
  Future<void> saveZone(PanoramaZoneEntity zone) async {
    savedZones.add(zone);
    final index = _zones.indexWhere((item) => item.id == zone.id);
    if (index < 0) {
      _zones.add(zone);
    } else {
      _zones[index] = zone;
    }
  }

  @override
  Future<void> deleteZone(PanoramaZoneEntity zone) async {
    deletedIds.add(zone.id);
    _zones.removeWhere((item) => item.id == zone.id);
  }
}
