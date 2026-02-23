import 'package:flutter/material.dart';
import '../config/design_system.dart';
import '../constants/app_constants.dart';
import 'glass_card.dart';

class BatchRegistrationModal extends StatefulWidget {
  final String selectedCategory;
  final VoidCallback onSingleMode;
  final Function(List<String> categories, String batchName) onBatchMode;

  const BatchRegistrationModal({
    super.key,
    required this.selectedCategory,
    required this.onSingleMode,
    required this.onBatchMode,
  });

  @override
  State<BatchRegistrationModal> createState() => _BatchRegistrationModalState();
}

class _BatchRegistrationModalState extends State<BatchRegistrationModal> {
  bool _showBatchFlow = false;
  final List<String> _selectedCategories = [];
  final String _batchName = 'SAME';

  final Map<String, CategoryIconConfig> _categoryConfig = {
    'Source Resource': CategoryIconConfig(
      icon: Icons.factory,
      color: const Color(0xFF64748B),
    ),
    'Non-Scarce Items': CategoryIconConfig(
      icon: Icons.archive,
      color: const Color(0xFFF59E0B),
    ),
    'Fertilizer': CategoryIconConfig(
      icon: Icons.eco,
      color: AppConstants.forestGreen,
    ),
    'Pesticides': CategoryIconConfig(
      icon: Icons.bug_report,
      color: Colors.red,
    ),
    'Fungicides': CategoryIconConfig(
      icon: Icons.local_florist,
      color: Colors.purple,
    ),
    'Seeds': CategoryIconConfig(
      icon: Icons.grass,
      color: Colors.green,
    ),
    'Tools': CategoryIconConfig(
      icon: Icons.handyman,
      color: Colors.blue,
    ),
    'Equipment': CategoryIconConfig(
      icon: Icons.construction,
      color: Colors.orange,
    ),
    'Irrigation': CategoryIconConfig(
      icon: Icons.water_drop,
      color: Colors.cyan,
    ),
  };

  List<String> get _availableCategories {
    return _categoryConfig.keys
        .where((cat) => cat != widget.selectedCategory)
        .toList();
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
                        Icons.add_circle_outline,
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
                            'How would you like to add?',
                            style: DesignSystem.heading(
                              fontSize: 20,
                              fontWeight: FontWeight.w900,
                              color: isDark ? Colors.white : Colors.black87,
                            ),
                          ),
                          Text(
                            'Choose your registration workflow',
                            style: DesignSystem.text(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: isDark
                                  ? Colors.white.withValues(alpha: 0.6)
                                  : Colors.grey[600],
                            ),
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

                // Content
                if (!_showBatchFlow) ...[
                  // Mode selection
                  _buildModeSelection(isDark),
                ] else ...[
                  // Batch configuration
                  _buildBatchConfiguration(isDark),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildModeSelection(bool isDark) {
    return Column(
      children: [
        // Single mode button
        _buildModeCard(
          isDark: isDark,
          icon: Icons.add,
          title: 'Default way',
          subtitle: 'Single resource entry',
          onTap: () {
            Navigator.pop(context);
            widget.onSingleMode();
          },
        ),
        const SizedBox(height: 16),

        // Batch mode button
        _buildModeCard(
          isDark: isDark,
          icon: Icons.layers,
          title: 'Use same batch',
          subtitle: 'Sequential registration',
          isPrimary: true,
          onTap: () {
            setState(() {
              _showBatchFlow = true;
            });
          },
        ),
      ],
    );
  }

  Widget _buildModeCard({
    required bool isDark,
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool isPrimary = false,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: isPrimary
              ? AppConstants.limeGreen.withValues(alpha: 0.05)
              : (isDark
                  ? Colors.white.withValues(alpha: 0.03)
                  : Colors.grey.withValues(alpha: 0.05)),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isPrimary
                ? AppConstants.limeGreen.withValues(alpha: 0.3)
                : (isDark
                    ? Colors.white.withValues(alpha: 0.1)
                    : Colors.grey.withValues(alpha: 0.2)),
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isPrimary
                    ? AppConstants.limeGreen.withValues(alpha: 0.1)
                    : (isDark
                        ? Colors.white.withValues(alpha: 0.05)
                        : Colors.grey.withValues(alpha: 0.1)),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                size: 32,
                color: isPrimary
                    ? AppConstants.limeGreen
                    : (isDark ? Colors.white70 : Colors.black54),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: DesignSystem.heading(
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: DesignSystem.text(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.6)
                          : Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward,
              color: isPrimary
                  ? AppConstants.limeGreen
                  : (isDark ? Colors.white38 : Colors.grey[400]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBatchConfiguration(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Back button
        Row(
          children: [
            TextButton.icon(
              onPressed: () {
                setState(() {
                  _showBatchFlow = false;
                });
              },
              icon: const Icon(Icons.arrow_back, size: 18),
              label: Text(
                'Change Mode',
                style: DesignSystem.text(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Step 1: Category selection
        Text(
          '1. SELECT OTHER CATEGORIES TO INCLUDE',
          style: DesignSystem.text(
            fontSize: 10,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.0,
            color:
                isDark ? Colors.white.withValues(alpha: 0.6) : Colors.grey[600],
          ),
        ),
        const SizedBox(height: 12),

        // Category grid
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _availableCategories.map((category) {
            final isSelected = _selectedCategories.contains(category);
            final config = _categoryConfig[category]!;

            return InkWell(
              onTap: () {
                setState(() {
                  if (isSelected) {
                    _selectedCategories.remove(category);
                  } else {
                    _selectedCategories.add(category);
                  }
                });
              },
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppConstants.limeGreen
                      : (isDark
                          ? Colors.white.withValues(alpha: 0.05)
                          : Colors.grey.withValues(alpha: 0.1)),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected
                        ? AppConstants.limeGreen
                        : (isDark
                            ? Colors.white.withValues(alpha: 0.1)
                            : Colors.grey.withValues(alpha: 0.2)),
                    width: 2,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      config.icon,
                      size: 16,
                      color: isSelected
                          ? Colors.white
                          : (isDark ? Colors.white70 : config.color),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      category,
                      style: DesignSystem.text(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: isSelected
                            ? Colors.white
                            : (isDark ? Colors.white : Colors.black87),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 24),

        // Step 2: Batch name
        Text(
          '2. SET BATCH NUMBER / NAME',
          style: DesignSystem.text(
            fontSize: 10,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.0,
            color:
                isDark ? Colors.white.withValues(alpha: 0.6) : Colors.grey[600],
          ),
        ),
        const SizedBox(height: 12),

        // Batch name input (read-only for now)
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: isDark
                ? Colors.white.withValues(alpha: 0.05)
                : Colors.grey.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.2)
                  : Colors.grey.withValues(alpha: 0.3),
            ),
          ),
          child: Row(
            children: [
              Icon(
                Icons.label,
                size: 18,
                color: AppConstants.limeGreen,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  _batchName,
                  style: DesignSystem.text(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.7)
                        : Colors.black87,
                  ),
                ),
              ),
              Text(
                '(Auto-generated)',
                style: DesignSystem.text(
                  fontSize: 11,
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.5)
                      : Colors.grey[500],
                ),
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
                onPressed: () {
                  setState(() {
                    _showBatchFlow = false;
                  });
                },
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Back',
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
                onPressed: _batchName.isNotEmpty
                    ? () {
                        Navigator.pop(context);
                        widget.onBatchMode(_selectedCategories, _batchName);
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppConstants.limeGreen,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Start Sequential Registration',
                      style: DesignSystem.text(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(Icons.arrow_forward, size: 18),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class CategoryIconConfig {
  final IconData icon;
  final Color color;

  CategoryIconConfig({
    required this.icon,
    required this.color,
  });
}
