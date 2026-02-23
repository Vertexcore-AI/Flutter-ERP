import 'dart:ui';
import 'package:flutter/material.dart';
import '../constants/app_constants.dart';
import 'animated_popup_menu_overlay.dart';

class CropCycleMenuButton extends StatelessWidget {
  final int cropCycleId;
  final String cropName;

  const CropCycleMenuButton({
    super.key,
    required this.cropCycleId,
    required this.cropName,
  });

  void _openMenu(BuildContext context) {
    Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        barrierDismissible: false,
        pageBuilder: (context, animation, secondaryAnimation) {
          return AnimatedPopupMenuOverlay(
            cropCycleId: cropCycleId,
            cropName: cropName,
          );
        },
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          // No transition animation - the overlay handles its own animations
          return child;
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _openMenu(context),
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppConstants.limeGreen.withValues(alpha: 0.1),
          border: Border.all(
            color: AppConstants.limeGreen.withValues(alpha: 0.3),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: AppConstants.limeGreen.withValues(alpha: 0.2),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ClipOval(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Center(
              child: Icon(
                Icons.more_vert,
                size: 20,
                color: AppConstants.limeGreen,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
