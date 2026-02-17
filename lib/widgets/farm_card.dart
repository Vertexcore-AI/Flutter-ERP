import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/farm_model.dart';
import '../constants/app_constants.dart';
import 'glass_card.dart';

class FarmCard extends StatelessWidget {
  final Farm farm;
  final String baseUrl;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback? onTap;

  const FarmCard({
    super.key,
    required this.farm,
    required this.baseUrl,
    required this.onEdit,
    required this.onDelete,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final imageUrl = farm.getImageUrl(baseUrl);

    return GlassCard(
      padding: EdgeInsets.zero,
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Farm Image (if available)
          if (imageUrl != null)
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
              child: SizedBox(
                height: 10,
                width: double.infinity,
                child: CachedNetworkImage(
                  imageUrl: imageUrl,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.05)
                        : Colors.grey[200],
                    child: const Center(
                      child: CircularProgressIndicator(
                        color: AppConstants.limeGreen,
                        strokeWidth: 2,
                      ),
                    ),
                  ),
                  errorWidget: (context, url, error) => Container(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.05)
                        : Colors.grey[200],
                    child: Icon(
                      Icons.broken_image_outlined,
                      size: 48,
                      color: isDark ? Colors.white24 : Colors.grey[400],
                    ),
                  ),
                ),
              ),
            ),

          // Card Content
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header: Icon and Actions
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppConstants.limeGreen.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.agriculture_outlined,
                        color: AppConstants.limeGreen,
                        size: 24,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: onEdit,
                      icon: const Icon(Icons.edit_outlined, size: 20),
                      color: isDark ? Colors.white70 : Colors.grey[600],
                    ),
                    IconButton(
                      onPressed: onDelete,
                      icon: const Icon(Icons.delete_outline, size: 20),
                      color: Colors.red[400],
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Farm Name
                Text(
                  farm.name,
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),

                // Main Category Badge
                GlassBadge(
                  text: farm.mainCategory.toUpperCase(),
                  color: isDark
                      ? AppConstants.lightSage
                      : AppConstants.darkGreen,
                ),
                const SizedBox(height: 8),

                // Sub Category
                Text(
                  farm.category,
                  style: GoogleFonts.spaceGrotesk(
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

                // Area Info
                _buildInfoRow(
                  icon: Icons.square_foot_outlined,
                  label: farm.displayArea,
                  isDark: isDark,
                ),

                // Location (if available)
                if (farm.location != null && farm.location!.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  _buildInfoRow(
                    icon: Icons.place_outlined,
                    label: farm.location!,
                    isDark: isDark,
                  ),
                ],

                // Crops Count
                const SizedBox(height: 12),
                _buildInfoRow(
                  icon: Icons.eco_outlined,
                  label: '${farm.cropsCount ?? 0} Active Crops',
                  isDark: isDark,
                  iconColor: AppConstants.forestGreen,
                ),
              ],
            ),
          ),
        ],
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
            style: GoogleFonts.spaceGrotesk(
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
