import 'package:flutter/material.dart';
import '../config/design_system.dart';
import '../constants/app_constants.dart';

class ApplicationTypeToggle extends StatelessWidget {
  final String selectedType;
  final Function(String) onChanged;

  const ApplicationTypeToggle({
    super.key,
    required this.selectedType,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.05)
            : Colors.black.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.1)
              : Colors.black.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          _buildOption(context, 'BY_PLANT', 'By Plant', isDark),
          _buildOption(context, 'ENTIRE_CROP', 'Entire Crop', isDark),
        ],
      ),
    );
  }

  Widget _buildOption(
      BuildContext context, String value, String label, bool isDark) {
    final isSelected = selectedType == value;

    return Expanded(
      child: GestureDetector(
        onTap: () => onChanged(value),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: isSelected
                ? AppConstants.limeGreen
                : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: Text(
              label,
              style: DesignSystem.text(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: isSelected
                    ? Colors.white
                    : (isDark ? Colors.white70 : Colors.black54),
                letterSpacing: 0.5,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
