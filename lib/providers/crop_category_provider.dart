import 'package:flutter/material.dart';
import '../models/crop_category_model.dart';
import '../services/crop_category_service.dart';

class CropCategoryProvider extends ChangeNotifier {
  List<CropCategory> _categories = [];
  Map<int, List<CropType>> _typesByCategory = {};
  bool _isLoading = false;
  String? _error;

  final CropCategoryService _service = CropCategoryService();

  List<CropCategory> get categories => _categories;
  Map<int, List<CropType>> get typesByCategory => _typesByCategory;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Fetch all crop categories from API
  Future<bool> fetchCategories(String token) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final result = await _service.fetchCategories(token);

    _isLoading = false;

    if (result['success']) {
      _categories = result['data'];
      notifyListeners();
      return true;
    } else {
      _error = result['error'];
      notifyListeners();
      return false;
    }
  }

  /// Fetch crop types for a specific category (with caching)
  Future<bool> fetchTypesByCategory(String token, int categoryId) async {
    // Check cache first to avoid redundant API calls
    if (_typesByCategory.containsKey(categoryId)) {
      return true;
    }

    final result = await _service.fetchTypesByCategory(token, categoryId);

    if (result['success']) {
      _typesByCategory[categoryId] = result['data'];
      notifyListeners();
      return true;
    } else {
      _error = result['error'];
      notifyListeners();
      return false;
    }
  }

  /// Get cached types for specific category
  List<CropType> getTypesForCategory(int categoryId) {
    return _typesByCategory[categoryId] ?? [];
  }

  /// Clear error message
  void clearError() {
    _error = null;
    notifyListeners();
  }

  /// Clear all cached data (useful for refresh)
  void clearCache() {
    _categories = [];
    _typesByCategory = {};
    notifyListeners();
  }
}
