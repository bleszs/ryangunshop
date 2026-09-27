import 'package:flutter/services.dart';
import 'package:image/image.dart' as image_lib;
import 'package:tflite_flutter/tflite_flutter.dart';

import '../../domain/entities/entities.dart';
import '../../domain/repositories/repositories.dart';
import 'product_model_manifest.dart';

class TfliteProductClassifier implements ProductClassifier {
  TfliteProductClassifier._({
    required Interpreter interpreter,
    required List<String> labels,
    required this.modelVersion,
    required this.inputMean,
    required this.inputStd,
    required this.recommendedThreshold,
  }) : _interpreter = interpreter,
       _labels = labels;

  final Interpreter _interpreter;
  final List<String> _labels;
  final String modelVersion;
  final double inputMean;
  final double inputStd;
  final double recommendedThreshold;

  static Future<TfliteProductClassifier> load({
    String manifestAsset = 'assets/models/product_classifier.manifest.json',
    bool allowUncalibratedModel = false,
  }) async {
    final manifest = await ProductModelManifest.load(asset: manifestAsset);
    if (!manifest.productionReady && !allowUncalibratedModel) {
      throw StateError(
        'Model hanya untuk benchmark dan belum lolos kalibrasi SKU produksi.',
      );
    }
    final options = InterpreterOptions()..threads = 2;
    final interpreter = await Interpreter.fromAsset(
      manifest.modelAsset,
      options: options,
    );
    final labelsText = await rootBundle.loadString(manifest.labelsAsset);
    final labels = labelsText
        .split(RegExp(r'\r?\n'))
        .map((line) => line.trim())
        .where((line) => line.isNotEmpty && !line.startsWith('#'))
        .toList(growable: false);
    if (labels.isEmpty) throw StateError('Label model belum tersedia');
    final input = interpreter.getInputTensor(0);
    final output = interpreter.getOutputTensor(0);
    if (input.type != TensorType.float32 ||
        input.shape.length != 4 ||
        input.shape[0] != 1 ||
        input.shape[1] != manifest.inputHeight ||
        input.shape[2] != manifest.inputWidth ||
        input.shape[3] != 3) {
      interpreter.close();
      throw StateError('Tensor input tidak sesuai manifest model.');
    }
    if (output.shape.length != 2 ||
        output.shape[0] != 1 ||
        output.shape[1] != labels.length ||
        labels.length != manifest.labelCount) {
      interpreter.close();
      throw StateError('Tensor output dan labels tidak konsisten.');
    }
    return TfliteProductClassifier._(
      interpreter: interpreter,
      labels: labels,
      modelVersion: manifest.modelVersion,
      inputMean: manifest.inputMean,
      inputStd: manifest.inputStd,
      recommendedThreshold: manifest.recommendedThreshold,
    );
  }

  @override
  Future<ClassificationResult> classify(RgbFrame frame) async {
    final stopwatch = Stopwatch()..start();
    final inputShape = _interpreter.getInputTensor(0).shape;
    final outputShape = _interpreter.getOutputTensor(0).shape;

    var source = image_lib.Image.fromBytes(
      width: frame.width,
      height: frame.height,
      bytes: frame.bytes.buffer,
      numChannels: 3,
      order: image_lib.ChannelOrder.rgb,
    );
    if (frame.rotationDegrees != 0) {
      source = image_lib.copyRotate(source, angle: frame.rotationDegrees);
    }
    final resized = image_lib.copyResize(
      source,
      width: inputShape[2],
      height: inputShape[1],
      interpolation: image_lib.Interpolation.linear,
    );
    final input = [
      List.generate(inputShape[1], (y) {
        return List.generate(inputShape[2], (x) {
          final pixel = resized.getPixel(x, y);
          return [
            (pixel.r.toDouble() - inputMean) / inputStd,
            (pixel.g.toDouble() - inputMean) / inputStd,
            (pixel.b.toDouble() - inputMean) / inputStd,
          ];
        });
      }),
    ];
    final output = [List<double>.filled(outputShape[1], 0)];
    _interpreter.run(input, output);

    final candidates = <AiCandidate>[];
    for (var index = 0; index < output.first.length; index += 1) {
      if (index >= _labels.length) break;
      candidates.add(
        AiCandidate(label: _labels[index], confidence: output.first[index]),
      );
    }
    candidates.sort((a, b) => b.confidence.compareTo(a.confidence));
    stopwatch.stop();
    return ClassificationResult(
      candidates: candidates.take(3).toList(growable: false),
      inferenceTime: stopwatch.elapsed,
      modelVersion: modelVersion,
    );
  }

  @override
  Future<void> close() async => _interpreter.close();
}
