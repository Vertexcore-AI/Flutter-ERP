import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/app_constants.dart';

/// Centralized Design System Configuration
///
/// Change fonts and colors from this single file!
/// All UI components will automatically use these settings.
class DesignSystem {
  // ============================================================================
  // TYPOGRAPHY SYSTEM
  // ============================================================================

  /// Primary font family for the entire app
  ///
  /// Available options (all free on Google Fonts):
  /// - GoogleFonts.robotoCondensed (Current) - Condensed, space-efficient, highly legible
  /// - GoogleFonts.spaceGrotesk - Unique character, tech-forward
  /// - GoogleFonts.manrope - Contemporary, highly legible
  /// - GoogleFonts.plusJakartaSans - Modern geometric with rounded corners
  /// - GoogleFonts.outfit - Rounded geometric, friendly
  /// - GoogleFonts.dmSans - Safe choice, excellent for dashboards
  /// - GoogleFonts.inter - Clean, modern
  static TextStyle primaryFont({
    Color? color,
    double? fontSize,
    FontWeight? fontWeight,
    double? letterSpacing,
    double? height,
  }) {
    return GoogleFonts.robotoCondensed(
      color: color,
      fontSize: fontSize,
      fontWeight: fontWeight,
      letterSpacing: letterSpacing,
      height: height,
    );
  }

  /// Optional: Different font for headings (set to same as primaryFont for consistency)
  static TextStyle headingFont({
    Color? color,
    double? fontSize,
    FontWeight? fontWeight,
    double? letterSpacing,
    double? height,
  }) {
    return GoogleFonts.robotoCondensed(
      color: color,
      fontSize: fontSize,
      fontWeight: fontWeight,
      letterSpacing: letterSpacing,
      height: height,
    );
  }

  /// Generate TextTheme for light mode
  static TextTheme lightTextTheme() {
    return GoogleFonts.robotoCondensedTextTheme().apply(
      bodyColor: AppConstants.darkGreen,
      displayColor: AppConstants.darkGreen,
    );
  }

  /// Generate TextTheme for dark mode
  static TextTheme darkTextTheme() {
    return GoogleFonts.robotoCondensedTextTheme(ThemeData.dark().textTheme).apply(
      bodyColor: AppConstants.lightSage,
      displayColor: AppConstants.lightSage,
    );
  }

  // ============================================================================
  // COLOR SYSTEM
  // ============================================================================

  /// Primary brand color - Used for CTAs, active states, main brand elements
  static const Color primary = AppConstants.limeGreen; // #9dac17

  /// Secondary brand color - Used for backgrounds, subtle fills
  static const Color secondary = AppConstants.lightSage; // #ccd4a4

  /// Accent color - Used for success states, completed status
  static const Color accent = AppConstants.forestGreen; // #74981e

  /// Tertiary color - Used for badges, neutral status
  static const Color tertiary = AppConstants.olive; // #97a25c

  /// Surface tint - Used for glass overlay base
  static const Color surfaceTint = AppConstants.beige; // #cfcabb

  /// Dark text/border color - Used on light backgrounds
  static const Color darkText = AppConstants.darkGreen; // #5d7534

  // Status colors
  static const Color success = AppConstants.forestGreen;
  static const Color warning = AppConstants.olive;
  static const Color error = Color(0xFFD32F2F); // Red[700]
  static const Color info = AppConstants.limeGreen;

  // ============================================================================
  // LIGHT MODE COLORS
  // ============================================================================

  static const Color lightScaffoldBackground = Color(0xFFF5F7F0); // Light sage tint
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightOnSurface = AppConstants.darkGreen;
  static const Color lightCardBackground = Color(0xFFFFFFFF);

  // ============================================================================
  // DARK MODE COLORS
  // ============================================================================

  static const Color darkScaffoldBackground = Color(0xFF0d0f0a); // Dark with green undertone
  static const Color darkSurface = Color(0xFF1a1a16); // Dark warm gray
  static const Color darkOnSurface = AppConstants.lightSage;
  static const Color darkCardBackground = Color(0xFF1a1a16);

  // ============================================================================
  // GLASS DESIGN CONSTANTS
  // ============================================================================

  static const double glassBlurSmall = 6.0;
  static const double glassBlurMedium = 10.0;
  static const double glassBlurLarge = 12.0;
  static const double glassBlurNav = 15.0;

  // Glass alpha values (transparency)
  static const double glassAlphaLightSmall = 0.85;
  static const double glassAlphaLightMedium = 0.80;
  static const double glassAlphaLightLarge = 0.75;

  static const double glassAlphaDarkSmall = 0.80;
  static const double glassAlphaDarkMedium = 0.75;
  static const double glassAlphaDarkLarge = 0.70;

  // ============================================================================
  // SPACING SYSTEM
  // ============================================================================

  static const double spacingXs = 4.0;
  static const double spacingSm = 8.0;
  static const double spacingMd = 16.0;
  static const double spacingLg = 24.0;
  static const double spacingXl = 32.0;
  static const double spacing2Xl = 48.0;

  // ============================================================================
  // BORDER RADIUS SYSTEM
  // ============================================================================

  static const double radiusSm = 8.0;
  static const double radiusMd = 12.0;
  static const double radiusLg = 16.0;
  static const double radiusXl = 24.0;
  static const double radiusFull = 999.0; // Pill shape

  // ============================================================================
  // HELPER METHODS
  // ============================================================================

  /// Get text style with primary font
  static TextStyle text({
    Color? color,
    double? fontSize,
    FontWeight? fontWeight,
    double? letterSpacing,
    double? height,
  }) {
    return primaryFont(
      color: color,
      fontSize: fontSize,
      fontWeight: fontWeight,
      letterSpacing: letterSpacing,
      height: height,
    );
  }

  /// Get text style with heading font
  static TextStyle heading({
    Color? color,
    double? fontSize,
    FontWeight? fontWeight,
    double? letterSpacing,
    double? height,
  }) {
    return headingFont(
      color: color,
      fontSize: fontSize,
      fontWeight: fontWeight,
      letterSpacing: letterSpacing,
      height: height,
    );
  }
}

/// Quick reference guide for changing design:
///
/// TO CHANGE FONT:
/// 1. Update primaryFont getter (line 24) to use different GoogleFonts method
/// 2. Update lightTextTheme() and darkTextTheme() to use same font
/// 3. Example: Replace "manrope" with "plusJakartaSans" in all three places
///
/// TO CHANGE COLORS:
/// 1. Update the color constants in AppConstants (lib/constants/app_constants.dart)
/// 2. OR override the color constants here (primary, secondary, accent, etc.)
///
/// TO ADJUST GLASS EFFECT:
/// 1. Modify glassBlur* constants to increase/decrease blur strength
/// 2. Modify glassAlpha* constants to change transparency (0.0 = invisible, 1.0 = solid)
