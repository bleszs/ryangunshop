import 'package:flutter/services.dart';
import 'package:image/image.dart' as image_lib;
import 'package:tflite_flutter/tflite_flutter.dart';

import '../../domain/entities/entities.dart';
import '../../domain/repositories/repositories.dart';

class TfliteProductClassifier implements ProductClassifier {
  TfliteProductClassifier._({
    required Interpreter interpreter,
    required List<String> labels,
    required this.modelVersion,
    required this.inputMean,
    required this.inputStd,
  }) : _interpreter = interpreter,
       _labels = labels;

  final Interpreter _interpreter;
  final List<String> _labels;
  final String modelVersion;
  final double inputMean;
  final double inputStd;

  static Future<TfliteProductClassifier> load({
    String modelAsset = 'assets/models/product_classifier.tflite',
    String labelsAsset = 'assets/models/labels.txt',
    String modelVersion = 'product-classifier-v1',
    double inputMean = 0,
    double inputStd = 255,
  }) async {
    final interpreter = await Interpreter.fromAsset(modelAsset);
    final labelsText = await rootBundle.loadString(labelsAsset);
    final labels = labelsText
        .split(RegExp(r'\r?\n'))
        .map((line) => line.trim())
        .where((line) => line.isNotEmpty && !line.startsWith('#'))
        .toList(growable: false);
    if (labels.isEmpty) throw StateError('Label model belum tersedia');
    return TfliteProductClassifier._(
      interpreter: interpreter,
      labels: labels,
      modelVersion: modelVersion,
      inputMean: inputMean,
      inputStd: inputStd,
    );
  }

  @override
  Future<ClassificationResult> classify(RgbFrame frame) async {
    final stopwatch = Stopwatch()..start();
    final inputTensor = _interpreter.getInputTensor(0);
    final outputTensor = _interpreter.getOutputTensor(0);
    final inputShape = inputTensor.shape;
    final outputShape = outputTensor.shape;
    if (inputTensor.type != TensorType.float32 ||
        inputShape.length != 4 ||
        inputShape[0] != 1 ||
        inputShape[3] != 3) {
      throw StateError(
        'Fondasi classifier mengharuskan model float32 [1,H,W,3]',
      );
    }
    if (outputShape.length != 2 || outputShape[0] != 1) {
      throw StateError('Output model harus berbentuk [1,jumlahLabel]');
    }

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
