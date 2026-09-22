import 'dart:convert';
import 'dart:math' as math;

import 'package:drift/drift.dart';

import '../../core/security/sensitive_data_redactor.dart';
import '../../domain/entities/entities.dart';
import '../../domain/repositories/repositories.dart';
import '../local/app_database.dart';
import 'store_layout_outbox_sync.dart';

class ProductCatalogOutboxSyncProcessor {
  ProductCatalogOutboxSyncProcessor({
    required AppDatabase database,
    required ProductRemoteRepository remote,
    DateTime Function()? clock,
    Duration baseRetryDelay = const Duration(seconds: 30),
    Duration maximumRetryDelay = const Duration(hours: 6),
    this.batchSize = 30,
  }) : _database = database,
       _remote = remote,
       _clock = clock ?? DateTime.now,
       _baseRetryDelay = baseRetryDelay,
       _maximumRetryDelay = maximumRetryDelay;

  final AppDatabase _database;
  final ProductRemoteRepository _remote;
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
              table.aggregateType.equals('product') &
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
              final decoded = _decodeProduct(event);
              await _remote.upsertProduct(
                decoded.product,
                mutationId: event.id,
                clientUpdatedAt: decoded.updatedAt,
              );
              break;
            case 'delete':
              await _remote.deleteProduct(
                storeId: event.storeId,
                productId: event.aggregateId,
                mutationId: event.id,
                deletedAt: _decodeDeletedAt(event),
              );
              break;
            default:
              throw FormatException(
                'Operasi produk tidak dikenal: ${event.operation}',
              );
          }
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
    await (_database.update(
      _database.syncOutbox,
    )..where((table) => table.id.equals(event.id))).write(
      SyncOutboxCompanion(
        attemptCount: Value(event.attemptCount + 1),
        nextAttemptAt: Value(_clock().add(_retryDelay(event.attemptCount))),
        lastError: Value(SensitiveDataRedactor.error(error)),
      ),
    );
  }

  Duration _retryDelay(int previousAttemptCount) {
    final multiplier = 1 << math.min(previousAttemptCount, 20);
    return Duration(
      microseconds: math.min(
        _baseRetryDelay.inMicroseconds * multiplier,
        _maximumRetryDelay.inMicroseconds,
      ),
    );
  }
}

({ProductEntity product, DateTime updatedAt}) _decodeProduct(
  SyncOutboxRow event,
) {
  final json = _decodeObject(event.payloadJson);
  final id = _string(json, 'id');
  final storeId = _string(json, 'storeId');
  if (id != event.aggregateId || storeId != event.storeId) {
    throw const FormatException('Tenant atau product payload tidak cocok');
  }
  return (
    product: ProductEntity(
      id: id,
      storeId: storeId,
      name: _string(json, 'name'),
      category: _string(json, 'category'),
      purchasePrice: _integer(json, 'purchasePrice'),
      sellingPrice: _integer(json, 'sellingPrice'),
      stock: _integer(json, 'stock'),
      minimumStock: _integer(json, 'minimumStock'),
      leadTimeDays: _optionalInteger(json, 'leadTimeDays', fallback: 3),
      barcode: _nullableString(json, 'barcode'),
      photoUri: _nullableString(json, 'photoUri'),
      shelfLocation: _nullableString(json, 'shelfLocation'),
      aiLabel: _nullableString(json, 'aiLabel'),
    ),
    updatedAt: DateTime.parse(_string(json, 'updatedAt')).toUtc(),
  );
}

DateTime _decodeDeletedAt(SyncOutboxRow event) {
  final json = _decodeObject(event.payloadJson);
  if (_string(json, 'id') != event.aggregateId ||
      _string(json, 'storeId') != event.storeId) {
    throw const FormatException('Tenant atau delete payload tidak cocok');
  }
  return DateTime.parse(_string(json, 'deletedAt')).toUtc();
}

Map<String, dynamic> _decodeObject(String source) {
  final decoded = jsonDecode(source);
  if (decoded is! Map<String, dynamic>) {
    throw const FormatException('Payload produk harus berupa object JSON');
  }
  return decoded;
}

String _string(Map<String, dynamic> json, String key) {
  final value = json[key];
  if (value is! String || value.trim().isEmpty) {
    throw FormatException('$key wajib berupa string');
  }
  return value;
}

String? _nullableString(Map<String, dynamic> json, String key) {
  final value = json[key];
  if (value == null) return null;
  if (value is! String) throw FormatException('$key harus berupa string/null');
  return value;
}

int _integer(Map<String, dynamic> json, String key) {
  final value = json[key];
  if (value is! int) throw FormatException('$key wajib berupa integer');
  return value;
}

int _optionalInteger(
  Map<String, dynamic> json,
  String key, {
  required int fallback,
}) {
  final value = json[key];
  if (value == null) return fallback;
  if (value is! int) throw FormatException('$key wajib berupa integer');
  return value;
}
