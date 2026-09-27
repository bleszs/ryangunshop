import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../domain/entities/panorama_entities.dart';
import '../../domain/repositories/repositories.dart';
import '../local/app_database.dart';

/// Menjaga UX panorama tetap local-first, lalu menulis satu event outbox
/// terbaru per zona. Flag upload dari event import tidak boleh hilang ketika
/// hotspot diedit sebelum foto sempat tersinkron.
class SyncingPanoramaRepository implements PanoramaRepository {
  SyncingPanoramaRepository({
    required PanoramaRepository local,
    required AppDatabase database,
    Uuid uuid = const Uuid(),
    DateTime Function()? clock,
    bool Function(String storeId)? shouldSync,
  }) : _local = local,
       _database = database,
       _uuid = uuid,
       _clock = clock ?? DateTime.now,
       _shouldSync = shouldSync ?? _alwaysSync;

  final PanoramaRepository _local;
  final AppDatabase _database;
  final Uuid _uuid;
  final DateTime Function() _clock;
  final bool Function(String storeId) _shouldSync;

  @override
  Future<List<PanoramaZoneEntity>> loadZones(String storeId) =>
      _local.loadZones(storeId);

  @override
  Future<PanoramaZoneEntity> importZone({
    required String storeId,
    required String name,
    required String sourceImagePath,
  }) async {
    final zone = await _local.importZone(
      storeId: storeId,
      name: name,
      sourceImagePath: sourceImagePath,
    );
    if (_shouldSync(zone.storeId)) {
      await _enqueueUpsert(zone, uploadRequired: true);
    }
    return zone;
  }

  @override
  Future<void> saveZone(PanoramaZoneEntity zone) async {
    await _local.saveZone(zone);
    if (_shouldSync(zone.storeId)) {
      await _enqueueUpsert(zone, uploadRequired: false);
    }
  }

  @override
  Future<void> deleteZone(PanoramaZoneEntity zone) async {
    await _local.deleteZone(zone);
    if (!_shouldSync(zone.storeId)) return;
    final now = _clock();
    await _database.transaction(() async {
      await _deletePending(zone.storeId, zone.id);
      await _database
          .into(_database.syncOutbox)
          .insert(
            SyncOutboxCompanion.insert(
              id: _uuid.v4(),
              storeId: zone.storeId,
              aggregateType: 'panoramaZone',
              aggregateId: zone.id,
              operation: 'delete',
              payloadJson: jsonEncode({
                'storeId': zone.storeId,
                'zoneId': zone.id,
                'deletedAt': now.toUtc().toIso8601String(),
              }),
              createdAt: now,
            ),
          );
    });
  }

  Future<void> _enqueueUpsert(
    PanoramaZoneEntity zone, {
    required bool uploadRequired,
  }) async {
    final now = _clock();
    await _database.transaction(() async {
      final pending =
          await (_database.select(_database.syncOutbox)..where(
                (table) =>
                    table.storeId.equals(zone.storeId) &
                    table.aggregateType.equals('panoramaZone') &
                    table.aggregateId.equals(zone.id),
              ))
              .get();
      final pendingUpload = pending.any((event) {
        if (event.operation != 'upsert') return false;
        try {
          final payload = jsonDecode(event.payloadJson);
          return payload is Map && payload['uploadRequired'] == true;
        } on FormatException {
          return false;
        }
      });
      await _deletePending(zone.storeId, zone.id);
      await _database
          .into(_database.syncOutbox)
          .insert(
            SyncOutboxCompanion.insert(
              id: _uuid.v4(),
              storeId: zone.storeId,
              aggregateType: 'panoramaZone',
              aggregateId: zone.id,
              operation: 'upsert',
              payloadJson: jsonEncode({
                ...zone.toJson(),
                'uploadRequired': uploadRequired || pendingUpload,
              }),
              createdAt: now,
            ),
          );
    });
  }

  Future<void> _deletePending(String storeId, String zoneId) =>
      (_database.delete(_database.syncOutbox)..where(
            (table) =>
                table.storeId.equals(storeId) &
                table.aggregateType.equals('panoramaZone') &
                table.aggregateId.equals(zoneId),
          ))
          .go();
}

bool _alwaysSync(String _) => true;
