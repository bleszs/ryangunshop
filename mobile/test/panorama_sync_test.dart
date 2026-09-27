import 'dart:convert';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ryangunshop/data/local/app_database.dart';
import 'package:ryangunshop/data/repositories/syncing_panorama_repository.dart';
import 'package:ryangunshop/data/sync/panorama_outbox_sync.dart';
import 'package:ryangunshop/domain/entities/panorama_entities.dart';
import 'package:ryangunshop/domain/repositories/repositories.dart';

void main() {
  late AppDatabase database;
  late _MemoryPanoramaRepository local;
  late SyncingPanoramaRepository repository;
  late _FakePanoramaRemote remote;
  late PanoramaOutboxSyncProcessor processor;
  var now = DateTime.utc(2026, 9, 27, 8);

  setUp(() {
    database = AppDatabase.forTesting(NativeDatabase.memory());
    local = _MemoryPanoramaRepository();
    repository = SyncingPanoramaRepository(
      local: local,
      database: database,
      clock: () => now,
    );
    remote = _FakePanoramaRemote();
    processor = PanoramaOutboxSyncProcessor(
      database: database,
      remote: remote,
      clock: () => now,
    );
  });

  tearDown(() => database.close());

  test('import dan edit hotspot mempertahankan satu upload foto', () async {
    final zone = await repository.importZone(
      storeId: 'store-1',
      name: 'Rak depan',
      sourceImagePath: '/private/source.jpg',
    );
    final edited = zone.copyWith(
      hotspots: const [
        PanoramaHotspotEntity(
          fixtureId: 'fixture-1',
          longitude: 12,
          latitude: -4,
        ),
      ],
      updatedAt: now.add(const Duration(minutes: 1)),
    );
    await repository.saveZone(edited);

    final events = await database.select(database.syncOutbox).get();
    expect(events, hasLength(1));
    expect(jsonDecode(events.single.payloadJson)['uploadRequired'], isTrue);

    final result = await processor.processPending(storeId: 'store-1');

    expect(result.synced, 1);
    expect(remote.upserts, hasLength(1));
    expect(remote.upserts.single.zone.hotspots, hasLength(1));
    expect(remote.upserts.single.uploadRequired, isTrue);
    expect(await database.select(database.syncOutbox).get(), isEmpty);
  });

  test('edit setelah upload hanya menyinkronkan metadata', () async {
    final zone = _zone();
    await repository.saveZone(zone);

    expect((await processor.processPending()).synced, 1);
    expect(remote.upserts.single.uploadRequired, isFalse);
  });

  test('hapus zona mengganti event pending dan menghapus remote', () async {
    final zone = await repository.importZone(
      storeId: 'store-1',
      name: 'Rak depan',
      sourceImagePath: '/private/source.jpg',
    );
    await repository.deleteZone(zone);

    final event = await database.select(database.syncOutbox).getSingle();
    expect(event.operation, 'delete');
    expect((await processor.processPending()).synced, 1);
    expect(remote.deletes, [('store-1', zone.id)]);
    expect(local.zones, isEmpty);
  });

  test('gagal upload dijadwalkan ulang tanpa membocorkan credential', () async {
    await repository.saveZone(_zone());
    remote.failure = StateError(
      'Authorization: Bearer panorama-secret owner@example.com',
    );

    expect((await processor.processPending()).failed, 1);
    final event = await database.select(database.syncOutbox).getSingle();
    expect(event.attemptCount, 1);
    expect(event.nextAttemptAt?.toUtc(), now.add(const Duration(seconds: 30)));
    expect(event.lastError, isNot(contains('panorama-secret')));
    expect(event.lastError, isNot(contains('owner@example.com')));
  });

  test('mode preview lokal tidak membuat antrean Firebase', () async {
    final previewRepository = SyncingPanoramaRepository(
      local: local,
      database: database,
      clock: () => now,
      shouldSync: (storeId) => storeId != 'local-preview-store',
    );

    await previewRepository.importZone(
      storeId: 'local-preview-store',
      name: 'Demo lokal',
      sourceImagePath: '/private/demo.jpg',
    );

    expect(await database.select(database.syncOutbox).get(), isEmpty);
  });
}

PanoramaZoneEntity _zone() => PanoramaZoneEntity(
  id: 'zone-1',
  storeId: 'store-1',
  name: 'Rak depan',
  imagePath: '/private/zone-1.jpg',
  thumbnailPath: '/private/zone-1-preview.jpg',
  updatedAt: DateTime.utc(2026, 9, 27, 8),
);

class _MemoryPanoramaRepository implements PanoramaRepository {
  final zones = <PanoramaZoneEntity>[];

  @override
  Future<List<PanoramaZoneEntity>> loadZones(String storeId) async =>
      zones.where((zone) => zone.storeId == storeId).toList(growable: false);

  @override
  Future<PanoramaZoneEntity> importZone({
    required String storeId,
    required String name,
    required String sourceImagePath,
  }) async {
    final zone = PanoramaZoneEntity(
      id: 'zone-1',
      storeId: storeId,
      name: name,
      imagePath: '/private/zone-1.jpg',
      thumbnailPath: '/private/zone-1-preview.jpg',
      updatedAt: DateTime.utc(2026, 9, 27, 8),
    );
    zones.add(zone);
    return zone;
  }

  @override
  Future<void> saveZone(PanoramaZoneEntity zone) async {
    zones.removeWhere((item) => item.id == zone.id);
    zones.add(zone);
  }

  @override
  Future<void> deleteZone(PanoramaZoneEntity zone) async {
    zones.removeWhere((item) => item.id == zone.id);
  }
}

class _FakePanoramaRemote implements PanoramaRemoteRepository {
  Object? failure;
  final upserts = <({PanoramaZoneEntity zone, bool uploadRequired})>[];
  final deletes = <(String, String)>[];

  @override
  Future<void> upsertPanoramaZone(
    PanoramaZoneEntity zone, {
    required String mutationId,
    required bool uploadRequired,
  }) async {
    if (failure case final current?) throw current;
    upserts.add((zone: zone, uploadRequired: uploadRequired));
  }

  @override
  Future<void> deletePanoramaZone({
    required String storeId,
    required String zoneId,
    required String mutationId,
  }) async {
    if (failure case final current?) throw current;
    deletes.add((storeId, zoneId));
  }
}
