import 'dart:convert';
import 'dart:math' as math;

import 'package:drift/drift.dart';

import '../../core/security/sensitive_data_redactor.dart';
import '../../domain/repositories/repositories.dart';
import '../local/app_database.dart';
import 'store_layout_outbox_sync.dart';

class InventoryStockOutboxSyncProcessor {
  InventoryStockOutboxSyncProcessor({
    required AppDatabase database,
    required InventoryStockRemoteRepository remote,
    DateTime Function()? clock,
    Duration baseRetryDelay = const Duration(seconds: 30),
    Duration maximumRetryDelay = const Duration(hours: 6),
    this.batchSize = 50,
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
      throw ArgumentError.value(maximumRetryDelay, 'maximumRetryDelay');
    }
  }

  final AppDatabase _database;
  final InventoryStockRemoteRepository _remote;
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
              table.aggregateType.equals('productStock') &
              table.operation.equals('adjust') &
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
          final mutation = _decodeMutation(event);
          await _remote.applyStockMutation(
            storeId: event.storeId,
            productId: event.aggregateId,
            delta: mutation.delta,
            transactionId: mutation.transactionId,
            mutationId: event.id,
            occurredAt: mutation.occurredAt,
          );
          await _markSynced(event);
          synced++;
        } on RemoteStockConflict catch (error) {
          await _markConflict(event, error);
          failed++;
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

  Future<void> _markConflict(
    SyncOutboxRow event,
    RemoteStockConflict error,
  ) async {
    await _database.transaction(() async {
      await (_database.update(
        _database.syncOutbox,
      )..where((table) => table.id.equals(event.id))).write(
        SyncOutboxCompanion(
          operation: const Value('conflict'),
          attemptCount: Value(event.attemptCount + 1),
          nextAttemptAt: const Value(null),
          lastError: Value(SensitiveDataRedactor.error(error)),
        ),
      );
      await (_database.update(_database.products)..where(
            (table) =>
                table.storeId.equals(event.storeId) &
                table.id.equals(event.aggregateId),
          ))
          .write(const ProductsCompanion(syncState: Value('failed')));
    });
  }

  Future<void> _markSynced(SyncOutboxRow event) async {
    await _database.transaction(() async {
      await (_database.delete(
        _database.syncOutbox,
      )..where((table) => table.id.equals(event.id))).go();
      final remaining =
          await (_database.select(_database.syncOutbox)
                ..where(
                  (table) =>
                      table.storeId.equals(event.storeId) &
                      table.aggregateId.equals(event.aggregateId) &
                      (table.aggregateType.equals('product') |
                          table.aggregateType.equals('productStock')),
                )
                ..limit(1))
              .getSingleOrNull();
      if (remaining == null) {
        await (_database.update(_database.products)..where(
              (table) =>
                  table.storeId.equals(event.storeId) &
                  table.id.equals(event.aggregateId),
            ))
            .write(const ProductsCompanion(syncState: Value('synced')));
      }
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
    final microseconds = math.min(
      _baseRetryDelay.inMicroseconds * multiplier,
      _maximumRetryDelay.inMicroseconds,
    );
    return Duration(microseconds: microseconds);
  }
}

({int delta, String transactionId, DateTime occurredAt}) _decodeMutation(
  SyncOutboxRow event,
) {
  final decoded = jsonDecode(event.payloadJson);
  if (decoded is! Map<String, dynamic>) {
    throw const FormatException('Payload stok harus berupa object JSON');
  }
  final productId = decoded['productId'];
  final delta = decoded['delta'];
  final transactionId = decoded['transactionId'];
  final occurredAt = decoded['occurredAt'];
  if (productId is! String || productId != event.aggregateId) {
    throw const FormatException('Product payload tidak cocok dengan aggregate');
  }
  if (delta is! int || delta == 0) {
    throw const FormatException('Delta stok wajib berupa integer non-zero');
  }
  if (transactionId is! String || transactionId.trim().isEmpty) {
    throw const FormatException('Transaction ID wajib diisi');
  }
  if (occurredAt is! String) {
    throw const FormatException('Waktu mutasi wajib diisi');
  }
  return (
    delta: delta,
    transactionId: transactionId,
    occurredAt: DateTime.parse(occurredAt).toUtc(),
  );
}
