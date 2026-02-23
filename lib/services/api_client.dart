import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import '../config/api_config.dart';
import 'secure_storage_service.dart';

/// Centralized API client with automatic error handling
/// Handles 401 (Unauthorized), 404 (Not Found), 429 (Rate Limit), and network errors
class ApiClient {
  static final ApiClient _instance = ApiClient._internal();
  factory ApiClient() => _instance;
  ApiClient._internal();

  final _secureStorage = SecureStorageService();

  /// Global context for navigation (set in main.dart)
  static GlobalKey<NavigatorState>? navigatorKey;

  /// GET request with error handling
  Future<http.Response> get(
    String url, {
    Map<String, String>? headers,
    bool requiresAuth = true,
  }) async {
    try {
      final Map<String, String> requestHeaders = headers ?? {};

      if (requiresAuth) {
        final token = await _secureStorage.getAuthToken();
        if (token == null) {
          throw UnauthorizedException('No authentication token found');
        }
        requestHeaders['Authorization'] = 'Bearer $token';
      }

      requestHeaders['Accept'] = 'application/json';
      requestHeaders['Content-Type'] = 'application/json';

      final response = await http
          .get(
            Uri.parse(url),
            headers: requestHeaders,
          )
          .timeout(const Duration(seconds: 30));

      return _handleResponse(response);
    } on SocketException {
      throw NetworkException('No internet connection');
    } on TimeoutException {
      throw NetworkException('Request timeout');
    } catch (e) {
      rethrow;
    }
  }

  /// POST request with error handling
  Future<http.Response> post(
    String url, {
    Map<String, String>? headers,
    Object? body,
    bool requiresAuth = true,
  }) async {
    try {
      final Map<String, String> requestHeaders = headers ?? {};

      if (requiresAuth) {
        final token = await _secureStorage.getAuthToken();
        if (token == null) {
          throw UnauthorizedException('No authentication token found');
        }
        requestHeaders['Authorization'] = 'Bearer $token';
      }

      requestHeaders['Accept'] = 'application/json';
      requestHeaders['Content-Type'] = 'application/json';

      final response = await http
          .post(
            Uri.parse(url),
            headers: requestHeaders,
            body: body != null ? jsonEncode(body) : null,
          )
          .timeout(const Duration(seconds: 30));

      return _handleResponse(response);
    } on SocketException {
      throw NetworkException('No internet connection');
    } on TimeoutException {
      throw NetworkException('Request timeout');
    } catch (e) {
      rethrow;
    }
  }

  /// PUT request with error handling
  Future<http.Response> put(
    String url, {
    Map<String, String>? headers,
    Object? body,
    bool requiresAuth = true,
  }) async {
    try {
      final Map<String, String> requestHeaders = headers ?? {};

      if (requiresAuth) {
        final token = await _secureStorage.getAuthToken();
        if (token == null) {
          throw UnauthorizedException('No authentication token found');
        }
        requestHeaders['Authorization'] = 'Bearer $token';
      }

      requestHeaders['Accept'] = 'application/json';
      requestHeaders['Content-Type'] = 'application/json';

      final response = await http
          .put(
            Uri.parse(url),
            headers: requestHeaders,
            body: body != null ? jsonEncode(body) : null,
          )
          .timeout(const Duration(seconds: 30));

      return _handleResponse(response);
    } on SocketException {
      throw NetworkException('No internet connection');
    } on TimeoutException {
      throw NetworkException('Request timeout');
    } catch (e) {
      rethrow;
    }
  }

  /// DELETE request with error handling
  Future<http.Response> delete(
    String url, {
    Map<String, String>? headers,
    bool requiresAuth = true,
  }) async {
    try {
      final Map<String, String> requestHeaders = headers ?? {};

      if (requiresAuth) {
        final token = await _secureStorage.getAuthToken();
        if (token == null) {
          throw UnauthorizedException('No authentication token found');
        }
        requestHeaders['Authorization'] = 'Bearer $token';
      }

      requestHeaders['Accept'] = 'application/json';
      requestHeaders['Content-Type'] = 'application/json';

      final response = await http
          .delete(
            Uri.parse(url),
            headers: requestHeaders,
          )
          .timeout(const Duration(seconds: 30));

      return _handleResponse(response);
    } on SocketException {
      throw NetworkException('No internet connection');
    } on TimeoutException {
      throw NetworkException('Request timeout');
    } catch (e) {
      rethrow;
    }
  }

  /// Handle HTTP response and throw appropriate exceptions
  http.Response _handleResponse(http.Response response) {
    switch (response.statusCode) {
      case 200:
      case 201:
      case 204:
        return response;

      case 401:
        // Unauthorized - token expired or invalid
        _handleUnauthorized();
        throw UnauthorizedException('Session expired. Please login again.');

      case 403:
        // Forbidden - user doesn't have permission
        throw ForbiddenException('You do not have permission to access this resource');

      case 404:
        // Not found - resource doesn't exist or doesn't belong to user
        final data = _tryParseJson(response.body);
        final message = data?['message'] ?? 'Resource not found or you do not have access';
        throw NotFoundException(message);

      case 422:
        // Validation error - but check for special flags first
        final data = _tryParseJson(response.body);

        // If recaptcha_required flag is present, return the response (don't throw)
        if (data?['recaptcha_required'] == true) {
          return response;
        }

        final errors = data?['errors'] as Map<String, dynamic>?;
        final message = _formatValidationErrors(errors) ?? data?['message'] ?? 'Validation failed';
        throw ValidationException(message);

      case 429:
        // Rate limit exceeded
        final data = _tryParseJson(response.body);
        final retryAfter = response.headers['retry-after'];
        final message = data?['message'] ?? 'Too many requests. Please try again later.';
        throw RateLimitException(message, retryAfter: retryAfter);

      case 500:
      case 502:
      case 503:
        throw ServerException('Server error. Please try again later.');

      default:
        final data = _tryParseJson(response.body);
        final message = data?['message'] ?? 'An error occurred';
        throw ApiException(message, statusCode: response.statusCode);
    }
  }

  /// Handle 401 Unauthorized - logout and redirect to login
  Future<void> _handleUnauthorized() async {
    // Clear stored token
    await _secureStorage.deleteAuthToken();

    // Navigate to login screen
    if (navigatorKey?.currentContext != null) {
      Navigator.of(navigatorKey!.currentContext!).pushNamedAndRemoveUntil(
        '/login',
        (route) => false,
      );

      // Show snackbar notification
      ScaffoldMessenger.of(navigatorKey!.currentContext!).showSnackBar(
        const SnackBar(
          content: Text('Session expired. Please login again.'),
          backgroundColor: Colors.orange,
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  /// Try to parse JSON safely
  Map<String, dynamic>? _tryParseJson(String body) {
    try {
      return jsonDecode(body) as Map<String, dynamic>;
    } catch (e) {
      return null;
    }
  }

  /// Format validation errors into readable message
  String? _formatValidationErrors(Map<String, dynamic>? errors) {
    if (errors == null || errors.isEmpty) return null;

    final messages = <String>[];
    errors.forEach((field, value) {
      if (value is List) {
        messages.addAll(value.cast<String>());
      } else if (value is String) {
        messages.add(value);
      }
    });

    return messages.join('\n');
  }
}

// ============================================================================
// Custom Exception Classes
// ============================================================================

class ApiException implements Exception {
  final String message;
  final int? statusCode;

  ApiException(this.message, {this.statusCode});

  @override
  String toString() => message;
}

class NetworkException extends ApiException {
  NetworkException(super.message);
}

class UnauthorizedException extends ApiException {
  UnauthorizedException(super.message) : super(statusCode: 401);
}

class ForbiddenException extends ApiException {
  ForbiddenException(super.message) : super(statusCode: 403);
}

class NotFoundException extends ApiException {
  NotFoundException(super.message) : super(statusCode: 404);
}

class ValidationException extends ApiException {
  ValidationException(super.message) : super(statusCode: 422);
}

class RateLimitException extends ApiException {
  final String? retryAfter;

  RateLimitException(super.message, {this.retryAfter}) : super(statusCode: 429);
}

class ServerException extends ApiException {
  ServerException(super.message) : super(statusCode: 500);
}

class TimeoutException extends NetworkException {
  TimeoutException(super.message);
}
