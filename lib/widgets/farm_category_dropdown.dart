import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class FarmCategoryDropdown extends StatelessWidget {
  final String label;
  final String value;
  final List<String> items;
  final Function(String?) onChanged;
  final IconData icon;

  const FarmCategoryDropdown({
    super.key,
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
    this.icon = Icons.category_outlined,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.spaceGrotesk(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: isDark ? Colors.white70 : Colors.grey[700],
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDark ? Colors.white24 : Colors.grey[200]!,
            ),
          ),
          child: DropdownButtonFormField<String>(
            initialValue: value,
            items: items.map((item) {
              return DropdownMenuItem(
                value: item,
                child: Text(
                  item,
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 15,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
              );
            }).toList(),
            onChanged: onChanged,
            decoration: InputDecoration(
              prefixIcon: Icon(
                icon,
                color: isDark ? Colors.white54 : Colors.grey[400],
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
            ),
            dropdownColor: isDark ? const Color(0xFF1a1a16) : Colors.white,
            icon: Icon(
              Icons.arrow_drop_down,
              color: isDark ? Colors.white54 : Colors.grey[400],
            ),
          ),
        ),
      ],
    );
  }
}
