import 'package:flutter/material.dart';
import '../models/task_model.dart';
import '../services/task_service.dart';

class TaskProvider extends ChangeNotifier {
  List<Task> _tasks = [];
  bool _isLoading = false;
  String? _error;
  final TaskService _taskService = TaskService();

  List<Task> get tasks => _tasks;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // ============================================================================
  // FILTERED GETTERS
  // ============================================================================

  /// Get pending tasks
  List<Task> get pendingTasks =>
      _tasks.where((task) => task.status == TaskConstants.statusPending).toList();

  /// Get in-progress tasks
  List<Task> get inProgressTasks =>
      _tasks.where((task) => task.status == TaskConstants.statusInProgress).toList();

  /// Get completed tasks
  List<Task> get completedTasks =>
      _tasks.where((task) => task.status == TaskConstants.statusCompleted).toList();

  /// Get cancelled tasks
  List<Task> get cancelledTasks =>
      _tasks.where((task) => task.status == TaskConstants.statusCancelled).toList();

  /// Get overdue tasks (not completed/cancelled and past due date)
  List<Task> get overdueTasks =>
      _tasks.where((task) => task.isOverdue()).toList();

  /// Get tasks due today
  List<Task> get dueTodayTasks =>
      _tasks.where((task) => task.isDueToday() && task.isActive).toList();

  /// Get tasks due this week
  List<Task> get dueThisWeekTasks =>
      _tasks.where((task) => task.isDueThisWeek() && task.isActive).toList();

  /// Get active tasks (not completed or cancelled)
  List<Task> get activeTasks =>
      _tasks.where((task) => task.isActive).toList();

  // ============================================================================
  // COUNT GETTERS
  // ============================================================================

  int get pendingCount => pendingTasks.length;
  int get inProgressCount => inProgressTasks.length;
  int get completedCount => completedTasks.length;
  int get overdueCount => overdueTasks.length;
  int get dueTodayCount => dueTodayTasks.length;

  // ============================================================================
  // CATEGORY FILTERS
  // ============================================================================

  /// Get tasks by category
  List<Task> getTasksByCategory(String category) {
    return _tasks.where((task) => task.category == category).toList();
  }

  /// Get tasks by crop ID
  List<Task> getTasksByCropId(int cropId) {
    return _tasks.where((task) => task.cropId == cropId).toList();
  }

  // ============================================================================
  // API METHODS
  // ============================================================================

  /// Fetch all tasks from API
  Future<bool> fetchTasks(String token) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final result = await _taskService.fetchTasks(token);

    _isLoading = false;

    if (result['success']) {
      _tasks = result['data'];
      // Sort tasks by due date (nearest first)
      _tasks.sort((a, b) => a.dueDate.compareTo(b.dueDate));
      notifyListeners();
      return true;
    } else {
      _error = result['error'];
      notifyListeners();
      return false;
    }
  }

  /// Create new task
  Future<bool> createTask({
    required String token,
    required String title,
    required DateTime dueDate,
    required String status,
    required String category,
    String? description,
    int? cropId,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final result = await _taskService.createTask(
      token: token,
      title: title,
      dueDate: dueDate,
      status: status,
      category: category,
      description: description,
      cropId: cropId,
    );

    _isLoading = false;

    if (result['success']) {
      // Refresh tasks list
      await fetchTasks(token);
      return true;
    } else {
      _error = result['error'];
      notifyListeners();
      return false;
    }
  }

  /// Update existing task
  Future<bool> updateTask({
    required String token,
    required int taskId,
    String? title,
    String? description,
    DateTime? dueDate,
    String? status,
    String? category,
    int? cropId,
    bool clearCrop = false,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final result = await _taskService.updateTask(
      token: token,
      taskId: taskId,
      title: title,
      description: description,
      dueDate: dueDate,
      status: status,
      category: category,
      cropId: cropId,
      clearCrop: clearCrop,
    );

    _isLoading = false;

    if (result['success']) {
      // Refresh tasks list
      await fetchTasks(token);
      return true;
    } else {
      _error = result['error'];
      notifyListeners();
      return false;
    }
  }

  /// Delete task
  Future<bool> deleteTask({
    required String token,
    required int taskId,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final result = await _taskService.deleteTask(token, taskId);

    _isLoading = false;

    if (result['success']) {
      // Remove from local list
      _tasks.removeWhere((task) => task.id == taskId);
      notifyListeners();
      return true;
    } else {
      _error = result['error'];
      notifyListeners();
      return false;
    }
  }

  /// Toggle task status between pending and completed
  /// Optimistic update for better UX
  Future<bool> toggleTaskStatus({
    required String token,
    required Task task,
  }) async {
    // Store original status for rollback
    final originalStatus = task.status;
    final newStatus = task.status.toLowerCase() == TaskConstants.statusPending
        ? TaskConstants.statusCompleted
        : TaskConstants.statusPending;

    // Optimistic update - update UI immediately
    final index = _tasks.indexWhere((t) => t.id == task.id);
    if (index != -1) {
      _tasks[index] = task.copyWith(status: newStatus);
      notifyListeners();
    }

    // Make API call
    final result = await _taskService.toggleTaskStatus(
      token: token,
      taskId: task.id,
      currentStatus: originalStatus,
    );

    if (!result['success']) {
      // Rollback on failure
      if (index != -1) {
        _tasks[index] = task.copyWith(status: originalStatus);
        _error = result['error'];
        notifyListeners();
      }
      return false;
    }

    // Refresh to get latest data from server
    await fetchTasks(token);
    return true;
  }

  /// Clear error message
  void clearError() {
    _error = null;
    notifyListeners();
  }

  /// Clear all tasks (e.g., on logout)
  void clearTasks() {
    _tasks = [];
    _error = null;
    _isLoading = false;
    notifyListeners();
  }
}
