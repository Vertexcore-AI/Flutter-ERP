import 'dart:ui';
import 'package:flutter/material.dart';
import '../constants/app_constants.dart';

enum GlassIntensity {
  small,   // Blur: 6px, Alpha: 0.85
  medium,  // Blur: 10px, Alpha: 0.80
  large,   // Blur: 12px, Alpha: 0.75
  nav,     // Blur: 15px, Alpha: 0.85
}

class GlassCard extends StatelessWidget {
  final Widget child;
  final BorderRadius? borderRadius;
  final EdgeInsets? padding;
  final GlassIntensity intensity;
  final Color? tintColor; // Optional color override
  final bool showBorder;
  final double? height;
  final double? width;
  final VoidCallback? onTap;

  const GlassCard({
    super.key,
    required this.child,
    this.borderRadius,
    this.padding = const EdgeInsets.all(20),
    this.intensity = GlassIntensity.medium,
    this.tintColor,
    this.showBorder = true,
    this.height,
    this.width,
    this.onTap,
  });

  // Factory constructors for common use cases
  factory GlassCard.small({
    required Widget child,
    EdgeInsets? padding,
    BorderRadius? borderRadius,
    VoidCallback? onTap,
  }) {
    return GlassCard(
      intensity: GlassIntensity.small,
      padding: padding ?? const EdgeInsets.all(12),
      borderRadius: borderRadius,
      onTap: onTap,
      child: child,
    );
  }

  factory GlassCard.large({
    required Widget child,
    EdgeInsets? padding,
    BorderRadius? borderRadius,
    VoidCallback? onTap,
  }) {
    return GlassCard(
      intensity: GlassIntensity.large,
      padding: padding ?? const EdgeInsets.all(24),
      borderRadius: borderRadius,
      onTap: onTap,
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final effectiveBorderRadius = borderRadius ?? BorderRadius.circular(16);

    // Get blur and alpha values based on intensity
    final (blurSigma, alphaLight, alphaDark) = _getIntensityValues();

    // Determine base tint color
    final Color baseTint = tintColor ??
        (isDark
            ? const Color(0xFF1a1a16) // Dark warm gray
            : Colors.white);

    // Apply alpha based on mode
    final Color glassColor = baseTint.withValues(
      alpha: isDark ? alphaDark : alphaLight,
    );

    // Border color
    final Color borderColor = isDark
        ? AppConstants.lightSage.withValues(alpha: 0.15)
        : Colors.white.withValues(alpha: 0.25);

    // Shadow
    final BoxShadow shadow = BoxShadow(
      color: Colors.black.withValues(alpha: isDark ? 0.15 : 0.08),
      blurRadius: isDark ? 12 : 8,
      offset: Offset(0, isDark ? 6 : 4),
    );

    final content = ClipRRect(
      borderRadius: effectiveBorderRadius,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
        child: Container(
          height: height,
          width: width,
          decoration: BoxDecoration(
            color: glassColor,
            borderRadius: effectiveBorderRadius,
            border: showBorder
                ? Border.all(
                    color: borderColor,
                    width: 1,
                  )
                : null,
            boxShadow: [shadow],
          ),
          child: padding != null
              ? Padding(padding: padding!, child: child)
              : child,
        ),
      ),
    );

    if (onTap != null) {
      return GestureDetector(onTap: onTap, child: content);
    }

    return content;
  }

  // Returns (blurSigma, alphaLight, alphaDark)
  (double, double, double) _getIntensityValues() {
    switch (intensity) {
      case GlassIntensity.small:
        return (6.0, 0.85, 0.80);
      case GlassIntensity.medium:
        return (10.0, 0.80, 0.75);
      case GlassIntensity.large:
        return (12.0, 0.75, 0.70);
      case GlassIntensity.nav:
        return (15.0, 0.85, 0.80);
    }
  }
}

// Glass Badge variant for status indicators
class GlassBadge extends StatelessWidget {
  final String text;
  final Color color;
  final EdgeInsets? padding;

  const GlassBadge({
    super.key,
    required this.text,
    required this.color,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding ?? const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        border: Border.all(color: color, width: 1.8),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}
