import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/app_constants.dart';
import '../services/secure_storage_service.dart';
import '../services/auth_service.dart';
import '../providers/user_provider.dart';
import '../widgets/glass_card.dart';
import 'onboarding_screen.dart';
import 'login_screen.dart';
import 'dashboard_screen.dart';
import 'profile_setup_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool _isLoading = true;
  String? _errorMessage;
  final _secureStorage = SecureStorageService();
  final _authService = AuthService();

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    // Minimum splash display time: 2 seconds for branding visibility
    final startTime = DateTime.now();

    try {
      // 1. Check for saved auth token
      final token = await _secureStorage.getAuthToken();

      if (token == null) {
        // First-time user or logged out
        await _ensureMinimumDelay(startTime, 2500);
        _navigateToOnboarding();
        return;
      }

      // 2. Validate token with backend (10 second timeout)
      final result = await _authService.getCurrentUser().timeout(
        const Duration(seconds: 10),
      );

      if (!result['success']) {
        // Token invalid/expired - clear storage
        await _secureStorage.clearAll();
        await _ensureMinimumDelay(startTime, 2500);
        _navigateToLogin();
        return;
      }

      // 3. Load user profile
      if (!mounted) return;
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final profileFetched = await userProvider.fetchProfile(token);

      if (!profileFetched || userProvider.user == null) {
        // Profile fetch failed - go to login
        await _ensureMinimumDelay(startTime, 2500);
        if (mounted) _navigateToLogin();
        return;
      }

      // 4. Route based on profile completion status
      await _ensureMinimumDelay(startTime, 2500);
      if (!mounted) return;

      if (userProvider.user!.profileCompleted) {
        _navigateToDashboard();
      } else {
        _navigateToProfileSetup();
      }
    } on TimeoutException {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage =
              'Connection timeout. Please check your internet connection.';
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage =
              'Unable to connect. Please check your internet connection.';
        });
      }
    }
  }

  /// Ensure splash screen displays for minimum duration (smooth UX)
  Future<void> _ensureMinimumDelay(DateTime startTime, int milliseconds) async {
    final elapsed = DateTime.now().difference(startTime).inMilliseconds;
    if (elapsed < milliseconds) {
      await Future.delayed(Duration(milliseconds: milliseconds - elapsed));
    }
  }

  void _navigateToOnboarding() {
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const OnboardingScreen()),
    );
  }

  void _navigateToLogin() {
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
  }

  void _navigateToDashboard() {
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const DashboardScreen()),
    );
  }

  void _navigateToProfileSetup() {
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const ProfileSetupScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/Splash_2.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: _isLoading ? _buildLoadingState() : _buildErrorState(),
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Column(
      children: [
        const Spacer(flex: 7), // 70% down
        const CircularProgressIndicator(color: Colors.white, strokeWidth: 4),
        const Spacer(flex: 3), // 30% remaining
      ],
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: GlassCard(
          intensity: GlassIntensity.medium,
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.cloud_off_outlined,
                  size: 48,
                  color: Colors.white,
                ),
                const SizedBox(height: 16),
                Text(
                  _errorMessage ?? 'An error occurred',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 16, color: Colors.white),
                ),
                const SizedBox(height: 24),

                // Retry Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _initializeApp,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppConstants.forestGreen,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      elevation: 4,
                    ),
                    child: const Text(
                      'Retry',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // Login Again Button
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: _navigateToLogin,
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      side: const BorderSide(color: Colors.white, width: 1.5),
                    ),
                    child: const Text(
                      'Login Again',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
