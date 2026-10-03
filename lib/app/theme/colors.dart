import 'package:flutter/material.dart';

class AppColors {
  // Light Canvas (Home.png, search page.png, library.png)
  static const Color backgroundLight = Color(0xFFF7F8FC);
  static const Color surfaceLight = Colors.white;
  static const Color cardLight = Color(0xFFEDF0F7);
  static const Color pillLight = Color(0xFFE5E9F2);
  static const Color textPrimaryLight = Color(0xFF131520);
  static const Color textSecondaryLight = Color(0xFF6B7280);

  // Dark Canvas & OLED
  static const Color backgroundDark = Color(0xFF090A10);
  static const Color surfaceDark = Color(0xFF13151F);
  static const Color cardDark = Color(0xFF1B1D2A);
  static const Color pillDark = Color(0xFF232536);
  static const Color textPrimaryDark = Colors.white;
  static const Color textSecondaryDark = Color(0xFF9CA3AF);

  // Accents & Gradients
  static const Color primary = Color(0xFF1E202B);
  static const Color accentIndigo = Color(0xFF6366F1);
  static const Color accentRose = Color(0xFFF43F5E);
  static const Color accentCyan = Color(0xFF06B6D4);

  // Glassmorphism overlays
  static Color glassBackground = Colors.white.withValues(alpha: 0.82);
  static Color glassBorder = Colors.white.withValues(alpha: 0.7);
  static Color glassScrim = Colors.black.withValues(alpha: 0.65);
}
