import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'crop_model.dart';
import '../constants/app_constants.dart';

/// Task Model
/// Represents a farming task with status, category, and optional crop association
class Task {
  final int id;
  final String title;
  final String? description;
  final DateTime dueDate;
  final String status; // pending, in_progress, completed, cancelled
  final String category; // harvest, planting, maintenance, task
  final int? cropId;
  final Crop? crop; // Nested crop object (optional)
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Task({
    required this.id,
    required this.title,
    this.description,
    required this.dueDate,
    required this.status,
    required this.category,
    this.cropId,
    this.crop,
    this.createdAt,
    this.updatedAt,
  });

  // JSON Deserialization
  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      dueDate: DateTime.parse(json['due_date']),
      status: json['status'] ?? 'pending',
      category: json['category'] ?? 'task',
      cropId: json['crop_id'],
      crop: json['crop'] != null ? Crop.fromJson(json['crop']) : null,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
    );
  }

  // JSON Serialization
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'due_date': DateFormat('yyyy-MM-dd').format(dueDate),
      'status': status,
      'category': category,
      'crop_id': cropId,
    };
  }

  // Create payload for API (without id, timestamps)
  Map<String, dynamic> toCreatePayload() {
    final payload = <String, dynamic>{
      'title': title,
      'due_date': DateFormat('yyyy-MM-dd').format(dueDate),
      'status': status,
      'category': category,
    };

    if (description != null && description!.isNotEmpty) {
      payload['description'] = description;
    }

    if (cropId != null) {
      payload['crop_id'] = cropId;
    }

    return payload;
  }

  // Create payload for update (only changed fields)
  Map<String, dynamic> toUpdatePayload({
    String? newTitle,
    String? newDescription,
    DateTime? newDueDate,
    String? newStatus,
    String? newCategory,
    int? newCropId,
    bool clearCrop = false,
  }) {
    final payload = <String, dynamic>{};

    if (newTitle != null && newTitle != title) {
      payload['title'] = newTitle;
    }

    if (newDescription != null && newDescription != description) {
      payload['description'] = newDescription;
    }

    if (newDueDate != null && newDueDate != dueDate) {
      payload['due_date'] = DateFormat('yyyy-MM-dd').format(newDueDate);
    }

    if (newStatus != null && newStatus != status) {
      payload['status'] = newStatus;
    }

    if (newCategory != null && newCategory != category) {
      payload['category'] = newCategory;
    }

    if (newCropId != null && newCropId != cropId) {
      payload['crop_id'] = newCropId;
    }

    if (clearCrop && cropId != null) {
      payload['crop_id'] = null;
    }

    return payload;
  }

  // ============================================================================
  // HELPER METHODS
  // ============================================================================

  /// Get color for task status
  Color statusColor() {
    switch (status.toLowerCase()) {
      case 'completed':
        return AppConstants.forestGreen; // Success green
      case 'in_progress':
        return AppConstants.limeGreen; // Primary lime green
      case 'cancelled':
        return Colors.red[700]!; // Error red
      case 'pending':
      default:
        return AppConstants.olive; // Neutral olive
    }
  }

  /// Get icon for task category
  IconData categoryIcon() {
    switch (category.toLowerCase()) {
      case 'harvest':
        return Icons.agriculture; // Harvest icon
      case 'planting':
        return Icons.eco; // Plant icon
      case 'maintenance':
        return Icons.build; // Maintenance icon
      case 'task':
      default:
        return Icons.assignment; // Generic task icon
    }
  }

  /// Calculate days from now until due date
  /// Positive = future, Negative = past (overdue)
  int daysUntilDue() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final due = DateTime(dueDate.year, dueDate.month, dueDate.day);
    return due.difference(today).inDays;
  }

  /// Check if task is overdue
  bool isOverdue() {
    if (status.toLowerCase() == 'completed' || status.toLowerCase() == 'cancelled') {
      return false; // Completed/cancelled tasks are not overdue
    }
    return daysUntilDue() < 0;
  }

  /// Check if task is due today
  bool isDueToday() {
    return daysUntilDue() == 0;
  }

  /// Check if task is due within the next 7 days
  bool isDueThisWeek() {
    final days = daysUntilDue();
    return days >= 0 && days <= 7;
  }

  /// Format due date for display (e.g., "Feb 24, 2026")
  String formattedDueDate() {
    return DateFormat('MMM dd, yyyy').format(dueDate);
  }

  /// Get relative due date string (e.g., "Due today", "Overdue by 2 days")
  String relativeDueDate() {
    final days = daysUntilDue();

    if (days < 0) {
      final overdueDays = -days;
      return 'Overdue by ${overdueDays == 1 ? '1 day' : '$overdueDays days'}';
    } else if (days == 0) {
      return 'Due today';
    } else if (days == 1) {
      return 'Due tomorrow';
    } else if (days <= 7) {
      return 'Due in $days days';
    } else {
      return 'Due on ${formattedDueDate()}';
    }
  }

  /// Get urgency level (for sorting/filtering)
  /// 0 = Overdue (critical)
  /// 1 = Today (urgent)
  /// 2 = This week (important)
  /// 3 = Later (normal)
  int urgencyLevel() {
    if (isOverdue()) return 0;
    if (isDueToday()) return 1;
    if (isDueThisWeek()) return 2;
    return 3;
  }

  /// Check if task is completed
  bool get isCompleted => status.toLowerCase() == 'completed';

  /// Check if task is cancelled
  bool get isCancelled => status.toLowerCase() == 'cancelled';

  /// Check if task is active (not completed/cancelled)
  bool get isActive => !isCompleted && !isCancelled;

  /// Get display name for crop (if linked)
  String? get cropName => crop?.name;

  /// Get display text for status
  String get statusDisplayText {
    switch (status.toLowerCase()) {
      case 'in_progress':
        return 'In Progress';
      case 'completed':
        return 'Completed';
      case 'cancelled':
        return 'Cancelled';
      case 'pending':
      default:
        return 'Pending';
    }
  }

  /// Get display text for category
  String get categoryDisplayText {
    switch (category.toLowerCase()) {
      case 'harvest':
        return 'Harvest';
      case 'planting':
        return 'Planting';
      case 'maintenance':
        return 'Maintenance';
      case 'task':
      default:
        return 'Task';
    }
  }

  // ============================================================================
  // COPY WITH METHOD (for easy updates)
  // ============================================================================

  Task copyWith({
    int? id,
    String? title,
    String? description,
    DateTime? dueDate,
    String? status,
    String? category,
    int? cropId,
    Crop? crop,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      dueDate: dueDate ?? this.dueDate,
      status: status ?? this.status,
      category: category ?? this.category,
      cropId: cropId ?? this.cropId,
      crop: crop ?? this.crop,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'Task(id: $id, title: $title, status: $status, category: $category, dueDate: $dueDate, cropId: $cropId)';
  }
}

// ============================================================================
// TASK CONSTANTS
// ============================================================================

class TaskConstants {
  // Status options
  static const String statusPending = 'pending';
  static const String statusInProgress = 'in_progress';
  static const String statusCompleted = 'completed';
  static const String statusCancelled = 'cancelled';

  static const List<String> allStatuses = [
    statusPending,
    statusInProgress,
    statusCompleted,
    statusCancelled,
  ];

  static const Map<String, String> statusDisplayNames = {
    statusPending: 'Pending',
    statusInProgress: 'In Progress',
    statusCompleted: 'Completed',
    statusCancelled: 'Cancelled',
  };

  // Category options
  static const String categoryHarvest = 'harvest';
  static const String categoryPlanting = 'planting';
  static const String categoryMaintenance = 'maintenance';
  static const String categoryTask = 'task';

  static const List<String> allCategories = [
    categoryHarvest,
    categoryPlanting,
    categoryMaintenance,
    categoryTask,
  ];

  static const Map<String, String> categoryDisplayNames = {
    categoryHarvest: 'Harvest',
    categoryPlanting: 'Planting',
    categoryMaintenance: 'Maintenance',
    categoryTask: 'Task',
  };

  // Category icons
  static const Map<String, IconData> categoryIcons = {
    categoryHarvest: Icons.agriculture,
    categoryPlanting: Icons.eco,
    categoryMaintenance: Icons.build,
    categoryTask: Icons.assignment,
  };

  // Status colors
  static const Map<String, Color> statusColors = {
    statusPending: AppConstants.olive,
    statusInProgress: AppConstants.limeGreen,
    statusCompleted: AppConstants.forestGreen,
    statusCancelled: Color(0xFFD32F2F), // Red[700]
  };
}
