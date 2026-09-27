import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:ryangunshop/core/ml/tflite_product_classifier.dart';
import 'package:ryangunshop/domain/entities/entities.dart';

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('MobileNetV2 baseline inference tetap di bawah lima detik', (
    tester,
  ) async {
    final classifier = await TfliteProductClassifier.load(
      allowUncalibratedModel: true,
    );
    final frame = RgbFrame(
      bytes: Uint8List.fromList(
        List<int>.generate(224 * 224 * 3, (index) => index % 256),
      ),
      width: 224,
      height: 224,
      rotationDegrees: 0,
      capturedAt: DateTime.now(),
    );

    try {
      await classifier.classify(frame);
      await classifier.classify(frame);
      final samples = <Duration>[];
      for (var index = 0; index < 10; index += 1) {
        samples.add((await classifier.classify(frame)).inferenceTime);
      }
      samples.sort();
      final p95Index = math.min(
        samples.length - 1,
        (samples.length * .95).ceil() - 1,
      );
      final p95 = samples[p95Index];
      final maximum = samples.last;
      binding.reportData = {
        'model': classifier.modelVersion,
        'p50Ms': samples[samples.length ~/ 2].inMilliseconds,
        'p95Ms': p95.inMilliseconds,
        'maxMs': maximum.inMilliseconds,
      };
      debugPrint(
        'MODEL_BENCHMARK model=${classifier.modelVersion} '
        'p50=${samples[samples.length ~/ 2].inMilliseconds}ms '
        'p95=${p95.inMilliseconds}ms max=${maximum.inMilliseconds}ms',
      );
      expect(maximum, lessThan(const Duration(seconds: 5)));
    } finally {
      await classifier.close();
    }
  });
}
