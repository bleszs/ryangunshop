import 'dart:async';

import '../entities/entities.dart';
import '../repositories/repositories.dart';

class ProductRecognitionCoordinator {
  const ProductRecognitionCoordinator({
    required ProductClassifier classifier,
    required ProductRepository products,
    required PredictionRepository predictions,
    this.threshold = 0.65,
    this.timeout = const Duration(seconds: 5),
  }) : _classifier = classifier,
       _products = products,
       _predictions = predictions;

  final ProductClassifier _classifier;
  final ProductRepository _products;
  final PredictionRepository _predictions;
  final double threshold;
  final Duration timeout;

  Future<RecognitionOutcome> recognize(String storeId, RgbFrame frame) async {
    try {
      final result = await _classifier.classify(frame).timeout(timeout);
      if (result.candidates.isEmpty) {
        return const RecognitionFallback(
          RecognitionFailureReason.modelUnavailable,
        );
      }
      final candidates = [...result.candidates]
        ..sort((a, b) => b.confidence.compareTo(a.confidence));
      final top = candidates.first;
      if (top.confidence < threshold) {
        return RecognitionFallback(
          RecognitionFailureReason.lowConfidence,
          candidates,
        );
      }
      final product = await _products.getByAiLabel(storeId, top.label);
      if (product == null) {
        return RecognitionFallback(
          RecognitionFailureReason.unknownLabel,
          candidates,
        );
      }
      return RecognizedProduct(
        product: product,
        candidates: candidates,
        inferenceTime: result.inferenceTime,
        modelVersion: result.modelVersion,
      );
    } on TimeoutException {
      return const RecognitionFallback(RecognitionFailureReason.timeout);
    } on StateError {
      return const RecognitionFallback(
        RecognitionFailureReason.modelUnavailable,
      );
    } catch (_) {
      return const RecognitionFallback(RecognitionFailureReason.inferenceError);
    }
  }

  Future<void> recordDecision(PredictionCorrection correction) =>
      _predictions.saveCorrection(correction);

  Future<void> close() => _classifier.close();
}
