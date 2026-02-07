import 'package:flutter/material.dart';
import '../constants/app_constants.dart';
import '../widgets/onboarding_page.dart';
import '../widgets/page_indicator.dart';

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
    // TODO: Navigate to login screen
    // For now, show a snackbar
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Navigate to Login Screen'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _onLogin() {
    // TODO: Navigate to login screen
    // For now, show a snackbar
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Navigate to Login Screen'),
        duration: Duration(seconds: 2),
      ),
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
              );
            },
          ),

          // Page Indicator overlay
          Positioned(
            left: 0,
            right: 0,
            bottom: 200,
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
