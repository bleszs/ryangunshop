import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

abstract final class AppColors {
  static const slate50 = Color(0xFFF5F5FB);
  static const slate100 = Color(0xFFE9EAF6);
  static const slate200 = Color(0xFFD4D6ED);
  static const slate300 = Color(0xFFB1B5DB);
  static const slate400 = Color(0xFF8B91D4);
  static const slate500 = Color(0xFF6D73B8);
  static const slate600 = Color(0xFF565C9D);
  static const slate700 = Color(0xFF44497E);
  static const slate800 = Color(0xFF34385F);
  static const slate900 = Color(0xFF25283F);
  static const canvas = Color(0xFFF7F7FB);
  static const surface = Color(0xFFFFFFFF);
  static const ink = Color(0xFF191A2E);
  static const muted = Color(0xFF62657A);
  static const outline = Color(0xFFD9DAE6);
  static const success = Color(0xFF287A66);
  static const warning = Color(0xFFA86616);
  static const error = Color(0xFFB44252);
}

abstract final class AppRadii {
  static const control = 12.0;
  static const surface = 16.0;
  static const hero = 20.0;
}

abstract final class AppSpacing {
  static const xs = 4.0;
  static const sm = 8.0;
  static const md = 12.0;
  static const lg = 16.0;
  static const xl = 24.0;
  static const xxl = 32.0;
}

abstract final class AppTextStyles {
  static const editorialDisplay = TextStyle(
    fontFamily: 'serif',
    color: AppColors.ink,
    fontSize: 30,
    height: 1.08,
    letterSpacing: -.7,
    fontWeight: FontWeight.w700,
  );

  static const editorialTitle = TextStyle(
    fontFamily: 'serif',
    color: AppColors.ink,
    fontSize: 24,
    height: 1.12,
    letterSpacing: -.35,
    fontWeight: FontWeight.w700,
  );
}

abstract final class AppTheme {
  static const primary = AppColors.slate600;
  static const canvas = AppColors.canvas;
  static const ink = AppColors.ink;
  static const muted = AppColors.muted;
  static const warning = AppColors.warning;

  static ThemeData get light {
    const colors = ColorScheme(
      brightness: Brightness.light,
      primary: AppColors.slate600,
      onPrimary: Colors.white,
      primaryContainer: AppColors.slate100,
      onPrimaryContainer: AppColors.slate900,
      secondary: AppColors.slate500,
      onSecondary: Colors.white,
      secondaryContainer: AppColors.slate50,
      onSecondaryContainer: AppColors.slate900,
      tertiary: AppColors.success,
      onTertiary: Colors.white,
      tertiaryContainer: Color(0xFFDDF1EB),
      onTertiaryContainer: Color(0xFF124C3E),
      error: AppColors.error,
      onError: Colors.white,
      errorContainer: Color(0xFFFFE7EA),
      onErrorContainer: Color(0xFF6D1725),
      surface: AppColors.surface,
      onSurface: AppColors.ink,
      surfaceContainerHighest: AppColors.slate100,
      onSurfaceVariant: AppColors.muted,
      outline: AppColors.outline,
      outlineVariant: Color(0xFFE8E8F0),
      shadow: Color(0x1A25283F),
      scrim: Color(0x6625283F),
      inverseSurface: AppColors.slate900,
      onInverseSurface: Colors.white,
      inversePrimary: AppColors.slate300,
    );
    return ThemeData(
      useMaterial3: true,
      colorScheme: colors,
      scaffoldBackgroundColor: AppColors.canvas,
      fontFamily: 'sans-serif',
      textTheme: const TextTheme(
        headlineMedium: TextStyle(
          fontFamily: 'serif',
          color: AppColors.ink,
          fontSize: 30,
          height: 1.1,
          letterSpacing: -.7,
          fontWeight: FontWeight.w700,
        ),
        headlineSmall: TextStyle(
          fontFamily: 'serif',
          color: AppColors.ink,
          fontSize: 24,
          height: 1.12,
          letterSpacing: -.35,
          fontWeight: FontWeight.w700,
        ),
        titleLarge: TextStyle(
          color: AppColors.ink,
          fontSize: 20,
          height: 1.25,
          fontWeight: FontWeight.w700,
        ),
        titleMedium: TextStyle(
          color: AppColors.ink,
          fontSize: 16,
          height: 1.3,
          fontWeight: FontWeight.w600,
        ),
        bodyLarge: TextStyle(color: AppColors.ink, fontSize: 16, height: 1.45),
        bodyMedium: TextStyle(color: AppColors.ink, fontSize: 14, height: 1.45),
        labelLarge: TextStyle(
          fontSize: 14,
          height: 1.2,
          fontWeight: FontWeight.w700,
        ),
      ),
      appBarTheme: const AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: AppColors.canvas,
        foregroundColor: AppColors.ink,
        surfaceTintColor: Colors.transparent,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(48, 52),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadii.control),
          ),
          textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(48, 48),
          side: const BorderSide(color: AppColors.outline),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadii.control),
          ),
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        elevation: 2,
        highlightElevation: 1,
        backgroundColor: AppColors.slate800,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(minimumSize: const Size(48, 48)),
      ),
      navigationBarTheme: NavigationBarThemeData(
        height: 76,
        elevation: 0,
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        indicatorColor: AppColors.slate100,
        labelTextStyle: WidgetStateProperty.resolveWith(
          (states) => TextStyle(
            color: states.contains(WidgetState.selected)
                ? AppColors.slate700
                : AppColors.muted,
            fontSize: 12,
            fontWeight: states.contains(WidgetState.selected)
                ? FontWeight.w700
                : FontWeight.w500,
          ),
        ),
      ),
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: ButtonStyle(
          minimumSize: const WidgetStatePropertyAll(Size(48, 44)),
          side: const WidgetStatePropertyAll(
            BorderSide(color: AppColors.outline),
          ),
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadii.control),
          borderSide: const BorderSide(color: AppColors.outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadii.control),
          borderSide: const BorderSide(color: AppColors.outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadii.control),
          borderSide: const BorderSide(color: AppColors.slate600, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadii.control),
          borderSide: const BorderSide(color: AppColors.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadii.control),
          borderSide: const BorderSide(color: AppColors.error, width: 2),
        ),
        labelStyle: const TextStyle(
          color: AppColors.muted,
          fontWeight: FontWeight.w500,
        ),
        hintStyle: const TextStyle(color: AppColors.muted),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        margin: EdgeInsets.zero,
        color: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.surface),
          side: const BorderSide(color: AppColors.outline),
        ),
      ),
      chipTheme: ChipThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.control),
        ),
        side: const BorderSide(color: AppColors.outline),
        backgroundColor: AppColors.surface,
        selectedColor: AppColors.slate100,
        labelStyle: const TextStyle(
          color: AppColors.ink,
          fontWeight: FontWeight.w600,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 7),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.slate600,
        linearTrackColor: AppColors.slate200,
        circularTrackColor: AppColors.slate200,
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        showDragHandle: true,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      snackBarTheme: const SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.slate900,
        contentTextStyle: TextStyle(color: Colors.white),
      ),
      dividerColor: AppColors.outline,
    );
  }
}
