import 'package:flutter/material.dart';
import '../config/design_system.dart';
import '../constants/app_constants.dart';

class StockImpactDisplay extends StatelessWidget {
  final double currentStock;
  final double usedAmount;
  final String unit;

  const StockImpactDisplay({
    super.key,
    required this.currentStock,
    required this.usedAmount,
    required this.unit,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final remainingStock = currentStock - usedAmount;
    final isInsufficient = remainingStock < 0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isInsufficient
            ? Colors.red.withValues(alpha: 0.1)
            : AppConstants.limeGreen.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isInsufficient
              ? Colors.red.withValues(alpha: 0.3)
              : AppConstants.limeGreen.withValues(alpha: 0.3),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Icon(
                isInsufficient
                    ? Icons.warning_rounded
                    : Icons.check_circle_rounded,
                size: 18,
                color: isInsufficient ? Colors.red : AppConstants.forestGreen,
              ),
              const SizedBox(width: 8),
              Text(
                'Stock Impact',
                style: DesignSystem.text(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white70 : Colors.black54,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Stock display
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Current stock
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'CURRENT',
                    style: DesignSystem.text(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white54 : Colors.black38,
                      letterSpacing: 1.0,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${currentStock.toStringAsFixed(2)} $unit',
                    style: DesignSystem.text(
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                ],
              ),

              // Arrow
              Icon(
                Icons.arrow_forward_rounded,
                size: 20,
                color: isDark ? Colors.white38 : Colors.black26,
              ),

              // After use
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'AFTER USE',
                    style: DesignSystem.text(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white54 : Colors.black38,
                      letterSpacing: 1.0,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${remainingStock.toStringAsFixed(2)} $unit',
                    style: DesignSystem.text(
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      color: isInsufficient
                          ? Colors.red
                          : AppConstants.forestGreen,
                    ),
                  ),
                ],
              ),
            ],
          ),

          // Warning message if insufficient
          if (isInsufficient) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.error_outline,
                    size: 16,
                    color: Colors.red,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Insufficient stock: ${currentStock.toStringAsFixed(2)} $unit available, ${usedAmount.toStringAsFixed(2)} $unit required',
                      style: DesignSystem.text(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Colors.red,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
