import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class RyanBrandMark extends StatelessWidget {
  const RyanBrandMark({
    this.size = 56,
    this.backgroundColor = AppColors.slate600,
    this.foregroundColor = Colors.white,
    super.key,
  });
  final double size;
  final Color backgroundColor;
  final Color foregroundColor;

  @override
  Widget build(BuildContext context) => Semantics(
    image: true,
    label: 'Logo RyanGunshop',
    child: SizedBox.square(
      dimension: size,
      child: CustomPaint(
        painter: _RyanBrandPainter(backgroundColor, foregroundColor),
      ),
    ),
  );
}

class _RyanBrandPainter extends CustomPainter {
  const _RyanBrandPainter(this.backgroundColor, this.foregroundColor);
  final Color backgroundColor;
  final Color foregroundColor;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Offset.zero & size,
        Radius.circular(size.width * .24),
      ),
      Paint()..color = backgroundColor,
    );
    final stroke = Paint()
      ..color = foregroundColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * .065
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    final left = size.width * .29;
    final right = size.width * .71;
    canvas.drawLine(
      Offset(left, size.height * .27),
      Offset(left, size.height * .72),
      stroke,
    );
    canvas.drawLine(
      Offset(right, size.height * .27),
      Offset(right, size.height * .72),
      stroke,
    );
    for (final y in [.32, .50, .68]) {
      canvas.drawLine(
        Offset(left, size.height * y),
        Offset(right, size.height * y),
        stroke,
      );
    }
    canvas.drawCircle(
      Offset(size.width * .76, size.height * .22),
      size.width * .055,
      Paint()..color = AppColors.slate300,
    );
  }

  @override
  bool shouldRepaint(covariant _RyanBrandPainter oldDelegate) =>
      oldDelegate.backgroundColor != backgroundColor ||
      oldDelegate.foregroundColor != foregroundColor;
}
