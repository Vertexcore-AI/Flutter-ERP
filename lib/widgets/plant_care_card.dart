import 'package:flutter/material.dart';
import '../config/design_system.dart';
import '../models/crop_model.dart';
import '../constants/app_constants.dart';
import 'glass_card.dart';

class PlantCareCard extends StatelessWidget {
  final Crop crop;

  const PlantCareCard({super.key, required this.crop});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final careData = crop.perenualData;

    if (careData == null) {
      return const SizedBox.shrink();
    }

    return GlassCard(
      intensity: GlassIntensity.medium,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppConstants.limeGreen.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Text(
                    '🌱',
                    style: TextStyle(fontSize: 20),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Care Instructions',
                  style: DesignSystem.heading(
                    fontSize: 18,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Scientific Name
            if (crop.scientificName != null) ...[
              _buildCareItem(
                icon: '🔬',
                label: 'Scientific Name',
                value: crop.scientificName!,
                isDark: isDark,
              ),
            ],

            // Watering
            if (crop.wateringFrequency != null) ...[
              _buildCareItem(
                icon: '💧',
                label: 'Watering',
                value: _formatCamelCase(crop.wateringFrequency!),
                isDark: isDark,
              ),
            ],

            // Sunlight
            if (crop.sunlightNeeds != null && crop.sunlightNeeds!.isNotEmpty) ...[
              _buildCareItem(
                icon: '☀️',
                label: 'Sunlight',
                value: crop.sunlightNeeds!
                    .map((s) => _formatCamelCase(s))
                    .join(', '),
                isDark: isDark,
              ),
            ],

            // Soil Types
            if (crop.soilTypes != null && crop.soilTypes!.isNotEmpty) ...[
              _buildCareItem(
                icon: '🌍',
                label: 'Soil Types',
                value: crop.soilTypes!
                    .map((s) => _formatCamelCase(s))
                    .join(', '),
                isDark: isDark,
              ),
            ],

            // Growth Rate
            if (crop.growthRate != null) ...[
              _buildCareItem(
                icon: '📈',
                label: 'Growth Rate',
                value: _formatCamelCase(crop.growthRate!),
                isDark: isDark,
              ),
            ],

            // Care Level
            if (crop.careLevel != null) ...[
              _buildCareItem(
                icon: '🎯',
                label: 'Care Level',
                value: _formatCamelCase(crop.careLevel!),
                isDark: isDark,
              ),
            ],

            // Edibility Info
            if (crop.isEdible == true) ...[
              _buildCareItem(
                icon: '🍽️',
                label: 'Edible',
                value: 'Yes - Produces edible fruit',
                isDark: isDark,
              ),
            ],

            // Safety Warning
            if (crop.isPoisonous == true) ...[
              _buildCareItem(
                icon: '⚠️',
                label: 'Warning',
                value: 'Poisonous to humans',
                isDark: isDark,
                isWarning: true,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildCareItem({
    required String icon,
    required String label,
    required String value,
    required bool isDark,
    bool isWarning = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(icon, style: const TextStyle(fontSize: 24)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: DesignSystem.text(
                    fontSize: 12,
                    color: isDark ? Colors.white60 : Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: DesignSystem.text(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: isWarning
                        ? Colors.red[400]
                        : (isDark ? Colors.white : Colors.black87),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Helper to format camelCase or snake_case to Title Case
  String _formatCamelCase(String text) {
    // Handle snake_case
    if (text.contains('_')) {
      return text
          .split('_')
          .map((word) =>
              word.isEmpty ? '' : word[0].toUpperCase() + word.substring(1))
          .join(' ');
    }

    // Handle camelCase
    final result = text.replaceAllMapped(
      RegExp(r'([A-Z])'),
      (match) => ' ${match.group(0)}',
    );
    return result.trim()[0].toUpperCase() + result.trim().substring(1);
  }
}
