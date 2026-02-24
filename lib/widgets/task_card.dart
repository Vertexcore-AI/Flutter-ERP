import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/task_model.dart';
import '../config/design_system.dart';
import '../constants/app_constants.dart';
import 'glass_card.dart';

/// Task Card Widget
/// Displays a single task with glass morphism design
class TaskCard extends StatelessWidget {
  final Task task;
  final VoidCallback? onToggleStatus;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onTapCrop;

  const TaskCard({
    super.key,
    required this.task,
    this.onToggleStatus,
    this.onEdit,
    this.onDelete,
    this.onTapCrop,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isCompleted = task.isCompleted;
    final isOverdue = task.isOverdue();

    // Determine border color based on category
    Color borderColor;
    switch (task.category.toLowerCase()) {
      case 'harvest':
        borderColor = AppConstants.forestGreen;
        break;
      case 'planting':
        borderColor = AppConstants.limeGreen;
        break;
      case 'maintenance':
        borderColor = AppConstants.olive;
        break;
      default:
        borderColor = AppConstants.darkGreen;
    }

    // Reduce opacity for completed tasks
    final containerOpacity = isCompleted ? 0.6 : 1.0;

    return Opacity(
      opacity: containerOpacity,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(DesignSystem.radiusMd),
          border: Border(
            left: BorderSide(
              color: isCompleted
                  ? (isDark ? Colors.grey.shade700 : Colors.grey.shade400)
                  : borderColor,
              width: 4,
            ),
          ),
        ),
        child: GlassCard(
          intensity: GlassIntensity.medium,
          padding: const EdgeInsets.all(16),
          borderRadius: BorderRadius.circular(DesignSystem.radiusMd),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Row: Title + Status Toggle
              Row(
                children: [
                  Expanded(
                    child: Text(
                      task.title,
                      style: DesignSystem.text(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: isDark
                            ? AppConstants.lightSage
                            : AppConstants.darkGreen,
                      ).copyWith(
                        decoration: isCompleted
                            ? TextDecoration.lineThrough
                            : null,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Status toggle button
                  GestureDetector(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      onToggleStatus?.call();
                    },
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isCompleted
                            ? AppConstants.forestGreen.withValues(alpha:0.2)
                            : (isDark
                                ? Colors.white.withValues(alpha:0.1)
                                : Colors.black.withValues(alpha:0.05)),
                      ),
                      child: Icon(
                        isCompleted
                            ? Icons.check_circle
                            : Icons.check_circle_outline,
                        size: 24,
                        color: isCompleted
                            ? AppConstants.forestGreen
                            : (isDark ? Colors.grey.shade400 : Colors.grey.shade600),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Second Row: Category Badge + Due Date
              Row(
                children: [
                  // Category Badge
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        task.categoryIcon(),
                        size: 14,
                        color: task.statusColor(),
                      ),
                      const SizedBox(width: 6),
                      GlassBadge(
                        text: task.categoryDisplayText,
                        color: task.statusColor(),
                      ),
                    ],
                  ),
                  const SizedBox(width: 12),

                  // Due Date
                  Expanded(
                    child: Row(
                      children: [
                        Icon(
                          Icons.calendar_today,
                          size: 14,
                          color: isOverdue
                              ? Colors.red[700]
                              : (isDark ? Colors.grey.shade400 : Colors.grey.shade600),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            task.relativeDueDate(),
                            style: DesignSystem.text(
                              fontSize: 13,
                              color: isOverdue
                                  ? Colors.red[700]
                                  : (isDark ? Colors.grey.shade400 : Colors.grey.shade600),
                              fontWeight: isOverdue ? FontWeight.w600 : FontWeight.w400,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              // Status Badge
              if (task.status != TaskConstants.statusPending) ...[
                const SizedBox(height: 8),
                GlassBadge(
                  text: task.statusDisplayText,
                  color: task.statusColor(),
                ),
              ],

              // Description (if exists)
              if (task.description != null && task.description!.isNotEmpty) ...[
                const SizedBox(height: 12),
                Text(
                  task.description!,
                  style: DesignSystem.text(
                    fontSize: 14,
                    color: isDark
                        ? Colors.grey.shade400
                        : Colors.grey.shade700,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ],

              // Linked Crop (if exists)
              if (task.cropName != null) ...[
                const SizedBox(height: 12),
                GestureDetector(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    onTapCrop?.call();
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppConstants.limeGreen.withValues(alpha:0.15),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: AppConstants.limeGreen.withValues(alpha:0.4),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.eco,
                          size: 14,
                          color: AppConstants.limeGreen,
                        ),
                        const SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            task.cropName!,
                            style: DesignSystem.text(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: AppConstants.limeGreen,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],

              // Action Buttons
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  // Edit Button
                  _ActionButton(
                    icon: Icons.edit_outlined,
                    label: 'Edit',
                    onTap: () {
                      HapticFeedback.lightImpact();
                      onEdit?.call();
                    },
                    color: isDark
                        ? AppConstants.limeGreen
                        : AppConstants.darkGreen,
                  ),
                  const SizedBox(width: 12),

                  // Delete Button
                  _ActionButton(
                    icon: Icons.delete_outline,
                    label: 'Delete',
                    onTap: () {
                      HapticFeedback.lightImpact();
                      onDelete?.call();
                    },
                    color: Colors.red[700]!,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Action Button Widget (Edit/Delete)
class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final Color color;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: color.withValues(alpha:0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: color.withValues(alpha:0.3),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 6),
            Text(
              label,
              style: DesignSystem.text(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
