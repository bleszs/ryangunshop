import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as image_lib;
import 'package:ryangunshop/core/privacy/correction_photo_store.dart';

void main() {
  late Directory temporaryDirectory;
  final now = DateTime.utc(2026, 9, 25, 8);

  setUp(() async {
    temporaryDirectory = await Directory.systemTemp.createTemp(
      'ryangunshop-correction-photo-',
    );
  });

  tearDown(() async {
    if (await temporaryDirectory.exists()) {
      await temporaryDirectory.delete(recursive: true);
    }
  });

  test('menghapus EXIF, mengecilkan foto, dan menetapkan retention', () async {
    final sourceImage = image_lib.Image(width: 1600, height: 800);
    sourceImage.exif.imageIfd
      ..make = 'Private Camera'
      ..model = 'GPS-enabled';
    sourceImage.exif.gpsIfd.userComment = 'lokasi sensitif';
    final source = File('${temporaryDirectory.path}/source.jpg');
    await source.writeAsBytes(image_lib.encodeJpg(sourceImage));
    final store = LocalCorrectionPhotoStore(
      clock: () => now,
      supportDirectory: () async => temporaryDirectory,
    );

    final result = await store.sanitizeAndStore(
      storeId: 'store/berbahaya',
      sourceImagePath: source.path,
    );

    final output = image_lib.decodeJpg(await File(result.path).readAsBytes());
    expect(output, isNotNull);
    expect(output!.width, 1280);
    expect(output.height, 640);
    expect(output.exif.isEmpty, isTrue);
    expect(result.expiresAt, DateTime.utc(2026, 10, 25, 8));
    expect(result.path, contains('store_berbahaya'));
  });

  test('membersihkan hanya JPEG privat yang melewati retention', () async {
    final store = LocalCorrectionPhotoStore(
      clock: () => now,
      supportDirectory: () async => temporaryDirectory,
    );
    final root = Directory(
      '${temporaryDirectory.path}/prediction_corrections/store-1',
    );
    await root.create(recursive: true);
    final expired = File('${root.path}/expired.jpg');
    final current = File('${root.path}/current.jpg');
    final unrelated = File('${root.path}/keep.txt');
    await expired.writeAsBytes([1]);
    await current.writeAsBytes([2]);
    await unrelated.writeAsBytes([3]);
    await expired.setLastModified(now.subtract(const Duration(days: 31)));
    await current.setLastModified(now.subtract(const Duration(days: 29)));

    expect(await store.purgeExpired(), 1);
    expect(await expired.exists(), isFalse);
    expect(await current.exists(), isTrue);
    expect(await unrelated.exists(), isTrue);
  });
}
