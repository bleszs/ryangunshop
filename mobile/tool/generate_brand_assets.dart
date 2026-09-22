import 'dart:io';

import 'package:image/image.dart' as img;

void main(List<String> arguments) {
  if (arguments.isEmpty) {
    stderr.writeln(
      'Usage: dart run tool/generate_brand_assets.dart <logo.png>',
    );
    exitCode = 64;
    return;
  }

  final sourcePath = arguments.join(' ');
  final source = img.decodePng(File(sourcePath).readAsBytesSync());
  if (source == null) {
    stderr.writeln('Logo harus berupa PNG yang valid.');
    exitCode = 65;
    return;
  }

  final flutterLogo = img.copyResize(
    source,
    width: 1024,
    height: 1024,
    interpolation: img.Interpolation.cubic,
  );
  _writePng('assets/branding/ryangunshop_logo.png', flutterLogo);

  final splashLogo = img.copyResize(
    source,
    width: 512,
    height: 512,
    interpolation: img.Interpolation.cubic,
  );
  _writePng(
    'android/app/src/main/res/drawable-nodpi/ryangunshop_splash_logo.png',
    splashLogo,
  );

  const legacySizes = <String, int>{
    'mdpi': 48,
    'hdpi': 72,
    'xhdpi': 96,
    'xxhdpi': 144,
    'xxxhdpi': 192,
  };
  const foregroundSizes = <String, int>{
    'mdpi': 108,
    'hdpi': 162,
    'xhdpi': 216,
    'xxhdpi': 324,
    'xxxhdpi': 432,
  };

  for (final entry in legacySizes.entries) {
    _writePng(
      'android/app/src/main/res/mipmap-${entry.key}/ic_launcher.png',
      img.copyResize(
        source,
        width: entry.value,
        height: entry.value,
        interpolation: img.Interpolation.cubic,
      ),
    );
  }

  for (final entry in foregroundSizes.entries) {
    final canvas = img.Image(
      width: entry.value,
      height: entry.value,
      numChannels: 4,
    );
    canvas.clear(img.ColorRgba8(0, 0, 0, 0));
    final contentSize = (entry.value * .66).round();
    final logo = img.copyResize(
      source,
      width: contentSize,
      height: contentSize,
      interpolation: img.Interpolation.cubic,
    );
    img.compositeImage(
      canvas,
      logo,
      dstX: (entry.value - contentSize) ~/ 2,
      dstY: (entry.value - contentSize) ~/ 2,
    );
    _writePng(
      'android/app/src/main/res/mipmap-${entry.key}/ic_launcher_foreground.png',
      canvas,
    );
  }
}

void _writePng(String path, img.Image image) {
  final file = File(path)..createSync(recursive: true);
  file.writeAsBytesSync(img.encodePng(image, level: 6));
  stdout.writeln('Generated $path');
}
