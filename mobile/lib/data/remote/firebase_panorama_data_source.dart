import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

import '../../domain/entities/panorama_entities.dart';
import '../../domain/repositories/repositories.dart';

class FirebasePanoramaDataSource implements PanoramaRemoteRepository {
  const FirebasePanoramaDataSource({
    required FirebaseFirestore firestore,
    required FirebaseStorage storage,
  }) : _firestore = firestore,
       _storage = storage;

  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;

  @override
  Future<void> upsertPanoramaZone(
    PanoramaZoneEntity zone, {
    required String mutationId,
    required bool uploadRequired,
  }) async {
    final image = _imageReference(zone.storeId, zone.id);
    final preview = _previewReference(zone.storeId, zone.id);
    if (uploadRequired) {
      await _upload(
        reference: image,
        localPath: zone.imagePath,
        storeId: zone.storeId,
        zoneId: zone.id,
        kind: 'panorama',
      );
      await _upload(
        reference: preview,
        localPath: zone.thumbnailPath,
        storeId: zone.storeId,
        zoneId: zone.id,
        kind: 'preview',
      );
    }
    await _zoneReference(zone.storeId, zone.id).set({
      'name': zone.name,
      'imageUri': _gsUri(image),
      'thumbnailUri': _gsUri(preview),
      'hotspots': zone.hotspots
          .map(
            (hotspot) => {
              'fixtureId': hotspot.fixtureId,
              'longitude': hotspot.longitude,
              'latitude': hotspot.latitude,
            },
          )
          .toList(growable: false),
      'clientMutationId': mutationId,
      'clientUpdatedAt': Timestamp.fromDate(zone.updatedAt.toUtc()),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  @override
  Future<void> deletePanoramaZone({
    required String storeId,
    required String zoneId,
    required String mutationId,
  }) async {
    await _deleteObjectBestEffort(_imageReference(storeId, zoneId));
    await _deleteObjectBestEffort(_previewReference(storeId, zoneId));
    await _zoneReference(storeId, zoneId).delete();
  }

  Future<void> _upload({
    required Reference reference,
    required String localPath,
    required String storeId,
    required String zoneId,
    required String kind,
  }) async {
    final file = File(localPath);
    if (!await file.exists()) {
      throw StateError('Berkas panorama lokal tidak ditemukan.');
    }
    await reference.putFile(
      file,
      SettableMetadata(
        contentType: 'image/jpeg',
        cacheControl: 'private, max-age=3600',
        customMetadata: {'storeId': storeId, 'zoneId': zoneId, 'kind': kind},
      ),
    );
  }

  Future<void> _deleteObjectBestEffort(Reference reference) async {
    try {
      await reference.delete();
    } on FirebaseException catch (error) {
      if (error.code != 'object-not-found') rethrow;
    }
  }

  DocumentReference<Map<String, dynamic>> _zoneReference(
    String storeId,
    String zoneId,
  ) => _firestore
      .collection('stores')
      .doc(storeId)
      .collection('panoramaZones')
      .doc(zoneId);

  Reference _imageReference(String storeId, String zoneId) =>
      _storage.ref('storePanoramas/$storeId/$zoneId/panorama.jpg');

  Reference _previewReference(String storeId, String zoneId) =>
      _storage.ref('storePanoramas/$storeId/$zoneId/preview.jpg');

  String _gsUri(Reference reference) =>
      'gs://${reference.bucket}/${reference.fullPath}';
}
