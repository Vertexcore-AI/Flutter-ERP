import 'dart:convert';
import '../config/api_config.dart';
import 'api_client.dart';

class FungicideManagementService {
  final String baseUrl = '${ApiConfig.baseUrl}${ApiConfig.apiPrefix}';
  final _apiClient = ApiClient();

  /// Create a new fungicide application log
  /// Deducts stock from inventory and creates management record
  Future<Map<String, dynamic>> createFungicideLog(
      String token, Map<String, dynamic> data) async {
    try {
      final response = await _apiClient.post(
        '$baseUrl/fungicide-management',
        body: data,
      );

      return {
        'success': true,
        'data': json.decode(response.body),
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

  /// Fetch all fungicide logs for a specific crop
  /// Returns logs with inventory relation loaded
  Future<Map<String, dynamic>> fetchFungicideLogs(
      String token, int cropId) async {
    try {
      final response = await _apiClient.get(
        '$baseUrl/crops/$cropId/fungicide-management',
      );

      return {
        'success': true,
        'data': json.decode(response.body),
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

  /// Delete a fungicide application log
  /// Note: Does NOT restore inventory stock (non-reversible)
  Future<Map<String, dynamic>> deleteFungicideLog(
      String token, int id) async {
    try {
      final response = await _apiClient.delete(
        '$baseUrl/fungicide-management/$id',
      );

      return {
        'success': true,
        'data': json.decode(response.body),
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
}
