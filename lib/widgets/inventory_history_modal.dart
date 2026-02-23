import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/design_system.dart';
import '../constants/app_constants.dart';
import '../providers/inventory_provider.dart';
import '../services/secure_storage_service.dart';
import 'glass_card.dart';

class InventoryHistoryModal extends StatefulWidget {
  final int itemId;
  final String itemName;
  final VoidCallback onClose;

  const InventoryHistoryModal({
    super.key,
    required this.itemId,
    required this.itemName,
    required this.onClose,
  });

  @override
  State<InventoryHistoryModal> createState() => _InventoryHistoryModalState();
}

class _InventoryHistoryModalState extends State<InventoryHistoryModal> {
  final _secureStorage = SecureStorageService();
  List<Map<String, dynamic>> _history = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    final token = await _secureStorage.getAuthToken();
    if (token == null || !mounted) return;

    final inventoryProvider =
        Provider.of<InventoryProvider>(context, listen: false);

    final result = await inventoryProvider.fetchHistory(
      token: token,
      id: widget.itemId,
    );

    if (mounted) {
      setState(() {
        _isLoading = false;
        if (result['success']) {
          _history = List<Map<String, dynamic>>.from(result['data']);
        } else {
          _error = result['error'];
        }
      });
    }
  }

  IconData _getIconForType(String type) {
    switch (type) {
      case 'Adjustment':
        return Icons.tune;
      case 'Allocation':
        return Icons.layers;
      case 'Fertilizer Application':
        return Icons.eco;
      case 'Pesticide Application':
        return Icons.bug_report;
      case 'Fungicide Application':
        return Icons.local_florist;
      default:
        return Icons.inventory;
    }
  }

  Color _getColorForType(String type) {
    switch (type) {
      case 'Adjustment':
        return Colors.amber;
      case 'Allocation':
        return AppConstants.limeGreen;
      case 'Fertilizer Application':
        return AppConstants.forestGreen;
      case 'Pesticide Application':
        return Colors.red;
      case 'Fungicide Application':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 700, maxHeight: 700),
        child: GlassCard(
          intensity: GlassIntensity.large,
          child: Column(
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(28),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppConstants.limeGreen.withValues(alpha: 0.08),
                      Colors.transparent,
                    ],
                  ),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppConstants.limeGreen.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.history,
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
                            'Usage History',
                            style: DesignSystem.heading(
                              fontSize: 22,
                              fontWeight: FontWeight.w900,
                              color: isDark ? Colors.white : Colors.black87,
                            ),
                          ),
                          Text(
                            widget.itemName,
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
                      onPressed: () {
                        widget.onClose();
                        Navigator.pop(context);
                      },
                      icon: Icon(
                        Icons.close,
                        color: isDark ? Colors.white60 : Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),

              // History list
              Expanded(
                child: _isLoading
                    ? Center(
                        child: CircularProgressIndicator(
                          color: AppConstants.limeGreen,
                        ),
                      )
                    : _error != null
                        ? Center(
                            child: Padding(
                              padding: const EdgeInsets.all(24),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.error_outline,
                                    size: 64,
                                    color: Colors.red.withValues(alpha: 0.5),
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    _error!,
                                    style: DesignSystem.text(
                                      fontSize: 14,
                                      color: Colors.red,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
                          )
                        : _history.isEmpty
                            ? Center(
                                child: Padding(
                                  padding: const EdgeInsets.all(24),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.inventory_2_outlined,
                                        size: 64,
                                        color: isDark
                                            ? Colors.white24
                                            : Colors.grey[300],
                                      ),
                                      const SizedBox(height: 16),
                                      Text(
                                        'No History',
                                        style: DesignSystem.heading(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: isDark
                                              ? Colors.white60
                                              : Colors.grey[600],
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        'No adjustments or allocations recorded yet',
                                        style: DesignSystem.text(
                                          fontSize: 13,
                                          color: isDark
                                              ? Colors.white38
                                              : Colors.grey[500],
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ],
                                  ),
                                ),
                              )
                            : ListView.separated(
                                padding: const EdgeInsets.all(24),
                                itemCount: _history.length,
                                separatorBuilder: (context, index) =>
                                    const SizedBox(height: 12),
                                itemBuilder: (context, index) {
                                  final entry = _history[index];
                                  return _buildHistoryEntry(entry, isDark);
                                },
                              ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHistoryEntry(Map<String, dynamic> entry, bool isDark) {
    final type = entry['type'] as String;
    final color = _getColorForType(type);
    final icon = _getIconForType(type);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.03)
            : Colors.grey.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.1)
              : Colors.grey.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 18,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      type,
                      style: DesignSystem.text(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    ),
                    Text(
                      entry['date'] as String,
                      style: DesignSystem.text(
                        fontSize: 11,
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.6)
                            : Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '${entry['amount']} ${entry['unit']}',
                style: DesignSystem.heading(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Details
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.02)
                  : Colors.grey.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (entry['target'] != null) ...[
                  Row(
                    children: [
                      Icon(
                        Icons.label,
                        size: 14,
                        color: AppConstants.limeGreen,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          entry['target'] as String,
                          style: DesignSystem.text(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white70 : Colors.grey[700],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
                if (entry['reason'] != null) ...[
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        size: 14,
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.6)
                            : Colors.grey[600],
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          entry['reason'] as String,
                          style: DesignSystem.text(
                            fontSize: 12,
                            color: isDark
                                ? Colors.white.withValues(alpha: 0.6)
                                : Colors.grey[600],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
                if (entry['notes'] != null &&
                    (entry['notes'] as String).isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.notes,
                        size: 14,
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.6)
                            : Colors.grey[600],
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          entry['notes'] as String,
                          style: DesignSystem.text(
                            fontSize: 12,
                            color: isDark
                                ? Colors.white.withValues(alpha: 0.5)
                                : Colors.grey[500],
                          ).copyWith(fontStyle: FontStyle.italic),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
