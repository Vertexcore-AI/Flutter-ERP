import 'package:flutter/material.dart';

class AppConstants {
  // Agriculture Color Palette - Liquid Glass Design
  static const Color limeGreen = Color(0xFF9dac17);      // Primary - CTAs, active states, brand
  static const Color lightSage = Color(0xFFccd4a4);      // Secondary - Backgrounds, borders (dark mode)
  static const Color forestGreen = Color(0xFF74981e);    // Accent - Success, completed status
  static const Color olive = Color(0xFF97a25c);          // Tertiary - Badges, neutral status
  static const Color beige = Color(0xFFcfcabb);          // Surface tint - Glass overlay base
  static const Color darkGreen = Color(0xFF5d7534);      // Text/Borders - Dark text on light backgrounds

  // Legacy Colors (Deprecated - kept for backward compatibility)
  @Deprecated('Use limeGreen instead')
  static const Color primaryGreen = Color(0xFF4CAF50);
  @Deprecated('Use forestGreen instead')
  static const Color brandGreen = Color(0xFF5cdb5c);
  @Deprecated('Use forestGreen instead')
  static const Color brandGreenHover = Color(0xFF4bc94b);
  @Deprecated('Use forestGreen instead')
  static const Color secondaryGreen = Color(0xFF388E3C);

  // Logo
  static const String logoPath = 'assets/images/govipotha.png';

  // Background Images - Local Assets
  static const String onboardingImage1 = 'assets/images/greenhouse-background-slide1.jpg';
  static const String onboardingImage2 = 'assets/images/greenhouse-background-slide2.jpg';
  static const String onboardingImage3 = 'assets/images/greenhouse-background-slide3.jpg';
  static const String loginBackgroundImage = 'assets/images/login.jpg';

  // Onboarding Content
  static const List<OnboardingData> onboardingPages = [
    OnboardingData(
      title: 'Smart',
      titleHighlight: 'Management',
      description: ' The Most Advanced All-in-One System in Sri Lanka Designed for Modern Farmers and Agriculture Industry Professionals.',
      imageUrl: onboardingImage1,
      hasRotatingText: true,
      rotatingWords: ['Green House', 'Farm', 'Paddy Field'],
    ),
    OnboardingData(
      title: 'Data-Driven',
      titleHighlight: 'Precision',
      description: 'Data-driven precision agriculture for Farmers . Monitor, analyze, and control operations with our advanced system',
      imageUrl: onboardingImage2,
    ),
    OnboardingData(
      title: 'Sustainable',
      titleHighlight: 'Solutions',
      description: 'Join our network of farmers and agricultural experts to share knowledge, innovate, and cultivate a prosperous, sustainable future for everyone.',
      imageUrl: onboardingImage3,
    ),
  ];
}

class OnboardingData {
  final String title;
  final String titleHighlight;
  final String description;
  final String imageUrl;
  final bool hasRotatingText;
  final List<String> rotatingWords;

  const OnboardingData({
    required this.title,
    required this.titleHighlight,
    required this.description,
    required this.imageUrl,
    this.hasRotatingText = false,
    this.rotatingWords = const [],
  });
}
