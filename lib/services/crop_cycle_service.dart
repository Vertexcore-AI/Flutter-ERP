import 'dart:convert';
import '../config/api_config.dart';
import '../models/crop_cycle_models.dart';
import 'api_client.dart';

class CropCycleService {
  final _apiClient = ApiClient();

  // ============================================================================
  // WATER MANAGEMENT ENDPOINTS
  // ============================================================================

  /// Fetch all water logs for a specific crop
  /// GET /api/crops/{cropId}/water-management
  Future<Map<String, dynamic>> fetchWaterLogs(String token, int cropId) async {
    try {
      final response = await _apiClient.get(
        '${ApiConfig.baseUrl}${ApiConfig.apiPrefix}/crops/$cropId/water-management',
      );

      final List<dynamic> jsonData = jsonDecode(response.body);
      final List<WaterManagement> logs =
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

  /// Create a new water log
  /// POST /api/water-management
  Future<Map<String, dynamic>> createWaterLog(
      String token, Map<String, dynamic> data) async {
    try {
      final response = await _apiClient.post(
        '${ApiConfig.baseUrl}${ApiConfig.apiPrefix}/water-management',
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

  /// Delete a water log
  /// DELETE /api/water-management/{id}
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

  // ============================================================================
  // FERTILIZER MANAGEMENT ENDPOINTS
  // ============================================================================

  /// Fetch all fertilizer logs for a specific crop
  /// GET /api/crops/{cropId}/fertilizer-management
  Future<Map<String, dynamic>> fetchFertilizerLogs(
      String token, int cropId) async {
    try {
      final response = await _apiClient.get(
        '${ApiConfig.baseUrl}${ApiConfig.apiPrefix}/crops/$cropId/fertilizer-management',
      );

      final List<dynamic> jsonData = jsonDecode(response.body);
      final List<FertilizerManagement> logs = jsonData
          .map((json) => FertilizerManagement.fromJson(json))
          .toList();
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

  /// Create a new fertilizer log
  /// POST /api/fertilizer-management
  Future<Map<String, dynamic>> createFertilizerLog(
      String token, Map<String, dynamic> data) async {
    try {
      final response = await _apiClient.post(
        '${ApiConfig.baseUrl}${ApiConfig.apiPrefix}/fertilizer-management',
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

  /// Delete a fertilizer log
  /// DELETE /api/fertilizer-management/{id}
  Future<Map<String, dynamic>> deleteFertilizerLog(
      String token, int id) async {
    try {
      await _apiClient.delete(
        '${ApiConfig.baseUrl}${ApiConfig.apiPrefix}/fertilizer-management/$id',
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

  // ============================================================================
  // PESTICIDE MANAGEMENT ENDPOINTS
  // ============================================================================

  /// Fetch all pesticide logs for a specific crop
  /// GET /api/crops/{cropId}/pesticide-management
  Future<Map<String, dynamic>> fetchPesticideLogs(
      String token, int cropId) async {
    try {
      final response = await _apiClient.get(
        '${ApiConfig.baseUrl}${ApiConfig.apiPrefix}/crops/$cropId/pesticide-management',
      );

      final List<dynamic> jsonData = jsonDecode(response.body);
      final List<PesticideManagement> logs =
          jsonData.map((json) => PesticideManagement.fromJson(json)).toList();
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

  /// Create a new pesticide log
  /// POST /api/pesticide-management
  Future<Map<String, dynamic>> createPesticideLog(
      String token, Map<String, dynamic> data) async {
    try {
      final response = await _apiClient.post(
        '${ApiConfig.baseUrl}${ApiConfig.apiPrefix}/pesticide-management',
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

  /// Delete a pesticide log
  /// DELETE /api/pesticide-management/{id}
  Future<Map<String, dynamic>> deletePesticideLog(String token, int id) async {
    try {
      await _apiClient.delete(
        '${ApiConfig.baseUrl}${ApiConfig.apiPrefix}/pesticide-management/$id',
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

  // ============================================================================
  // FUNGICIDE MANAGEMENT ENDPOINTS
  // ============================================================================

  /// Fetch all fungicide logs for a specific crop
  /// GET /api/crops/{cropId}/fungicide-management
  Future<Map<String, dynamic>> fetchFungicideLogs(
      String token, int cropId) async {
    try {
      final response = await _apiClient.get(
        '${ApiConfig.baseUrl}${ApiConfig.apiPrefix}/crops/$cropId/fungicide-management',
      );

      final List<dynamic> jsonData = jsonDecode(response.body);
      final List<FungicideManagement> logs =
          jsonData.map((json) => FungicideManagement.fromJson(json)).toList();
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

  /// Create a new fungicide log
  /// POST /api/fungicide-management
  Future<Map<String, dynamic>> createFungicideLog(
      String token, Map<String, dynamic> data) async {
    try {
      final response = await _apiClient.post(
        '${ApiConfig.baseUrl}${ApiConfig.apiPrefix}/fungicide-management',
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

  /// Delete a fungicide log
  /// DELETE /api/fungicide-management/{id}
  Future<Map<String, dynamic>> deleteFungicideLog(String token, int id) async {
    try {
      await _apiClient.delete(
        '${ApiConfig.baseUrl}${ApiConfig.apiPrefix}/fungicide-management/$id',
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

  // ============================================================================
  // CROP MAINTENANCE ENDPOINTS
  // ============================================================================

  /// Fetch crop maintenance configuration for a specific crop
  /// GET /api/crop-maintenance?crop_id={cropId}
  Future<Map<String, dynamic>> fetchMaintenanceConfig(
      String token, int cropId) async {
    try {
      final response = await _apiClient.get(
        '${ApiConfig.baseUrl}${ApiConfig.apiPrefix}/crop-maintenance?crop_id=$cropId',
      );

      final jsonData = jsonDecode(response.body);
      if (jsonData != null && jsonData is Map) {
        final CropMaintenance maintenance =
            CropMaintenance.fromJson(jsonData as Map<String, dynamic>);
        return {'success': true, 'data': maintenance};
      } else {
        return {'success': true, 'data': null}; // No config yet
      }
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

  /// Create crop maintenance configuration
  /// POST /api/crop-maintenance
  Future<Map<String, dynamic>> createMaintenanceConfig(
      String token, Map<String, dynamic> data) async {
    try {
      final response = await _apiClient.post(
        '${ApiConfig.baseUrl}${ApiConfig.apiPrefix}/crop-maintenance',
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

  /// Update crop maintenance configuration
  /// PUT /api/crop-maintenance/{id}
  Future<Map<String, dynamic>> updateMaintenanceConfig(
      String token, int id, Map<String, dynamic> data) async {
    try {
      final response = await _apiClient.put(
        '${ApiConfig.baseUrl}${ApiConfig.apiPrefix}/crop-maintenance/$id',
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

  /// Delete crop maintenance configuration
  /// DELETE /api/crop-maintenance/{id}
  Future<Map<String, dynamic>> deleteMaintenanceConfig(
      String token, int id) async {
    try {
      await _apiClient.delete(
        '${ApiConfig.baseUrl}${ApiConfig.apiPrefix}/crop-maintenance/$id',
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

  // ============================================================================
  // MAINTENANCE REPORTS ENDPOINTS
  // ============================================================================

  /// Fetch all maintenance reports for a specific crop
  /// GET /api/maintenance-reports?crop_id={cropId}
  Future<Map<String, dynamic>> fetchMaintenanceReports(
      String token, int cropId) async {
    try {
      final response = await _apiClient.get(
        '${ApiConfig.baseUrl}${ApiConfig.apiPrefix}/maintenance-reports?crop_id=$cropId',
      );

      final List<dynamic> jsonData = jsonDecode(response.body);
      final List<MaintenanceReport> reports =
          jsonData.map((json) => MaintenanceReport.fromJson(json)).toList();
      return {'success': true, 'data': reports};
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

  /// Create a new maintenance report
  /// POST /api/maintenance-reports
  Future<Map<String, dynamic>> createMaintenanceReport(
      String token, Map<String, dynamic> data) async {
    try {
      final response = await _apiClient.post(
        '${ApiConfig.baseUrl}${ApiConfig.apiPrefix}/maintenance-reports',
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

  /// Update a maintenance report
  /// PUT /api/maintenance-reports/{id}
  Future<Map<String, dynamic>> updateMaintenanceReport(
      String token, int id, Map<String, dynamic> data) async {
    try {
      final response = await _apiClient.put(
        '${ApiConfig.baseUrl}${ApiConfig.apiPrefix}/maintenance-reports/$id',
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

  /// Delete a maintenance report
  /// DELETE /api/maintenance-reports/{id}
  Future<Map<String, dynamic>> deleteMaintenanceReport(
      String token, int id) async {
    try {
      await _apiClient.delete(
        '${ApiConfig.baseUrl}${ApiConfig.apiPrefix}/maintenance-reports/$id',
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
