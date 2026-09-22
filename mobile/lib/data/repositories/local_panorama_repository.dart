import 'dart:convert';
import 'dart:io';

import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image/image.dart' as image_lib;
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import '../../domain/entities/panorama_entities.dart';
import '../../domain/repositories/repositories.dart';

class PanoramaImportFailure implements Exception {
  const PanoramaImportFailure(this.message);
  final String message;

  @override
  String toString() => message;
}

class LocalPanoramaRepository implements PanoramaRepository {
  LocalPanoramaRepository({
    Uuid uuid = const Uuid(),
    Future<Directory> Function()? documentsDirectory,
  }) : _uuid = uuid,
       _documentsDirectory =
           documentsDirectory ?? getApplicationDocumentsDirectory;

  final Uuid _uuid;
  final Future<Directory> Function() _documentsDirectory;

  @override
  Future<List<PanoramaZoneEntity>> loadZones(String storeId) async {
    final preferences = await SharedPreferences.getInstance();
    final encoded = preferences.getString(_preferenceKey(storeId));
    if (encoded == null || encoded.isEmpty) return const [];
    try {
      final values = jsonDecode(encoded) as List<Object?>;
      final zones =
          values
              .map(
                (value) => PanoramaZoneEntity.fromJson(
                  Map<String, Object?>.from(value! as Map),
                ),
              )
              .where((zone) => File(zone.imagePath).existsSync())
              .toList(growable: false)
            ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
      return zones;
    } on FormatException {
      return const [];
    }
  }

  @override
  Future<PanoramaZoneEntity> importZone({
    required String storeId,
    required String name,
    required String sourceImagePath,
  }) async {
    final normalizedName = name.trim();
    if (normalizedName.isEmpty) {
      throw const PanoramaImportFailure('Nama zona tidak boleh kosong.');
    }
    final source = File(sourceImagePath);
    if (!await source.exists()) {
      throw const PanoramaImportFailure('Foto panorama tidak ditemukan.');
    }

    final decoded = await image_lib.decodeImageFile(source.path);
    if (decoded == null) {
      throw const PanoramaImportFailure('Format foto tidak dapat dibaca.');
    }
    final ratio = decoded.width / decoded.height;
    if (ratio < 1.75 || ratio > 2.25) {
      throw const PanoramaImportFailure(
        'Gunakan foto equirectangular dengan rasio mendekati 2:1.',
      );
    }

    final root = await _storeDirectory(storeId);
    final id = _uuid.v4();
    final imageFile = File(path.join(root.path, '$id.jpg'));
    final thumbnailFile = File(path.join(root.path, '${id}_preview.jpg'));
    final imageTemp = '${imageFile.path}.tmp.jpg';
    final thumbnailTemp = '${thumbnailFile.path}.tmp.jpg';

    final compressed = await FlutterImageCompress.compressAndGetFile(
      source.path,
      imageTemp,
      minWidth: 4096,
      minHeight: 2048,
      quality: 84,
      keepExif: false,
    );
    if (compressed == null) {
      throw const PanoramaImportFailure('Foto gagal dikompresi.');
    }
    final preview = await FlutterImageCompress.compressAndGetFile(
      source.path,
      thumbnailTemp,
      minWidth: 1024,
      minHeight: 512,
      quality: 70,
      keepExif: false,
    );
    if (preview == null) {
      final temporaryImage = File(imageTemp);
      if (await temporaryImage.exists()) await temporaryImage.delete();
      throw const PanoramaImportFailure('Preview foto gagal dibuat.');
    }

    await File(imageTemp).rename(imageFile.path);
    await File(thumbnailTemp).rename(thumbnailFile.path);
    final zone = PanoramaZoneEntity(
      id: id,
      storeId: storeId,
      name: normalizedName,
      imagePath: imageFile.path,
      thumbnailPath: thumbnailFile.path,
      updatedAt: DateTime.now(),
    );
    await saveZone(zone);
    return zone;
  }

  @override
  Future<void> saveZone(PanoramaZoneEntity zone) async {
    final zones = (await loadZones(zone.storeId)).toList();
    final index = zones.indexWhere((item) => item.id == zone.id);
    if (index < 0) {
      zones.add(zone);
    } else {
      zones[index] = zone;
    }
    zones.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(
      _preferenceKey(zone.storeId),
      jsonEncode(zones.map((item) => item.toJson()).toList()),
    );
  }

  @override
  Future<void> deleteZone(PanoramaZoneEntity zone) async {
    final zones = (await loadZones(
      zone.storeId,
    )).where((item) => item.id != zone.id).toList(growable: false);
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(
      _preferenceKey(zone.storeId),
      jsonEncode(zones.map((item) => item.toJson()).toList()),
    );

    final root = await _storeDirectory(zone.storeId);
    for (final candidate in [zone.imagePath, zone.thumbnailPath]) {
      final resolved = path.canonicalize(candidate);
      if (!path.isWithin(root.path, resolved)) continue;
      final file = File(resolved);
      if (await file.exists()) await file.delete();
    }
  }

  Future<Directory> _storeDirectory(String storeId) async {
    final documents = await _documentsDirectory();
    final safeStoreId = storeId.replaceAll(RegExp(r'[^a-zA-Z0-9_-]'), '_');
    final directory = Directory(
      path.join(documents.path, 'panoramas', safeStoreId),
    );
    await directory.create(recursive: true);
    return directory;
  }
}

String _preferenceKey(String storeId) => 'panorama-zones-v1-$storeId';
