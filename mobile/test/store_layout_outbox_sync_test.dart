import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ryangunshop/data/local/app_database.dart';
import 'package:ryangunshop/data/repositories/drift_repositories.dart';
import 'package:ryangunshop/data/sync/store_layout_outbox_sync.dart';
import 'package:ryangunshop/domain/entities/store_layout_entities.dart';
import 'package:ryangunshop/domain/repositories/repositories.dart';

void main() {
  late AppDatabase database;
  late DriftStoreLayoutRepository layouts;
  late _FakeStoreLayoutRemote remote;
  late StoreLayoutOutboxSyncProcessor processor;
  var now = DateTime.utc(2026, 9, 19, 12);

  setUp(() {
    database = AppDatabase.forTesting(NativeDatabase.memory());
    layouts = DriftStoreLayoutRepository(database, clock: () => now);
    remote = _FakeStoreLayoutRemote();
    processor = StoreLayoutOutboxSyncProcessor(
      database: database,
      remote: remote,
      clock: () => now,
    );
  });

  tearDown(() => database.close());

  test(
    'mengirim layout lalu menandai layout dan fixture sebagai synced',
    () async {
      await layouts.saveLayout(_layout(label: 'Rak awal'));
      final event = await database.select(database.syncOutbox).getSingle();

      final result = await processor.processPending(storeId: 'store-1');

      expect(result.attempted, 1);
      expect(result.synced, 1);
      expect(result.failed, 0);
      expect(remote.calls, 1);
      expect(remote.layouts.single.fixtures.single.label, 'Rak awal');
      expect(remote.mutationIds.single, event.id);
      expect(await database.select(database.syncOutbox).get(), isEmpty);
      expect(
        (await database.select(database.storeLayouts).getSingle()).syncState,
        'synced',
      );
      expect(
        (await database.select(database.storeFixtures).getSingle()).syncState,
        'synced',
      );
    },
  );

  test('kegagalan dijadwalkan ulang dengan exponential backoff', () async {
    await layouts.saveLayout(_layout(label: 'Rak offline'));
    remote.failure = StateError('jaringan offline');

    final first = await processor.processPending();
    var event = await database.select(database.syncOutbox).getSingle();
    expect(first.failed, 1);
    expect(event.attemptCount, 1);
    expect(event.nextAttemptAt?.toUtc(), now.add(const Duration(seconds: 30)));
    expect(event.lastError, contains('jaringan offline'));

    expect((await processor.processPending()).attempted, 0);
    now = now.add(const Duration(seconds: 30));
    final second = await processor.processPending();
    event = await database.select(database.syncOutbox).getSingle();
    expect(second.failed, 1);
    expect(event.attemptCount, 2);
    expect(event.nextAttemptAt?.toUtc(), now.add(const Duration(minutes: 1)));

    now = now.add(const Duration(seconds: 59));
    expect((await processor.processPending()).attempted, 0);
    now = now.add(const Duration(seconds: 1));
    remote.failure = null;
    expect((await processor.processPending()).synced, 1);
    expect(await database.select(database.syncOutbox).get(), isEmpty);
  });

  test('error outbox meredaksi credential sebelum disimpan', () async {
    await layouts.saveLayout(_layout(label: 'Rak aman'));
    remote.failure = StateError(
      'Authorization: Bearer super-secret token=abc123 owner@example.com',
    );

    await processor.processPending();
    final event = await database.select(database.syncOutbox).getSingle();

    expect(event.lastError, isNot(contains('super-secret')));
    expect(event.lastError, isNot(contains('abc123')));
    expect(event.lastError, isNot(contains('owner@example.com')));
    expect(event.lastError, contains('[REDACTED]'));
  });

  test(
    'event lama tidak menandai perubahan layout yang lebih baru synced',
    () async {
      await layouts.saveLayout(_layout(label: 'Rak versi 1'));
      now = now.add(const Duration(seconds: 1));
      await layouts.saveLayout(_layout(label: 'Rak versi 2'));
      processor = StoreLayoutOutboxSyncProcessor(
        database: database,
        remote: remote,
        clock: () => now,
        batchSize: 1,
      );

      expect((await processor.processPending()).synced, 1);
      expect(
        (await database.select(database.storeLayouts).getSingle()).syncState,
        'pending',
      );
      expect(await database.select(database.syncOutbox).get(), hasLength(1));

      expect((await processor.processPending()).synced, 1);
      expect(
        (await database.select(database.storeLayouts).getSingle()).syncState,
        'synced',
      );
      expect(remote.layouts.last.fixtures.single.label, 'Rak versi 2');
    },
  );
}

StoreLayoutEntity _layout({required String label}) => StoreLayoutEntity(
  id: 'layout-1',
  storeId: 'store-1',
  name: 'Layout utama',
  canvasAspectRatio: .78,
  templateVersion: 1,
  fixtures: [
    StoreFixture(
      id: 'fixture-1',
      type: StoreFixtureType.shelf,
      label: label,
      x: .1,
      y: .2,
      width: .3,
      height: .2,
      productIds: const ['product-1'],
    ),
  ],
  updatedAt: DateTime.utc(2026, 9, 19),
);

class _FakeStoreLayoutRemote implements StoreLayoutRemoteRepository {
  Object? failure;
  int calls = 0;
  final layouts = <StoreLayoutEntity>[];
  final mutationIds = <String>[];

  @override
  Future<void> upsertStoreLayout(
    StoreLayoutEntity layout, {
    required String mutationId,
  }) async {
    calls++;
    final currentFailure = failure;
    if (currentFailure != null) throw currentFailure;
    layouts.add(layout);
    mutationIds.add(mutationId);
  }
}
