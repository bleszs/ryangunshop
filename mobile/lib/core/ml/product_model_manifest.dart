import 'dart:convert';

import 'package:flutter/services.dart';

class ProductModelManifest {
  const ProductModelManifest({
    required this.schemaVersion,
    required this.modelVersion,
    required this.architecture,
    required this.modelAsset,
    required this.labelsAsset,
    required this.modelSha256,
    required this.labelsSha256,
    required this.inputWidth,
    required this.inputHeight,
    required this.inputMean,
    required this.inputStd,
    required this.labelCount,
    required this.recommendedThreshold,
    required this.productionReady,
    required this.purpose,
    required this.source,
  });

  final int schemaVersion;
  final String modelVersion;
  final String architecture;
  final String modelAsset;
  final String labelsAsset;
  final String modelSha256;
  final String labelsSha256;
  final int inputWidth;
  final int inputHeight;
  final double inputMean;
  final double inputStd;
  final int labelCount;
  final double recommendedThreshold;
  final bool productionReady;
  final String purpose;
  final String source;

  static Future<ProductModelManifest> load({
    String asset = 'assets/models/product_classifier.manifest.json',
  }) async {
    final raw = await rootBundle.loadString(asset);
    final decoded = jsonDecode(raw);
    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('Manifest model harus berupa object JSON.');
    }
    return ProductModelManifest.fromJson(decoded);
  }

  factory ProductModelManifest.fromJson(Map<String, dynamic> json) {
    final manifest = ProductModelManifest(
      schemaVersion: _integer(json, 'schemaVersion'),
      modelVersion: _string(json, 'modelVersion'),
      architecture: _string(json, 'architecture'),
      modelAsset: _string(json, 'modelAsset'),
      labelsAsset: _string(json, 'labelsAsset'),
      modelSha256: _sha256(json, 'modelSha256'),
      labelsSha256: _sha256(json, 'labelsSha256'),
      inputWidth: _integer(json, 'inputWidth'),
      inputHeight: _integer(json, 'inputHeight'),
      inputMean: _number(json, 'inputMean'),
      inputStd: _number(json, 'inputStd'),
      labelCount: _integer(json, 'labelCount'),
      recommendedThreshold: _number(json, 'recommendedThreshold'),
      productionReady: _boolean(json, 'productionReady'),
      purpose: _string(json, 'purpose'),
      source: _string(json, 'source'),
    );
    if (manifest.schemaVersion != 1) {
      throw const FormatException('Versi manifest model belum didukung.');
    }
    if (manifest.inputWidth <= 0 ||
        manifest.inputHeight <= 0 ||
        manifest.labelCount <= 1) {
      throw const FormatException(
        'Dimensi atau jumlah label model tidak valid.',
      );
    }
    if (manifest.inputStd <= 0) {
      throw const FormatException('inputStd model harus lebih besar dari nol.');
    }
    if (manifest.recommendedThreshold <= 0 ||
        manifest.recommendedThreshold >= 1) {
      throw const FormatException(
        'Threshold model harus berada antara 0 dan 1.',
      );
    }
    return manifest;
  }
}

String _string(Map<String, dynamic> json, String key) {
  final value = json[key];
  if (value is! String || value.trim().isEmpty) {
    throw FormatException('$key harus berupa string yang tidak kosong.');
  }
  return value.trim();
}

String _sha256(Map<String, dynamic> json, String key) {
  final value = _string(json, key).toLowerCase();
  if (!RegExp(r'^[a-f0-9]{64}$').hasMatch(value)) {
    throw FormatException('$key bukan SHA-256 yang valid.');
  }
  return value;
}

int _integer(Map<String, dynamic> json, String key) {
  final value = json[key];
  if (value is! num || !value.isFinite || value != value.roundToDouble()) {
    throw FormatException('$key harus berupa bilangan bulat.');
  }
  return value.toInt();
}

double _number(Map<String, dynamic> json, String key) {
  final value = json[key];
  if (value is! num || !value.isFinite) {
    throw FormatException('$key harus berupa angka.');
  }
  return value.toDouble();
}

bool _boolean(Map<String, dynamic> json, String key) {
  final value = json[key];
  if (value is! bool) throw FormatException('$key harus berupa boolean.');
  return value;
}
