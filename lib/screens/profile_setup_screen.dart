import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/app_constants.dart';
import '../models/ai_division_model.dart';
import '../providers/user_provider.dart';
import '../widgets/ai_division_search_field.dart';
import '../widgets/glass_card.dart';
import '../widgets/glass_date_picker_field.dart';
import 'dashboard_screen.dart';

class ProfileSetupScreen extends StatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  final _fullNameController = TextEditingController();
  final _certificateNumberController = TextEditingController();
  final _locationController = TextEditingController();

  DateTime? _selectedDateOfBirth;
  AIDivision? _selectedAIDivision;
  bool _isSlGapCertified = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _fullNameController.dispose();
    _certificateNumberController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  String? _validateFullName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Full name is required';
    }
    if (value.trim().length < 2) {
      return 'Full name must be at least 2 characters';
    }
    if (value.trim().length > 255) {
      return 'Full name must be less than 255 characters';
    }
    return null;
  }

  String? _validateDateOfBirth(DateTime? date) {
    if (date == null) {
      return 'Date of birth is required';
    }

    final now = DateTime.now();
    int age = now.year - date.year;
    if (now.month < date.month || (now.month == date.month && now.day < date.day)) {
      age--;
    }

    if (age < 18) {
      return 'You must be at least 18 years old';
    }

    return null;
  }

  String? _validateAIDivision(AIDivision? division) {
    if (division == null) {
      return 'AI Division is required';
    }
    return null;
  }

  String? _validateCertificateNumber(String? value) {
    if (_isSlGapCertified) {
      if (value == null || value.trim().isEmpty) {
        return 'Certificate number is required when certified';
      }
    }
    return null;
  }

  String? _validateLocation(String? value) {
    if (value != null && value.trim().length > 500) {
      return 'Location must be less than 500 characters';
    }
    return null;
  }

  Future<void> _handleSubmit() async {
    // Validate all fields
    final nameError = _validateFullName(_fullNameController.text);
    final dobError = _validateDateOfBirth(_selectedDateOfBirth);
    final divisionError = _validateAIDivision(_selectedAIDivision);
    final certificateError = _validateCertificateNumber(_certificateNumberController.text);
    final locationError = _validateLocation(_locationController.text);

    if (nameError != null || dobError != null || divisionError != null ||
        certificateError != null || locationError != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(nameError ?? dobError ?? divisionError ?? certificateError ?? locationError ?? 'Please fix the errors'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Get token from SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      if (token == null) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Authentication token not found. Please login again.'),
            backgroundColor: Colors.red,
          ),
        );
        setState(() => _isLoading = false);
        return;
      }

      // Update profile using UserProvider
      if (!mounted) return;
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final success = await userProvider.updateProfile(
        token: token,
        fullName: _fullNameController.text.trim(),
        dateOfBirth: _selectedDateOfBirth!,
        aiDivisionId: _selectedAIDivision!.id,
        slGapCertified: _isSlGapCertified,
        slGapCertificateNumber: _isSlGapCertified ? _certificateNumberController.text.trim() : null,
        location: _locationController.text.trim().isEmpty ? null : _locationController.text.trim(),
      );

      if (!mounted) return;

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile completed successfully!'),
            backgroundColor: AppConstants.forestGreen,
          ),
        );

        // Navigate to DashboardScreen
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const DashboardScreen()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(userProvider.error ?? 'Failed to update profile'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('An error occurred: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Complete Your Profile',
          style: GoogleFonts.spaceGrotesk(
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        elevation: 0,
      ),
      body: Stack(
        children: [
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Introduction Text
                  Text(
                    'Welcome!',
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Please complete your profile to get started with your smart farming journey.',
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 14,
                      color: isDark ? Colors.white70 : Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Personal Information Section
                  GlassCard.large(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.person_outline,
                              color: AppConstants.limeGreen,
                              size: 24,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'Personal Information',
                              style: GoogleFonts.spaceGrotesk(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: isDark ? Colors.white : Colors.black87,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),

                        // Full Name Field
                        Text(
                          'Full Name *',
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: isDark ? Colors.white70 : Colors.grey[700],
                          ),
                        ),
                        const SizedBox(height: 8),
                        _buildTextField(
                          controller: _fullNameController,
                          icon: Icons.badge_outlined,
                          hintText: 'Enter your full name',
                        ),
                        const SizedBox(height: 20),

                        // Date of Birth Field
                        Text(
                          'Date of Birth *',
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: isDark ? Colors.white70 : Colors.grey[700],
                          ),
                        ),
                        const SizedBox(height: 8),
                        GlassDatePickerField(
                          initialDate: _selectedDateOfBirth,
                          hintText: 'Select your date of birth',
                          onChanged: (date) {
                            setState(() {
                              _selectedDateOfBirth = date;
                            });
                          },
                          validator: _validateDateOfBirth,
                          icon: Icons.cake_outlined,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Agriculture Information Section
                  GlassCard.large(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.agriculture_outlined,
                              color: AppConstants.limeGreen,
                              size: 24,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'Agriculture Information',
                              style: GoogleFonts.spaceGrotesk(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: isDark ? Colors.white : Colors.black87,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),

                        // AI Division Field
                        Text(
                          'AI Division *',
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: isDark ? Colors.white70 : Colors.grey[700],
                          ),
                        ),
                        const SizedBox(height: 8),
                        AIDivisionSearchField(
                          initialValue: _selectedAIDivision,
                          onChanged: (division) {
                            setState(() {
                              _selectedAIDivision = division;
                            });
                          },
                          validator: _validateAIDivision,
                        ),
                        const SizedBox(height: 20),

                        // SL-GAP Certified Toggle
                        Container(
                          decoration: BoxDecoration(
                            color: isDark
                                ? Colors.white.withValues(alpha: 0.05)
                                : AppConstants.lightSage.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isDark
                                  ? Colors.white24
                                  : AppConstants.lightSage.withValues(alpha: 0.3),
                            ),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          child: Row(
                            children: [
                              Icon(
                                Icons.verified_outlined,
                                color: _isSlGapCertified
                                    ? AppConstants.limeGreen
                                    : (isDark ? Colors.white54 : Colors.grey[400]),
                                size: 24,
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'SL-GAP Certified',
                                      style: GoogleFonts.spaceGrotesk(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600,
                                        color: isDark ? Colors.white : Colors.black87,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      'Are you SL-GAP certified?',
                                      style: GoogleFonts.spaceGrotesk(
                                        fontSize: 12,
                                        color: isDark ? Colors.white54 : Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Switch(
                                value: _isSlGapCertified,
                                onChanged: (value) {
                                  setState(() {
                                    _isSlGapCertified = value;
                                    if (!value) {
                                      _certificateNumberController.clear();
                                    }
                                  });
                                },
                                activeTrackColor: AppConstants.limeGreen.withValues(alpha: 0.5),
                                activeThumbColor: AppConstants.limeGreen,
                              ),
                            ],
                          ),
                        ),

                        // Certificate Number Field (conditional)
                        if (_isSlGapCertified) ...[
                          const SizedBox(height: 20),
                          Text(
                            'Certificate Number *',
                            style: GoogleFonts.spaceGrotesk(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: isDark ? Colors.white70 : Colors.grey[700],
                            ),
                          ),
                          const SizedBox(height: 8),
                          _buildTextField(
                            controller: _certificateNumberController,
                            icon: Icons.numbers,
                            hintText: 'Enter your SL-GAP certificate number',
                          ),
                        ],
                        const SizedBox(height: 20),

                        // Location Field
                        Text(
                          'Location (Optional)',
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: isDark ? Colors.white70 : Colors.grey[700],
                          ),
                        ),
                        const SizedBox(height: 8),
                        _buildTextField(
                          controller: _locationController,
                          icon: Icons.place_outlined,
                          hintText: 'Enter your farm location',
                          maxLines: 2,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Submit Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _handleSubmit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppConstants.limeGreen,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        'Complete Profile',
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),

          // Loading Overlay
          if (_isLoading)
            Positioned.fill(
              child: Container(
                color: Colors.black.withValues(alpha: 0.5),
                child: Center(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                      child: Container(
                        padding: const EdgeInsets.all(32),
                        decoration: BoxDecoration(
                          color: isDark
                              ? Colors.white.withValues(alpha: 0.1)
                              : Colors.white.withValues(alpha: 0.8),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const CircularProgressIndicator(
                              color: AppConstants.limeGreen,
                              strokeWidth: 3,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Updating profile...',
                              style: GoogleFonts.spaceGrotesk(
                                fontSize: 14,
                                color: isDark ? Colors.white : Colors.black87,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required IconData icon,
    required String hintText,
    int maxLines = 1,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.white24 : Colors.grey[200]!,
        ),
        boxShadow: [
          if (!isDark)
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
        ],
      ),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        style: GoogleFonts.spaceGrotesk(
          fontSize: 15,
          color: isDark ? Colors.white : Colors.black87,
        ),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: GoogleFonts.spaceGrotesk(
            fontSize: 15,
            color: isDark ? Colors.white38 : Colors.grey[400],
          ),
          prefixIcon: Icon(
            icon,
            color: isDark ? Colors.white54 : Colors.grey[400],
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
      ),
    );
  }
}
