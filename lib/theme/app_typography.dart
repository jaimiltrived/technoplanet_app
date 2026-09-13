// lib/theme/app_typography.dart
import 'package:flutter/material.dart';

class AppTypography {
  static const String _fontFamily = 'Inter';

  // Headline Large
  static const TextStyle headlineLg = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 32,
    fontWeight: FontWeight.w700,
    height: 40 / 32,
    letterSpacing: -0.64, // -0.02em
  );

  // Headline Large Mobile
  static const TextStyle headlineLgMobile = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 26,
    fontWeight: FontWeight.w700,
    height: 32 / 26,
    letterSpacing: -0.26, // -0.01em
  );

  // Headline Medium
  static const TextStyle headlineMd = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 20,
    fontWeight: FontWeight.w600,
    height: 28 / 20,
  );

  // Body Large
  static const TextStyle bodyLg = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 24 / 16,
  );

  // Body Small
  static const TextStyle bodySm = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 20 / 14,
  );

  // Label Bold
  static const TextStyle labelBold = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w600,
    height: 16 / 12,
    letterSpacing: 0.6, // 0.05em
  );

  // Label Regular
  static const TextStyle labelRegular = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 16 / 12,
    letterSpacing: 0.5,
  );

  // Data Point
  static const TextStyle dataPoint = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 18,
    fontWeight: FontWeight.w700,
    height: 24 / 18,
    fontFeatures: [FontFeature.tabularFigures()],
  );
}