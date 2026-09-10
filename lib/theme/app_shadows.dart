// lib/theme/app_shadows.dart
import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppShadows {
  // Level 1 - Cards
  static List<BoxShadow> cardShadow = [
    BoxShadow(
      offset: const Offset(0, 4),
      blurRadius: 12,
      color: AppColors.cardShadow,
    ),
  ];

  // Level 2 - Interactive/Active
  static List<BoxShadow> activeShadow = [
    BoxShadow(
      offset: const Offset(0, 8),
      blurRadius: 20,
      color: AppColors.activeShadow,
    ),
  ];

  // No shadow (Level 0)
  static const List<BoxShadow> none = [];
}