import 'package:flutter/material.dart';
import 'dart:io';
import '../models/farm_model.dart';
import '../services/farm_service.dart';

class FarmProvider extends ChangeNotifier {
  List<Farm> _farms = [];
  bool _isLoading = false;
  String? _error;
  final FarmService _farmService = FarmService();

  List<Farm> get farms => _farms;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Fetch farms from API
  Future<bool> fetchFarms(String token) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final result = await _farmService.fetchFarms(token);

    _isLoading = false;

    if (result['success']) {
      _farms = result['data'];
      notifyListeners();
      return true;
    } else {
      _error = result['error'];
      notifyListeners();
      return false;
    }
  }

  // Create farm
  Future<bool> createFarm({
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
    _isLoading = true;
    _error = null;
    notifyListeners();

    final result = await _farmService.createFarm(
      token: token,
      name: name,
      mainCategory: mainCategory,
      category: category,
      area: area,
      areaUnit: areaUnit,
      location: location,
      latitude: latitude,
      longitude: longitude,
      notes: notes,
      imageFile: imageFile,
    );

    _isLoading = false;

    if (result['success']) {
      // Refresh farms list
      await fetchFarms(token);
      return true;
    } else {
      _error = result['error'];
      notifyListeners();
      return false;
    }
  }

  // Update farm
  Future<bool> updateFarm({
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
    _isLoading = true;
    _error = null;
    notifyListeners();

    final result = await _farmService.updateFarm(
      token: token,
      farmId: farmId,
      name: name,
      mainCategory: mainCategory,
      category: category,
      area: area,
      areaUnit: areaUnit,
      location: location,
      latitude: latitude,
      longitude: longitude,
      notes: notes,
      imageFile: imageFile,
    );

    _isLoading = false;

    if (result['success']) {
      // Refresh farms list
      await fetchFarms(token);
      return true;
    } else {
      _error = result['error'];
      notifyListeners();
      return false;
    }
  }

  // Delete farm
  Future<bool> deleteFarm({
    required String token,
    required int farmId,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final result = await _farmService.deleteFarm(
      token: token,
      farmId: farmId,
    );

    _isLoading = false;

    if (result['success']) {
      // Remove from local list
      _farms.removeWhere((farm) => farm.id == farmId);
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
}
