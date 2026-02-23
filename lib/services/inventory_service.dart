import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import 'api_client.dart';

class InventoryService {
  final _apiClient = ApiClient();
  final String baseUrl = '${ApiConfig.baseUrl}${ApiConfig.apiPrefix}';

  // Fetch all inventory items
  Future<Map<String, dynamic>> fetchInventory(String token) async {
    try {
      final response = await _apiClient.get('$baseUrl/inventory');
      final List<dynamic> data = json.decode(response.body);

      return {'success': true, 'data': data};
    } on UnauthorizedException catch (e) {
      return {
        'success': false,
        'error': e.message,
        'unauthorized': true,
      };
    } on NotFoundException catch (e) {
      return {
        'success': false,
        'error': e.message,
      };
    } on RateLimitException catch (e) {
      return {
        'success': false,
        'error': e.message,
        'retryAfter': e.retryAfter,
      };
    } on NetworkException catch (e) {
      return {
        'success': false,
        'error': e.message,
      };
    } on ApiException catch (e) {
      return {
        'success': false,
        'error': e.message,
      };
    } catch (e) {
      return {'success': false, 'error': 'Unexpected error: ${e.toString()}'};
    }
  }

  // Create new inventory item
  Future<Map<String, dynamic>> createItem({
    required String token,
    required String itemName,
    required String category,
    required String inventoryType,
    String? sourceResource,
    required int quantityPurchased,
    required String unit,
    required double unitPrice,
    required String purchaseDate,
  }) async {
    try {
      final response = await _apiClient.post(
        '$baseUrl/inventory',
        body: {
          'item_name': itemName,
          'category': category,
          'inventory_type': inventoryType,
          'source_resource': sourceResource,
          'quantity_purchased': quantityPurchased,
          'unit': unit,
          'unit_price': unitPrice,
          'purchase_date': purchaseDate,
        },
      );

      return {'success': true, 'data': json.decode(response.body)};
    } on ValidationException catch (e) {
      return {
        'success': false,
        'error': e.message,
      };
    } on UnauthorizedException catch (e) {
      return {
        'success': false,
        'error': e.message,
        'unauthorized': true,
      };
    } on RateLimitException catch (e) {
      return {
        'success': false,
        'error': e.message,
        'retryAfter': e.retryAfter,
      };
    } on NetworkException catch (e) {
      return {
        'success': false,
        'error': e.message,
      };
    } on ApiException catch (e) {
      return {
        'success': false,
        'error': e.message,
      };
    } catch (e) {
      return {'success': false, 'error': 'Unexpected error: ${e.toString()}'};
    }
  }

  // Update inventory item
  Future<Map<String, dynamic>> updateItem({
    required String token,
    required int id, // Changed from itemId to match provider
    required String itemName,
    required String category,
    required String inventoryType,
    String? sourceResource,
    required int quantityPurchased,
    int? quantityAvailable, // Added to match provider
    required String unit,
    required double unitPrice,
    required String purchaseDate,
  }) async {
    try {
      final response = await _apiClient.put(
        '$baseUrl/inventory/$id',
        body: {
          'item_name': itemName,
          'category': category,
          'inventory_type': inventoryType,
          'source_resource': sourceResource,
          'quantity_purchased': quantityPurchased,
          if (quantityAvailable != null) 'quantity_available': quantityAvailable,
          'unit': unit,
          'unit_price': unitPrice,
          'purchase_date': purchaseDate,
        },
      );

      return {'success': true, 'data': json.decode(response.body)};
    } on ValidationException catch (e) {
      return {
        'success': false,
        'error': e.message,
      };
    } on UnauthorizedException catch (e) {
      return {
        'success': false,
        'error': e.message,
        'unauthorized': true,
      };
    } on NotFoundException catch (e) {
      return {
        'success': false,
        'error': e.message,
      };
    } on RateLimitException catch (e) {
      return {
        'success': false,
        'error': e.message,
        'retryAfter': e.retryAfter,
      };
    } on NetworkException catch (e) {
      return {
        'success': false,
        'error': e.message,
      };
    } on ApiException catch (e) {
      return {
        'success': false,
        'error': e.message,
      };
    } catch (e) {
      return {'success': false, 'error': 'Unexpected error: ${e.toString()}'};
    }
  }

  // Delete inventory item
  Future<Map<String, dynamic>> deleteItem({
    required String token,
    required int id, // Changed from itemId to match provider
  }) async {
    try {
      final response = await _apiClient.delete('$baseUrl/inventory/$id');
      final data = json.decode(response.body);

      return {
        'success': true,
        'message': data['message'] ?? 'Item deleted successfully'
      };
    } on UnauthorizedException catch (e) {
      return {
        'success': false,
        'error': e.message,
        'unauthorized': true,
      };
    } on NotFoundException catch (e) {
      return {
        'success': false,
        'error': e.message,
      };
    } on RateLimitException catch (e) {
      return {
        'success': false,
        'error': e.message,
        'retryAfter': e.retryAfter,
      };
    } on NetworkException catch (e) {
      return {
        'success': false,
        'error': e.message,
      };
    } on ApiException catch (e) {
      return {
        'success': false,
        'error': e.message,
      };
    } catch (e) {
      return {'success': false, 'error': 'Unexpected error: ${e.toString()}'};
    }
  }

  // Fetch inventory history
  Future<Map<String, dynamic>> fetchHistory({
    required String token,
    required int id, // Changed from itemId to match provider
  }) async {
    try {
      final response = await _apiClient.get('$baseUrl/inventory/$id/history');
      final data = json.decode(response.body);

      return {'success': true, 'data': data};
    } on UnauthorizedException catch (e) {
      return {
        'success': false,
        'error': e.message,
        'unauthorized': true,
      };
    } on NotFoundException catch (e) {
      return {
        'success': false,
        'error': e.message,
      };
    } on RateLimitException catch (e) {
      return {
        'success': false,
        'error': e.message,
        'retryAfter': e.retryAfter,
      };
    } on NetworkException catch (e) {
      return {
        'success': false,
        'error': e.message,
      };
    } on ApiException catch (e) {
      return {
        'success': false,
        'error': e.message,
      };
    } catch (e) {
      return {'success': false, 'error': 'Unexpected error: ${e.toString()}'};
    }
  }

  // Create stock adjustment
  Future<Map<String, dynamic>> createAdjustment({
    required String token,
    required int inventoryId,
    required String adjustmentType,
    required double quantity, // Changed to double to match provider
    required String reason,
    required String adjustmentDate,
    String? notes,
  }) async {
    try {
      final response = await _apiClient.post(
        '$baseUrl/stock-adjustments',
        body: {
          'inventory_id': inventoryId,
          'adjustment_type': adjustmentType,
          'quantity': quantity,
          'reason': reason,
          'adjustment_date': adjustmentDate,
          if (notes != null) 'notes': notes,
        },
      );

      return {'success': true, 'data': json.decode(response.body)};
    } on ValidationException catch (e) {
      return {
        'success': false,
        'error': e.message,
      };
    } on UnauthorizedException catch (e) {
      return {
        'success': false,
        'error': e.message,
        'unauthorized': true,
      };
    } on RateLimitException catch (e) {
      return {
        'success': false,
        'error': e.message,
        'retryAfter': e.retryAfter,
      };
    } on NetworkException catch (e) {
      return {
        'success': false,
        'error': e.message,
      };
    } on ApiException catch (e) {
      return {
        'success': false,
        'error': e.message,
      };
    } catch (e) {
      return {'success': false, 'error': 'Unexpected error: ${e.toString()}'};
    }
  }

  // Create inventory allocation (link inventory to crop)
  Future<Map<String, dynamic>> createAllocation({
    required String token,
    required int inventoryId,
    required int cropId,
    required int quantityUsed,
    double? cost, // Made optional to match provider usage
    required String dateUsed,
  }) async {
    try {
      final response = await _apiClient.post(
        '$baseUrl/inventory-allocations',
        body: {
          'inventory_id': inventoryId,
          'crop_id': cropId,
          'quantity_used': quantityUsed,
          if (cost != null) 'cost': cost,
          'date_used': dateUsed,
        },
      );

      return {'success': true, 'data': json.decode(response.body)};
    } on ValidationException catch (e) {
      return {
        'success': false,
        'error': e.message,
      };
    } on UnauthorizedException catch (e) {
      return {
        'success': false,
        'error': e.message,
        'unauthorized': true,
      };
    } on RateLimitException catch (e) {
      return {
        'success': false,
        'error': e.message,
        'retryAfter': e.retryAfter,
      };
    } on NetworkException catch (e) {
      return {
        'success': false,
        'error': e.message,
      };
    } on ApiException catch (e) {
      return {
        'success': false,
        'error': e.message,
      };
    } catch (e) {
      return {'success': false, 'error': 'Unexpected error: ${e.toString()}'};
    }
  }
}
