import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../config/design_system.dart';
import '../constants/app_constants.dart';
import '../models/task_model.dart';
import '../providers/task_provider.dart';
import '../providers/crop_provider.dart';
import '../services/secure_storage_service.dart';
import '../widgets/app_bar_glass.dart';
import '../widgets/glass_card.dart';
import '../widgets/task_card.dart';
import '../widgets/task_form_widget.dart';

/// Tasks Page
/// Full CRUD interface for task management
class TasksPage extends StatefulWidget {
  const TasksPage({super.key});

  @override
  State<TasksPage> createState() => _TasksPageState();
}

class _TasksPageState extends State<TasksPage>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  final _secureStorage = SecureStorageService();
  bool _showForm = false;
  Task? _editingTask;
  String _selectedFilter = 'all'; // all, pending, in_progress, completed, overdue

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  Future<void> _loadData() async {
    final taskProvider = Provider.of<TaskProvider>(context, listen: false);
    final cropProvider = Provider.of<CropProvider>(context, listen: false);

    final token = await _secureStorage.getAuthToken();
    if (token != null) {
      // Load tasks
      await taskProvider.fetchTasks(token);

      // Load crops for dropdown (if not already loaded)
      if (cropProvider.crops.isEmpty) {
        await cropProvider.fetchCrops(token);
      }
    }
  }

  Future<void> _handleRefresh() async {
    await _loadData();
  }

  void _showCreateForm() {
    HapticFeedback.lightImpact();
    setState(() {
      _editingTask = null;
      _showForm = true;
    });
  }

  void _showEditForm(Task task) {
    HapticFeedback.lightImpact();
    setState(() {
      _editingTask = task;
      _showForm = true;
    });
  }

  void _hideForm() {
    setState(() {
      _showForm = false;
      _editingTask = null;
    });
  }

  Future<void> _handleFormSubmit(Map<String, dynamic> data) async {
    final taskProvider = Provider.of<TaskProvider>(context, listen: false);
    final token = await _secureStorage.getAuthToken();

    if (token == null) return;

    bool success;

    if (_editingTask == null) {
      // Create new task
      success = await taskProvider.createTask(
        token: token,
        title: data['title'],
        dueDate: data['dueDate'],
        status: data['status'],
        category: data['category'],
        description: data['description'],
        cropId: data['cropId'],
      );
    } else {
      // Update existing task
      success = await taskProvider.updateTask(
        token: token,
        taskId: _editingTask!.id,
        title: data['title'],
        description: data['description'],
        dueDate: data['dueDate'],
        status: data['status'],
        category: data['category'],
        cropId: data['cropId'],
      );
    }

    if (success && mounted) {
      _hideForm();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _editingTask == null
                ? 'Task created successfully'
                : 'Task updated successfully',
          ),
          backgroundColor: AppConstants.forestGreen,
        ),
      );
    } else if (mounted && taskProvider.error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(taskProvider.error!),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _handleToggleStatus(Task task) async {
    final taskProvider = Provider.of<TaskProvider>(context, listen: false);
    final token = await _secureStorage.getAuthToken();

    if (token == null) return;

    final success = await taskProvider.toggleTaskStatus(
      token: token,
      task: task,
    );

    if (!success && mounted && taskProvider.error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(taskProvider.error!),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _handleDelete(Task task) async {
    HapticFeedback.mediumImpact();

    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => _buildDeleteConfirmDialog(task),
    );

    if (confirmed != true) return;

    if (!mounted) return;

    final taskProvider = Provider.of<TaskProvider>(context, listen: false);
    final token = await _secureStorage.getAuthToken();

    if (token == null) return;

    final success = await taskProvider.deleteTask(
      token: token,
      taskId: task.id,
    );

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Task deleted successfully'),
          backgroundColor: Colors.red,
        ),
      );
    } else if (mounted && taskProvider.error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(taskProvider.error!),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  List<Task> _getFilteredTasks(TaskProvider taskProvider) {
    switch (_selectedFilter) {
      case 'pending':
        return taskProvider.pendingTasks;
      case 'in_progress':
        return taskProvider.inProgressTasks;
      case 'completed':
        return taskProvider.completedTasks;
      case 'overdue':
        return taskProvider.overdueTasks;
      default:
        return taskProvider.tasks;
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final taskProvider = Provider.of<TaskProvider>(context);
    final filteredTasks = _getFilteredTasks(taskProvider);

    return Scaffold(
      backgroundColor: isDark
          ? DesignSystem.darkScaffoldBackground
          : DesignSystem.lightScaffoldBackground,
      body: SafeArea(
        child: Column(
          children: [
            // App Bar
            AppBarGlass(
              mode: AppBarMode.title,
              title: 'Task Management',
              subtitle: 'Organize your farming activities',
            ),

            // Content
            Expanded(
              child: RefreshIndicator(
                onRefresh: _handleRefresh,
                color: AppConstants.limeGreen,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(24, 24, 24, 110),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Summary Cards
                      _buildSummaryCards(taskProvider),

                      const SizedBox(height: 24),

                      // Filter Tabs
                      _buildFilterTabs(),

                      const SizedBox(height: 24),

                      // New Task Button
                      if (!_showForm)
                        _buildNewTaskButton()
                      else
                        const SizedBox.shrink(),

                      // Task Form (Conditional)
                      if (_showForm) ...[
                        const SizedBox(height: 16),
                        TaskFormWidget(
                          task: _editingTask,
                          onSubmit: _handleFormSubmit,
                          onCancel: _hideForm,
                        ),
                        const SizedBox(height: 24),
                      ],

                      // Task List
                      if (taskProvider.isLoading)
                        _buildLoadingState()
                      else if (filteredTasks.isEmpty)
                        _buildEmptyState()
                      else
                        _buildTaskList(filteredTasks),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCards(TaskProvider taskProvider) {
    return Row(
      children: [
        Expanded(
          child: _buildSummaryCard(
            'Pending',
            taskProvider.pendingCount.toString(),
            AppConstants.olive,
            Icons.pending_actions,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildSummaryCard(
            'In Progress',
            taskProvider.inProgressCount.toString(),
            AppConstants.limeGreen,
            Icons.access_time,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildSummaryCard(
            'Completed',
            taskProvider.completedCount.toString(),
            AppConstants.forestGreen,
            Icons.check_circle,
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryCard(
    String label,
    String count,
    Color accentColor,
    IconData icon,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GlassCard.small(
      child: Column(
        children: [
          Icon(icon, size: 24, color: accentColor),
          const SizedBox(height: 8),
          Text(
            count,
            style: DesignSystem.heading(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: accentColor,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: DesignSystem.text(
              fontSize: 12,
              color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildFilterTabs() {
    final filters = [
      {'key': 'all', 'label': 'All Tasks'},
      {'key': 'pending', 'label': 'Pending'},
      {'key': 'in_progress', 'label': 'In Progress'},
      {'key': 'completed', 'label': 'Completed'},
      {'key': 'overdue', 'label': 'Overdue'},
    ];

    return SizedBox(
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: filters.length,
        itemBuilder: (context, index) {
          final filter = filters[index];
          final isSelected = _selectedFilter == filter['key'];

          return Padding(
            padding: EdgeInsets.only(right: index < filters.length - 1 ? 12 : 0),
            child: _buildFilterChip(
              label: filter['label']!,
              isSelected: isSelected,
              onTap: () {
                HapticFeedback.lightImpact();
                setState(() {
                  _selectedFilter = filter['key']!;
                });
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? AppConstants.limeGreen
              : (isDark
                  ? Colors.white.withValues(alpha: 0.1)
                  : Colors.black.withValues(alpha: 0.05)),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? AppConstants.limeGreen
                : (isDark ? Colors.grey.shade700 : Colors.grey.shade300),
            width: 1.5,
          ),
        ),
        child: Text(
          label,
          style: DesignSystem.text(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: isSelected
                ? Colors.white
                : (isDark ? AppConstants.lightSage : AppConstants.darkGreen),
          ),
        ),
      ),
    );
  }

  Widget _buildNewTaskButton() {
    return GestureDetector(
      onTap: _showCreateForm,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppConstants.limeGreen,
              AppConstants.forestGreen,
            ],
          ),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: AppConstants.limeGreen.withValues(alpha: 0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.add_task, color: Colors.white, size: 24),
            const SizedBox(width: 12),
            Text(
              'Create New Task',
              style: DesignSystem.text(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(48.0),
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(AppConstants.limeGreen),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(48.0),
        child: Column(
          children: [
            Icon(
              Icons.assignment_outlined,
              size: 80,
              color: isDark ? Colors.grey.shade700 : Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              _selectedFilter == 'all'
                  ? 'No tasks yet'
                  : 'No ${_selectedFilter.replaceAll('_', ' ')} tasks',
              style: DesignSystem.heading(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.grey.shade500 : Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _selectedFilter == 'all'
                  ? 'Create your first task to get started'
                  : 'Try selecting a different filter',
              style: DesignSystem.text(
                fontSize: 14,
                color: isDark ? Colors.grey.shade600 : Colors.grey.shade500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTaskList(List<Task> tasks) {
    // Group tasks by sections
    final overdue = tasks.where((t) => t.isOverdue()).toList();
    final dueToday = tasks.where((t) => t.isDueToday() && t.isActive).toList();
    final thisWeek = tasks
        .where((t) => t.isDueThisWeek() && !t.isDueToday() && t.isActive)
        .toList();
    final later = tasks
        .where((t) =>
            !t.isOverdue() &&
            !t.isDueToday() &&
            !t.isDueThisWeek() &&
            t.isActive)
        .toList();
    final completed = tasks.where((t) => t.isCompleted).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (overdue.isNotEmpty) _buildTaskSection('Overdue', overdue, Colors.red[700]!),
        if (dueToday.isNotEmpty) _buildTaskSection('Due Today', dueToday, AppConstants.limeGreen),
        if (thisWeek.isNotEmpty) _buildTaskSection('This Week', thisWeek, AppConstants.olive),
        if (later.isNotEmpty) _buildTaskSection('Later', later, AppConstants.darkGreen),
        if (completed.isNotEmpty) _buildTaskSection('Completed', completed, AppConstants.forestGreen),
      ],
    );
  }

  Widget _buildTaskSection(String title, List<Task> tasks, Color accentColor) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Header
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Row(
            children: [
              Container(
                width: 4,
                height: 20,
                decoration: BoxDecoration(
                  color: accentColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: DesignSystem.heading(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: isDark ? AppConstants.lightSage : AppConstants.darkGreen,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  tasks.length.toString(),
                  style: DesignSystem.text(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: accentColor,
                  ),
                ),
              ),
            ],
          ),
        ),

        // Tasks in this section
        ...tasks.map((task) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: TaskCard(
                task: task,
                onToggleStatus: () => _handleToggleStatus(task),
                onEdit: () => _showEditForm(task),
                onDelete: () => _handleDelete(task),
              ),
            )),

        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildDeleteConfirmDialog(Task task) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AlertDialog(
      backgroundColor: isDark ? DesignSystem.darkSurface : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      title: Row(
        children: [
          Icon(
            Icons.warning_amber_rounded,
            color: Colors.red[700],
            size: 28,
          ),
          const SizedBox(width: 12),
          Text(
            'Delete Task?',
            style: DesignSystem.heading(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: isDark ? AppConstants.lightSage : AppConstants.darkGreen,
            ),
          ),
        ],
      ),
      content: Text(
        'Are you sure you want to delete "${task.title}"? This action cannot be undone.',
        style: DesignSystem.text(
          fontSize: 15,
          color: isDark ? Colors.grey.shade400 : Colors.grey.shade700,
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(
            'Cancel',
            style: DesignSystem.text(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
            ),
          ),
        ),
        ElevatedButton(
          onPressed: () => Navigator.of(context).pop(true),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red[700],
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: const Text('Delete'),
        ),
      ],
    );
  }
}
