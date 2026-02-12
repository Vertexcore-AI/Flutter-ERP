import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/dashboard_models.dart';

class FieldInfoCard extends StatelessWidget {
  final FieldInfo field;

  const FieldInfoCard({super.key, required this.field});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Field Image
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(16),
              topRight: Radius.circular(16),
            ),
            child: Image.asset(
              field.imagePath,
              height: 160,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  height: 160,
                  color: isDark ? Colors.grey[800] : Colors.grey[300],
                  child: const Center(
                    child: Icon(Icons.image, size: 50),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Field Selector
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: isDark ? Colors.white24 : Colors.grey[300]!,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        field.name,
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                      Icon(
                        Icons.keyboard_arrow_down,
                        size: 20,
                        color: isDark ? Colors.white70 : Colors.grey[600],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                // Field Info Rows
                _buildInfoRow(
                  context,
                  label: 'Crop Health',
                  value: field.cropHealth,
                  isGood: field.cropHealth == 'Good',
                ),
                const SizedBox(height: 12),
                _buildInfoRow(
                  context,
                  label: 'Planting Date',
                  value: field.plantingDate,
                ),
                const SizedBox(height: 12),
                _buildInfoRow(
                  context,
                  label: 'Pesticide Use',
                  value: field.pesticideUse,
                ),
                const SizedBox(height: 16),
                // More Details Button
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {},
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'More Details',
                          style: GoogleFonts.spaceGrotesk(fontSize: 12),
                        ),
                        const Icon(Icons.arrow_forward, size: 16),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(
    BuildContext context, {
    required String label,
    required String value,
    bool isGood = false,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.spaceGrotesk(
            fontSize: 13,
            color: isDark ? Colors.white70 : Colors.grey[600],
          ),
        ),
        Row(
          children: [
            if (isGood)
              Container(
                width: 8,
                height: 8,
                margin: const EdgeInsets.only(right: 6),
                decoration: const BoxDecoration(
                  color: Colors.green,
                  shape: BoxShape.circle,
                ),
              ),
            Text(
              value,
              style: GoogleFonts.spaceGrotesk(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
