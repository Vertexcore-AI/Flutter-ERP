import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/crop_model.dart';

class CropService {
  // Fetch all crops
  Future<Map<String, dynamic>> fetchCrops(String token) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.apiPrefix}/crops'),
        headers: ApiConfig.getAuthHeaders(token),
      );

      final data = jsonDecode(response.body);
      print('CropService.fetchCrops - response status: ${response.statusCode}'); // DEBUG
      print('CropService.fetchCrops - raw data: $data'); // DEBUG

      if (response.statusCode == 200) {
        // Backend returns array directly (not wrapped in 'data' key)
        try {
          final List<Crop> crops = (data as List)
              .map((item) {
                try {
                  return Crop.fromJson(item);
                } catch (e) {
                  print('CropService.fetchCrops - Error parsing crop item: $e'); // DEBUG
                  print('CropService.fetchCrops - Item data: $item'); // DEBUG
                  rethrow;
                }
              })
              .toList();

          print('CropService.fetchCrops - parsed ${crops.length} crops'); // DEBUG
          return {
            'success': true,
            'data': crops,
          };
        } catch (e) {
          print('CropService.fetchCrops - Error parsing crops list: $e'); // DEBUG
          return {
            'success': false,
            'error': 'Failed to parse crops: ${e.toString()}',
          };
        }
      } else {
        return {
          'success': false,
          'error': data['message'] ?? 'Failed to fetch crops',
        };
      }
    } catch (e) {
      print('CropService.fetchCrops - Network error: $e'); // DEBUG
      return {
        'success': false,
        'error': 'Network error: ${e.toString()}',
      };
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

      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.apiPrefix}/crops'),
        headers: ApiConfig.getAuthHeaders(token),
        body: jsonEncode(requestBody),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 201) {
        // Backend returns the created crop object directly
        final crop = Crop.fromJson(data);
        return {
          'success': true,
          'data': crop,
        };
      } else {
        return {
          'success': false,
          'error': data['message'] ?? data['error'] ?? 'Failed to create crop',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'Network error: ${e.toString()}',
      };
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

      final response = await http.put(
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.apiPrefix}/crops/$cropId'),
        headers: ApiConfig.getAuthHeaders(token),
        body: jsonEncode(requestBody),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        // Backend returns the updated crop object
        final crop = Crop.fromJson(data);
        return {
          'success': true,
          'data': crop,
        };
      } else {
        return {
          'success': false,
          'error': data['message'] ?? data['error'] ?? 'Failed to update crop',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'Network error: ${e.toString()}',
      };
    }
  }

  // Delete crop
  Future<Map<String, dynamic>> deleteCrop(String token, int cropId) async {
    try {
      final response = await http.delete(
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.apiPrefix}/crops/$cropId'),
        headers: ApiConfig.getAuthHeaders(token),
      );

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': 'Crop deleted successfully',
        };
      } else {
        final data = jsonDecode(response.body);
        return {
          'success': false,
          'error': data['message'] ?? 'Failed to delete crop',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'Network error: ${e.toString()}',
      };
    }
  }

  // Get single crop by ID
  Future<Map<String, dynamic>> getCrop(String token, int cropId) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.apiPrefix}/crops/$cropId'),
        headers: ApiConfig.getAuthHeaders(token),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        final crop = Crop.fromJson(data);
        return {
          'success': true,
          'data': crop,
        };
      } else {
        return {
          'success': false,
          'error': data['message'] ?? 'Failed to fetch crop',
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
