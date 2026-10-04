import 'package:flutter/material.dart';

class AppDimensions {
  AppDimensions._();

  // Spacing
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;

  // Corner Radii (as defined in Echo Music DESIGN.md)
  static const double radiusSmall = 12.0;
  static const double radiusCard = 24.0;
  static const double radiusLarge = 28.0;
  static const double radiusPill = 999.0;

  static final BorderRadius borderSmall = BorderRadius.circular(radiusSmall);
  static final BorderRadius borderCard = BorderRadius.circular(radiusCard);
  static final BorderRadius borderLarge = BorderRadius.circular(radiusLarge);
  static final BorderRadius borderPill = BorderRadius.circular(radiusPill);

  // Player & Navigation heights
  static const double miniPlayerHeight = 64.0;
  static const double bottomNavHeight = 68.0;
  static const double bottomNavTotalSpace = 148.0; // Mini player + bottom nav + paddings
  static const double listThumbnailSize = 54.0;
  static const double gridItemWidth = 148.0;
}
