import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/app_constants.dart';
import '../providers/user_provider.dart';
import '../widgets/glass_card.dart';
import '../widgets/change_password_dialog.dart';
import 'profile_setup_screen.dart';
import 'login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    setState(() => _isLoading = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      if (token != null && mounted) {
        final userProvider = Provider.of<UserProvider>(context, listen: false);
        await userProvider.fetchProfile(token);
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _handleEditProfile() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const ProfileSetupScreen()),
    ).then((_) {
      // Reload profile when returning from edit
      _loadProfile();
    });
  }

  void _handleChangePassword() async {
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
      return;
    }

    if (!mounted) return;
    showDialog(
      context: context,
      builder: (context) => ChangePasswordDialog(token: token),
    );
  }

  Future<void> _handleLogout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).brightness == Brightness.dark
            ? Colors.grey[900]
            : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Text(
          'Logout',
          style: GoogleFonts.spaceGrotesk(
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Text(
          'Are you sure you want to logout?',
          style: GoogleFonts.spaceGrotesk(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(
              'Cancel',
              style: GoogleFonts.spaceGrotesk(
                color: Colors.grey,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              'Logout',
              style: GoogleFonts.spaceGrotesk(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('auth_token');
      await prefs.remove('username');

      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (route) => false,
      );
    }
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'Not set';
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${date.day} ${months[date.month - 1]}, ${date.year}';
  }

  int _calculateAge(DateTime? dateOfBirth) {
    if (dateOfBirth == null) return 0;
    final now = DateTime.now();
    int age = now.year - dateOfBirth.year;
    if (now.month < dateOfBirth.month || (now.month == dateOfBirth.month && now.day < dateOfBirth.day)) {
      age--;
    }
    return age;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : Colors.grey[50],
      appBar: AppBar(
        title: Text(
          'My Profile',
          style: GoogleFonts.spaceGrotesk(
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: _handleEditProfile,
            icon: const Icon(Icons.edit_outlined, size: 22),
            tooltip: 'Edit Profile',
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(
                color: AppConstants.limeGreen,
                strokeWidth: 3,
              ),
            )
          : Consumer<UserProvider>(
              builder: (context, userProvider, child) {
                if (userProvider.user == null) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.person_off_outlined,
                          size: 64,
                          color: isDark ? Colors.white38 : Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Unable to load profile',
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 16,
                            color: isDark ? Colors.white70 : Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton.icon(
                          onPressed: _loadProfile,
                          icon: const Icon(Icons.refresh, size: 20),
                          label: Text(
                            'Retry',
                            style: GoogleFonts.spaceGrotesk(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppConstants.limeGreen,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 12,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }

                final user = userProvider.user!;
                final age = _calculateAge(user.dateOfBirth);

                return SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      // Profile Header Card with Gradient Avatar
                      GlassCard.large(
                        child: Column(
                          children: [
                            // Large Avatar with Gradient
                            Container(
                              width: 100,
                              height: 100,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: LinearGradient(
                                  colors: [
                                    AppConstants.limeGreen,
                                    AppConstants.forestGreen,
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppConstants.limeGreen.withValues(alpha: 0.3),
                                    blurRadius: 20,
                                    offset: const Offset(0, 8),
                                  ),
                                ],
                              ),
                              child: Center(
                                child: Text(
                                  user.fullName != null && user.fullName!.isNotEmpty
                                      ? user.fullName!.split(' ').map((e) => e[0]).take(2).join().toUpperCase()
                                      : user.username.substring(0, 1).toUpperCase(),
                                  style: GoogleFonts.spaceGrotesk(
                                    fontSize: 36,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),

                            // Full Name
                            Text(
                              user.fullName ?? 'Complete your profile',
                              style: GoogleFonts.spaceGrotesk(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: isDark ? Colors.white : Colors.black87,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 4),

                            // Username
                            Text(
                              '@${user.username}',
                              style: GoogleFonts.spaceGrotesk(
                                fontSize: 14,
                                color: isDark ? Colors.white60 : Colors.grey[600],
                              ),
                            ),
                            const SizedBox(height: 16),

                            // Role Badge
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: AppConstants.forestGreen.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: AppConstants.forestGreen.withValues(alpha: 0.4),
                                  width: 1.5,
                                ),
                              ),
                              child: Text(
                                user.role.toUpperCase(),
                                style: GoogleFonts.spaceGrotesk(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: AppConstants.forestGreen,
                                  letterSpacing: 1.2,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Personal Information Card
                      GlassCard.large(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildSectionHeader(
                              context,
                              icon: Icons.person_outline,
                              title: 'Personal Information',
                            ),
                            const SizedBox(height: 20),

                            _buildInfoTile(
                              context,
                              icon: Icons.cake_outlined,
                              label: 'Date of Birth',
                              value: _formatDate(user.dateOfBirth),
                              subtitle: age > 0 ? '$age years old' : null,
                            ),
                            const SizedBox(height: 14),

                            _buildInfoTile(
                              context,
                              icon: Icons.place_outlined,
                              label: 'Location',
                              value: user.location ?? 'Not specified',
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Agriculture Information Card
                      GlassCard.large(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildSectionHeader(
                              context,
                              icon: Icons.agriculture_outlined,
                              title: 'Agriculture Details',
                            ),
                            const SizedBox(height: 20),

                            // AI Division
                            _buildInfoTile(
                              context,
                              icon: Icons.location_city_outlined,
                              label: 'AI Division',
                              value: user.aiDivision?.name ?? 'Not assigned',
                            ),

                            if (user.aiDivision != null) ...[
                              const SizedBox(height: 14),
                              Padding(
                                padding: const EdgeInsets.only(left: 44),
                                child: Column(
                                  children: [
                                    _buildSubInfo(
                                      context,
                                      label: 'District',
                                      value: user.aiDivision!.district,
                                    ),
                                    const SizedBox(height: 8),
                                    _buildSubInfo(
                                      context,
                                      label: 'Province',
                                      value: user.aiDivision!.province,
                                    ),
                                  ],
                                ),
                              ),
                            ],

                            const SizedBox(height: 20),

                            // SL-GAP Certification Status
                            Container(
                              decoration: BoxDecoration(
                                gradient: user.slGapCertified
                                    ? LinearGradient(
                                        colors: [
                                          AppConstants.forestGreen.withValues(alpha: 0.1),
                                          AppConstants.limeGreen.withValues(alpha: 0.05),
                                        ],
                                      )
                                    : null,
                                color: !user.slGapCertified
                                    ? (isDark
                                        ? Colors.white.withValues(alpha: 0.03)
                                        : Colors.grey.withValues(alpha: 0.05))
                                    : null,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: user.slGapCertified
                                      ? AppConstants.forestGreen.withValues(alpha: 0.4)
                                      : (isDark ? Colors.white12 : Colors.grey[300]!),
                                  width: 1.5,
                                ),
                              ),
                              padding: const EdgeInsets.all(16),
                              child: Row(
                                children: [
                                  Container(
                                    width: 48,
                                    height: 48,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: user.slGapCertified
                                          ? AppConstants.forestGreen.withValues(alpha: 0.15)
                                          : (isDark ? Colors.white.withValues(alpha: 0.05) : Colors.grey[200]),
                                    ),
                                    child: Icon(
                                      user.slGapCertified
                                          ? Icons.verified
                                          : Icons.cancel_outlined,
                                      color: user.slGapCertified
                                          ? AppConstants.forestGreen
                                          : (isDark ? Colors.white38 : Colors.grey[400]),
                                      size: 26,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'SL-GAP Certification',
                                          style: GoogleFonts.spaceGrotesk(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w600,
                                            color: isDark ? Colors.white : Colors.black87,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        if (user.slGapCertified && user.slGapCertificateNumber != null)
                                          Text(
                                            'Cert. No: ${user.slGapCertificateNumber}',
                                            style: GoogleFonts.spaceGrotesk(
                                              fontSize: 12,
                                              color: isDark ? Colors.white60 : Colors.grey[600],
                                            ),
                                          )
                                        else
                                          Text(
                                            user.slGapCertified ? 'Certified' : 'Not certified',
                                            style: GoogleFonts.spaceGrotesk(
                                              fontSize: 12,
                                              color: isDark ? Colors.white60 : Colors.grey[600],
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: user.slGapCertified
                                          ? AppConstants.forestGreen.withValues(alpha: 0.15)
                                          : (isDark ? Colors.white.withValues(alpha: 0.05) : Colors.grey[200]),
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: user.slGapCertified
                                            ? AppConstants.forestGreen.withValues(alpha: 0.4)
                                            : (isDark ? Colors.white24 : Colors.grey[400]!),
                                        width: 1,
                                      ),
                                    ),
                                    child: Text(
                                      user.slGapCertified ? 'ACTIVE' : 'INACTIVE',
                                      style: GoogleFonts.spaceGrotesk(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w700,
                                        color: user.slGapCertified
                                            ? AppConstants.forestGreen
                                            : (isDark ? Colors.white54 : Colors.grey[600]),
                                        letterSpacing: 0.8,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Actions Card
                      GlassCard.large(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildSectionHeader(
                              context,
                              icon: Icons.security_outlined,
                              title: 'Account & Security',
                            ),
                            const SizedBox(height: 20),

                            // Change Password Button
                            _buildActionButton(
                              context,
                              icon: Icons.lock_outline,
                              label: 'Change Password',
                              onTap: _handleChangePassword,
                              color: AppConstants.limeGreen,
                            ),
                            const SizedBox(height: 12),

                            // Logout Button
                            _buildActionButton(
                              context,
                              icon: Icons.logout,
                              label: 'Logout',
                              onTap: _handleLogout,
                              color: Colors.red,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                );
              },
            ),
    );
  }

  Widget _buildSectionHeader(
    BuildContext context, {
    required IconData icon,
    required String title,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppConstants.limeGreen.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            color: AppConstants.limeGreen,
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: GoogleFonts.spaceGrotesk(
            fontSize: 17,
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoTile(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    String? subtitle,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Row(
      children: [
        Icon(
          icon,
          size: 20,
          color: isDark ? Colors.white54 : Colors.grey[600],
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 12,
                  color: isDark ? Colors.white54 : Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 11,
                    color: AppConstants.forestGreen,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSubInfo(
    BuildContext context, {
    required String label,
    required String value,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Row(
      children: [
        Container(
          width: 4,
          height: 4,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isDark ? Colors.white38 : Colors.grey[400],
          ),
        ),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: GoogleFonts.spaceGrotesk(
            fontSize: 12,
            color: isDark ? Colors.white54 : Colors.grey[600],
          ),
        ),
        Text(
          value,
          style: GoogleFonts.spaceGrotesk(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.white70 : Colors.grey[700],
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required Color color,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: color.withValues(alpha: 0.3),
              width: 1.5,
            ),
          ),
          child: Row(
            children: [
              Icon(icon, size: 20, color: color),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: color.withValues(alpha: 0.6),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
