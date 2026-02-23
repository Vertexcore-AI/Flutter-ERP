import 'dart:convert';
import '../config/api_config.dart';
import '../models/ai_division_model.dart';
import 'api_client.dart';

class AIDivisionService {
  final _apiClient = ApiClient();
  // Search AI divisions
  Future<Map<String, dynamic>> search({
    String? query,
    String? district,
    String? province,
    int limit = 50,
  }) async {
    try {
      // Build query parameters
      final queryParams = <String, String>{};
      if (query != null && query.isNotEmpty) queryParams['q'] = query;
      if (district != null) queryParams['district'] = district;
      if (province != null) queryParams['province'] = province;
      queryParams['limit'] = limit.toString();

      final uri = Uri.parse(
        '${ApiConfig.baseUrl}${ApiConfig.apiPrefix}/ai-divisions/search',
      ).replace(queryParameters: queryParams);

      final response = await _apiClient.get(uri.toString(), requiresAuth: false);
      final data = jsonDecode(response.body);

      final List<AIDivision> divisions = (data['data'] as List)
          .map((item) => AIDivision.fromJson(item))
          .toList();

      return {
        'success': true,
        'data': divisions,
      };
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

  // Get all districts
  Future<Map<String, dynamic>> getDistricts() async {
    try {
      final response = await _apiClient.get(
        '${ApiConfig.baseUrl}${ApiConfig.apiPrefix}/ai-divisions/districts',
        requiresAuth: false,
      );

      final data = jsonDecode(response.body);
      return {
        'success': true,
        'data': List<String>.from(data['data']),
      };
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

  // Get all provinces
  Future<Map<String, dynamic>> getProvinces() async {
    try {
      final response = await _apiClient.get(
        '${ApiConfig.baseUrl}${ApiConfig.apiPrefix}/ai-divisions/provinces',
        requiresAuth: false,
      );

      final data = jsonDecode(response.body);
      return {
        'success': true,
        'data': List<String>.from(data['data']),
      };
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
