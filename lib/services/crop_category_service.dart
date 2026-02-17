import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/crop_category_model.dart';

class CropCategoryService {
  /// Fetch all crop categories
  Future<Map<String, dynamic>> fetchCategories(String token) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.apiPrefix}/crop-categories'),
        headers: ApiConfig.getAuthHeaders(token),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        final categories = data.map((item) => CropCategory.fromJson(item)).toList();

        return {'success': true, 'data': categories};
      } else {
        return {'success': false, 'error': 'Failed to fetch categories'};
      }
    } catch (e) {
      return {'success': false, 'error': 'Network error: ${e.toString()}'};
    }
  }

  /// Fetch crop types by category ID
  Future<Map<String, dynamic>> fetchTypesByCategory(String token, int categoryId) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.apiPrefix}/crop-categories/$categoryId/types'),
        headers: ApiConfig.getAuthHeaders(token),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        final types = data.map((item) => CropType.fromJson(item)).toList();

        return {'success': true, 'data': types};
      } else {
        return {'success': false, 'error': 'Failed to fetch crop types'};
      }
    } catch (e) {
      return {'success': false, 'error': 'Network error: ${e.toString()}'};
    }
  }

  /// Search crop types (optional - for future autocomplete feature)
  Future<Map<String, dynamic>> searchTypes(String token, {String? query, int? categoryId}) async {
    try {
      final queryParams = <String, String>{};
      if (query != null) queryParams['q'] = query;
      if (categoryId != null) queryParams['category_id'] = categoryId.toString();

      final uri = Uri.parse('${ApiConfig.baseUrl}${ApiConfig.apiPrefix}/crop-types/search')
          .replace(queryParameters: queryParams);

      final response = await http.get(uri, headers: ApiConfig.getAuthHeaders(token));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final types = (data['data'] as List).map((item) => CropType.fromJson(item)).toList();

        return {'success': true, 'data': types};
      } else {
        return {'success': false, 'error': 'Failed to search crop types'};
      }
    } catch (e) {
      return {'success': false, 'error': 'Network error: ${e.toString()}'};
    }
  }
}
