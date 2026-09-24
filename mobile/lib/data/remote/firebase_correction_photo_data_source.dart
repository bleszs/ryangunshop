import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';

import '../../domain/repositories/repositories.dart';

class FirebaseCorrectionPhotoDataSource
    implements PredictionCorrectionPhotoRemoteRepository {
  FirebaseCorrectionPhotoDataSource(this._storage);

  final FirebaseStorage _storage;

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
    final file = File(localPhotoPath);
    if (!await file.exists()) {
      throw StateError('Foto koreksi lokal tidak ditemukan.');
    }
    final reference = _storage.ref().child(
      'predictionCorrections/$storeId/$predictionId.jpg',
    );
    await reference.putFile(
      file,
      SettableMetadata(
        contentType: 'image/jpeg',
        cacheControl: 'private, max-age=0, no-store',
        customMetadata: {
          'storeId': storeId,
          'predictionId': predictionId,
          'consent': 'true',
          'expiresAt': expiresAt.toUtc().toIso8601String(),
          'selectedProductId': selectedProductId,
          'modelVersion': modelVersion,
          'initialLabel': initialLabel ?? '',
          'initialConfidence': initialConfidence?.toString() ?? '',
        },
      ),
    );
    return 'gs://${reference.bucket}/${reference.fullPath}';
  }
}
