import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import 'secure_storage_service.dart';
import 'api_client.dart';

class AuthService {
  final _secureStorage = SecureStorageService();
  final _apiClient = ApiClient();
  /// Register new user (always requires reCAPTCHA)
  Future<Map<String, dynamic>> register({
    required String username,
    required String email,
    required String password,
    required String passwordConfirmation,
    required String recaptchaToken,
  }) async {
    try {
      final response = await _apiClient.post(
        ApiConfig.register,
        body: {
          'username': username,
          'email': email,
          'password': password,
          'password_confirmation': passwordConfirmation,
          'recaptcha_token': recaptchaToken,
        },
        requiresAuth: false, // Registration doesn't require auth
      );

      final data = jsonDecode(response.body);

      return {
        'success': true,
        'data': data,
      };
    } on ValidationException catch (e) {
      return {
        'success': false,
        'error': e.message,
      };
    } on RateLimitException catch (e) {
      return {
        'success': false,
        'error': e.message,
        'retryAfter': e.retryAfter,
      };
    } on NetworkException catch (e) {
      return {
        'success': false,
        'error': e.message,
      };
    } on ApiException catch (e) {
      return {
        'success': false,
        'error': e.message,
      };
    } catch (e) {
      return {
        'success': false,
        'error': 'Unexpected error: ${e.toString()}',
      };
    }
  }

  /// Login
  /// Returns Map with:
  /// - success: bool
  /// - data: response data
  /// - error: error message
  /// - recaptcha_required: bool (if reCAPTCHA is needed)
  Future<Map<String, dynamic>> login({
    required String username,
    required String password,
    String? recaptchaToken,
    bool rememberMe = false,
  }) async {
    try {
      // Build request body
      final body = {
        'username': username,
        'password': password,
        'remember_me': rememberMe,
        if (recaptchaToken != null && recaptchaToken.isNotEmpty)
          'recaptcha_token': recaptchaToken,
      };

      final response = await _apiClient.post(
        ApiConfig.login,
        body: body,
        requiresAuth: false, // Login doesn't require auth
      );

      final data = jsonDecode(response.body);

      // Check if reCAPTCHA is required (422 response with special flag)
      if (data['recaptcha_required'] == true) {
        return {
          'success': false,
          'recaptcha_required': true,
          'error': data['error'] ?? 'reCAPTCHA verification required',
        };
      }

      // Success - save token securely
      final token = data['data']['access_token'];
      await _secureStorage.saveAuthToken(token);

      return {
        'success': true,
        'data': data['data'],
      };
    } on ValidationException catch (e) {
      return {
        'success': false,
        'error': e.message,
      };
    } on RateLimitException catch (e) {
      return {
        'success': false,
        'error': e.message,
        'retryAfter': e.retryAfter,
      };
    } on NetworkException catch (e) {
      return {
        'success': false,
        'error': e.message,
      };
    } on ApiException catch (e) {
      return {
        'success': false,
        'error': e.message,
      };
    } catch (e) {
      return {
        'success': false,
        'error': 'Unexpected error: ${e.toString()}',
      };
    }
  }

  /// Logout user
  Future<Map<String, dynamic>> logout() async {
    try {
      final token = await _secureStorage.getAuthToken();
      if (token == null) {
        return {'success': false, 'error': 'Not logged in'};
      }

      final response = await http.post(
        Uri.parse(ApiConfig.logout),
        headers: ApiConfig.getAuthHeaders(token),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        // Clear secure storage
        await _secureStorage.clearAll();
        return {
          'success': true,
          'message': data['message'],
        };
      } else {
        return {
          'success': false,
          'error': 'Logout failed',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'Network error: ${e.toString()}',
      };
    }
  }

  /// Get current user
  Future<Map<String, dynamic>> getCurrentUser() async {
    try {
      final token = await _secureStorage.getAuthToken();
      if (token == null) {
        return {'success': false, 'error': 'Not logged in'};
      }

      final response = await http.get(
        Uri.parse(ApiConfig.me),
        headers: ApiConfig.getAuthHeaders(token),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'data': data['data'],
        };
      } else {
        return {
          'success': false,
          'error': 'Failed to get user data',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'Network error: ${e.toString()}',
      };
    }
  }

  /// Verify email with token
  Future<Map<String, dynamic>> verifyEmail({
    required String token,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConfig.verifyEmail),
        headers: ApiConfig.headers,
        body: jsonEncode({
          'token': token,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        // Save token securely (auto-login after verification)
        final authToken = data['data']['access_token'];
        await _secureStorage.saveAuthToken(authToken);

        return {
          'success': true,
          'data': data['data'],
          'message': data['message'],
        };
      } else {
        return {
          'success': false,
          'error': data['error'] ?? 'Email verification failed',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'Network error: ${e.toString()}',
      };
    }
  }
}
