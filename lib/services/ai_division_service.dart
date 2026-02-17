import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/ai_division_model.dart';

class AIDivisionService {
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

      final response = await http.get(uri, headers: ApiConfig.headers);
      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        final List<AIDivision> divisions = (data['data'] as List)
            .map((item) => AIDivision.fromJson(item))
            .toList();

        return {
          'success': true,
          'data': divisions,
        };
      } else {
        return {
          'success': false,
          'error': 'Failed to fetch divisions',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'Network error: ${e.toString()}',
      };
    }
  }

  // Get all districts
  Future<Map<String, dynamic>> getDistricts() async {
    try {
      final response = await http.get(
        Uri.parse(
            '${ApiConfig.baseUrl}${ApiConfig.apiPrefix}/ai-divisions/districts'),
        headers: ApiConfig.headers,
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'data': List<String>.from(data['data']),
        };
      } else {
        return {
          'success': false,
          'error': 'Failed to fetch districts',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'Network error: ${e.toString()}',
      };
    }
  }

  // Get all provinces
  Future<Map<String, dynamic>> getProvinces() async {
    try {
      final response = await http.get(
        Uri.parse(
            '${ApiConfig.baseUrl}${ApiConfig.apiPrefix}/ai-divisions/provinces'),
        headers: ApiConfig.headers,
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'data': List<String>.from(data['data']),
        };
      } else {
        return {
          'success': false,
          'error': 'Failed to fetch provinces',
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
