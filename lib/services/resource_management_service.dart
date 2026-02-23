import 'dart:convert';
import '../config/api_config.dart';
import '../models/fertilizer_management_model.dart';
import '../models/pesticide_management_model.dart';
import '../models/fungicide_management_model.dart';
import '../models/inventory_item_model.dart';
import 'api_client.dart';

class ResourceManagementService {
  final _apiClient = ApiClient();
  // FERTILIZER MANAGEMENT
  Future<Map<String, dynamic>> createFertilizerLog(
    String token,
    Map<String, dynamic> data,
  ) async {
    return _createResourceLog(token, 'fertilizer-management', data);
  }

  Future<Map<String, dynamic>> fetchFertilizerLogs(
      String token, int cropId) async {
    return _fetchResourceLogs(token, cropId, 'fertilizer-management',
        (json) => FertilizerManagement.fromJson(json));
  }

  Future<Map<String, dynamic>> deleteFertilizerLog(
      String token, int id) async {
    return _deleteResourceLog(token, 'fertilizer-management', id);
  }

  // PESTICIDE MANAGEMENT
  Future<Map<String, dynamic>> createPesticideLog(
    String token,
    Map<String, dynamic> data,
  ) async {
    return _createResourceLog(token, 'pesticide-management', data);
  }

  Future<Map<String, dynamic>> fetchPesticideLogs(
      String token, int cropId) async {
    return _fetchResourceLogs(token, cropId, 'pesticide-management',
        (json) => PesticideManagement.fromJson(json));
  }

  Future<Map<String, dynamic>> deletePesticideLog(String token, int id) async {
    return _deleteResourceLog(token, 'pesticide-management', id);
  }

  // FUNGICIDE MANAGEMENT
  Future<Map<String, dynamic>> createFungicideLog(
    String token,
    Map<String, dynamic> data,
  ) async {
    return _createResourceLog(token, 'fungicide-management', data);
  }

  Future<Map<String, dynamic>> fetchFungicideLogs(
      String token, int cropId) async {
    return _fetchResourceLogs(token, cropId, 'fungicide-management',
        (json) => FungicideManagement.fromJson(json));
  }

  Future<Map<String, dynamic>> deleteFungicideLog(String token, int id) async {
    return _deleteResourceLog(token, 'fungicide-management', id);
  }

  // INVENTORY
  Future<Map<String, dynamic>> fetchInventory(String token) async {
    try {
      final response = await _apiClient.get(
        '${ApiConfig.baseUrl}${ApiConfig.apiPrefix}/inventory',
      );

      final List<dynamic> jsonData = jsonDecode(response.body);
      final items =
          jsonData.map((json) => InventoryItem.fromJson(json)).toList();
      return {'success': true, 'data': items};
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

  // PRIVATE HELPER METHODS
  Future<Map<String, dynamic>> _createResourceLog(
    String token,
    String endpoint,
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await _apiClient.post(
        '${ApiConfig.baseUrl}${ApiConfig.apiPrefix}/$endpoint',
        body: data,
      );

      final jsonData = jsonDecode(response.body);
      return {'success': true, 'data': jsonData};
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

  Future<Map<String, dynamic>> _fetchResourceLogs(
    String token,
    int cropId,
    String endpoint,
    Function fromJsonFactory,
  ) async {
    try {
      final response = await _apiClient.get(
        '${ApiConfig.baseUrl}${ApiConfig.apiPrefix}/crops/$cropId/$endpoint',
      );

      final List<dynamic> jsonData = jsonDecode(response.body);
      final logs = jsonData.map((json) => fromJsonFactory(json)).toList();
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

  Future<Map<String, dynamic>> _deleteResourceLog(
    String token,
    String endpoint,
    int id,
  ) async {
    try {
      await _apiClient.delete(
        '${ApiConfig.baseUrl}${ApiConfig.apiPrefix}/$endpoint/$id',
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
