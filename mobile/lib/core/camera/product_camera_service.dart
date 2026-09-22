import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';

import '../../domain/entities/entities.dart';

class ProductCameraService {
  CameraController? _controller;
  bool _processingFrame = false;

  CameraController? get controller => _controller;

  Future<void> initialize() async {
    await dispose();
    final cameras = await availableCameras();
    if (cameras.isEmpty) throw StateError('Kamera tidak tersedia');
    final backCamera = cameras
        .where((camera) => camera.lensDirection == CameraLensDirection.back)
        .firstOrNull;
    final selected = backCamera ?? cameras.first;
    final controller = CameraController(
      selected,
      ResolutionPreset.medium,
      enableAudio: false,
      imageFormatGroup: ImageFormatGroup.yuv420,
    );
    await controller.initialize();
    _controller = controller;
  }

  Future<void> startAnalysis({
    required Future<void> Function(RgbFrame frame) onFrame,
    required void Function(Object error, StackTrace stackTrace) onError,
  }) async {
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized) {
      throw StateError('Kamera belum diinisialisasi');
    }
    await controller.startImageStream((cameraImage) async {
      if (_processingFrame) return;
      _processingFrame = true;
      try {
        if (cameraImage.planes.length < 3) {
          throw StateError('Format kamera bukan YUV420 tiga plane');
        }
        final payload = <String, Object>{
          'width': cameraImage.width,
          'height': cameraImage.height,
          'y': Uint8List.fromList(cameraImage.planes[0].bytes),
          'u': Uint8List.fromList(cameraImage.planes[1].bytes),
          'v': Uint8List.fromList(cameraImage.planes[2].bytes),
          'yRowStride': cameraImage.planes[0].bytesPerRow,
          'uvRowStride': cameraImage.planes[1].bytesPerRow,
          'uvPixelStride': cameraImage.planes[1].bytesPerPixel ?? 1,
        };
        final rgb = await compute(_convertYuv420ToRgb, payload);
        await onFrame(
          RgbFrame(
            bytes: rgb,
            width: cameraImage.width,
            height: cameraImage.height,
            rotationDegrees: controller.description.sensorOrientation,
            capturedAt: DateTime.now(),
          ),
        );
      } catch (error, stackTrace) {
        onError(error, stackTrace);
      } finally {
        _processingFrame = false;
      }
    });
  }

  Future<String> captureForBarcode() async {
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized) {
      throw StateError('Kamera belum diinisialisasi');
    }
    if (controller.value.isStreamingImages) await controller.stopImageStream();
    return (await controller.takePicture()).path;
  }

  Future<void> stopAnalysis() async {
    final controller = _controller;
    if (controller != null && controller.value.isStreamingImages) {
      await controller.stopImageStream();
    }
    _processingFrame = false;
  }

  Future<void> dispose() async {
    final controller = _controller;
    _controller = null;
    if (controller?.value.isStreamingImages ?? false) {
      await controller?.stopImageStream();
    }
    _processingFrame = false;
    await controller?.dispose();
  }
}

Uint8List _convertYuv420ToRgb(Map<String, Object> data) {
  final width = data['width']! as int;
  final height = data['height']! as int;
  final yPlane = data['y']! as Uint8List;
  final uPlane = data['u']! as Uint8List;
  final vPlane = data['v']! as Uint8List;
  final yRowStride = data['yRowStride']! as int;
  final uvRowStride = data['uvRowStride']! as int;
  final uvPixelStride = data['uvPixelStride']! as int;
  final rgb = Uint8List(width * height * 3);

  var outputIndex = 0;
  for (var y = 0; y < height; y += 1) {
    for (var x = 0; x < width; x += 1) {
      final yValue = yPlane[y * yRowStride + x];
      final uvIndex = (y ~/ 2) * uvRowStride + (x ~/ 2) * uvPixelStride;
      final uValue = uPlane[uvIndex] - 128;
      final vValue = vPlane[uvIndex] - 128;
      final red = (yValue + 1.402 * vValue).round().clamp(0, 255);
      final green = (yValue - 0.344136 * uValue - 0.714136 * vValue)
          .round()
          .clamp(0, 255);
      final blue = (yValue + 1.772 * uValue).round().clamp(0, 255);
      rgb[outputIndex++] = red;
      rgb[outputIndex++] = green;
      rgb[outputIndex++] = blue;
    }
  }
  return rgb;
}
