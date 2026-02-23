import 'dart:convert';
import '../config/api_config.dart';
import '../models/crop_model.dart';
import 'api_client.dart';

class CropService {
  final _apiClient = ApiClient();
  // Fetch all crops
  Future<Map<String, dynamic>> fetchCrops(String token) async {
    try {
      final response = await _apiClient.get(
        '${ApiConfig.baseUrl}${ApiConfig.apiPrefix}/crops',
      );

      final data = jsonDecode(response.body);

      try {
        final List<Crop> crops = (data as List)
            .map((item) => Crop.fromJson(item))
            .toList();

        return {
          'success': true,
          'data': crops,
        };
      } catch (e) {
        return {
          'success': false,
          'error': 'Failed to parse crops: ${e.toString()}',
        };
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

  // Create new crop
  Future<Map<String, dynamic>> createCrop({
    required String token,
    required String farmName,
    required int cropCategoryId, // NEW
    required int cropTypeId, // NEW
    required String cropType, // Deprecated - backend will populate from crop_type_id
    required DateTime startDate,
    required int plants,
    required String status,
    required int farmId,
    DateTime? expectedHarvestDate,
    String? notes,
    double? waterUsage,
  }) async {
    try {
      final requestBody = {
        'name': farmName, // Required by backend - uses farm name
        'crop_category_id': cropCategoryId, // NEW
        'crop_type_id': cropTypeId, // NEW
        'crop_type': cropType, // Deprecated - backend will override
        'start_date': startDate.toIso8601String().split('T')[0], // YYYY-MM-DD
        'plants': plants,
        'status': status,
        'farm_id': farmId,
      };

      // Add optional fields
      if (expectedHarvestDate != null) {
        requestBody['expected_harvest_date'] =
            expectedHarvestDate.toIso8601String().split('T')[0];
      }
      if (notes != null && notes.isNotEmpty) {
        requestBody['notes'] = notes;
      }
      if (waterUsage != null) {
        requestBody['water_usage'] = waterUsage;
      }

      final response = await _apiClient.post(
        '${ApiConfig.baseUrl}${ApiConfig.apiPrefix}/crops',
        body: requestBody,
      );

      final data = jsonDecode(response.body);
      final crop = Crop.fromJson(data);
      return {
        'success': true,
        'data': crop,
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

  // Update existing crop
  Future<Map<String, dynamic>> updateCrop({
    required String token,
    required int cropId,
    required String farmName,
    required int cropCategoryId, // NEW
    required int cropTypeId, // NEW
    required String cropType, // Deprecated - backend will populate from crop_type_id
    required DateTime startDate,
    required int plants,
    required String status,
    required int farmId,
    DateTime? expectedHarvestDate,
    String? notes,
    double? waterUsage,
    String? totalHarvest,
  }) async {
    try {
      final requestBody = {
        'name': farmName, // Required by backend - uses farm name
        'crop_category_id': cropCategoryId, // NEW
        'crop_type_id': cropTypeId, // NEW
        'crop_type': cropType, // Deprecated - backend will override
        'start_date': startDate.toIso8601String().split('T')[0],
        'plants': plants,
        'status': status,
        'farm_id': farmId,
      };

      // Add optional fields
      if (expectedHarvestDate != null) {
        requestBody['expected_harvest_date'] =
            expectedHarvestDate.toIso8601String().split('T')[0];
      }
      if (notes != null && notes.isNotEmpty) {
        requestBody['notes'] = notes;
      }
      if (waterUsage != null) {
        requestBody['water_usage'] = waterUsage;
      }
      if (totalHarvest != null && totalHarvest.isNotEmpty) {
        requestBody['total_harvest'] = totalHarvest;
      }

      final response = await _apiClient.put(
        '${ApiConfig.baseUrl}${ApiConfig.apiPrefix}/crops/$cropId',
        body: requestBody,
      );

      final data = jsonDecode(response.body);
      // Backend returns the updated crop object
      final crop = Crop.fromJson(data);
      return {
        'success': true,
        'data': crop,
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

  // Delete crop
  Future<Map<String, dynamic>> deleteCrop(String token, int cropId) async {
    try {
      await _apiClient.delete(
        '${ApiConfig.baseUrl}${ApiConfig.apiPrefix}/crops/$cropId',
      );

      return {
        'success': true,
        'message': 'Crop deleted successfully',
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

  // Get single crop by ID
  Future<Map<String, dynamic>> getCrop(String token, int cropId) async {
    try {
      final response = await _apiClient.get(
        '${ApiConfig.baseUrl}${ApiConfig.apiPrefix}/crops/$cropId',
      );

      final data = jsonDecode(response.body);
      final crop = Crop.fromJson(data);
      return {
        'success': true,
        'data': crop,
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
