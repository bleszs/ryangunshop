import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class AppSpinner extends StatelessWidget {
  const AppSpinner({this.size = 26, this.color, super.key});
  final double size;
  final Color? color;

  @override
  Widget build(BuildContext context) => SizedBox.square(
    dimension: size,
    child: CircularProgressIndicator(
      strokeWidth: 2.6,
      strokeCap: StrokeCap.round,
      color: color ?? AppColors.slate600,
    ),
  );
}

class AppLoadingView extends StatelessWidget {
  const AppLoadingView({
    this.label = 'Menyiapkan warung…',
    this.light = false,
    super.key,
  });
  final String label;
  final bool light;

  @override
  Widget build(BuildContext context) => Center(
    child: Semantics(
      liveRegion: true,
      label: label,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AppSpinner(
            size: 32,
            color: light ? AppColors.slate200 : AppColors.slate600,
          ),
          const SizedBox(height: 14),
          Text(
            label,
            style: TextStyle(
              color: light ? AppColors.slate200 : AppColors.muted,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    ),
  );
}
