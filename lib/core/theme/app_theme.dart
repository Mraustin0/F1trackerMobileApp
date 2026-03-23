import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';
import 'app_text_styles.dart';
import 'team_theme_extension.dart';

class AppTheme {
  AppTheme._();

  static ThemeData darkTheme({TeamTheme? teamTheme}) {
    final team = teamTheme ?? TeamTheme.defaultTheme;

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.background,

      // Color scheme
      colorScheme: ColorScheme.dark(
        primary: AppColors.primary,
        secondary: team.accentColor,
        surface: AppColors.surface,
        error: AppColors.error,
        onPrimary: AppColors.onPrimary,
        onSecondary: Colors.white,
        onSurface: AppColors.onSurface,
        onError: Colors.white,
        surfaceContainerHighest: AppColors.surfaceHighest,
        surfaceContainerHigh: AppColors.surfaceHigh,
        surfaceContainer: AppColors.surface,
        surfaceContainerLow: AppColors.surfaceLow,
        surfaceContainerLowest: AppColors.surfaceLowest,
        outline: AppColors.outline,
        outlineVariant: AppColors.outlineVariant,
      ),

      // Text theme
      textTheme: TextTheme(
        displayLarge: AppTextStyles.displayLarge,
        displayMedium: AppTextStyles.displayMedium,
        headlineLarge: AppTextStyles.headlineLarge,
        headlineMedium: AppTextStyles.headlineMedium,
        headlineSmall: AppTextStyles.headlineSmall,
        bodyLarge: AppTextStyles.bodyLarge,
        bodyMedium: AppTextStyles.bodyMedium,
        bodySmall: AppTextStyles.bodySmall,
        labelLarge: AppTextStyles.labelBold,
        labelSmall: AppTextStyles.labelSmall,
      ),

      // App bar
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
        ),
        titleTextStyle: GoogleFonts.spaceGrotesk(
          fontWeight: FontWeight.w900,
          fontStyle: FontStyle.italic,
          fontSize: 22,
          color: AppColors.appRed,
          letterSpacing: 3,
        ),
      ),

      // Navigation bar (bottom)
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.background.withOpacity(0.9),
        indicatorColor: team.accentColor.withOpacity(0.15),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return IconThemeData(color: team.accentColor, size: 24);
          }
          return const IconThemeData(color: Color(0xFF6B6B7B), size: 24);
        }),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppTextStyles.navLabel.copyWith(color: team.accentColor);
          }
          return AppTextStyles.navLabel.copyWith(color: const Color(0xFF6B6B7B));
        }),
        height: 72,
        elevation: 0,
      ),

      // Card
      cardTheme: CardThemeData(
        color: AppColors.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: EdgeInsets.zero,
      ),

      // Divider
      dividerTheme: const DividerThemeData(
        color: Color(0x14FFFFFF),
        thickness: 1,
        space: 0,
      ),

      // Icon
      iconTheme: const IconThemeData(color: AppColors.tertiary, size: 24),

      // Extensions for team color
      extensions: [team],
    );
  }
}
