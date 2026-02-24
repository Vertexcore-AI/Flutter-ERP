import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/buyer_model.dart';
import '../config/design_system.dart';
import '../constants/app_constants.dart';
import 'glass_card.dart';

/// Buyer Card Widget
/// Displays a single buyer with glass morphism design
class BuyerCard extends StatelessWidget {
  final Buyer buyer;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onTap;

  const BuyerCard({
    super.key,
    required this.buyer,
    this.onEdit,
    this.onDelete,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(DesignSystem.radiusMd),
          border: Border(
            left: BorderSide(
              color: AppConstants.limeGreen,
              width: 4,
            ),
          ),
        ),
        child: GlassCard(
          intensity: GlassIntensity.medium,
          padding: const EdgeInsets.all(16),
          borderRadius: BorderRadius.circular(DesignSystem.radiusMd),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Top Row: Name + Action Buttons
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Buyer Name
                        Text(
                          buyer.name,
                          style: DesignSystem.text(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: isDark
                                ? AppConstants.lightSage
                                : AppConstants.darkGreen,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),

                        // Location
                        Row(
                          children: [
                            Icon(
                              Icons.location_on_outlined,
                              size: 16,
                              color: isDark
                                  ? AppConstants.lightSage.withValues(alpha: 0.7)
                                  : AppConstants.darkGreen.withValues(alpha: 0.7),
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                buyer.formattedLocation(),
                                style: DesignSystem.text(
                                  fontSize: 14,
                                  color: isDark
                                      ? AppConstants.lightSage.withValues(alpha: 0.8)
                                      : AppConstants.darkGreen.withValues(alpha: 0.8),
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),

                        // Postal Code (if available)
                        if (buyer.postalCode != null && buyer.postalCode!.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(
                                Icons.mail_outline,
                                size: 16,
                                color: isDark
                                    ? AppConstants.lightSage.withValues(alpha: 0.7)
                                    : AppConstants.darkGreen.withValues(alpha: 0.7),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                buyer.postalCode!,
                                style: DesignSystem.text(
                                  fontSize: 13,
                                  color: isDark
                                      ? AppConstants.lightSage.withValues(alpha: 0.7)
                                      : AppConstants.darkGreen.withValues(alpha: 0.7),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),

                  // Action Buttons
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Edit Button
                      if (onEdit != null)
                        GestureDetector(
                          onTap: () {
                            HapticFeedback.lightImpact();
                            onEdit?.call();
                          },
                          child: Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: AppConstants.limeGreen.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: AppConstants.limeGreen.withValues(alpha: 0.3),
                                width: 1,
                              ),
                            ),
                            child: Icon(
                              Icons.edit_outlined,
                              size: 18,
                              color: AppConstants.limeGreen,
                            ),
                          ),
                        ),

                      if (onEdit != null && onDelete != null)
                        const SizedBox(height: 8),

                      // Delete Button
                      if (onDelete != null)
                        GestureDetector(
                          onTap: () {
                            HapticFeedback.lightImpact();
                            onDelete?.call();
                          },
                          child: Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: Colors.red.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: Colors.red.withValues(alpha: 0.3),
                                width: 1,
                              ),
                            ),
                            child: const Icon(
                              Icons.delete_outline,
                              size: 18,
                              color: Colors.red,
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),

              // Coordinates indicator (if available)
              if (buyer.hasCoordinates()) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppConstants.forestGreen.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: AppConstants.forestGreen.withValues(alpha: 0.3),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.my_location,
                        size: 12,
                        color: AppConstants.forestGreen,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Location saved',
                        style: DesignSystem.text(
                          fontSize: 11,
                          color: AppConstants.forestGreen,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
