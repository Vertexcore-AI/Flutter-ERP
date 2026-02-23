import 'package:flutter/material.dart';
import '../config/design_system.dart';
import '../models/inventory_item_model.dart';

class InventorySelector extends StatelessWidget {
  final int? selectedId;
  final List<InventoryItem> items;
  final String label;
  final String hint;
  final ValueChanged<int?> onChanged;
  final FormFieldValidator<int?>? validator;
  final bool isDark;

  const InventorySelector({
    super.key,
    required this.selectedId,
    required this.items,
    required this.label,
    required this.hint,
    required this.onChanged,
    required this.isDark,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: DesignSystem.text(
            fontSize: 10,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.0,
            color: isDark
                ? Colors.white.withValues(alpha: 0.6)
                : Colors.grey[600],
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<int>(
          initialValue: selectedId,
          decoration: InputDecoration(
            hintText: hint,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
          items: items.map((item) {
            final isLowStock = item.quantityAvailable < 10;
            return DropdownMenuItem<int>(
              value: item.id,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    item.itemName,
                    style: DesignSystem.heading(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Text(
                        'Available: ${item.quantityAvailable.toStringAsFixed(2)} ${item.unit}',
                        style: DesignSystem.text(
                          fontSize: 11,
                          color: isLowStock
                              ? Colors.orange
                              : (isDark ? Colors.white60 : Colors.grey[600]),
                        ),
                      ),
                      if (isLowStock) ...[
                        const SizedBox(width: 4),
                        const Icon(
                          Icons.warning,
                          size: 12,
                          color: Colors.orange,
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            );
          }).toList(),
          onChanged: onChanged,
          validator: validator,
          isExpanded: true,
        ),
      ],
    );
  }
}
