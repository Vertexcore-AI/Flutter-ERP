import 'package:flutter/material.dart';
import '../config/design_system.dart';
import '../constants/app_constants.dart';
import 'glass_card.dart';

class InventoryStatCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color bgColor;
  final String category;
  final int itemCount;
  final double totalQuantity;
  final VoidCallback onTap;

  const InventoryStatCard({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.bgColor,
    required this.category,
    required this.itemCount,
    required this.totalQuantity,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: GlassCard(
        intensity: GlassIntensity.medium,
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                iconColor.withValues(alpha: 0.08),
                Colors.transparent,
              ],
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icon and item count row
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: bgColor,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: iconColor.withValues(alpha: 0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Icon(
                      icon,
                      size: 28,
                      color: iconColor,
                    ),
                  ),
                  const Spacer(),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        itemCount.toString(),
                        style: DesignSystem.heading(
                          fontSize: 28,
                          fontWeight: FontWeight.w900,
                          color: iconColor,
                        ),
                      ),
                      Text(
                        'ITEMS',
                        style: DesignSystem.text(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.0,
                          color: isDark
                              ? Colors.white.withValues(alpha: 0.6)
                              : Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Category name
              Text(
                category.toUpperCase(),
                style: DesignSystem.heading(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  color: isDark ? Colors.white : Colors.black87,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),

              // Total stock info
              Row(
                children: [
                  Icon(
                    Icons.inventory_2,
                    size: 14,
                    color: AppConstants.limeGreen,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'Stock: ${totalQuantity.toStringAsFixed(0)} units',
                      style: DesignSystem.text(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.7)
                            : Colors.grey[700],
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward,
                    size: 16,
                    color: AppConstants.limeGreen,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
