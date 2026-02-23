import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/crop_cycle_model.dart';

class CropCycleProvider extends ChangeNotifier {
  List<CropCycle> _cropCycles = [];
  bool _isLoading = false;
  String? _error;

  List<CropCycle> get cropCycles => _cropCycles;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Fetch all crop cycles (crops with eager-loaded management relationships)
  /// The backend /api/crops endpoint already returns all nested data
  Future<bool> fetchCropCycles(String token) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.apiPrefix}/crops'),
        headers: ApiConfig.getAuthHeaders(token),
      );

      _isLoading = false;

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = jsonDecode(response.body);
        _cropCycles = jsonData
            .map((json) => CropCycle.fromJson(json as Map<String, dynamic>))
            .toList();
        notifyListeners();
        return true;
      } else {
        final errorData = jsonDecode(response.body);
        _error = errorData['message'] ?? 'Failed to fetch crop cycles';
        notifyListeners();
        return false;
      }
    } catch (e) {
      _isLoading = false;
      _error = 'Network error: ${e.toString()}';
      notifyListeners();
      return false;
    }
  }

  /// Get crop cycles by status
  List<CropCycle> getCyclesByStatus(String status) {
    return _cropCycles.where((cycle) => cycle.status == status).toList();
  }

  /// Get active crop cycles
  List<CropCycle> get activeCycles {
    return _cropCycles.where((cycle) => cycle.status == 'Active').toList();
  }

  /// Get crop cycles with today's activity
  List<CropCycle> get cyclesWithTodaysActivity {
    return _cropCycles.where((cycle) => cycle.hasTodaysActivity).toList();
  }

  /// Get total water used across all cycles
  double get totalWaterUsed {
    return _cropCycles.fold(0.0, (sum, cycle) => sum + cycle.totalWater);
  }

  /// Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
