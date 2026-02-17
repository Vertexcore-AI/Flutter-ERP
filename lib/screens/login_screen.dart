import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/app_constants.dart';
import '../providers/user_provider.dart';
import '../services/auth_service.dart';
import 'signup_screen.dart';
import 'dashboard_screen.dart';
import 'profile_setup_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isLoading = false;
  final _authService = AuthService();

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleSignIn() async {
    if (_usernameController.text.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill in all fields'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final result = await _authService.login(
        username: _usernameController.text.trim(),
        password: _passwordController.text,
      );

      if (!mounted) return;

      if (result['success']) {
        // Store token in shared preferences
        final prefs = await SharedPreferences.getInstance();
        final token = result['data']['access_token'];
        await prefs.setString('auth_token', token);
        await prefs.setString('username', _usernameController.text.trim());

        // Fetch user profile to check if profile is completed
        if (!mounted) return;
        final userProvider = Provider.of<UserProvider>(context, listen: false);
        final profileFetched = await userProvider.fetchProfile(token);

        if (!mounted) return;

        if (profileFetched && userProvider.user != null) {
          // Check if profile is completed
          if (userProvider.user!.profileCompleted) {
            // Profile complete - navigate to dashboard
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => const DashboardScreen()),
            );
          } else {
            // Profile incomplete - navigate to profile setup
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => const ProfileSetupScreen()),
            );
          }
        } else {
          // Failed to fetch profile, but login successful - navigate to dashboard
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const DashboardScreen()),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['error'] ?? 'Login failed'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _handleGoogleSignIn() {
    // TODO: Implement Google sign in
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Google Sign In to be implemented'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _handleFacebookSignIn() {
    // TODO: Implement Facebook sign in
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Facebook Sign In to be implemented'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _handleSignUp() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const SignupScreen()),
    );
  }

  void _handleForgotPassword() {
    // TODO: Navigate to forgot password screen
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Forgot Password functionality to be implemented'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Image
          Positioned.fill(
            child: Image.asset(
              AppConstants.loginBackgroundImage,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(color: Colors.grey[800]);
              },
            ),
          ),

          // Dark Overlay
          Positioned.fill(
            child: Container(
              color: Colors.black.withValues(alpha: 0.2),
            ),
          ),

          // Gradient Top Overlay
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 256,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.6),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          // Content
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight,
                    ),
                    child: IntrinsicHeight(
                      child: Column(
                        children: [
                          // Header Brand
                          Padding(
                            padding: const EdgeInsets.all(32),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      'Greenland',
                                      style: GoogleFonts.spaceGrotesk(
                                        fontSize: 28,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                        letterSpacing: -0.5,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Image.asset(
                                      AppConstants.logoPath,
                                      width: 32,
                                      height: 32,
                                      errorBuilder: (context, error, stackTrace) {
                                        return const Icon(
                                          Icons.eco,
                                          color: AppConstants.limeGreen,
                                          size: 28,
                                        );
                                      },
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Smart Farming Solutions',
                                  style: GoogleFonts.spaceGrotesk(
                                    fontSize: 12,
                                    color: Colors.white.withValues(alpha: 0.8),
                                    fontWeight: FontWeight.w300,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const Spacer(),

                          // Login Form Card
                          _buildLoginCard(),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // Loading Overlay
          if (_isLoading)
            Positioned.fill(
              child: Container(
                color: Colors.black.withValues(alpha: 0.5),
                child: const Center(
                  child: CircularProgressIndicator(
                    color: AppConstants.forestGreen,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildLoginCard() {
    return ClipRRect(
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(40),
        topRight: Radius.circular(40),
      ),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.85),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(40),
              topRight: Radius.circular(40),
            ),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                // Title
                Text(
                  'Welcome Back.',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[900],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Enter your email and password to access your farm dashboard.',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 24),

                // Username Field
                _buildTextField(
                  controller: _usernameController,
                  icon: Icons.person_outline,
                  hintText: 'Username',
                  keyboardType: TextInputType.text,
                ),
                const SizedBox(height: 16),

                // Password Field
                _buildPasswordField(),
                const SizedBox(height: 8),

                // Forgot Password
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: _handleForgotPassword,
                    child: Text(
                      'Forgot Password?',
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: Colors.red[500],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),

                // Sign In Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _handleSignIn,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF3FA118),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      elevation: 8,
                      shadowColor: const Color(0xFF3FA118).withValues(alpha: 0.3),
                    ),
                    child: Text(
                      'Sign In',
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Divider
                Row(
                  children: [
                    Expanded(
                      child: Divider(color: Colors.grey[300], thickness: 1),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        'Or',
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 12,
                          color: Colors.grey[500],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Divider(color: Colors.grey[300], thickness: 1),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Social Login Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildSocialButton(
                      onTap: _handleGoogleSignIn,
                      imageUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuB4Ycde1vM4BNMeWJNfztoVtKy-t3YCi7dtyGq1DptryygXtSQ9Tk2Klttb9o22xLu2ahCNvboc3d7y0cFJJBuMAvLLKH66SD4Cv9f_ICxyLcCYF3ERP_YxmOwbGneSliMjTNB6sI6Fuewi020zV6a13sOrEvbw2o6d0ncOYgWrlItgWi-xGgeE3sJao5cde7I7YXeH1Joigfq2qILI3t1Do6Jc_wax9k7psYbNpp2lj2SDaYYgvAJ9fVBi0sY-jXrb0tj2MuAOq-8',
                    ),
                    const SizedBox(width: 24),
                    _buildSocialButton(
                      onTap: _handleFacebookSignIn,
                      imageUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuCtYpYwa5apWgIuMX-SXv6A_cmc8qMExcvhCcBjUyv3H363V1MVlbut7M74y-Vph-p1itAZy9zETY-qFXKpGYrBVPBiMVOBCBR6VMG0O6i5ErdWOEJysyemZeKgcROLfnABiKPyNYCDG0AEZhlK9YxqKDRH4pyW2za4D8r4vgfjkyZeK429Jd5ITlDwfAJnZJWC5Y3VVJnwQC07s6SWcSxm2zhJuCov8auKRly7wbaF3g8gNRWBNCOf8y5abLobOyUG4KFNx-3v6zE',
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Sign Up Link
                Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "Don't have an account?",
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(width: 4),
                      GestureDetector(
                        onTap: _handleSignUp,
                        child: Text(
                          'Sign Up',
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF3FA118),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required IconData icon,
    required String hintText,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        style: GoogleFonts.spaceGrotesk(
          fontSize: 15,
          color: Colors.grey[900],
        ),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: GoogleFonts.spaceGrotesk(
            fontSize: 15,
            color: Colors.grey[400],
          ),
          prefixIcon: Icon(icon, color: Colors.grey[400]),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
      ),
    );
  }

  Widget _buildPasswordField() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: _passwordController,
        obscureText: !_isPasswordVisible,
        style: GoogleFonts.spaceGrotesk(
          fontSize: 15,
          color: Colors.grey[900],
        ),
        decoration: InputDecoration(
          hintText: 'Password',
          hintStyle: GoogleFonts.spaceGrotesk(
            fontSize: 15,
            color: Colors.grey[400],
          ),
          prefixIcon: Icon(Icons.lock_outline, color: Colors.grey[400]),
          suffixIcon: IconButton(
            icon: Icon(
              _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
              color: Colors.grey[400],
            ),
            onPressed: () {
              setState(() {
                _isPasswordVisible = !_isPasswordVisible;
              });
            },
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
      ),
    );
  }

  Widget _buildSocialButton({
    required VoidCallback onTap,
    required String imageUrl,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.grey[200]!),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Center(
          child: Image.network(
            imageUrl,
            width: 24,
            height: 24,
            errorBuilder: (context, error, stackTrace) {
              return Icon(Icons.error_outline, color: Colors.grey[400]);
            },
          ),
        ),
      ),
    );
  }
}
