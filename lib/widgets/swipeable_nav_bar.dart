import 'package:flutter/material.dart';
import '../constants/app_constants.dart';
import 'glass_card.dart';

class NavigationItem {
  final String label;
  final String iconPath;

  NavigationItem({
    required this.label,
    required this.iconPath,
  });
}

class SwipeableNavBar extends StatefulWidget {
  final List<NavigationItem> items;
  final int currentIndex;
  final ValueChanged<int> onItemSelected;

  const SwipeableNavBar({
    super.key,
    required this.items,
    required this.currentIndex,
    required this.onItemSelected,
  });

  @override
  State<SwipeableNavBar> createState() => _SwipeableNavBarState();
}

class _SwipeableNavBarState extends State<SwipeableNavBar> {
  late PageController _pageController;
  double _currentPage = 0.0;

  @override
  void initState() {
    super.initState();
    _currentPage = widget.currentIndex.toDouble();
    _pageController = PageController(
      initialPage: widget.currentIndex,
      viewportFraction: 0.25, // Show ~4 icons at a time
    );
    _pageController.addListener(() {
      setState(() {
        _currentPage = _pageController.page ?? widget.currentIndex.toDouble();
      });
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(SwipeableNavBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentIndex != widget.currentIndex) {
      _pageController.animateToPage(
        widget.currentIndex,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOutCubic,
      );
    }
  }

  Color _getNavBarTint(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark
        ? const Color(0xFF1E1E1E).withValues(alpha: 0.95)  // Dark gray/black in dark mode
        : Colors.white.withValues(alpha: 0.9);  // White in light mode
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final orientation = MediaQuery.of(context).orientation;
    final isMobile = screenWidth < 600;
    final isTablet = screenWidth >= 600 && screenWidth < 1200;
    final isLandscape = orientation == Orientation.landscape;

    // Wider on tablets, full width on phones and desktop
    final effectiveMaxWidth = isMobile
        ? double.infinity  // Phone: full width with padding
        : isTablet
            ? screenWidth * 0.7  // Tablet: 70% of screen width
            : 600.0;  // Desktop: fixed 600px

    final navBarHeight = isLandscape ? 70.0 : 80.0;  // Nav bar height
    final baseIconSize = isLandscape ? 22.0 : 24.0;  // Smaller icon size

    return Padding(
      padding: EdgeInsets.only(
        left: isMobile ? 16 : 24,
        right: isMobile ? 16 : 24,
        bottom: 16,
      ),
      child: Center(
        child: SizedBox(
          width: effectiveMaxWidth,
          height: navBarHeight,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              // Glass background
              GlassCard(
                intensity: GlassIntensity.nav,
                tintColor: _getNavBarTint(context),
                borderRadius: BorderRadius.circular(28),
                padding: EdgeInsets.zero,
                height: navBarHeight,
                child: const SizedBox.expand(),
              ),

              // PageView with icons
              PageView.builder(
                controller: _pageController,
                itemCount: widget.items.length,
                onPageChanged: widget.onItemSelected,
                itemBuilder: (context, index) {
                  return _buildNavIcon(
                    item: widget.items[index],
                    index: index,
                    baseIconSize: baseIconSize,
                  );
                },
              ),

              // Fixed center circle with inner glow
              Positioned(
                left: 0,
                right: 0,
                top: 0,
                bottom: 0,
                child: IgnorePointer(
                  child: Center(
                    child: Container(
                      width: 58,
                      height: 58,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppConstants.limeGreen.withValues(alpha: 0.15),
                        border: Border.all(
                          color: AppConstants.limeGreen.withValues(alpha: 0.5),
                          width: 2,
                        ),
                        boxShadow: [
                          // Inner glow effect (inset shadow simulation)
                          BoxShadow(
                            color: AppConstants.limeGreen.withValues(alpha: 0.2),
                            blurRadius: 12,
                            spreadRadius: -4,
                            offset: const Offset(0, 0),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavIcon({
    required NavigationItem item,
    required int index,
    required double baseIconSize,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Calculate distance from center for scaling
    final distance = (_currentPage - index).abs();
    final isSelected = distance < 0.5; // Icon is at center position
    final scale = 1.0 + (1.0 - distance.clamp(0.0, 1.0)) * 0.5; // 1.0x to 1.5x
    final opacity = 0.6 + (1.0 - distance.clamp(0.0, 1.0)) * 0.4; // 60% to 100%

    return GestureDetector(
      onTap: () => widget.onItemSelected(index),
      child: Transform.scale(
        scale: scale,
        child: Opacity(
            opacity: opacity,
            child: Center(
              child: isSelected
                  // Selected icon: Show full colors without filtering
                  ? Image.asset(
                      item.iconPath,
                      width: baseIconSize,
                      height: baseIconSize,
                      filterQuality: FilterQuality.high,
                      errorBuilder: (context, error, stackTrace) {
                        return Icon(
                          Icons.circle,
                          size: baseIconSize,
                          color: AppConstants.limeGreen,
                        );
                      },
                    )
                  // Unselected icons: Apply color filter (monochrome)
                  : ColorFiltered(
                      colorFilter: ColorFilter.mode(
                        isDark
                            ? Colors.white.withValues(alpha: 0.5)
                            : AppConstants.darkGreen.withValues(alpha: 0.4),
                        BlendMode.srcIn,
                      ),
                      child: Image.asset(
                        item.iconPath,
                        width: baseIconSize,
                        height: baseIconSize,
                        filterQuality: FilterQuality.high,
                        errorBuilder: (context, error, stackTrace) {
                          return Icon(
                            Icons.circle,
                            size: baseIconSize,
                            color: isDark ? Colors.white : AppConstants.darkGreen,
                          );
                        },
                      ),
                    ),
            ),
          ),
      ),
    );
  }
}
