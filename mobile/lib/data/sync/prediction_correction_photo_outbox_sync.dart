import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart';

import '../../core/security/sensitive_data_redactor.dart';
import '../../domain/repositories/repositories.dart';
import '../local/app_database.dart';
import 'store_layout_outbox_sync.dart';

class PredictionCorrectionPhotoOutboxSyncProcessor {
  PredictionCorrectionPhotoOutboxSyncProcessor({
    required AppDatabase database,
    required PredictionCorrectionPhotoRemoteRepository remote,
    DateTime Function()? clock,
    this.batchSize = 10,
  }) : _database = database,
       _remote = remote,
       _clock = clock ?? DateTime.now {
    if (batchSize <= 0) throw ArgumentError.value(batchSize, 'batchSize');
  }

  final AppDatabase _database;
  final PredictionCorrectionPhotoRemoteRepository _remote;
  final DateTime Function() _clock;
  final int batchSize;
  bool _isRunning = false;

  Future<OutboxSyncResult> processPending({String? storeId}) async {
    if (_isRunning) {
      return const OutboxSyncResult(skippedBecauseBusy: true);
    }
    _isRunning = true;
    try {
      final now = _clock().toUtc();
      final query = _database.select(_database.syncOutbox)
        ..where((table) {
          var predicate =
              table.aggregateType.equals('predictionCorrection') &
              table.operation.equals('uploadPhoto') &
              (table.nextAttemptAt.isNull() |
                  table.nextAttemptAt.isSmallerOrEqualValue(now));
          final tenant = storeId?.trim();
          if (tenant != null && tenant.isNotEmpty) {
            predicate = predicate & table.storeId.equals(tenant);
          }
          return predicate;
        })
        ..orderBy([(table) => OrderingTerm.asc(table.createdAt)])
        ..limit(batchSize);

      final events = await query.get();
      var synced = 0;
      var failed = 0;
      for (final event in events) {
        try {
          final payload = _decode(event);
          if (!payload.expiresAt.isAfter(now)) {
            await _finish(event, remoteUri: null, state: 'expired');
            await _deleteLocalBestEffort(payload.localPhotoPath);
            synced++;
            continue;
          }
          final remoteUri = await _remote.uploadCorrectionPhoto(
            storeId: event.storeId,
            predictionId: event.aggregateId,
            localPhotoPath: payload.localPhotoPath,
            expiresAt: payload.expiresAt,
            selectedProductId: payload.selectedProductId,
            modelVersion: payload.modelVersion,
            initialLabel: payload.initialLabel,
            initialConfidence: payload.initialConfidence,
          );
          await _finish(event, remoteUri: remoteUri, state: 'synced');
          await _deleteLocalBestEffort(payload.localPhotoPath);
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

  Future<void> _deleteLocalBestEffort(String localPhotoPath) async {
    try {
      final file = File(localPhotoPath);
      if (await file.exists()) await file.delete();
    } on Object {
      // Upload sudah tercatat. Pembersihan periodik akan mencoba lagi nanti.
    }
  }

  Future<void> _finish(
    SyncOutboxRow event, {
    required String? remoteUri,
    required String state,
  }) async {
    await _database.transaction(() async {
      await (_database.delete(
        _database.syncOutbox,
      )..where((table) => table.id.equals(event.id))).go();
      await (_database.update(_database.predictions)..where(
            (table) =>
                table.id.equals(event.aggregateId) &
                table.storeId.equals(event.storeId),
          ))
          .write(
            PredictionsCompanion(
              correctionPhotoUri: Value(remoteUri),
              syncState: Value(state),
              updatedAt: Value(_clock()),
            ),
          );
    });
  }

  Future<void> _scheduleRetry(SyncOutboxRow event, Object error) async {
    final attemptCount = event.attemptCount + 1;
    final exponent = event.attemptCount.clamp(0, 10).toInt();
    final delaySeconds = (30 * (1 << exponent)).clamp(30, 21600).toInt();
    await (_database.update(
      _database.syncOutbox,
    )..where((table) => table.id.equals(event.id))).write(
      SyncOutboxCompanion(
        attemptCount: Value(attemptCount),
        nextAttemptAt: Value(
          _clock().toUtc().add(Duration(seconds: delaySeconds)),
        ),
        lastError: Value(SensitiveDataRedactor.error(error)),
      ),
    );
  }
}

_CorrectionPhotoPayload _decode(SyncOutboxRow event) {
  final decoded = jsonDecode(event.payloadJson);
  if (decoded is! Map<String, dynamic>) {
    throw const FormatException('Payload foto koreksi harus berupa object.');
  }
  final predictionId = decoded['predictionId'];
  final storeId = decoded['storeId'];
  final localPhotoPath = decoded['localPhotoPath'];
  final expiresAt = decoded['expiresAt'];
  final selectedProductId = decoded['selectedProductId'];
  final modelVersion = decoded['modelVersion'];
  final initialLabel = decoded['initialLabel'];
  final initialConfidence = decoded['initialConfidence'];
  if (predictionId != event.aggregateId || storeId != event.storeId) {
    throw const FormatException('Tenant atau predictionId tidak cocok.');
  }
  if (localPhotoPath is! String || localPhotoPath.trim().isEmpty) {
    throw const FormatException('Path foto koreksi tidak valid.');
  }
  if (expiresAt is! String) {
    throw const FormatException('Retention foto koreksi tidak valid.');
  }
  if (selectedProductId is! String || selectedProductId.trim().isEmpty) {
    throw const FormatException('Label produk koreksi tidak valid.');
  }
  if (modelVersion is! String || modelVersion.trim().isEmpty) {
    throw const FormatException('Versi model koreksi tidak valid.');
  }
  if (initialLabel != null && initialLabel is! String) {
    throw const FormatException('Label awal koreksi tidak valid.');
  }
  if (initialConfidence != null && initialConfidence is! num) {
    throw const FormatException('Confidence awal koreksi tidak valid.');
  }
  return _CorrectionPhotoPayload(
    localPhotoPath: localPhotoPath,
    expiresAt: DateTime.parse(expiresAt).toUtc(),
    selectedProductId: selectedProductId,
    modelVersion: modelVersion,
    initialLabel: initialLabel as String?,
    initialConfidence: (initialConfidence as num?)?.toDouble(),
  );
}

class _CorrectionPhotoPayload {
  const _CorrectionPhotoPayload({
    required this.localPhotoPath,
    required this.expiresAt,
    required this.selectedProductId,
    required this.modelVersion,
    required this.initialLabel,
    required this.initialConfidence,
  });

  final String localPhotoPath;
  final DateTime expiresAt;
  final String selectedProductId;
  final String modelVersion;
  final String? initialLabel;
  final double? initialConfidence;
}
