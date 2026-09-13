// lib/theme/app_colors.dart
import 'package:flutter/material.dart';

class AppColors {
  // Primary
  static const Color primary = Color(0xFF000A1E);
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color primaryContainer = Color(0xFF002147);
  static const Color onPrimaryContainer = Color(0xFF708AB5);
  static const Color inversePrimary = Color(0xFFAEC7F6);

  // Secondary
  static const Color secondary = Color(0xFF735C00);
  static const Color onSecondary = Color(0xFFFFFFFF);
  static const Color secondaryContainer = Color(0xFFFED65B);
  static const Color onSecondaryContainer = Color(0xFF745C00);

  // Tertiary
  static const Color tertiary = Color(0xFF090B0C);
  static const Color onTertiary = Color(0xFFFFFFFF);
  static const Color tertiaryContainer = Color(0xFF1F2223);
  static const Color onTertiaryContainer = Color(0xFF87898A);

  // Error
  static const Color error = Color(0xFFBA1A1A);
  static const Color onError = Color(0xFFFFFFFF);
  static const Color errorContainer = Color(0xFFFFDAD6);
  static const Color onErrorContainer = Color(0xFF93000A);

  // Surface
  static const Color surface = Color(0xFFFBF9F8);
  static const Color surfaceDim = Color(0xFFDBD9D9);
  static const Color surfaceBright = Color(0xFFFBF9F8);
  static const Color surfaceContainerLowest = Color(0xFFFFFFFF);
  static const Color surfaceContainerLow = Color(0xFFF5F3F3);
  static const Color surfaceContainer = Color(0xFFEFEDED);
  static const Color surfaceContainerHigh = Color(0xFFEAE8E7);
  static const Color surfaceContainerHighest = Color(0xFFE4E2E2);
  static const Color onSurface = Color(0xFF1B1C1C);
  static const Color onSurfaceVariant = Color(0xFF44474E);
  static const Color inverseSurface = Color(0xFF303030);
  static const Color inverseOnSurface = Color(0xFFF2F0F0);
  static const Color surfaceVariant = Color(0xFFE4E2E2);
  static const Color surfaceTint = Color(0xFF465F88);

  // Outline
  static const Color outline = Color(0xFF74777F);
  static const Color outlineVariant = Color(0xFFC4C6CF);

  // Background
  static const Color background = Color(0xFFFBF9F8);
  static const Color onBackground = Color(0xFF1B1C1C);

  // Fixed
  static const Color primaryFixed = Color(0xFFD6E3FF);
  static const Color primaryFixedDim = Color(0xFFAEC7F6);
  static const Color onPrimaryFixed = Color(0xFF001B3D);
  static const Color onPrimaryFixedVariant = Color(0xFF2D476F);
  static const Color secondaryFixed = Color(0xFFFFE088);
  static const Color secondaryFixedDim = Color(0xFFE9C349);
  static const Color onSecondaryFixed = Color(0xFF241A00);
  static const Color onSecondaryFixedVariant = Color(0xFF574500);
  static const Color tertiaryFixed = Color(0xFFE1E3E4);
  static const Color tertiaryFixedDim = Color(0xFFC5C7C8);
  static const Color onTertiaryFixed = Color(0xFF191C1D);
  static const Color onTertiaryFixedVariant = Color(0xFF454748);

  // Custom Design System Colors
  static const Color cardBackground = Color(0xFFFFFFFF);
  static const Color canvasBackground = Color(0xFFF8F9FA);
  static const Color cardBorder = Color(0xFFE9ECEF);
  static const Color goldAccent = Color(0xFFFED65B);
  static const Color deepNavy = Color(0xFF002147);

  // Shadow colors
  static Color cardShadow = const Color(0xFF002147).withValues(alpha: 0.05);
  static Color activeShadow = const Color(0xFF002147).withValues(alpha: 0.12);
}