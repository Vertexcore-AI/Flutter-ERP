import 'dart:convert';
import '../config/api_config.dart';
import '../models/water_management_model.dart';
import 'api_client.dart';

class WaterManagementService {
  final _apiClient = ApiClient();
  // Create new water log
  Future<Map<String, dynamic>> createWaterLog(
    String token,
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await _apiClient.post(
        '${ApiConfig.baseUrl}${ApiConfig.apiPrefix}/water-management',
        body: data,
      );

      final jsonData = jsonDecode(response.body);
      return {
        'success': true,
        'data': WaterManagement.fromJson(jsonData)
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

  // Fetch water logs for a crop
  Future<Map<String, dynamic>> fetchWaterLogs(String token, int cropId) async {
    try {
      final response = await _apiClient.get(
        '${ApiConfig.baseUrl}${ApiConfig.apiPrefix}/crops/$cropId/water-management',
      );

      final List<dynamic> jsonData = jsonDecode(response.body);
      final logs =
          jsonData.map((json) => WaterManagement.fromJson(json)).toList();
      return {'success': true, 'data': logs};
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

  // Delete water log
  Future<Map<String, dynamic>> deleteWaterLog(String token, int id) async {
    try {
      await _apiClient.delete(
        '${ApiConfig.baseUrl}${ApiConfig.apiPrefix}/water-management/$id',
      );

      return {'success': true};
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
}
