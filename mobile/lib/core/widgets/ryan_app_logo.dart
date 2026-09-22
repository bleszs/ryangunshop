import 'package:flutter/material.dart';

class RyanAppLogo extends StatelessWidget {
  const RyanAppLogo({
    required this.size,
    this.semanticLabel = 'Logo RyanGunshop',
    this.cacheSize = 768,
    super.key,
  });

  static const assetPath = 'assets/branding/ryangunshop_logo.png';

  final double size;
  final String semanticLabel;
  final int cacheSize;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      image: true,
      label: semanticLabel,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(size * .16),
        child: Image.asset(
          assetPath,
          width: size,
          height: size,
          fit: BoxFit.cover,
          cacheWidth: cacheSize,
          filterQuality: FilterQuality.high,
          excludeFromSemantics: true,
        ),
      ),
    );
  }
}
