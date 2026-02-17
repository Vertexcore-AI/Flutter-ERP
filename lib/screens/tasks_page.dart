import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/app_constants.dart';
import '../models/dashboard_models.dart';
import '../widgets/task_table_widget.dart';
import '../widgets/glass_card.dart';

class TasksPage extends StatefulWidget {
  const TasksPage({super.key});

  @override
  State<TasksPage> createState() => _TasksPageState();
}

class _TasksPageState extends State<TasksPage> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  static final mockTasks = [
    TaskItem(
      taskName: 'Apply Fertilizer to Corn',
      assignedTo: 'Lissa Muurna',
      dueDate: 'Aug 27, 2024',
      status: 'Cancelled',
    ),
    TaskItem(
      taskName: 'Harvest Wheat Field A',
      assignedTo: 'John Farmer',
      dueDate: 'Aug 25, 2024',
      status: 'Completed',
    ),
    TaskItem(
      taskName: 'Irrigation System Check',
      assignedTo: 'Sarah Green',
      dueDate: 'Aug 30, 2024',
      status: 'In Progress',
    ),
    TaskItem(
      taskName: 'Pest Control Treatment',
      assignedTo: 'Mike Brown',
      dueDate: 'Sep 2, 2024',
      status: 'In Progress',
    ),
    TaskItem(
      taskName: 'Soil Testing - Field B',
      assignedTo: 'Emma Wilson',
      dueDate: 'Sep 5, 2024',
      status: 'In Progress',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 110),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            // Header
            Row(
              children: [
                Icon(Icons.assignment_outlined, color: AppConstants.limeGreen, size: 32),
                const SizedBox(width: 12),
                Text(
                  'Task Management',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Manage and track all farm tasks',
              style: GoogleFonts.spaceGrotesk(
                fontSize: 14,
                color: isDark ? Colors.white70 : Colors.grey[600],
              ),
            ),
            const SizedBox(height: 32),
            // Task Summary Cards
            Row(
              children: [
                Expanded(
                  child: GlassCard(
                    intensity: GlassIntensity.medium,
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.pending_actions, color: AppConstants.limeGreen, size: 28),
                        const SizedBox(height: 12),
                        Text(
                          '3',
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                        ),
                        Text(
                          'In Progress',
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 14,
                            color: isDark ? Colors.white70 : Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: GlassCard(
                    intensity: GlassIntensity.medium,
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.check_circle_outline, color: AppConstants.forestGreen, size: 28),
                        const SizedBox(height: 12),
                        Text(
                          '1',
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                        ),
                        Text(
                          'Completed',
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 14,
                            color: isDark ? Colors.white70 : Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: GlassCard(
                    intensity: GlassIntensity.medium,
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.cancel_outlined, color: Colors.red[400], size: 28),
                        const SizedBox(height: 12),
                        Text(
                          '1',
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                        ),
                        Text(
                          'Cancelled',
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 14,
                            color: isDark ? Colors.white70 : Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            // Task Table
            TaskTableWidget(tasks: mockTasks),
          ],
        ),
      );
  }
}
