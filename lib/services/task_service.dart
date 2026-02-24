import 'dart:convert';
import 'package:intl/intl.dart';
import '../config/api_config.dart';
import '../models/task_model.dart';
import 'api_client.dart';

class TaskService {
  final _apiClient = ApiClient();

  // Fetch all tasks
  Future<Map<String, dynamic>> fetchTasks(String token) async {
    try {
      final response = await _apiClient.get(
        '${ApiConfig.baseUrl}${ApiConfig.apiPrefix}/tasks',
      );

      final data = jsonDecode(response.body);

      try {
        final List<Task> tasks = (data as List)
            .map((item) => Task.fromJson(item))
            .toList();

        return {
          'success': true,
          'data': tasks,
        };
      } catch (e) {
        return {
          'success': false,
          'error': 'Failed to parse tasks: ${e.toString()}',
        };
      }
    } on UnauthorizedException catch (e) {
      return {'success': false, 'error': e.message, 'unauthorized': true};
    } on NotFoundException catch (e) {
      return {'success': false, 'error': e.message};
    } on RateLimitException catch (e) {
      return {'success': false, 'error': e.message, 'retryAfter': e.retryAfter};
    } on NetworkException catch (e) {
      return {'success': false, 'error': e.message};
    } on ApiException catch (e) {
      return {'success': false, 'error': e.message};
    } catch (e) {
      return {'success': false, 'error': 'Unexpected error: ${e.toString()}'};
    }
  }

  // Create new task
  Future<Map<String, dynamic>> createTask({
    required String token,
    required String title,
    required DateTime dueDate,
    required String status,
    required String category,
    String? description,
    int? cropId,
  }) async {
    try {
      final requestBody = <String, dynamic>{
        'title': title,
        'due_date': DateFormat('yyyy-MM-dd').format(dueDate),
        'status': status,
        'category': category,
      };

      // Add optional fields
      if (description != null && description.isNotEmpty) {
        requestBody['description'] = description;
      }
      if (cropId != null) {
        requestBody['crop_id'] = cropId;
      }

      final response = await _apiClient.post(
        '${ApiConfig.baseUrl}${ApiConfig.apiPrefix}/tasks',
        body: requestBody,
      );

      final data = jsonDecode(response.body);
      final task = Task.fromJson(data);
      return {
        'success': true,
        'data': task,
      };
    } on UnauthorizedException catch (e) {
      return {'success': false, 'error': e.message, 'unauthorized': true};
    } on ValidationException catch (e) {
      return {'success': false, 'error': e.message};
    } on NotFoundException catch (e) {
      return {'success': false, 'error': e.message};
    } on RateLimitException catch (e) {
      return {'success': false, 'error': e.message, 'retryAfter': e.retryAfter};
    } on NetworkException catch (e) {
      return {'success': false, 'error': e.message};
    } on ApiException catch (e) {
      return {'success': false, 'error': e.message};
    } catch (e) {
      return {'success': false, 'error': 'Unexpected error: ${e.toString()}'};
    }
  }

  // Update existing task
  Future<Map<String, dynamic>> updateTask({
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
    try {
      final requestBody = <String, dynamic>{};

      // Add fields that are provided (partial update)
      if (title != null) {
        requestBody['title'] = title;
      }
      if (description != null) {
        requestBody['description'] = description;
      }
      if (dueDate != null) {
        requestBody['due_date'] = DateFormat('yyyy-MM-dd').format(dueDate);
      }
      if (status != null) {
        requestBody['status'] = status;
      }
      if (category != null) {
        requestBody['category'] = category;
      }
      if (cropId != null) {
        requestBody['crop_id'] = cropId;
      }
      if (clearCrop) {
        requestBody['crop_id'] = null;
      }

      final response = await _apiClient.put(
        '${ApiConfig.baseUrl}${ApiConfig.apiPrefix}/tasks/$taskId',
        body: requestBody,
      );

      final data = jsonDecode(response.body);
      // Backend returns the updated task object
      final task = Task.fromJson(data);
      return {
        'success': true,
        'data': task,
      };
    } on UnauthorizedException catch (e) {
      return {'success': false, 'error': e.message, 'unauthorized': true};
    } on ValidationException catch (e) {
      return {'success': false, 'error': e.message};
    } on NotFoundException catch (e) {
      return {'success': false, 'error': e.message};
    } on RateLimitException catch (e) {
      return {'success': false, 'error': e.message, 'retryAfter': e.retryAfter};
    } on NetworkException catch (e) {
      return {'success': false, 'error': e.message};
    } on ApiException catch (e) {
      return {'success': false, 'error': e.message};
    } catch (e) {
      return {'success': false, 'error': 'Unexpected error: ${e.toString()}'};
    }
  }

  // Delete task
  Future<Map<String, dynamic>> deleteTask(String token, int taskId) async {
    try {
      await _apiClient.delete(
        '${ApiConfig.baseUrl}${ApiConfig.apiPrefix}/tasks/$taskId',
      );

      return {
        'success': true,
        'message': 'Task deleted successfully',
      };
    } on UnauthorizedException catch (e) {
      return {'success': false, 'error': e.message, 'unauthorized': true};
    } on NotFoundException catch (e) {
      return {'success': false, 'error': e.message};
    } on RateLimitException catch (e) {
      return {'success': false, 'error': e.message, 'retryAfter': e.retryAfter};
    } on NetworkException catch (e) {
      return {'success': false, 'error': e.message};
    } on ApiException catch (e) {
      return {'success': false, 'error': e.message};
    } catch (e) {
      return {'success': false, 'error': 'Unexpected error: ${e.toString()}'};
    }
  }

  // Toggle task status (convenience method for quick status changes)
  Future<Map<String, dynamic>> toggleTaskStatus({
    required String token,
    required int taskId,
    required String currentStatus,
  }) async {
    // Toggle between pending and completed
    final newStatus = currentStatus.toLowerCase() == 'pending'
        ? 'completed'
        : 'pending';

    return await updateTask(
      token: token,
      taskId: taskId,
      status: newStatus,
    );
  }
}
