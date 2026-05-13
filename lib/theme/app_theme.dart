import 'package:flutter/material.dart';

import 'theme_controller.dart';

class AppColors {
  static const Color background = Color(0xFFF8F7FC);
  static const Color surface = Colors.white;
  static const Color ink = Color(0xFF392747);
  static const Color muted = Color(0xFF8E7B95);
  static const Color border = Color(0xFFF2DDEA);
  static const Color accent = Color(0xFF7E8BFF);
  static const Color accentSoft = Color(0xFFE8EBFF);
  static Color get currentAccent => ThemeController.instance.accentColor;
  static Color get currentAccentSoft =>
      Color.lerp(currentAccent, Colors.white, 0.82)!;
  static const Color navy = Color(0xFF6E5A8A);
  static const Color blue = Color(0xFF86C8FF);
  static const Color orange = Color(0xFFFFB38A);
  static const Color purple = Color(0xFFC69BFF);
  static const Color green = Color(0xFF8EE1C1);
  static const Color lemon = Color(0xFFFFD96A);
}

ThemeData buildAppTheme() {
  final colorScheme = ColorScheme.fromSeed(
    seedColor: AppColors.accent,
    brightness: Brightness.light,
  ).copyWith(
    primary: AppColors.accent,
    secondary: AppColors.purple,
    surface: AppColors.surface,
  );

  return ThemeData(
    useMaterial3: true,
    colorScheme: colorScheme,
    scaffoldBackgroundColor: AppColors.background,
    textTheme: Typography.blackCupertino,
    dividerColor: AppColors.border,
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      foregroundColor: AppColors.ink,
      elevation: 0,
      scrolledUnderElevation: 0,
    ),
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
    ),
    cardTheme: CardThemeData(
      color: Colors.white.withValues(alpha: 0.9),
      elevation: 0,
      shadowColor: AppColors.accent.withValues(alpha: 0.08),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFFF3F4FD),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(color: AppColors.accent),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(foregroundColor: AppColors.navy),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: AppColors.accent,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      ),
    ),
  );
}
