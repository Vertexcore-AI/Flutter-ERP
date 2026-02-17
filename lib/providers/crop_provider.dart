import 'package:flutter/material.dart';
import '../models/crop_model.dart';
import '../services/crop_service.dart';

class CropProvider extends ChangeNotifier {
  List<Crop> _crops = [];
  bool _isLoading = false;
  String? _error;
  final CropService _cropService = CropService();

  List<Crop> get crops => _crops;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Fetch crops from API
  Future<bool> fetchCrops(String token) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final result = await _cropService.fetchCrops(token);
    print('CropProvider.fetchCrops - result: $result'); // DEBUG

    _isLoading = false;

    if (result['success']) {
      _crops = result['data'];
      print('CropProvider.fetchCrops - crops count: ${_crops.length}'); // DEBUG
      notifyListeners();
      return true;
    } else {
      _error = result['error'];
      print('CropProvider.fetchCrops - error: $_error'); // DEBUG
      notifyListeners();
      return false;
    }
  }

  // Create crop
  Future<bool> createCrop({
    required String token,
    required String farmName,
    required int cropCategoryId, // NEW
    required int cropTypeId, // NEW
    required String cropType, // Deprecated
    required DateTime startDate,
    required int plants,
    required String status,
    required int farmId,
    DateTime? expectedHarvestDate,
    String? notes,
    double? waterUsage,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final result = await _cropService.createCrop(
      token: token,
      farmName: farmName,
      cropCategoryId: cropCategoryId, // NEW
      cropTypeId: cropTypeId, // NEW
      cropType: cropType,
      startDate: startDate,
      plants: plants,
      status: status,
      farmId: farmId,
      expectedHarvestDate: expectedHarvestDate,
      notes: notes,
      waterUsage: waterUsage,
    );

    _isLoading = false;

    if (result['success']) {
      // Refresh crops list
      await fetchCrops(token);
      return true;
    } else {
      _error = result['error'];
      notifyListeners();
      return false;
    }
  }

  // Update crop
  Future<bool> updateCrop({
    required String token,
    required int cropId,
    required String farmName,
    required int cropCategoryId, // NEW
    required int cropTypeId, // NEW
    required String cropType, // Deprecated
    required DateTime startDate,
    required int plants,
    required String status,
    required int farmId,
    DateTime? expectedHarvestDate,
    String? notes,
    double? waterUsage,
    String? totalHarvest,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final result = await _cropService.updateCrop(
      token: token,
      cropId: cropId,
      farmName: farmName,
      cropCategoryId: cropCategoryId, // NEW
      cropTypeId: cropTypeId, // NEW
      cropType: cropType,
      startDate: startDate,
      plants: plants,
      status: status,
      farmId: farmId,
      expectedHarvestDate: expectedHarvestDate,
      notes: notes,
      waterUsage: waterUsage,
      totalHarvest: totalHarvest,
    );

    _isLoading = false;

    if (result['success']) {
      // Refresh crops list
      await fetchCrops(token);
      return true;
    } else {
      _error = result['error'];
      notifyListeners();
      return false;
    }
  }

  // Delete crop
  Future<bool> deleteCrop({
    required String token,
    required int cropId,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final result = await _cropService.deleteCrop(token, cropId);

    _isLoading = false;

    if (result['success']) {
      // Remove from local list
      _crops.removeWhere((crop) => crop.id == cropId);
      notifyListeners();
      return true;
    } else {
      _error = result['error'];
      notifyListeners();
      return false;
    }
  }

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Get crop by farm ID
  List<Crop> getCropsByFarmId(int farmId) {
    return _crops.where((crop) => crop.farmId == farmId).toList();
  }

  // Get crop by status
  List<Crop> getCropsByStatus(String status) {
    return _crops.where((crop) => crop.status == status).toList();
  }

  // Get active crops count
  int get activeCropsCount {
    return _crops.where((crop) => crop.status == CropStatus.active).length;
  }

  // Get planned crops count
  int get plannedCropsCount {
    return _crops.where((crop) => crop.status == CropStatus.planned).length;
  }

  // Get harvested crops count
  int get harvestedCropsCount {
    return _crops.where((crop) => crop.status == CropStatus.harvested).length;
  }
}
