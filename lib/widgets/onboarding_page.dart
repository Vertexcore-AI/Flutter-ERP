import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/app_constants.dart';
import 'animated_rotating_text.dart';

class OnboardingPage extends StatelessWidget {
  final String title;
  final String titleHighlight;
  final String description;
  final String imageUrl;
  final int currentPage;
  final int totalPages;
  final VoidCallback onGetStarted;
  final VoidCallback onLogin;
  final bool hasRotatingText;
  final List<String> rotatingWords;

  const OnboardingPage({
    super.key,
    required this.title,
    required this.titleHighlight,
    required this.description,
    required this.imageUrl,
    required this.currentPage,
    required this.totalPages,
    required this.onGetStarted,
    required this.onLogin,
    this.hasRotatingText = false,
    this.rotatingWords = const [],
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Background Image
        Positioned.fill(
          child: Image.asset(
            imageUrl,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                color: Colors.grey[800],
                child: const Center(
                  child: Icon(Icons.image_not_supported, size: 50, color: Colors.white54),
                ),
              );
            },
          ),
        ),

        // Gradient Overlay
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.transparent,
                  Colors.black.withValues(alpha: 0.9),
                ],
                stops: const [0.0, 0.4, 1.0],
              ),
            ),
          ),
        ),

        // Content
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
                // Brand Badge with Glass-morphism
                _buildBrandBadge(),

                const Spacer(),

                // Bottom Content
                _buildBottomContent(context),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBrandBadge() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          child: Image.asset(
            AppConstants.logoPath,
            width: 48,
            height: 48,
            errorBuilder: (context, error, stackTrace) {
              return const Icon(
                Icons.eco,
                color: Colors.white,
                size: 32,
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildBottomContent(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title with highlight on same line or animated rotating text
        if (hasRotatingText && rotatingWords.isNotEmpty)
          AnimatedRotatingText(
            staticText: title,
            rotatingWords: rotatingWords,
            suffixText: titleHighlight,
            duration: const Duration(seconds: 3),
            textStyle: GoogleFonts.spaceGrotesk(
              fontSize: 36,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              height: 1.1,
            ),
            rotatingTextStyle: GoogleFonts.spaceGrotesk(
              fontSize: 36,
              fontWeight: FontWeight.bold,
              color: AppConstants.brandGreen,
              height: 1.1,
            ),
            suffixTextStyle: GoogleFonts.spaceGrotesk(
              fontSize: 36,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              height: 1.1,
            ),
          )
        else
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: '$title ',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    height: 1.1,
                  ),
                ),
                TextSpan(
                  text: titleHighlight,
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: AppConstants.brandGreen,
                    height: 1.1,
                  ),
                ),
              ],
            ),
          ),
        const SizedBox(height: 12),

        // Description
        Text(
          description,
          style: GoogleFonts.spaceGrotesk(
            fontSize: 16,
            color: Colors.grey[300],
            height: 1.5,
          ),
        ),
        const SizedBox(height: 32),

        // Page Indicator (placeholder - will be added in onboarding_screen)
        const SizedBox(height: 8),

        const SizedBox(height: 16),

        // Get Started Button
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: onGetStarted,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppConstants.brandGreen,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              elevation: 8,
              shadowColor: AppConstants.secondaryGreen.withValues(alpha: 0.3),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Get Started',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(
                  Icons.arrow_forward,
                  color: Colors.white,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),

        // Login Link
        Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Already have an account?',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 14,
                  color: Colors.grey[400],
                ),
              ),
              const SizedBox(width: 4),
              GestureDetector(
                onTap: onLogin,
                child: Text(
                  'Log In',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
