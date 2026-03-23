import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTextStyles {
  AppTextStyles._();

  // --- Headline: Space Grotesk (bold italic) ---
  static TextStyle get displayLarge => GoogleFonts.spaceGrotesk(
        fontWeight: FontWeight.w900,
        fontStyle: FontStyle.italic,
        fontSize: 56,
        letterSpacing: -2,
        color: AppColors.onSurface,
      );

  static TextStyle get displayMedium => GoogleFonts.spaceGrotesk(
        fontWeight: FontWeight.w800,
        fontStyle: FontStyle.italic,
        fontSize: 40,
        letterSpacing: -1.5,
        color: AppColors.onSurface,
      );

  static TextStyle get headlineLarge => GoogleFonts.spaceGrotesk(
        fontWeight: FontWeight.w800,
        fontStyle: FontStyle.italic,
        fontSize: 32,
        letterSpacing: -1,
        color: AppColors.onSurface,
      );

  static TextStyle get headlineMedium => GoogleFonts.spaceGrotesk(
        fontWeight: FontWeight.w700,
        fontStyle: FontStyle.italic,
        fontSize: 24,
        letterSpacing: -0.5,
        color: AppColors.onSurface,
      );

  static TextStyle get headlineSmall => GoogleFonts.spaceGrotesk(
        fontWeight: FontWeight.w700,
        fontStyle: FontStyle.italic,
        fontSize: 18,
        color: AppColors.onSurface,
      );

  // Countdown digit style
  static TextStyle get countdown => GoogleFonts.spaceGrotesk(
        fontWeight: FontWeight.w900,
        fontStyle: FontStyle.italic,
        fontSize: 44,
        color: AppColors.primary,
        height: 1,
      );

  // Rank number (large italic)
  static TextStyle get rankLarge => GoogleFonts.spaceGrotesk(
        fontWeight: FontWeight.w900,
        fontStyle: FontStyle.italic,
        fontSize: 28,
        color: AppColors.onSurface,
      );

  static TextStyle get rankXL => GoogleFonts.spaceGrotesk(
        fontWeight: FontWeight.w900,
        fontStyle: FontStyle.italic,
        fontSize: 48,
        color: AppColors.onSurface,
      );

  // --- Body: Inter ---
  static TextStyle get bodyLarge => GoogleFonts.inter(
        fontWeight: FontWeight.w400,
        fontSize: 16,
        color: AppColors.onSurface,
      );

  static TextStyle get bodyMedium => GoogleFonts.inter(
        fontWeight: FontWeight.w400,
        fontSize: 14,
        color: AppColors.onSurface,
      );

  static TextStyle get bodySmall => GoogleFonts.inter(
        fontWeight: FontWeight.w400,
        fontSize: 12,
        color: AppColors.tertiary,
      );

  // --- Label: Inter (uppercase, tracking) ---
  static TextStyle get labelBold => GoogleFonts.inter(
        fontWeight: FontWeight.w700,
        fontSize: 11,
        letterSpacing: 1.4,
        color: AppColors.tertiary,
      );

  static TextStyle get labelSmall => GoogleFonts.inter(
        fontWeight: FontWeight.w700,
        fontSize: 9,
        letterSpacing: 1.6,
        color: AppColors.tertiary,
      );

  static TextStyle get labelAccent => GoogleFonts.inter(
        fontWeight: FontWeight.w800,
        fontSize: 11,
        letterSpacing: 1.4,
        color: AppColors.primary,
      );

  // --- Nav label ---
  static TextStyle get navLabel => GoogleFonts.inter(
        fontWeight: FontWeight.w700,
        fontSize: 9,
        letterSpacing: 1.2,
      );
}
