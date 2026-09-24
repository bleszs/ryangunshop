import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ryangunshop/data/local/app_database.dart';
import 'package:ryangunshop/data/repositories/drift_repositories.dart';
import 'package:ryangunshop/data/sync/prediction_correction_photo_outbox_sync.dart';
import 'package:ryangunshop/domain/entities/entities.dart';
import 'package:ryangunshop/domain/repositories/repositories.dart';

void main() {
  late AppDatabase database;
  late DriftPredictionRepository predictions;
  late _FakeCorrectionPhotoRemote remote;
  late PredictionCorrectionPhotoOutboxSyncProcessor processor;
  late Directory temporaryDirectory;
  var now = DateTime.utc(2026, 9, 25, 8);

  setUp(() async {
    database = AppDatabase.forTesting(NativeDatabase.memory());
    predictions = DriftPredictionRepository(database, clock: () => now);
    remote = _FakeCorrectionPhotoRemote();
    processor = PredictionCorrectionPhotoOutboxSyncProcessor(
      database: database,
      remote: remote,
      clock: () => now,
    );
    temporaryDirectory = await Directory.systemTemp.createTemp(
      'ryangunshop-correction-sync-',
    );
  });

  tearDown(() async {
    await database.close();
    if (await temporaryDirectory.exists()) {
      await temporaryDirectory.delete(recursive: true);
    }
  });

  test('mengantrekan dan mengunggah foto koreksi tenant-scoped', () async {
    final photo = File('${temporaryDirectory.path}/correction.jpg');
    await photo.writeAsBytes([0xff, 0xd8, 0xff, 0xd9]);
    final expiresAt = now.add(const Duration(days: 30));
    await predictions.saveCorrection(
      _correction(photoPath: photo.path, expiresAt: expiresAt, consent: true),
    );

    expect(await database.select(database.syncOutbox).get(), hasLength(1));
    final result = await processor.processPending(storeId: 'store-1');

    expect(result.synced, 1);
    expect(remote.calls, 1);
    expect(remote.storeIds.single, 'store-1');
    expect(remote.localPaths.single, photo.path);
    expect(remote.expiries.single, expiresAt);
    expect(remote.selectedProductIds.single, 'product-1');
    expect(remote.modelVersions.single, 'test-v1');
    expect(remote.initialLabels.single, 'kopi_lama');
    expect(remote.initialConfidences.single, .64);
    expect(await database.select(database.syncOutbox).get(), isEmpty);
    final row = await database.select(database.predictions).getSingle();
    expect(row.correctionPhotoUri, startsWith('gs://test/'));
    expect(row.correctionPhotoExpiresAt?.toUtc(), expiresAt);
    expect(row.syncState, 'synced');
    expect(await photo.exists(), isFalse);
  });

  test(
    'tanpa consent tidak menyimpan path atau membuat event upload',
    () async {
      await predictions.saveCorrection(
        _correction(
          photoPath: 'C:/private/raw.jpg',
          expiresAt: now.add(const Duration(days: 30)),
          consent: false,
        ),
      );

      final row = await database.select(database.predictions).getSingle();
      expect(row.correctionPhotoUri, isNull);
      expect(row.correctionPhotoExpiresAt, isNull);
      expect(row.consentToTraining, isFalse);
      expect(await database.select(database.syncOutbox).get(), isEmpty);
    },
  );

  test('foto kedaluwarsa dihapus dari antrean tanpa diunggah', () async {
    final expiredPhoto = File('${temporaryDirectory.path}/expired.jpg');
    await expiredPhoto.writeAsBytes([0xff, 0xd8, 0xff, 0xd9]);
    await predictions.saveCorrection(
      _correction(
        photoPath: expiredPhoto.path,
        expiresAt: now.add(const Duration(hours: 1)),
        consent: true,
      ),
    );
    now = now.add(const Duration(hours: 2));

    final result = await processor.processPending();

    expect(result.synced, 1);
    expect(remote.calls, 0);
    expect(await database.select(database.syncOutbox).get(), isEmpty);
    final row = await database.select(database.predictions).getSingle();
    expect(row.correctionPhotoUri, isNull);
    expect(row.syncState, 'expired');
    expect(await expiredPhoto.exists(), isFalse);
  });
}

PredictionCorrection _correction({
  required String photoPath,
  required DateTime expiresAt,
  required bool consent,
}) => PredictionCorrection(
  storeId: 'store-1',
  cashierId: 'cashier-1',
  capturedAt: DateTime.utc(2026, 9, 25, 7, 59),
  initialLabel: 'kopi_lama',
  initialConfidence: .64,
  selectedProductId: 'product-1',
  corrected: true,
  correctionPhotoUri: photoPath,
  correctionPhotoExpiresAt: expiresAt,
  modelVersion: 'test-v1',
  consentToTraining: consent,
);

class _FakeCorrectionPhotoRemote
    implements PredictionCorrectionPhotoRemoteRepository {
  int calls = 0;
  final storeIds = <String>[];
  final localPaths = <String>[];
  final expiries = <DateTime>[];
  final selectedProductIds = <String>[];
  final modelVersions = <String>[];
  final initialLabels = <String?>[];
  final initialConfidences = <double?>[];

  @override
  Future<String> uploadCorrectionPhoto({
    required String storeId,
    required String predictionId,
    required String localPhotoPath,
    required DateTime expiresAt,
    required String selectedProductId,
    required String modelVersion,
    required String? initialLabel,
    required double? initialConfidence,
  }) async {
    calls++;
    storeIds.add(storeId);
    localPaths.add(localPhotoPath);
    expiries.add(expiresAt);
    selectedProductIds.add(selectedProductId);
    modelVersions.add(modelVersion);
    initialLabels.add(initialLabel);
    initialConfidences.add(initialConfidence);
    return 'gs://test/predictionCorrections/$storeId/$predictionId.jpg';
  }
}
