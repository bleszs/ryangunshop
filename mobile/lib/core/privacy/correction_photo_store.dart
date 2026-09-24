import 'dart:io';

import 'package:image/image.dart' as image_lib;
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

class StoredCorrectionPhoto {
  const StoredCorrectionPhoto({required this.path, required this.expiresAt});

  final String path;
  final DateTime expiresAt;
}

class CorrectionPhotoFailure implements Exception {
  const CorrectionPhotoFailure(this.message);

  final String message;

  @override
  String toString() => message;
}

/// Menyalin foto koreksi ke penyimpanan privat setelah decode dan encode ulang.
/// Proses ini membuang EXIF/GPS, membatasi resolusi, dan memberi masa simpan.
class LocalCorrectionPhotoStore {
  LocalCorrectionPhotoStore({
    Uuid uuid = const Uuid(),
    DateTime Function()? clock,
    Future<Directory> Function()? supportDirectory,
    this.retention = const Duration(days: 30),
    this.maximumDimension = 1280,
    this.jpegQuality = 84,
  }) : _uuid = uuid,
       _clock = clock ?? DateTime.now,
       _supportDirectory = supportDirectory ?? getApplicationSupportDirectory {
    if (retention <= Duration.zero) {
      throw ArgumentError.value(retention, 'retention');
    }
    if (maximumDimension < 320) {
      throw ArgumentError.value(maximumDimension, 'maximumDimension');
    }
    if (jpegQuality < 40 || jpegQuality > 95) {
      throw ArgumentError.value(jpegQuality, 'jpegQuality');
    }
  }

  final Uuid _uuid;
  final DateTime Function() _clock;
  final Future<Directory> Function() _supportDirectory;
  final Duration retention;
  final int maximumDimension;
  final int jpegQuality;

  Future<StoredCorrectionPhoto> sanitizeAndStore({
    required String storeId,
    required String sourceImagePath,
  }) async {
    final source = File(sourceImagePath);
    if (!await source.exists()) {
      throw const CorrectionPhotoFailure('Foto koreksi tidak ditemukan.');
    }
    final decoded = image_lib.decodeImage(await source.readAsBytes());
    if (decoded == null) {
      throw const CorrectionPhotoFailure('Format foto koreksi tidak didukung.');
    }

    var sanitized = image_lib.bakeOrientation(decoded);
    sanitized.exif.clear();
    final longestSide = sanitized.width > sanitized.height
        ? sanitized.width
        : sanitized.height;
    if (longestSide > maximumDimension) {
      sanitized = sanitized.width >= sanitized.height
          ? image_lib.copyResize(
              sanitized,
              width: maximumDimension,
              interpolation: image_lib.Interpolation.average,
            )
          : image_lib.copyResize(
              sanitized,
              height: maximumDimension,
              interpolation: image_lib.Interpolation.average,
            );
      sanitized.exif.clear();
    }

    final directory = await _directoryFor(storeId);
    final output = File(path.join(directory.path, '${_uuid.v4()}.jpg'));
    final temporary = File('${output.path}.tmp');
    try {
      await temporary.writeAsBytes(
        image_lib.encodeJpg(sanitized, quality: jpegQuality),
        flush: true,
      );
      await temporary.rename(output.path);
    } on Object {
      if (await temporary.exists()) await temporary.delete();
      rethrow;
    }
    return StoredCorrectionPhoto(
      path: output.path,
      expiresAt: _clock().toUtc().add(retention),
    );
  }

  Future<int> purgeExpired() async {
    final root = Directory(
      path.join((await _supportDirectory()).path, 'prediction_corrections'),
    );
    if (!await root.exists()) return 0;
    final cutoff = _clock().toUtc().subtract(retention);
    var removed = 0;
    await for (final entity in root.list(recursive: true)) {
      if (entity is! File || path.extension(entity.path) != '.jpg') continue;
      final modified = (await entity.stat()).modified.toUtc();
      if (modified.isAfter(cutoff)) continue;
      await entity.delete();
      removed++;
    }
    return removed;
  }

  Future<Directory> _directoryFor(String storeId) async {
    final safeStoreId = storeId.replaceAll(RegExp(r'[^a-zA-Z0-9_-]'), '_');
    final directory = Directory(
      path.join(
        (await _supportDirectory()).path,
        'prediction_corrections',
        safeStoreId,
      ),
    );
    await directory.create(recursive: true);
    return directory;
  }
}
