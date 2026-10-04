import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'colors.dart';
import 'typography.dart';
import 'dimensions.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get darkTheme => createTheme(isPureBlack: false);
  static ThemeData get pureBlackTheme => createTheme(isPureBlack: true);
  static ThemeData get lightTheme => createTheme(isPureBlack: false);

  static ThemeData createTheme({
    bool isPureBlack = false,
    Color seedColor = AppColors.primarySeed,
  }) {
    final bg = isPureBlack ? AppColors.pureBlackBackground : AppColors.darkBackground;
    final surface = isPureBlack ? AppColors.pureBlackSurface : AppColors.darkSurface;
    final surfaceVariant = isPureBlack ? const Color(0xFF141416) : AppColors.darkSurfaceVariant;

    final colorScheme = ColorScheme.dark(
      primary: seedColor,
      onPrimary: Colors.white,
      secondary: AppColors.accentBlue,
      onSecondary: Colors.white,
      surface: surface,
      onSurface: AppColors.textPrimary,
      surfaceContainerHighest: surfaceVariant,
      onSurfaceVariant: AppColors.textSecondary,
      error: AppColors.error,
      onError: Colors.white,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: bg,
      colorScheme: colorScheme,
      cardColor: surfaceVariant,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        titleTextStyle: AppTypography.headlineMedium,
        iconTheme: IconThemeData(color: AppColors.textPrimary),
      ),
      cardTheme: CardThemeData(
        color: AppColors.darkCard,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
        ),
        margin: EdgeInsets.zero,
      ),
      sliderTheme: SliderThemeData(
        activeTrackColor: seedColor,
        inactiveTrackColor: Colors.white.withValues(alpha: 0.15),
        thumbColor: Colors.white,
        overlayColor: seedColor.withValues(alpha: 0.2),
        trackHeight: 4,
        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: Colors.transparent,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(AppDimensions.radiusLarge)),
        ),
      ),
    );
  }
}
