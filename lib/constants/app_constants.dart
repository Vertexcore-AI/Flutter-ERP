import 'package:flutter/material.dart';

class AppConstants {
  // Colors
  static const Color primaryGreen = Color(0xFF4CAF50);
  static const Color brandGreen = Color(0xFF5cdb5c);
  static const Color brandGreenHover = Color(0xFF4bc94b);
  static const Color secondaryGreen = Color(0xFF388E3C);

  // Background Images URLs
  static const String onboardingImage1 =
      'https://lh3.googleusercontent.com/aida-public/AB6AXuBmd5lo2Fp2acvyAfT88ycPjdbkg1Lo3z3XRk8VK-wGMOzlgM96PlntOQn-i_T8XLMNk5_hfVT1GSwniMSUQxUCd-ZghkwyG7GnISBFwZLyn7R2WqcNI_rrqSZRpvRdeiFodb7_Ky3GcJVBHiCmDPl1bW5FyJRI7at7Z8Ju1YJYHEgPPFeKmxXnV81Ko5Yf5U7ropvvpBu0gwNZodZtbswhHgd3ezEj3GKWuj3DIIOqL3jcVc7bz5vgFnutc_cfCK_2QmqTm-07P30';

  static const String onboardingImage2 =
      'https://lh3.googleusercontent.com/aida-public/AB6AXuBiB8iVk-UPp6B-OjLfpXXhIvdP1zDsRqnw_mahfgWNc7Ljz-h-poQ8bL3efgsm7w4l67grKrIV4Stjixg8O2k8V_vSV4pK1bOkmpTeSM5YgMCgUDrrbRg7oYQjXDy3POLInEDujQKMNXUcVw8pnEsPC6vBlrL6_xhxW11DA_LRopkmvjXKIBEupC6-Ekz1FegniBwcZxqzlScZrmPqfCiQhTXkyBt_zZwcSaUWwHwxlYMOKcM8NELgC0MYLsYjeA41vPPD9wjRnbI';

  // Onboarding Content
  static const List<OnboardingData> onboardingPages = [
    OnboardingData(
      title: 'Smart Greenhouse',
      titleHighlight: 'Management',
      description: 'Monitor climate, automate irrigation, and optimize crop yields with our all-in-one precision farming solution.',
      imageUrl: onboardingImage1,
    ),
    OnboardingData(
      title: 'Precision',
      titleHighlight: 'Automation',
      description: 'Automate irrigation, lighting, and climate controls to ensure optimal growth conditions 24/7.',
      imageUrl: onboardingImage2,
    ),
  ];
}

class OnboardingData {
  final String title;
  final String titleHighlight;
  final String description;
  final String imageUrl;

  const OnboardingData({
    required this.title,
    required this.titleHighlight,
    required this.description,
    required this.imageUrl,
  });
}
