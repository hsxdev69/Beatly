import 'package:flutter/material.dart';
import 'colors.dart';

class AppTypography {
  static const TextStyle headerLarge = TextStyle(
    fontSize: 26,
    fontWeight: FontWeight.w800,
    letterSpacing: -0.6,
    color: AppColors.textPrimaryLight,
  );

  static const TextStyle sectionTitle = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w800,
    letterSpacing: 0.8,
    color: Color(0xFF5A6076),
  );

  static const TextStyle songTitle = TextStyle(
    fontSize: 14.5,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimaryLight,
  );

  static const TextStyle songSubtitle = TextStyle(
    fontSize: 12.5,
    color: AppColors.textSecondaryLight,
  );

  static const TextStyle playerTitle = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w800,
    letterSpacing: -0.4,
    color: Colors.white,
  );

  static const TextStyle playerSubtitle = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: Colors.white70,
  );
}

class AppDimensions {
  static const double radiusSmall = 10.0;
  static const double radiusMedium = 16.0;
  static const double radiusLarge = 22.0;
  static const double radiusCard = 28.0;
  static const double radiusDock = 34.0;

  static const double paddingScreen = 20.0;
}

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: AppColors.backgroundLight,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        brightness: Brightness.light,
        surface: AppColors.surfaceLight,
      ),
      fontFamily: 'sans-serif',
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: AppColors.backgroundDark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.accentIndigo,
        brightness: Brightness.dark,
        surface: AppColors.surfaceDark,
      ),
      fontFamily: 'sans-serif',
    );
  }
}
