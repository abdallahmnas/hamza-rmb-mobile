import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTypography {
  // Base text theme using Hanken Grotesk
  static TextTheme get _baseTextTheme => GoogleFonts.hankenGroteskTextTheme();

  static TextTheme get lightTextTheme {
    return _baseTextTheme.copyWith(
      displayLarge: _baseTextTheme.displayLarge?.copyWith(
        fontSize: 30,
        fontWeight: FontWeight.w700,
        height: 38 / 30,
        letterSpacing: -0.02,
        color: AppColors.onBackground,
      ),
      displayMedium: _baseTextTheme.displayMedium?.copyWith(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        height: 32 / 24,
        color: AppColors.onBackground,
      ),
      displaySmall: _baseTextTheme.displaySmall?.copyWith(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        height: 28 / 20,
        color: AppColors.onBackground,
      ),
      bodyLarge: _baseTextTheme.bodyLarge?.copyWith(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        height: 24 / 16,
        color: AppColors.onBackground,
      ),
      bodyMedium: _baseTextTheme.bodyMedium?.copyWith(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        height: 20 / 14,
        color: AppColors.onBackground,
      ),
      bodySmall: _baseTextTheme.bodySmall?.copyWith(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        height: 16 / 12,
        color: AppColors.onBackground,
      ),
      labelLarge: GoogleFonts.jetBrainsMono(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        height: 14 / 11,
        letterSpacing: 0.05,
        color: AppColors.onBackground,
      ),
      headlineLarge: _baseTextTheme.headlineLarge?.copyWith(
        fontSize: 32,
        fontWeight: FontWeight.w700,
        height: 40 / 32,
        letterSpacing: -0.01,
        color: AppColors.tertiary,
      ),
    );
  }

  // Extensions for easy access (using specific style names from DESIGN.md)
  static TextStyle get headlineLg => lightTextTheme.displayLarge!;
  static TextStyle get headlineLgMobile => lightTextTheme.displayMedium!;
  static TextStyle get headlineMd => lightTextTheme.displaySmall!;
  static TextStyle get bodyLg => lightTextTheme.bodyLarge!;
  static TextStyle get bodyMd => lightTextTheme.bodyMedium!;
  static TextStyle get bodySm => lightTextTheme.bodySmall!;
  static TextStyle get labelCaps => lightTextTheme.labelLarge!;
  static TextStyle get currencyDisplay => lightTextTheme.headlineLarge!;
}
