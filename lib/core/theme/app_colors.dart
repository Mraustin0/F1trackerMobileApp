import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // --- Base surfaces ---
  static const background = Color(0xFF13131B);
  static const surfaceLowest = Color(0xFF0D0D16);
  static const surfaceLow = Color(0xFF1B1B24);
  static const surface = Color(0xFF1F1F28);
  static const surfaceHigh = Color(0xFF292933);
  static const surfaceHighest = Color(0xFF34343E);
  static const surfaceBright = Color(0xFF393842);

  // --- Primary accent (salmon / coral) ---
  static const primary = Color(0xFFFFB4A7);
  static const primaryContainer = Color(0xFFFF553D);
  static const onPrimary = Color(0xFF670400);
  static const onPrimaryContainer = Color(0xFF5B0300);

  // --- App red (logo, nav active indicator) ---
  static const appRed = Color(0xFFDC2626);
  static const appRedDark = Color(0xFFBE0E00);

  // --- Text on surfaces ---
  static const onSurface = Color(0xFFE4E1EE);
  static const onSurfaceVariant = Color(0xFFEABCB4);
  static const tertiary = Color(0xFFC6C6C7);
  static const tertiaryContainer = Color(0xFF909191);

  // --- Utility ---
  static const error = Color(0xFFDC2626);
  static const outlineVariant = Color(0xFF5F3E39);
  static const outline = Color(0xFFB08780);

  // --- Glass effect helpers (const-safe hex values) ---
  static const Color glassBackground = Color(0x0DFFFFFF); // white 5%
  static const Color glassBorder = Color(0x14FFFFFF);     // white 8%
  static const Color glassHighlight = Color(0x08FFFFFF);  // white 3%
}
