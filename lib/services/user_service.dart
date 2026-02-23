import 'dart:convert';
import '../config/api_config.dart';
import '../models/user_model.dart';
import 'api_client.dart';

class UserService {
  final _apiClient = ApiClient();
  // Get user profile
  Future<Map<String, dynamic>> getProfile(String token) async {
    try {
      final response = await _apiClient.get(
        '${ApiConfig.baseUrl}${ApiConfig.apiPrefix}/user/profile',
      );

      final data = jsonDecode(response.body);
      return {
        'success': true,
        'data': User.fromJson(data['data']),
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

  // Update user profile
  Future<Map<String, dynamic>> updateProfile({
    required String token,
    required String fullName,
    required DateTime dateOfBirth,
    required int aiDivisionId,
    required bool slGapCertified,
    String? slGapCertificateNumber,
    String? location,
  }) async {
    try {
      final response = await _apiClient.put(
        '${ApiConfig.baseUrl}${ApiConfig.apiPrefix}/user/profile',
        body: {
          'full_name': fullName,
          'date_of_birth': dateOfBirth.toIso8601String().split('T')[0],
          'ai_division_id': aiDivisionId,
          'sl_gap_certified': slGapCertified,
          'sl_gap_certificate_number': slGapCertificateNumber,
          'location': location,
        },
      );

      final data = jsonDecode(response.body);
      return {
        'success': true,
        'data': User.fromJson(data['data']),
        'message': data['message'],
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

  // Update password
  Future<Map<String, dynamic>> updatePassword({
    required String token,
    required String currentPassword,
    required String newPassword,
    required String newPasswordConfirmation,
  }) async {
    try {
      final response = await _apiClient.put(
        '${ApiConfig.baseUrl}${ApiConfig.apiPrefix}/user/password',
        body: {
          'current_password': currentPassword,
          'new_password': newPassword,
          'new_password_confirmation': newPasswordConfirmation,
        },
      );

      final data = jsonDecode(response.body);
      return {
        'success': true,
        'message': data['message'],
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
}
