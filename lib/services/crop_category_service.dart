import 'dart:convert';
import '../config/api_config.dart';
import '../models/crop_category_model.dart';
import 'api_client.dart';

class CropCategoryService {
  final _apiClient = ApiClient();
  /// Fetch all crop categories
  Future<Map<String, dynamic>> fetchCategories(String token) async {
    try {
      final response = await _apiClient.get(
        '${ApiConfig.baseUrl}${ApiConfig.apiPrefix}/crop-categories',
      );

      final List<dynamic> data = jsonDecode(response.body);
      final categories = data.map((item) => CropCategory.fromJson(item)).toList();

      return {'success': true, 'data': categories};
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

  /// Fetch crop types by category ID
  Future<Map<String, dynamic>> fetchTypesByCategory(String token, int categoryId) async {
    try {
      final response = await _apiClient.get(
        '${ApiConfig.baseUrl}${ApiConfig.apiPrefix}/crop-categories/$categoryId/types',
      );

      final List<dynamic> data = jsonDecode(response.body);
      final types = data.map((item) => CropType.fromJson(item)).toList();

      return {'success': true, 'data': types};
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

  /// Search crop types (optional - for future autocomplete feature)
  Future<Map<String, dynamic>> searchTypes(String token, {String? query, int? categoryId}) async {
    try {
      final queryParams = <String, String>{};
      if (query != null) queryParams['q'] = query;
      if (categoryId != null) queryParams['category_id'] = categoryId.toString();

      final uri = Uri.parse('${ApiConfig.baseUrl}${ApiConfig.apiPrefix}/crop-types/search')
          .replace(queryParameters: queryParams);

      final response = await _apiClient.get(uri.toString());

      final data = jsonDecode(response.body);
      final types = (data['data'] as List).map((item) => CropType.fromJson(item)).toList();

      return {'success': true, 'data': types};
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
