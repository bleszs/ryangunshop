import 'dart:convert';

import 'package:drift/drift.dart';

import '../../core/security/sensitive_data_redactor.dart';
import '../../domain/entities/panorama_entities.dart';
import '../../domain/repositories/repositories.dart';
import '../local/app_database.dart';
import 'store_layout_outbox_sync.dart';

class PanoramaOutboxSyncProcessor {
  PanoramaOutboxSyncProcessor({
    required AppDatabase database,
    required PanoramaRemoteRepository remote,
    DateTime Function()? clock,
    this.batchSize = 10,
  }) : _database = database,
       _remote = remote,
       _clock = clock ?? DateTime.now {
    if (batchSize <= 0) throw ArgumentError.value(batchSize, 'batchSize');
  }

  final AppDatabase _database;
  final PanoramaRemoteRepository _remote;
  final DateTime Function() _clock;
  final int batchSize;
  bool _isRunning = false;

  Future<OutboxSyncResult> processPending({String? storeId}) async {
    if (_isRunning) {
      return const OutboxSyncResult(skippedBecauseBusy: true);
    }
    _isRunning = true;
    try {
      final now = _clock();
      final query = _database.select(_database.syncOutbox)
        ..where((table) {
          var predicate =
              table.aggregateType.equals('panoramaZone') &
              (table.nextAttemptAt.isNull() |
                  table.nextAttemptAt.isSmallerOrEqualValue(now));
          final tenant = storeId?.trim();
          if (tenant != null && tenant.isNotEmpty) {
            predicate = predicate & table.storeId.equals(tenant);
          }
          return predicate;
        })
        ..orderBy([
          (table) => OrderingTerm.asc(table.createdAt),
          (table) => OrderingTerm.asc(table.id),
        ])
        ..limit(batchSize);

      final events = await query.get();
      var synced = 0;
      var failed = 0;
      for (final event in events) {
        try {
          switch (event.operation) {
            case 'upsert':
              final payload = _decodeUpsert(event);
              await _remote.upsertPanoramaZone(
                payload.zone,
                mutationId: event.id,
                uploadRequired: payload.uploadRequired,
              );
            case 'delete':
              _validateDelete(event);
              await _remote.deletePanoramaZone(
                storeId: event.storeId,
                zoneId: event.aggregateId,
                mutationId: event.id,
              );
            default:
              throw FormatException(
                'Operasi panorama tidak didukung: ${event.operation}',
              );
          }
          await (_database.delete(
            _database.syncOutbox,
          )..where((table) => table.id.equals(event.id))).go();
          synced++;
        } on Object catch (error) {
          await _scheduleRetry(event, error);
          failed++;
        }
      }
      return OutboxSyncResult(
        attempted: events.length,
        synced: synced,
        failed: failed,
      );
    } finally {
      _isRunning = false;
    }
  }

  Future<void> _scheduleRetry(SyncOutboxRow event, Object error) async {
    final attemptCount = event.attemptCount + 1;
    final exponent = event.attemptCount.clamp(0, 10).toInt();
    final seconds = (30 * (1 << exponent)).clamp(30, 21600).toInt();
    await (_database.update(
      _database.syncOutbox,
    )..where((table) => table.id.equals(event.id))).write(
      SyncOutboxCompanion(
        attemptCount: Value(attemptCount),
        nextAttemptAt: Value(_clock().add(Duration(seconds: seconds))),
        lastError: Value(SensitiveDataRedactor.error(error)),
      ),
    );
  }
}

_PanoramaUpsertPayload _decodeUpsert(SyncOutboxRow event) {
  final decoded = jsonDecode(event.payloadJson);
  if (decoded is! Map<String, dynamic>) {
    throw const FormatException('Payload panorama harus berupa object.');
  }
  if (decoded['id'] != event.aggregateId ||
      decoded['storeId'] != event.storeId) {
    throw const FormatException('Tenant atau zoneId panorama tidak cocok.');
  }
  final imagePath = decoded['imagePath'];
  final thumbnailPath = decoded['thumbnailPath'];
  final uploadRequired = decoded['uploadRequired'];
  if (imagePath is! String || imagePath.trim().isEmpty) {
    throw const FormatException('Path panorama tidak valid.');
  }
  if (thumbnailPath is! String || thumbnailPath.trim().isEmpty) {
    throw const FormatException('Path preview panorama tidak valid.');
  }
  if (uploadRequired is! bool) {
    throw const FormatException('Status upload panorama tidak valid.');
  }
  return _PanoramaUpsertPayload(
    zone: PanoramaZoneEntity.fromJson(decoded),
    uploadRequired: uploadRequired,
  );
}

void _validateDelete(SyncOutboxRow event) {
  final decoded = jsonDecode(event.payloadJson);
  if (decoded is! Map<String, dynamic> ||
      decoded['storeId'] != event.storeId ||
      decoded['zoneId'] != event.aggregateId ||
      decoded['deletedAt'] is! String) {
    throw const FormatException('Payload hapus panorama tidak valid.');
  }
}

class _PanoramaUpsertPayload {
  const _PanoramaUpsertPayload({
    required this.zone,
    required this.uploadRequired,
  });

  final PanoramaZoneEntity zone;
  final bool uploadRequired;
}
