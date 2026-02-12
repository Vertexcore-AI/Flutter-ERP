import 'package:flutter/material.dart';
import '../constants/app_constants.dart';
import 'design_system.dart';

class ThemeConfig {
  // Glass Design Constants (now managed in DesignSystem)
  static const double glassBlurLarge = DesignSystem.glassBlurLarge;
  static const double glassBlurMedium = DesignSystem.glassBlurMedium;
  static const double glassBlurSmall = DesignSystem.glassBlurSmall;
  static const double glassBlurNav = DesignSystem.glassBlurNav;

  // Light Theme - Liquid Glass Design
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,

      // Explicit ColorScheme with agriculture palette
      colorScheme: const ColorScheme(
        brightness: Brightness.light,
        primary: AppConstants.limeGreen,
        onPrimary: Colors.white,
        secondary: AppConstants.forestGreen,
        onSecondary: Colors.white,
        tertiary: AppConstants.olive,
        onTertiary: Colors.white,
        surface: Color(0xFFFFFFFF), // Will be made glass with BackdropFilter
        onSurface: AppConstants.darkGreen,
        error: Color(0xFFD32F2F), // Red[700]
        onError: Colors.white,
      ),

      scaffoldBackgroundColor: AppConstants.lightSage.withValues(alpha: 0.15),

      appBarTheme: AppBarTheme(
        backgroundColor: Colors.white.withValues(alpha: 0.85),
        elevation: 0,
        iconTheme: const IconThemeData(color: AppConstants.darkGreen),
        titleTextStyle: DesignSystem.heading(
          color: AppConstants.darkGreen,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),

      // Glass-styled elevated buttons - Subtle Glass Design
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppConstants.limeGreen.withValues(alpha: 0.12),
          foregroundColor: AppConstants.limeGreen,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(
              color: AppConstants.limeGreen.withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          elevation: 0, // No elevation for glass design
          shadowColor: Colors.transparent,
        ),
      ),

      drawerTheme: DrawerThemeData(
        backgroundColor: Colors.white.withValues(alpha: 0.85),
      ),

      textTheme: DesignSystem.lightTextTheme(),
    );
  }

  // Dark Theme - Liquid Glass Design
  static ThemeData get darkTheme {
    const darkBackground = Color(0xFF0d0f0a); // True dark with green undertone
    const darkSurface = Color(0xFF1a1a16); // Dark warm gray

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,

      colorScheme: const ColorScheme(
        brightness: Brightness.dark,
        primary: AppConstants.limeGreen,
        onPrimary: darkBackground,
        secondary: AppConstants.forestGreen,
        onSecondary: Colors.white,
        tertiary: AppConstants.olive,
        onTertiary: Colors.white,
        surface: darkSurface, // Will be made glass with BackdropFilter
        onSurface: AppConstants.lightSage,
        error: Color(0xFFEF5350), // Red[400]
        onError: darkBackground,
      ),

      scaffoldBackgroundColor: darkBackground,

      appBarTheme: AppBarTheme(
        backgroundColor: darkSurface.withValues(alpha: 0.80),
        elevation: 0,
        iconTheme: const IconThemeData(color: AppConstants.lightSage),
        titleTextStyle: DesignSystem.heading(
          color: AppConstants.lightSage,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppConstants.limeGreen.withValues(alpha: 0.15),
          foregroundColor: AppConstants.limeGreen,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(
              color: AppConstants.limeGreen.withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          elevation: 0,
          shadowColor: Colors.transparent,
        ),
      ),

      drawerTheme: DrawerThemeData(
        backgroundColor: darkSurface.withValues(alpha: 0.85),
      ),

      textTheme: DesignSystem.darkTextTheme(),
    );
  }
}
