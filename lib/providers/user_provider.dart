import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/user_model.dart';
import '../services/user_service.dart';

class UserProvider extends ChangeNotifier {
  User? _user;
  bool _isLoading = false;
  String? _error;
  final UserService _userService = UserService();

  User? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isProfileComplete => _user?.profileCompleted ?? false;

  // Load user from SharedPreferences cache
  Future<void> loadUserFromCache() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString('user_data');

    if (userJson != null) {
      try {
        _user = User.fromJson(jsonDecode(userJson));
        notifyListeners();
      } catch (e) {
        // Invalid cached data, clear it
        await prefs.remove('user_data');
      }
    }
  }

  // Fetch user profile from API
  Future<bool> fetchProfile(String token) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final result = await _userService.getProfile(token);

    _isLoading = false;

    if (result['success']) {
      _user = result['data'];
      await _cacheUser(_user!);
      notifyListeners();
      return true;
    } else {
      _error = result['error'];
      notifyListeners();
      return false;
    }
  }

  // Update user profile
  Future<bool> updateProfile({
    required String token,
    required String fullName,
    required DateTime dateOfBirth,
    required int aiDivisionId,
    required bool slGapCertified,
    String? slGapCertificateNumber,
    String? location,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final result = await _userService.updateProfile(
      token: token,
      fullName: fullName,
      dateOfBirth: dateOfBirth,
      aiDivisionId: aiDivisionId,
      slGapCertified: slGapCertified,
      slGapCertificateNumber: slGapCertificateNumber,
      location: location,
    );

    _isLoading = false;

    if (result['success']) {
      _user = result['data'];
      await _cacheUser(_user!);
      notifyListeners();
      return true;
    } else {
      _error = result['error'];
      notifyListeners();
      return false;
    }
  }

  // Cache user data locally
  Future<void> _cacheUser(User user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_data', jsonEncode(user.toJson()));
  }

  // Clear user data on logout
  Future<void> clearUser() async {
    _user = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_data');
    notifyListeners();
  }
}
