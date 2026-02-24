import 'dart:convert';
import '../config/api_config.dart';
import '../models/buyer_model.dart';
import 'api_client.dart';

class BuyerService {
  final _apiClient = ApiClient();

  // Fetch all buyers
  Future<Map<String, dynamic>> fetchBuyers(String token) async {
    try {
      final response = await _apiClient.get(
        '${ApiConfig.baseUrl}${ApiConfig.apiPrefix}/buyers',
      );

      final data = jsonDecode(response.body);

      try {
        final List<Buyer> buyers = (data as List)
            .map((item) => Buyer.fromJson(item))
            .toList();

        return {
          'success': true,
          'data': buyers,
        };
      } catch (e) {
        return {
          'success': false,
          'error': 'Failed to parse buyers: ${e.toString()}',
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

  // Create new buyer
  Future<Map<String, dynamic>> createBuyer({
    required String token,
    required String name,
    required String city,
    required String province,
    String? postalCode,
    double? latitude,
    double? longitude,
  }) async {
    try {
      final requestBody = <String, dynamic>{
        'name': name,
        'city': city,
        'province': province,
      };

      // Add optional fields
      if (postalCode != null && postalCode.isNotEmpty) {
        requestBody['postal_code'] = postalCode;
      }
      if (latitude != null) {
        requestBody['latitude'] = latitude;
      }
      if (longitude != null) {
        requestBody['longitude'] = longitude;
      }

      final response = await _apiClient.post(
        '${ApiConfig.baseUrl}${ApiConfig.apiPrefix}/buyers',
        body: requestBody,
      );

      final data = jsonDecode(response.body);
      final buyer = Buyer.fromJson(data);
      return {
        'success': true,
        'data': buyer,
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

  // Update existing buyer
  Future<Map<String, dynamic>> updateBuyer({
    required String token,
    required int buyerId,
    String? name,
    String? city,
    String? province,
    String? postalCode,
    double? latitude,
    double? longitude,
    bool clearCoordinates = false,
  }) async {
    try {
      final requestBody = <String, dynamic>{};

      // Add fields that are provided (partial update)
      if (name != null) {
        requestBody['name'] = name;
      }
      if (city != null) {
        requestBody['city'] = city;
      }
      if (province != null) {
        requestBody['province'] = province;
      }
      if (postalCode != null) {
        requestBody['postal_code'] = postalCode;
      }

      if (clearCoordinates) {
        requestBody['latitude'] = null;
        requestBody['longitude'] = null;
      } else {
        if (latitude != null) {
          requestBody['latitude'] = latitude;
        }
        if (longitude != null) {
          requestBody['longitude'] = longitude;
        }
      }

      final response = await _apiClient.put(
        '${ApiConfig.baseUrl}${ApiConfig.apiPrefix}/buyers/$buyerId',
        body: requestBody,
      );

      final data = jsonDecode(response.body);
      final buyer = Buyer.fromJson(data);
      return {
        'success': true,
        'data': buyer,
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

  // Delete buyer
  Future<Map<String, dynamic>> deleteBuyer(String token, int buyerId) async {
    try {
      await _apiClient.delete(
        '${ApiConfig.baseUrl}${ApiConfig.apiPrefix}/buyers/$buyerId',
      );

      return {
        'success': true,
        'message': 'Buyer deleted successfully',
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
