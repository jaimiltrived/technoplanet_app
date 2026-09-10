// lib/theme/app_radius.dart
import 'package:flutter/material.dart';

class AppRadius {
  static const double sm = 4.0; // 0.25rem
  static const double regular = 8.0; // 0.5rem
  static const double md = 12.0; // 0.75rem
  static const double lg = 16.0; // 1rem
  static const double xl = 24.0; // 1.5rem
  static const double full = 9999.0;

  static const BorderRadius smRadius = BorderRadius.all(Radius.circular(sm));
  static const BorderRadius regularRadius =
      BorderRadius.all(Radius.circular(regular));
  static const BorderRadius mdRadius = BorderRadius.all(Radius.circular(md));
  static const BorderRadius lgRadius = BorderRadius.all(Radius.circular(lg));
  static const BorderRadius xlRadius = BorderRadius.all(Radius.circular(xl));
  static const BorderRadius fullRadius =
      BorderRadius.all(Radius.circular(full));
}