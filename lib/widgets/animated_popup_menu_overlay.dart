import 'dart:ui';
import 'package:flutter/material.dart';
import '../config/design_system.dart';
import '../constants/app_constants.dart';
import 'popup_menu_item_widget.dart';
import '../screens/resource_management/water_log_form_screen.dart';
import '../screens/resource_management/fertilizer_log_form_screen.dart';
import '../screens/resource_management/pesticide_log_form_screen.dart';
import '../screens/resource_management/fungicide_log_form_screen.dart';

class AnimatedPopupMenuOverlay extends StatefulWidget {
  final int cropCycleId;
  final String cropName;

  const AnimatedPopupMenuOverlay({
    super.key,
    required this.cropCycleId,
    required this.cropName,
  });

  @override
  State<AnimatedPopupMenuOverlay> createState() =>
      _AnimatedPopupMenuOverlayState();
}

class _AnimatedPopupMenuOverlayState extends State<AnimatedPopupMenuOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _backgroundAnimation;
  late Animation<double> _containerScaleAnimation;
  late Animation<double> _containerOpacityAnimation;

  // Water animations
  late Animation<Offset> _waterSlideAnimation;
  late Animation<double> _waterFadeAnimation;

  // Fertilizer animations
  late Animation<Offset> _fertilizerSlideAnimation;
  late Animation<double> _fertilizerFadeAnimation;

  // Pesticide animations
  late Animation<Offset> _pesticideSlideAnimation;
  late Animation<double> _pesticideFadeAnimation;

  // Fungicide animations
  late Animation<Offset> _fungicideSlideAnimation;
  late Animation<double> _fungicideFadeAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 700),
      vsync: this,
    );

    // Background blur fade-in (0-200ms)
    _backgroundAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.286, curve: Curves.easeInCubic),
      ),
    );

    // Container scale (100-400ms)
    _containerScaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.143, 0.571, curve: Curves.easeOutBack),
      ),
    );

    // Container opacity (100-400ms)
    _containerOpacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.143, 0.571, curve: Curves.easeOut),
      ),
    );

    // Water item (200-450ms - Interval 0.286, 0.643)
    _waterSlideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.286, 0.643, curve: Curves.easeOutCubic),
      ),
    );
    _waterFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.286, 0.643, curve: Curves.easeOut),
      ),
    );

    // Fertilizer item (280-530ms - Interval 0.400, 0.757)
    _fertilizerSlideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.400, 0.757, curve: Curves.easeOutCubic),
      ),
    );
    _fertilizerFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.400, 0.757, curve: Curves.easeOut),
      ),
    );

    // Pesticide item (360-610ms - Interval 0.514, 0.871)
    _pesticideSlideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.514, 0.871, curve: Curves.easeOutCubic),
      ),
    );
    _pesticideFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.514, 0.871, curve: Curves.easeOut),
      ),
    );

    // Fungicide item (440-690ms - Interval 0.629, 0.986)
    _fungicideSlideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.629, 0.986, curve: Curves.easeOutCubic),
      ),
    );
    _fungicideFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.629, 0.986, curve: Curves.easeOut),
      ),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _handleClose() async {
    await _controller.reverse();
    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  void _handleMenuItemTap(String resourceType) async {
    // Close menu with animation
    await _handleClose();

    if (!mounted) return;

    // Navigate to appropriate form screen
    Widget? formScreen;

    switch (resourceType) {
      case 'Water':
        formScreen = WaterLogFormScreen(
          cropCycleId: widget.cropCycleId,
          cropName: widget.cropName,
        );
        break;
      case 'Fertilizer':
        formScreen = FertilizerLogFormScreen(
          cropCycleId: widget.cropCycleId,
          cropName: widget.cropName,
        );
        break;
      case 'Pesticide':
        formScreen = PesticideLogFormScreen(
          cropCycleId: widget.cropCycleId,
          cropName: widget.cropName,
        );
        break;
      case 'Fungicide':
        formScreen = FungicideLogFormScreen(
          cropCycleId: widget.cropCycleId,
          cropName: widget.cropName,
        );
        break;
    }

    if (formScreen != null && mounted) {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (context) => formScreen!),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (!didPop) {
          await _handleClose();
        }
      },
      child: Material(
        type: MaterialType.transparency,
        child: Stack(
          children: [
            // Animated blurred background
            AnimatedBuilder(
              animation: _backgroundAnimation,
              builder: (context, child) {
                return BackdropFilter(
                  filter: ImageFilter.blur(
                    sigmaX: 10 * _backgroundAnimation.value,
                    sigmaY: 10 * _backgroundAnimation.value,
                  ),
                  child: Container(
                    color: Colors.black
                        .withValues(alpha: 0.6 * _backgroundAnimation.value),
                  ),
                );
              },
            ),

            // Tap to close
            GestureDetector(
              onTap: _handleClose,
              behavior: HitTestBehavior.opaque,
            ),

            // Menu content (centered)
            Center(
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  return ScaleTransition(
                    scale: _containerScaleAnimation,
                    child: FadeTransition(
                      opacity: _containerOpacityAnimation,
                      child: _buildMenuContent(),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuContent() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 600;

        return Container(
          constraints: BoxConstraints(
            maxWidth: isMobile ? constraints.maxWidth - 48 : 600,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Crop name header
              Text(
                'MANAGE ${widget.cropName.toUpperCase()}',
                style: DesignSystem.text(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                  color: AppConstants.limeGreen,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),

              // Menu items
              if (isMobile)
                _buildMobileGrid()
              else
                _buildDesktopRow(),

              const SizedBox(height: 48),

              // Close button
              _buildCloseButton(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMobileGrid() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        PopupMenuItemWidget(
          label: 'Water',
          icon: Icons.water_drop,
          color: Colors.blue.shade600,
          onTap: () => _handleMenuItemTap('Water'),
          slideAnimation: _waterSlideAnimation,
          fadeAnimation: _waterFadeAnimation,
        ),
        const SizedBox(height: 24),
        PopupMenuItemWidget(
          label: 'Fertilizer',
          icon: Icons.local_florist,
          color: Colors.orange.shade600,
          onTap: () => _handleMenuItemTap('Fertilizer'),
          slideAnimation: _fertilizerSlideAnimation,
          fadeAnimation: _fertilizerFadeAnimation,
        ),
        const SizedBox(height: 24),
        PopupMenuItemWidget(
          label: 'Pesticide',
          icon: Icons.bug_report,
          color: Colors.purple.shade600,
          onTap: () => _handleMenuItemTap('Pesticide'),
          slideAnimation: _pesticideSlideAnimation,
          fadeAnimation: _pesticideFadeAnimation,
        ),
        const SizedBox(height: 24),
        PopupMenuItemWidget(
          label: 'Fungicide',
          icon: Icons.spa,
          color: Colors.red.shade600,
          onTap: () => _handleMenuItemTap('Fungicide'),
          slideAnimation: _fungicideSlideAnimation,
          fadeAnimation: _fungicideFadeAnimation,
        ),
      ],
    );
  }

  Widget _buildDesktopRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        PopupMenuItemWidget(
          label: 'Water',
          icon: Icons.water_drop,
          color: Colors.blue.shade600,
          onTap: () => _handleMenuItemTap('Water'),
          slideAnimation: _waterSlideAnimation,
          fadeAnimation: _waterFadeAnimation,
        ),
        const SizedBox(width: 32),
        PopupMenuItemWidget(
          label: 'Fertilizer',
          icon: Icons.local_florist,
          color: Colors.orange.shade600,
          onTap: () => _handleMenuItemTap('Fertilizer'),
          slideAnimation: _fertilizerSlideAnimation,
          fadeAnimation: _fertilizerFadeAnimation,
        ),
        const SizedBox(width: 32),
        PopupMenuItemWidget(
          label: 'Pesticide',
          icon: Icons.bug_report,
          color: Colors.purple.shade600,
          onTap: () => _handleMenuItemTap('Pesticide'),
          slideAnimation: _pesticideSlideAnimation,
          fadeAnimation: _pesticideFadeAnimation,
        ),
        const SizedBox(width: 32),
        PopupMenuItemWidget(
          label: 'Fungicide',
          icon: Icons.spa,
          color: Colors.red.shade600,
          onTap: () => _handleMenuItemTap('Fungicide'),
          slideAnimation: _fungicideSlideAnimation,
          fadeAnimation: _fungicideFadeAnimation,
        ),
      ],
    );
  }

  Widget _buildCloseButton() {
    return GestureDetector(
      onTap: _handleClose,
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppConstants.limeGreen,
          boxShadow: [
            BoxShadow(
              color: AppConstants.limeGreen.withValues(alpha: 0.4),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: const Icon(
          Icons.close,
          size: 28,
          color: Colors.white,
        ),
      ),
    );
  }
}
