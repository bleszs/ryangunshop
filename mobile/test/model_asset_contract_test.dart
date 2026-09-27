import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ryangunshop/core/ml/product_model_manifest.dart';

void main() {
  test('asset model cocok dengan manifest dan labels', () async {
    final manifestJson =
        jsonDecode(
              await File(
                'assets/models/product_classifier.manifest.json',
              ).readAsString(),
            )
            as Map<String, dynamic>;
    final manifest = ProductModelManifest.fromJson(manifestJson);
    final modelBytes = await File(manifest.modelAsset).readAsBytes();
    final labelsBytes = await File(manifest.labelsAsset).readAsBytes();
    final labels = utf8
        .decode(labelsBytes)
        .split(RegExp(r'\r?\n'))
        .map((line) => line.trim())
        .where((line) => line.isNotEmpty && !line.startsWith('#'))
        .toList(growable: false);

    expect(modelBytes.length, greaterThan(8));
    expect(ascii.decode(modelBytes.sublist(4, 8)), 'TFL3');
    expect(sha256.convert(modelBytes).toString(), manifest.modelSha256);
    expect(sha256.convert(labelsBytes).toString(), manifest.labelsSha256);
    expect(labels, hasLength(manifest.labelCount));
    expect(manifest.productionReady, isFalse);
    expect(manifest.purpose, contains('bukan klasifikasi SKU'));
  });

  test('manifest menolak threshold dan checksum yang tidak valid', () {
    final valid = <String, dynamic>{
      'schemaVersion': 1,
      'modelVersion': 'test-v1',
      'architecture': 'MobileNetV2',
      'modelAsset': 'model.tflite',
      'labelsAsset': 'labels.txt',
      'modelSha256': 'a' * 64,
      'labelsSha256': 'b' * 64,
      'inputWidth': 224,
      'inputHeight': 224,
      'inputMean': 0,
      'inputStd': 1,
      'labelCount': 3,
      'recommendedThreshold': 0.8,
      'productionReady': true,
      'purpose': 'test',
      'source': 'test',
    };

    expect(
      () =>
          ProductModelManifest.fromJson({...valid, 'recommendedThreshold': 1}),
      throwsFormatException,
    );
    expect(
      () => ProductModelManifest.fromJson({...valid, 'modelSha256': 'bad'}),
      throwsFormatException,
    );
  });
}
