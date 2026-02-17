import 'package:flutter/material.dart';
import '../models/crop_model.dart';
import '../config/design_system.dart';
import '../constants/app_constants.dart';
import 'glass_card.dart';

class CropCard extends StatelessWidget {
  final Crop crop;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback? onTap;

  const CropCard({
    super.key,
    required this.crop,
    required this.onEdit,
    required this.onDelete,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GlassCard(
      padding: EdgeInsets.zero,
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Crop Image from Perenual API
            if (crop.cropImageUrl != null) ...[
              AspectRatio(
                aspectRatio: 16 / 9,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    crop.cropImageUrl!,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Container(
                        color: isDark ? Colors.grey[800] : Colors.grey[200],
                        child: Center(
                          child: CircularProgressIndicator(
                            value: loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded /
                                    loadingProgress.expectedTotalBytes!
                                : null,
                            color: AppConstants.limeGreen,
                            strokeWidth: 2,
                          ),
                        ),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        decoration: BoxDecoration(
                          color: isDark ? Colors.grey[800] : Colors.grey[200],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: Icon(
                            Icons.image_not_supported_outlined,
                            size: 48,
                            color: Colors.grey[600],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Crop Type (Main Title) with Action Buttons
            Row(
              children: [
                Expanded(
                  child: Text(
                    crop.cropType,
                    style: DesignSystem.text(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                IconButton(
                  onPressed: onEdit,
                  icon: const Icon(Icons.edit_outlined, size: 18),
                  color: isDark ? Colors.white70 : Colors.grey[600],
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  visualDensity: VisualDensity.compact,
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: onDelete,
                  icon: const Icon(Icons.delete_outline, size: 18),
                  color: Colors.red[400],
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  visualDensity: VisualDensity.compact,
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Status Badge
            GlassBadge(
              text: crop.status.toUpperCase(),
              color: crop.statusColor,
            ),
            const SizedBox(height: 8),

            // Farm Name
            Text(
              crop.displayFarm,
              style: DesignSystem.text(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppConstants.limeGreen,
              ),
            ),
            const SizedBox(height: 16),

            // Details Divider
            Container(
              height: 1,
              color: isDark
                  ? Colors.white.withValues(alpha: 0.1)
                  : Colors.grey[200],
            ),
            const SizedBox(height: 16),

            // Planting Date
            _buildInfoRow(
              icon: Icons.calendar_today_outlined,
              label: 'Planted: ${crop.formattedStartDate}',
              isDark: isDark,
            ),

            // Expected Harvest Date (if available)
            if (crop.expectedHarvestDate != null) ...[
              const SizedBox(height: 12),
              _buildInfoRow(
                icon: Icons.event_outlined,
                label: 'Harvest: ${crop.formattedExpectedHarvestDate}',
                isDark: isDark,
                iconColor: AppConstants.forestGreen,
              ),
            ],

            // Days Until Harvest (if available)
            if (crop.daysUntilHarvest != null) ...[
              const SizedBox(height: 12),
              _buildInfoRow(
                icon: Icons.access_time_outlined,
                label: crop.daysUntilHarvest! > 0
                    ? '${crop.daysUntilHarvest} days left'
                    : crop.daysUntilHarvest == 0
                        ? 'Harvest today!'
                        : '${crop.daysUntilHarvest!.abs()} days overdue',
                isDark: isDark,
                iconColor: crop.daysUntilHarvest! < 0
                    ? Colors.red[400]
                    : AppConstants.olive,
              ),
            ],

            // Number of Plants
            const SizedBox(height: 12),
            _buildInfoRow(
              icon: Icons.local_florist_outlined,
              label: '${crop.plants} Plants',
              isDark: isDark,
            ),

            // Area and Category (if available)
            if (crop.area != null && crop.category != null) ...[
              const SizedBox(height: 12),
              _buildInfoRow(
                icon: Icons.square_foot_outlined,
                label: crop.displayArea,
                isDark: isDark,
              ),
            ],

            // Water Usage (if available)
            if (crop.totalWaterUsed != null && crop.totalWaterUsed! > 0) ...[
              const SizedBox(height: 12),
              _buildInfoRow(
                icon: Icons.water_drop_outlined,
                label: '${crop.totalWaterUsed!.toStringAsFixed(0)} L water used',
                isDark: isDark,
                iconColor: Colors.blue[400],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required bool isDark,
    Color? iconColor,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: iconColor ?? (isDark ? Colors.white54 : Colors.grey[600]),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            style: DesignSystem.text(
              fontSize: 13,
              color: isDark ? Colors.white70 : Colors.grey[700],
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
