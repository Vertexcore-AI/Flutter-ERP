import 'package:flutter/material.dart';
import '../models/buyer_model.dart';
import '../services/buyer_service.dart';
import '../services/secure_storage_service.dart';

class BuyerProvider extends ChangeNotifier {
  List<Buyer> _buyers = [];
  bool _isLoading = false;
  String? _error;
  final BuyerService _buyerService = BuyerService();
  final SecureStorageService _secureStorage = SecureStorageService();

  List<Buyer> get buyers => _buyers;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // ============================================================================
  // GETTERS
  // ============================================================================

  /// Get all buyers sorted alphabetically by name
  List<Buyer> get allBuyers {
    final sorted = List<Buyer>.from(_buyers);
    sorted.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    return sorted;
  }

  /// Total buyer count
  int get totalBuyers => _buyers.length;

  /// Get buyer by ID
  Buyer? getById(int id) {
    try {
      return _buyers.firstWhere((buyer) => buyer.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Get buyers by city
  List<Buyer> getBuyersByCity(String city) {
    return _buyers
        .where((buyer) => buyer.city.toLowerCase() == city.toLowerCase())
        .toList();
  }

  /// Get buyers by province
  List<Buyer> getBuyersByProvince(String province) {
    return _buyers
        .where((buyer) => buyer.province.toLowerCase() == province.toLowerCase())
        .toList();
  }

  /// Get buyers with coordinates
  List<Buyer> get buyersWithCoordinates {
    return _buyers.where((buyer) => buyer.hasCoordinates()).toList();
  }

  // ============================================================================
  // API METHODS
  // ============================================================================

  /// Fetch all buyers from API
  Future<bool> fetchBuyers() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final token = await _secureStorage.getAuthToken();
      if (token == null) {
        _error = 'No authentication token found';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      final result = await _buyerService.fetchBuyers(token);

      _isLoading = false;

      if (result['success']) {
        _buyers = result['data'];
        notifyListeners();
        return true;
      } else {
        _error = result['error'];
        notifyListeners();
        return false;
      }
    } catch (e) {
      _isLoading = false;
      _error = 'Failed to fetch buyers: ${e.toString()}';
      notifyListeners();
      return false;
    }
  }

  /// Create new buyer
  Future<bool> createBuyer({
    required String name,
    required String city,
    required String province,
    String? postalCode,
    double? latitude,
    double? longitude,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final token = await _secureStorage.getAuthToken();
      if (token == null) {
        _error = 'No authentication token found';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      final result = await _buyerService.createBuyer(
        token: token,
        name: name,
        city: city,
        province: province,
        postalCode: postalCode,
        latitude: latitude,
        longitude: longitude,
      );

      _isLoading = false;

      if (result['success']) {
        _buyers.add(result['data']);
        notifyListeners();
        return true;
      } else {
        _error = result['error'];
        notifyListeners();
        return false;
      }
    } catch (e) {
      _isLoading = false;
      _error = 'Failed to create buyer: ${e.toString()}';
      notifyListeners();
      return false;
    }
  }

  /// Update existing buyer
  Future<bool> updateBuyer({
    required int buyerId,
    String? name,
    String? city,
    String? province,
    String? postalCode,
    double? latitude,
    double? longitude,
    bool clearCoordinates = false,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final token = await _secureStorage.getAuthToken();
      if (token == null) {
        _error = 'No authentication token found';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      final result = await _buyerService.updateBuyer(
        token: token,
        buyerId: buyerId,
        name: name,
        city: city,
        province: province,
        postalCode: postalCode,
        latitude: latitude,
        longitude: longitude,
        clearCoordinates: clearCoordinates,
      );

      _isLoading = false;

      if (result['success']) {
        final index = _buyers.indexWhere((b) => b.id == buyerId);
        if (index != -1) {
          _buyers[index] = result['data'];
        }
        notifyListeners();
        return true;
      } else {
        _error = result['error'];
        notifyListeners();
        return false;
      }
    } catch (e) {
      _isLoading = false;
      _error = 'Failed to update buyer: ${e.toString()}';
      notifyListeners();
      return false;
    }
  }

  /// Delete buyer
  Future<bool> deleteBuyer(int buyerId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final token = await _secureStorage.getAuthToken();
      if (token == null) {
        _error = 'No authentication token found';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      final result = await _buyerService.deleteBuyer(token, buyerId);

      _isLoading = false;

      if (result['success']) {
        _buyers.removeWhere((b) => b.id == buyerId);
        notifyListeners();
        return true;
      } else {
        _error = result['error'];
        notifyListeners();
        return false;
      }
    } catch (e) {
      _isLoading = false;
      _error = 'Failed to delete buyer: ${e.toString()}';
      notifyListeners();
      return false;
    }
  }

  /// Clear error message
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
