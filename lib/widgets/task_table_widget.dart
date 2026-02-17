import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/app_constants.dart';
import '../models/dashboard_models.dart';
import 'glass_card.dart';

class TaskTableWidget extends StatelessWidget {
  final List<TaskItem> tasks;

  const TaskTableWidget({super.key, required this.tasks});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isMobile = MediaQuery.of(context).size.width < 600;

    return GlassCard.large(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  'Task Management',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Subtle Glass Button - New Task
                  Container(
                    decoration: BoxDecoration(
                      color: AppConstants.limeGreen.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: AppConstants.limeGreen.withValues(alpha: 0.3),
                        width: 1,
                      ),
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {},
                        borderRadius: BorderRadius.circular(10),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.add_rounded,
                                size: 16,
                                color: AppConstants.limeGreen,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'New Task',
                                style: GoogleFonts.spaceGrotesk(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: AppConstants.limeGreen,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Glass Icon Button - Filter
                  Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.08)
                          : AppConstants.darkGreen.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.15)
                            : AppConstants.darkGreen.withValues(alpha: 0.15),
                        width: 1,
                      ),
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {},
                        borderRadius: BorderRadius.circular(8),
                        child: Icon(
                          Icons.tune_rounded,
                          size: 18,
                          color: isDark
                              ? Colors.white70
                              : AppConstants.darkGreen.withValues(alpha: 0.8),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (isMobile)
            _buildMobileTaskList(context)
          else
            _buildDesktopTaskTable(context),
          const SizedBox(height: 16),
          // Subtle Glass Link Button - More Details
          Align(
            alignment: Alignment.centerRight,
            child: Container(
              decoration: BoxDecoration(
                color: AppConstants.forestGreen.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppConstants.forestGreen.withValues(alpha: 0.2),
                  width: 1,
                ),
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {},
                  borderRadius: BorderRadius.circular(8),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 7,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'More Details',
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: AppConstants.forestGreen,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(
                          Icons.arrow_forward_rounded,
                          size: 15,
                          color: AppConstants.forestGreen,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileTaskList(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      children: tasks.map((task) {
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isDark
              ? Colors.black.withValues(alpha: 0.2)
              : AppConstants.beige.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isDark
                ? AppConstants.lightSage.withValues(alpha: 0.1)
                : AppConstants.darkGreen.withValues(alpha: 0.1),
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                task.taskName,
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    Icons.person_outline,
                    size: 14,
                    color: isDark ? Colors.white60 : Colors.grey[600],
                  ),
                  const SizedBox(width: 4),
                  Text(
                    task.assignedTo,
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 12,
                      color: isDark ? Colors.white60 : Colors.grey[600],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(
                    Icons.calendar_today,
                    size: 14,
                    color: isDark ? Colors.white60 : Colors.grey[600],
                  ),
                  const SizedBox(width: 4),
                  Text(
                    task.dueDate,
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 12,
                      color: isDark ? Colors.white60 : Colors.grey[600],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              _buildStatusBadge(task.status),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildDesktopTaskTable(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Table(
      columnWidths: const {
        0: FlexColumnWidth(3),
        1: FlexColumnWidth(2),
        2: FlexColumnWidth(2),
        3: FlexColumnWidth(1.5),
      },
      children: [
        // Header row
        TableRow(
          decoration: BoxDecoration(
            color: isDark
              ? Colors.black.withValues(alpha: 0.2)
              : AppConstants.beige.withValues(alpha: 0.2),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(8),
              topRight: Radius.circular(8),
            ),
          ),
          children: [
            _buildTableHeader(context, 'Task Name'),
            _buildTableHeader(context, 'Assigned To'),
            _buildTableHeader(context, 'Due Date'),
            _buildTableHeader(context, 'Status'),
          ],
        ),
        // Data rows
        ...tasks.map((task) {
          return TableRow(
            children: [
              _buildTableCell(context, task.taskName),
              _buildTableCell(context, task.assignedTo),
              _buildTableCell(context, task.dueDate),
              Padding(
                padding: const EdgeInsets.all(12),
                child: _buildStatusBadge(task.status),
              ),
            ],
          );
        }),
      ],
    );
  }

  Widget _buildTableHeader(BuildContext context, String text) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.all(12),
      child: Text(
        text,
        style: GoogleFonts.spaceGrotesk(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: isDark ? Colors.white : Colors.black87,
        ),
      ),
    );
  }

  Widget _buildTableCell(BuildContext context, String text) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.all(12),
      child: Text(
        text,
        style: GoogleFonts.spaceGrotesk(
          fontSize: 13,
          color: isDark ? Colors.white70 : Colors.grey[700],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color badgeColor;

    switch (status) {
      case 'Completed':
        badgeColor = AppConstants.forestGreen; // #74981e
        break;
      case 'In Progress':
        badgeColor = AppConstants.limeGreen; // #9dac17
        break;
      case 'Cancelled':
        badgeColor = const Color(0xFFD32F2F); // Red[700] for accessibility
        break;
      default:
        badgeColor = AppConstants.olive; // #97a25c
    }

    return GlassBadge(
      text: status,
      color: badgeColor,
    );
  }
}
