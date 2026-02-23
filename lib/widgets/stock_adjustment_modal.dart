import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/design_system.dart';
import '../constants/app_constants.dart';
import '../models/inventory_item_model.dart';
import '../providers/inventory_provider.dart';
import '../services/secure_storage_service.dart';
import 'glass_card.dart';

class StockAdjustmentModal extends StatefulWidget {
  final InventoryItem item;
  final VoidCallback onSuccess;

  const StockAdjustmentModal({
    super.key,
    required this.item,
    required this.onSuccess,
  });

  @override
  State<StockAdjustmentModal> createState() => _StockAdjustmentModalState();
}

class _StockAdjustmentModalState extends State<StockAdjustmentModal> {
  final _formKey = GlobalKey<FormState>();
  final _secureStorage = SecureStorageService();

  String _adjustmentType = 'INCREASE';
  String _quantity = '';
  String _reason = 'Correction';
  String _notes = '';
  DateTime _selectedDate = DateTime.now();

  final List<String> _reasons = [
    'Correction',
    'Damage',
    'Loss',
    'Return',
    'Found Stock',
    'Expiry',
    'Usage recorded late',
  ];

  double get _currentStock => widget.item.quantityAvailable.toDouble();

  double get _adjustmentQuantity {
    final qty = double.tryParse(_quantity) ?? 0;
    return qty;
  }

  double get _newStock {
    if (_adjustmentType == 'INCREASE') {
      return _currentStock + _adjustmentQuantity;
    } else {
      return _currentStock - _adjustmentQuantity;
    }
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final token = await _secureStorage.getAuthToken();
    if (token == null || !mounted) return;

    final inventoryProvider =
        Provider.of<InventoryProvider>(context, listen: false);

    final success = await inventoryProvider.createAdjustment(
      token: token,
      inventoryId: widget.item.id,
      adjustmentType: _adjustmentType,
      quantity: _adjustmentQuantity,
      reason: _reason,
      adjustmentDate:
          '${_selectedDate.year}-${_selectedDate.month.toString().padLeft(2, '0')}-${_selectedDate.day.toString().padLeft(2, '0')}',
      notes: _notes.isEmpty ? null : _notes,
    );

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Stock adjustment recorded successfully'),
            backgroundColor: AppConstants.forestGreen,
          ),
        );
        widget.onSuccess();
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                inventoryProvider.error ?? 'Failed to record adjustment'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _selectDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );

    if (date != null) {
      setState(() {
        _selectedDate = date;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 600),
        child: GlassCard(
          intensity: GlassIntensity.large,
          child: Container(
            padding: const EdgeInsets.all(28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppConstants.limeGreen.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.tune,
                        color: AppConstants.limeGreen,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Adjust Stock',
                            style: DesignSystem.heading(
                              fontSize: 22,
                              fontWeight: FontWeight.w900,
                              color: isDark ? Colors.white : Colors.black87,
                            ),
                          ),
                          Text(
                            widget.item.itemName,
                            style: DesignSystem.text(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: AppConstants.limeGreen,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Icon(
                        Icons.close,
                        color: isDark ? Colors.white60 : Colors.grey[600],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Current stock display
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.05)
                        : AppConstants.lightSage.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppConstants.limeGreen.withValues(alpha: 0.3),
                      width: 2,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'CURRENT STOCK',
                            style: DesignSystem.text(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.0,
                              color: isDark
                                  ? Colors.white.withValues(alpha: 0.6)
                                  : Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${_currentStock.toStringAsFixed(0)} ${widget.item.unit}',
                            style: DesignSystem.heading(
                              fontSize: 24,
                              fontWeight: FontWeight.w900,
                              color: isDark ? Colors.white : Colors.black87,
                            ),
                          ),
                        ],
                      ),
                      if (_quantity.isNotEmpty)
                        Icon(
                          Icons.arrow_forward,
                          color: AppConstants.limeGreen,
                          size: 28,
                        ),
                      if (_quantity.isNotEmpty)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              'NEW STOCK',
                              style: DesignSystem.text(
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 1.0,
                                color: isDark
                                    ? Colors.white.withValues(alpha: 0.6)
                                    : Colors.grey[600],
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${_newStock.toStringAsFixed(0)} ${widget.item.unit}',
                              style: DesignSystem.heading(
                                fontSize: 24,
                                fontWeight: FontWeight.w900,
                                color: _adjustmentType == 'INCREASE'
                                    ? AppConstants.forestGreen
                                    : Colors.orange,
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Form
                Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Adjustment Type
                      Text(
                        'ADJUSTMENT TYPE',
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
                      Row(
                        children: [
                          Expanded(
                            child: _buildTypeButton(
                              'INCREASE',
                              Icons.add_circle_outline,
                              AppConstants.forestGreen,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildTypeButton(
                              'DECREASE',
                              Icons.remove_circle_outline,
                              Colors.orange,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Quantity
                      Text(
                        'QUANTITY',
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
                      TextFormField(
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          hintText: '0',
                          suffixText: widget.item.unit,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onChanged: (value) {
                          setState(() {
                            _quantity = value;
                          });
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Quantity is required';
                          }
                          final qty = double.tryParse(value);
                          if (qty == null || qty <= 0) {
                            return 'Quantity must be greater than 0';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),

                      // Reason
                      Text(
                        'REASON',
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
                      DropdownButtonFormField<String>(
                        initialValue: _reason,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        items: _reasons
                            .map((reason) => DropdownMenuItem(
                                  value: reason,
                                  child: Text(reason),
                                ))
                            .toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              _reason = value;
                            });
                          }
                        },
                      ),
                      const SizedBox(height: 20),

                      // Date
                      Text(
                        'ADJUSTMENT DATE',
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
                      InkWell(
                        onTap: _selectDate,
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: isDark
                                  ? Colors.white.withValues(alpha: 0.3)
                                  : Colors.grey[400]!,
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.calendar_today,
                                size: 18,
                                color: AppConstants.limeGreen,
                              ),
                              const SizedBox(width: 12),
                              Text(
                                '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                                style: DesignSystem.text(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color:
                                      isDark ? Colors.white : Colors.black87,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Notes (optional)
                      Text(
                        'NOTES (OPTIONAL)',
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
                      TextFormField(
                        maxLines: 3,
                        decoration: InputDecoration(
                          hintText: 'Additional notes...',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onChanged: (value) {
                          setState(() {
                            _notes = value;
                          });
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Action buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          'Cancel',
                          style: DesignSystem.text(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: ElevatedButton(
                        onPressed: _handleSubmit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppConstants.limeGreen,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          'Record Adjustment',
                          style: DesignSystem.text(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTypeButton(String type, IconData icon, Color color) {
    final isSelected = _adjustmentType == type;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: () {
        setState(() {
          _adjustmentType = type;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: isSelected
              ? color.withValues(alpha: 0.15)
              : (isDark
                  ? Colors.white.withValues(alpha: 0.05)
                  : Colors.grey.withValues(alpha: 0.1)),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? color : Colors.transparent,
            width: 2,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected ? color : (isDark ? Colors.white60 : Colors.grey[600]),
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              type,
              style: DesignSystem.text(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: isSelected ? color : (isDark ? Colors.white : Colors.black87),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
