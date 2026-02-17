import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/user_model.dart';

class UserService {
  // Get user profile
  Future<Map<String, dynamic>> getProfile(String token) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.apiPrefix}/user/profile'),
        headers: ApiConfig.getAuthHeaders(token),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'data': User.fromJson(data['data']),
        };
      } else {
        return {
          'success': false,
          'error': data['error'] ?? 'Failed to fetch profile',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'Network error: ${e.toString()}',
      };
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
      final response = await http.put(
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.apiPrefix}/user/profile'),
        headers: ApiConfig.getAuthHeaders(token),
        body: jsonEncode({
          'full_name': fullName,
          'date_of_birth': dateOfBirth.toIso8601String().split('T')[0],
          'ai_division_id': aiDivisionId,
          'sl_gap_certified': slGapCertified,
          'sl_gap_certificate_number': slGapCertificateNumber,
          'location': location,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'data': User.fromJson(data['data']),
          'message': data['message'],
        };
      } else {
        return {
          'success': false,
          'error': data['error'] ?? 'Failed to update profile',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'Network error: ${e.toString()}',
      };
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
      final response = await http.put(
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.apiPrefix}/user/password'),
        headers: ApiConfig.getAuthHeaders(token),
        body: jsonEncode({
          'current_password': currentPassword,
          'new_password': newPassword,
          'new_password_confirmation': newPasswordConfirmation,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': data['message'],
        };
      } else {
        return {
          'success': false,
          'error': data['error'] ?? 'Failed to update password',
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
