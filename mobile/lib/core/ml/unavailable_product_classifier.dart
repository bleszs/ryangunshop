import '../../domain/entities/entities.dart';
import '../../domain/repositories/repositories.dart';

class UnavailableProductClassifier implements ProductClassifier {
  const UnavailableProductClassifier();

  @override
  Future<ClassificationResult> classify(RgbFrame frame) {
    throw StateError('Model klasifikasi belum dipasang');
  }

  @override
  Future<void> close() async {}
}
