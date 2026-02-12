import 'package:flutter/material.dart';
import '../constants/app_constants.dart';
import '../widgets/onboarding_page.dart';
import '../widgets/page_indicator.dart';
import 'login_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onGetStarted() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
  }

  void _onLogin() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // PageView with onboarding pages
          PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
            },
            itemCount: AppConstants.onboardingPages.length,
            itemBuilder: (context, index) {
              final pageData = AppConstants.onboardingPages[index];
              return OnboardingPage(
                title: pageData.title,
                titleHighlight: pageData.titleHighlight,
                description: pageData.description,
                imageUrl: pageData.imageUrl,
                currentPage: _currentPage,
                totalPages: AppConstants.onboardingPages.length,
                onGetStarted: _onGetStarted,
                onLogin: _onLogin,
                hasRotatingText: pageData.hasRotatingText,
                rotatingWords: pageData.rotatingWords,
              );
            },
          ),

          // Page Indicator overlay
          Positioned(
            left: 0,
            right: 0,
            bottom: 170,
            child: PageIndicator(
              currentPage: _currentPage,
              pageCount: AppConstants.onboardingPages.length,
            ),
          ),
        ],
      ),
    );
  }
}
