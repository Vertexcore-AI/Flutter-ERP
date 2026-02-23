import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../config/design_system.dart';
import '../constants/app_constants.dart';
import '../providers/theme_provider.dart';
import '../providers/user_provider.dart';
import '../screens/profile_screen.dart';

enum AppBarMode {
  branding, // Home page: Shows "Greenland" logo
  title, // Feature pages: Shows page title + subtitle
}

class AppBarGlass extends StatelessWidget {
  // Layout mode
  final AppBarMode mode;

  // Branding mode (home page)
  final String? brandingText;
  final IconData? brandingIcon;

  // Title mode (feature pages)
  final String? title;
  final String? subtitle;
  final IconData? titleIcon;
  final Widget? leadingAction;
  final List<Widget>? trailingActions;

  // Common props
  final bool showProfileIcon;
  final bool showThemeToggle;
  final bool showUserAvatar;
  final String? userInitials;
  final VoidCallback? onProfileTap;

  const AppBarGlass({
    super.key,
    required this.mode,
    this.brandingText,
    this.brandingIcon,
    this.title,
    this.subtitle,
    this.titleIcon,
    this.leadingAction,
    this.trailingActions,
    this.showProfileIcon = true,
    this.showThemeToggle = true,
    this.showUserAvatar = true,
    this.userInitials,
    this.onProfileTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 600;
        final isLandscape =
            MediaQuery.of(context).orientation == Orientation.landscape;

        return ClipRRect(
          borderRadius: BorderRadius.circular(21),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              decoration: _buildGlassDecoration(isDark),
              padding: EdgeInsets.symmetric(
                horizontal: isMobile ? 16 : 20,
                vertical: isLandscape ? 10 : 12,
              ),
              child: _buildContent(context, isDark, isMobile),
            ),
          ),
        );
      },
    );
  }

  BoxDecoration _buildGlassDecoration(bool isDark) {
    return BoxDecoration(
      color: isDark
          ? const Color(0xFF1a1a16).withValues(alpha: 0.75)
          : Colors.white.withValues(alpha: 0.80),
      borderRadius: BorderRadius.circular(21),
      border: Border.all(
        color: isDark
            ? AppConstants.lightSage.withValues(alpha: 0.15)
            : Colors.white.withValues(alpha: 0.25),
        width: 1,
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: isDark ? 0.15 : 0.08),
          blurRadius: isDark ? 12 : 8,
          offset: Offset(0, isDark ? 6 : 4),
        ),
      ],
    );
  }

  Widget _buildContent(BuildContext context, bool isDark, bool isMobile) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(child: _buildLeftSection(isDark)),
        _buildRightActions(context, isDark),
      ],
    );
  }

  Widget _buildLeftSection(bool isDark) {
    if (mode == AppBarMode.branding) {
      return _buildBrandingSection(isDark);
    } else {
      return _buildTitleSection(isDark);
    }
  }

  Widget _buildBrandingSection(bool isDark) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          brandingIcon ?? Icons.eco,
          color: AppConstants.limeGreen,
          size: 24,
        ),
        const SizedBox(width: 12),
        Text(
          brandingText ?? 'Greenland',
          style: GoogleFonts.robotoCondensed(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _buildTitleSection(bool isDark) {
    return Row(
      children: [
        if (leadingAction != null) ...[
          leadingAction!,
          const SizedBox(width: 8),
        ],
        if (titleIcon != null) ...[
          Icon(
            titleIcon,
            color: AppConstants.limeGreen,
            size: 24,
          ),
          const SizedBox(width: 12),
        ],
        Expanded(
          child: Text(
            title ?? '',
            style: DesignSystem.heading(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white : Colors.black87,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildRightActions(BuildContext context, bool isDark) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Custom trailing actions
        if (trailingActions != null)
          ...trailingActions!.map((action) => Padding(
                padding: const EdgeInsets.only(right: 8),
                child: action,
              )),

        // Profile icon
        if (showProfileIcon)
          IconButton(
            onPressed: () {
              HapticFeedback.lightImpact();
              if (onProfileTap != null) {
                onProfileTap!();
              } else {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ProfileScreen()),
                );
              }
            },
            icon: Icon(
              Icons.person_outline,
              size: 22,
              color: isDark ? Colors.white : Colors.black87,
            ),
            tooltip: 'Profile',
          ),

        // Theme toggle
        if (showThemeToggle)
          Consumer<ThemeProvider>(
            builder: (context, themeProvider, _) {
              return IconButton(
                onPressed: () {
                  HapticFeedback.lightImpact();
                  themeProvider.toggleTheme();
                },
                icon: Icon(
                  isDark ? Icons.light_mode : Icons.dark_mode,
                  size: 22,
                  color: isDark ? Colors.white : Colors.black87,
                ),
                tooltip: isDark ? 'Light Mode' : 'Dark Mode',
              );
            },
          ),

        // User avatar
        if (showUserAvatar) const SizedBox(width: 4),
        if (showUserAvatar)
          Consumer<UserProvider>(
            builder: (context, userProvider, _) {
              final initials = _extractInitials(
                userProvider.user?.fullName ?? userInitials ?? 'U',
              );
              return CircleAvatar(
                radius: 18,
                backgroundColor: AppConstants.limeGreen,
                child: Text(
                  initials,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              );
            },
          ),
      ],
    );
  }

  String _extractInitials(String name) {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    } else if (parts.isNotEmpty && parts[0].isNotEmpty) {
      return parts[0][0].toUpperCase();
    }
    return 'U';
  }
}
