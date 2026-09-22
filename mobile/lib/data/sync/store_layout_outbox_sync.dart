import 'dart:convert';
import 'dart:math' as math;

import 'package:drift/drift.dart';

import '../../core/security/sensitive_data_redactor.dart';
import '../../domain/entities/store_layout_entities.dart';
import '../../domain/repositories/repositories.dart';
import '../local/app_database.dart';

class OutboxSyncResult {
  const OutboxSyncResult({
    this.attempted = 0,
    this.synced = 0,
    this.failed = 0,
    this.skippedBecauseBusy = false,
  });

  final int attempted;
  final int synced;
  final int failed;
  final bool skippedBecauseBusy;
}

/// Mengirim event `storeLayout.upsert` yang sudah disimpan secara atomik oleh
/// [DriftStoreLayoutRepository]. Pemanggil boleh menjalankan proses ini saat
/// aplikasi aktif maupun dari background worker pada tahap berikutnya.
class StoreLayoutOutboxSyncProcessor {
  StoreLayoutOutboxSyncProcessor({
    required AppDatabase database,
    required StoreLayoutRemoteRepository remote,
    DateTime Function()? clock,
    Duration baseRetryDelay = const Duration(seconds: 30),
    Duration maximumRetryDelay = const Duration(hours: 6),
    this.batchSize = 20,
  }) : _database = database,
       _remote = remote,
       _clock = clock ?? DateTime.now,
       _baseRetryDelay = baseRetryDelay,
       _maximumRetryDelay = maximumRetryDelay {
    if (batchSize <= 0) throw ArgumentError.value(batchSize, 'batchSize');
    if (baseRetryDelay <= Duration.zero) {
      throw ArgumentError.value(baseRetryDelay, 'baseRetryDelay');
    }
    if (maximumRetryDelay < baseRetryDelay) {
      throw ArgumentError.value(
        maximumRetryDelay,
        'maximumRetryDelay',
        'Harus lebih besar atau sama dengan baseRetryDelay',
      );
    }
  }

  final AppDatabase _database;
  final StoreLayoutRemoteRepository _remote;
  final DateTime Function() _clock;
  final Duration _baseRetryDelay;
  final Duration _maximumRetryDelay;
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
              table.aggregateType.equals('storeLayout') &
              table.operation.equals('upsert') &
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
          final layout = _decodeLayout(event);
          await _remote.upsertStoreLayout(layout, mutationId: event.id);
          await _markSynced(event);
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

  Future<void> _markSynced(SyncOutboxRow event) async {
    await _database.transaction(() async {
      await (_database.delete(
        _database.syncOutbox,
      )..where((table) => table.id.equals(event.id))).go();

      final newerEvent =
          await (_database.select(_database.syncOutbox)
                ..where(
                  (table) =>
                      table.storeId.equals(event.storeId) &
                      table.aggregateType.equals(event.aggregateType) &
                      table.aggregateId.equals(event.aggregateId),
                )
                ..limit(1))
              .getSingleOrNull();
      if (newerEvent != null) return;

      await (_database.update(_database.storeLayouts)..where(
            (table) =>
                table.storeId.equals(event.storeId) &
                table.id.equals(event.aggregateId),
          ))
          .write(const StoreLayoutsCompanion(syncState: Value('synced')));
      await (_database.update(_database.storeFixtures)..where(
            (table) =>
                table.storeId.equals(event.storeId) &
                table.layoutId.equals(event.aggregateId),
          ))
          .write(const StoreFixturesCompanion(syncState: Value('synced')));
    });
  }

  Future<void> _scheduleRetry(SyncOutboxRow event, Object error) async {
    final attemptCount = event.attemptCount + 1;
    final nextAttemptAt = _clock().add(_retryDelay(event.attemptCount));
    await (_database.update(
      _database.syncOutbox,
    )..where((table) => table.id.equals(event.id))).write(
      SyncOutboxCompanion(
        attemptCount: Value(attemptCount),
        nextAttemptAt: Value(nextAttemptAt),
        lastError: Value(SensitiveDataRedactor.error(error)),
      ),
    );
  }

  Duration _retryDelay(int previousAttemptCount) {
    final exponent = math.min(previousAttemptCount, 20);
    final multiplier = 1 << exponent;
    final delayedMicroseconds = math.min(
      _baseRetryDelay.inMicroseconds * multiplier,
      _maximumRetryDelay.inMicroseconds,
    );
    return Duration(microseconds: delayedMicroseconds);
  }
}

StoreLayoutEntity _decodeLayout(SyncOutboxRow event) {
  final decoded = jsonDecode(event.payloadJson);
  if (decoded is! Map<String, dynamic>) {
    throw const FormatException('Payload layout harus berupa object JSON');
  }
  final id = _requiredString(decoded, 'id');
  final storeId = _requiredString(decoded, 'storeId');
  if (id != event.aggregateId || storeId != event.storeId) {
    throw const FormatException('Tenant atau aggregate payload tidak cocok');
  }
  final rawFixtures = decoded['fixtures'];
  if (rawFixtures is! List<dynamic>) {
    throw const FormatException('fixtures harus berupa array');
  }

  return StoreLayoutEntity(
    id: id,
    storeId: storeId,
    name: _requiredString(decoded, 'name'),
    canvasAspectRatio: _requiredNumber(decoded, 'canvasAspectRatio').toDouble(),
    templateVersion: _requiredNumber(decoded, 'templateVersion').toInt(),
    fixtures: rawFixtures
        .map((value) {
          if (value is! Map<String, dynamic>) {
            throw const FormatException('Fixture harus berupa object JSON');
          }
          final typeName = _requiredString(value, 'type');
          final productIds = value['productIds'];
          if (productIds is! List<dynamic>) {
            throw const FormatException('productIds harus berupa array');
          }
          StoreFixtureType type;
          try {
            type = StoreFixtureType.values.byName(typeName);
          } on ArgumentError {
            throw FormatException('Tipe fixture tidak dikenal: $typeName');
          }
          final panoramaZoneId = value['panoramaZoneId'];
          if (panoramaZoneId != null && panoramaZoneId is! String) {
            throw const FormatException('panoramaZoneId harus berupa string');
          }
          return StoreFixture(
            id: _requiredString(value, 'id'),
            type: type,
            label: _requiredString(value, 'label'),
            x: _requiredNumber(value, 'x').toDouble(),
            y: _requiredNumber(value, 'y').toDouble(),
            width: _requiredNumber(value, 'width').toDouble(),
            height: _requiredNumber(value, 'height').toDouble(),
            rotationQuarterTurns: _requiredNumber(
              value,
              'rotationQuarterTurns',
            ).toInt(),
            productIds: productIds
                .map((productId) {
                  if (productId is! String) {
                    throw const FormatException(
                      'productId harus berupa string',
                    );
                  }
                  return productId;
                })
                .toList(growable: false),
            panoramaZoneId: panoramaZoneId as String?,
          );
        })
        .toList(growable: false),
    updatedAt: DateTime.parse(_requiredString(decoded, 'updatedAt')).toUtc(),
  );
}

String _requiredString(Map<String, dynamic> json, String key) {
  final value = json[key];
  if (value is! String || value.trim().isEmpty) {
    throw FormatException('$key wajib berupa string');
  }
  return value;
}

num _requiredNumber(Map<String, dynamic> json, String key) {
  final value = json[key];
  if (value is! num || !value.isFinite) {
    throw FormatException('$key wajib berupa angka valid');
  }
  return value;
}
