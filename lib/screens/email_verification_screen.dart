import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/app_constants.dart';
import '../services/auth_service.dart';
import 'home_page.dart';
import 'login_screen.dart';

class EmailVerificationScreen extends StatefulWidget {
  final String token;

  const EmailVerificationScreen({
    super.key,
    required this.token,
  });

  @override
  State<EmailVerificationScreen> createState() => _EmailVerificationScreenState();
}

class _EmailVerificationScreenState extends State<EmailVerificationScreen> {
  final _authService = AuthService();
  bool _isVerifying = true;
  bool _isSuccess = false;
  String _message = '';

  @override
  void initState() {
    super.initState();
    _verifyEmail();
  }

  Future<void> _verifyEmail() async {
    setState(() => _isVerifying = true);

    try {
      final result = await _authService.verifyEmail(token: widget.token);

      if (!mounted) return;

      setState(() {
        _isVerifying = false;
        _isSuccess = result['success'];
        _message = result['success']
            ? (result['message'] ?? 'Email verified successfully!')
            : (result['error'] ?? 'Verification failed');
      });

      // If successful, wait 2 seconds then navigate to home
      if (result['success']) {
        await Future.delayed(const Duration(seconds: 2));
        if (!mounted) return;
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const HomePage()),
        );
      }
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isVerifying = false;
        _isSuccess = false;
        _message = 'An error occurred during verification';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo/Icon
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: _isVerifying
                        ? AppConstants.forestGreen.withValues(alpha: 0.1)
                        : _isSuccess
                            ? Colors.green.withValues(alpha: 0.1)
                            : Colors.red.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _isVerifying
                        ? Icons.email
                        : _isSuccess
                            ? Icons.check_circle
                            : Icons.error,
                    size: 64,
                    color: _isVerifying
                        ? AppConstants.forestGreen
                        : _isSuccess
                            ? Colors.green
                            : Colors.red,
                  ),
                ),
                const SizedBox(height: 32),

                // Status Text
                if (_isVerifying)
                  Column(
                    children: [
                      Text(
                        'Verifying Your Email',
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[900],
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      const CircularProgressIndicator(
                        color: AppConstants.forestGreen,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Please wait...',
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  )
                else
                  Column(
                    children: [
                      Text(
                        _isSuccess ? 'Email Verified!' : 'Verification Failed',
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: _isSuccess ? Colors.green : Colors.red,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _message,
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 14,
                          color: Colors.grey[700],
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 32),

                      // Action Button
                      if (_isSuccess)
                        Text(
                          'Redirecting to home...',
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 12,
                            color: Colors.grey[500],
                          ),
                        )
                      else
                        ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).pushReplacement(
                              MaterialPageRoute(
                                builder: (context) => const LoginScreen(),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppConstants.forestGreen,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 48,
                              vertical: 16,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          child: Text(
                            'Go to Login',
                            style: GoogleFonts.spaceGrotesk(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
