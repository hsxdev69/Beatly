import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Primary seed from Echo Music DESIGN.md (Coral Red)
  static const Color primarySeed = Color(0xFFED5564);
  static const Color primary = Color(0xFFED5564);
  static const Color primaryLight = Color(0xFFFF7281);

  // Dark Theme Surfaces (OLED & Dark Mode)
  static const Color darkBackground = Color(0xFF0C0C0E);
  static const Color darkSurface = Color(0xFF141418);
  static const Color darkSurfaceVariant = Color(0xFF1E1E24);
  static const Color darkCard = Color(0x33282832);
  static const Color darkGlassBorder = Color(0x1AFFFFFF);

  // Light surfaces fallback tokens
  static const Color backgroundLight = Color(0xFFF7F8FC);
  static const Color surfaceLight = Colors.white;
  static const Color cardLight = Color(0xFFEDF0F7);
  static const Color pillLight = Color(0xFFE5E9F2);
  static const Color textPrimaryLight = Color(0xFF131520);
  static const Color textSecondaryLight = Color(0xFF6B7280);

  // Pure Black Mode (OLED)
  static const Color pureBlackBackground = Color(0xFF000000);
  static const Color pureBlackSurface = Color(0xFF0A0A0A);
  static const Color backgroundDark = Color(0xFF0C0C0E);
  static const Color surfaceDark = Color(0xFF141418);
  static const Color cardDark = Color(0xFF1B1D2A);
  static const Color pillDark = Color(0xFF232536);
  static const Color textPrimaryDark = Colors.white;
  static const Color textSecondaryDark = Color(0xFF9CA3AF);

  // Text Colors
  static const Color textPrimary = Color(0xFFF2F2F6);
  static const Color textSecondary = Color(0xFFA0A0AC);
  static const Color textTertiary = Color(0xFF6E6E7A);

  // Interactive & Accents
  static const Color accentBlue = Color(0xFF4A90E2);
  static const Color accentIndigo = Color(0xFF6366F1);
  static const Color accentRose = Color(0xFFF43F5E);
  static const Color accentCyan = Color(0xFF06B6D4);
  static const Color error = Color(0xFFE53935);
  static const Color success = Color(0xFF4CAF50);

  // Glassmorphic Glows
  static const Color glowCoral = Color(0x40ED5564);
  static const Color glowPurple = Color(0x338A2BE2);
  static Color glassBackground = const Color(0xFF1E1E24).withValues(alpha: 0.85);
  static Color glassBorder = Colors.white.withValues(alpha: 0.1);
  static Color glassScrim = Colors.black.withValues(alpha: 0.65);
}
