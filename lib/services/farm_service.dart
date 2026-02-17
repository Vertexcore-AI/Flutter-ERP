import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import '../config/api_config.dart';
import '../models/farm_model.dart';

class FarmService {
  // Fetch all farms
  Future<Map<String, dynamic>> fetchFarms(String token) async {
    try {
      final response = await http.get(
        Uri.parse(ApiConfig.farms),
        headers: ApiConfig.getAuthHeaders(token),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        // Backend returns array directly (not wrapped in 'data' key)
        final List<Farm> farms = (data as List)
            .map((item) => Farm.fromJson(item))
            .toList();

        return {
          'success': true,
          'data': farms,
        };
      } else {
        return {
          'success': false,
          'error': data['message'] ?? 'Failed to fetch farms',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'Network error: ${e.toString()}',
      };
    }
  }

  // Create new farm
  Future<Map<String, dynamic>> createFarm({
    required String token,
    required String name,
    required String mainCategory,
    required String category,
    required String area,
    required String areaUnit,
    String? location,
    double? latitude,
    double? longitude,
    String? notes,
    File? imageFile,
  }) async {
    try {
      final uri = Uri.parse(ApiConfig.farms);
      final request = http.MultipartRequest('POST', uri);

      // Add auth header
      request.headers.addAll({
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      });

      // Add text fields
      request.fields['name'] = name;
      request.fields['main_category'] = mainCategory;
      request.fields['category'] = category;
      request.fields['area'] = area;
      request.fields['area_unit'] = areaUnit;
      if (location != null && location.isNotEmpty) {
        request.fields['location'] = location;
      }
      if (latitude != null) {
        request.fields['latitude'] = latitude.toString();
      }
      if (longitude != null) {
        request.fields['longitude'] = longitude.toString();
      }
      if (notes != null && notes.isNotEmpty) {
        request.fields['notes'] = notes;
      }

      // Add image file if provided
      if (imageFile != null) {
        final mimeType = _getMimeType(imageFile.path);
        request.files.add(
          await http.MultipartFile.fromPath(
            'image',
            imageFile.path,
            contentType: MediaType.parse(mimeType),
          ),
        );
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      final data = jsonDecode(response.body);

      if (response.statusCode == 201) {
        return {
          'success': true,
          'data': Farm.fromJson(data),
          'message': 'Farm created successfully',
        };
      } else {
        return {
          'success': false,
          'error': data['message'] ?? 'Failed to create farm',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'Network error: ${e.toString()}',
      };
    }
  }

  // Update existing farm
  Future<Map<String, dynamic>> updateFarm({
    required String token,
    required int farmId,
    required String name,
    required String mainCategory,
    required String category,
    required String area,
    required String areaUnit,
    String? location,
    double? latitude,
    double? longitude,
    String? notes,
    File? imageFile,
  }) async {
    try {
      final uri = Uri.parse('${ApiConfig.farms}/$farmId');
      final request = http.MultipartRequest('POST', uri); // POST for multipart

      // Add auth header
      request.headers.addAll({
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      });

      // Laravel multipart update workaround
      request.fields['_method'] = 'PUT';

      // Add text fields
      request.fields['name'] = name;
      request.fields['main_category'] = mainCategory;
      request.fields['category'] = category;
      request.fields['area'] = area;
      request.fields['area_unit'] = areaUnit;
      if (location != null && location.isNotEmpty) {
        request.fields['location'] = location;
      }
      if (latitude != null) {
        request.fields['latitude'] = latitude.toString();
      }
      if (longitude != null) {
        request.fields['longitude'] = longitude.toString();
      }
      if (notes != null && notes.isNotEmpty) {
        request.fields['notes'] = notes;
      }

      // Add image file if provided
      if (imageFile != null) {
        final mimeType = _getMimeType(imageFile.path);
        request.files.add(
          await http.MultipartFile.fromPath(
            'image',
            imageFile.path,
            contentType: MediaType.parse(mimeType),
          ),
        );
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'data': Farm.fromJson(data),
          'message': 'Farm updated successfully',
        };
      } else {
        return {
          'success': false,
          'error': data['message'] ?? 'Failed to update farm',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'Network error: ${e.toString()}',
      };
    }
  }

  // Delete farm
  Future<Map<String, dynamic>> deleteFarm({
    required String token,
    required int farmId,
  }) async {
    try {
      final response = await http.delete(
        Uri.parse('${ApiConfig.farms}/$farmId'),
        headers: ApiConfig.getAuthHeaders(token),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': data['message'] ?? 'Farm deleted successfully',
        };
      } else {
        return {
          'success': false,
          'error': data['message'] ?? 'Failed to delete farm',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'Network error: ${e.toString()}',
      };
    }
  }

  // Helper: Determine MIME type from file extension
  String _getMimeType(String path) {
    final extension = path.split('.').last.toLowerCase();
    switch (extension) {
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      case 'gif':
        return 'image/gif';
      case 'svg':
        return 'image/svg+xml';
      default:
        return 'image/jpeg';
    }
  }
}
