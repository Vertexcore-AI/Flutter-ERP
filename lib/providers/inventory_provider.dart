import 'package:flutter/material.dart';
import '../models/inventory_item_model.dart';
import '../services/inventory_service.dart';

class InventoryProvider extends ChangeNotifier {
  List<InventoryItem> _items = [];
  bool _isLoading = false;
  String? _error;
  final InventoryService _inventoryService = InventoryService();

  List<InventoryItem> get items => _items;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Fetch all inventory items
  Future<bool> fetchInventory(String token) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final result = await _inventoryService.fetchInventory(token);

    _isLoading = false;

    if (result['success']) {
      _items = (result['data'] as List)
          .map((json) => InventoryItem.fromJson(json))
          .toList();
      notifyListeners();
      return true;
    } else {
      _error = result['error'];
      notifyListeners();
      return false;
    }
  }

  // Create new inventory item
  Future<bool> createItem({
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
    _isLoading = true;
    _error = null;
    notifyListeners();

    final result = await _inventoryService.createItem(
      token: token,
      itemName: itemName,
      category: category,
      inventoryType: inventoryType,
      sourceResource: sourceResource,
      quantityPurchased: quantityPurchased,
      unit: unit,
      unitPrice: unitPrice,
      purchaseDate: purchaseDate,
    );

    _isLoading = false;

    if (result['success']) {
      // Refresh inventory list
      await fetchInventory(token);
      return true;
    } else {
      _error = result['error'];
      notifyListeners();
      return false;
    }
  }

  // Update inventory item
  Future<bool> updateItem({
    required String token,
    required int id,
    required String itemName,
    required String category,
    required String inventoryType,
    String? sourceResource,
    required int quantityPurchased,
    required int quantityAvailable,
    required String unit,
    required double unitPrice,
    required String purchaseDate,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final result = await _inventoryService.updateItem(
      token: token,
      id: id,
      itemName: itemName,
      category: category,
      inventoryType: inventoryType,
      sourceResource: sourceResource,
      quantityPurchased: quantityPurchased,
      quantityAvailable: quantityAvailable,
      unit: unit,
      unitPrice: unitPrice,
      purchaseDate: purchaseDate,
    );

    _isLoading = false;

    if (result['success']) {
      // Refresh inventory list
      await fetchInventory(token);
      return true;
    } else {
      _error = result['error'];
      notifyListeners();
      return false;
    }
  }

  // Delete inventory item
  Future<bool> deleteItem({
    required String token,
    required int id,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final result = await _inventoryService.deleteItem(
      token: token,
      id: id,
    );

    _isLoading = false;

    if (result['success']) {
      // Remove from local list
      _items.removeWhere((item) => item.id == id);
      notifyListeners();
      return true;
    } else {
      _error = result['error'];
      notifyListeners();
      return false;
    }
  }

  // Fetch inventory history
  Future<Map<String, dynamic>> fetchHistory({
    required String token,
    required int id,
  }) async {
    final result = await _inventoryService.fetchHistory(
      token: token,
      id: id,
    );

    return result;
  }

  // Create stock adjustment
  Future<bool> createAdjustment({
    required String token,
    required int inventoryId,
    required String adjustmentType,
    required double quantity,
    required String reason,
    required String adjustmentDate,
    String? notes,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final result = await _inventoryService.createAdjustment(
      token: token,
      inventoryId: inventoryId,
      adjustmentType: adjustmentType,
      quantity: quantity,
      reason: reason,
      adjustmentDate: adjustmentDate,
      notes: notes,
    );

    _isLoading = false;

    if (result['success']) {
      // Refresh inventory list to get updated quantities
      await fetchInventory(token);
      return true;
    } else {
      _error = result['error'];
      notifyListeners();
      return false;
    }
  }

  // Create inventory allocation
  Future<bool> createAllocation({
    required String token,
    required int cropId,
    required int inventoryId,
    required int quantityUsed,
    required String dateUsed,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final result = await _inventoryService.createAllocation(
      token: token,
      cropId: cropId,
      inventoryId: inventoryId,
      quantityUsed: quantityUsed,
      dateUsed: dateUsed,
    );

    _isLoading = false;

    if (result['success']) {
      // Refresh inventory list to get updated quantities
      await fetchInventory(token);
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

  // Get category stats
  Map<String, CategoryStats> getCategoryStats() {
    final stats = <String, CategoryStats>{};

    final categories = [
      'Source Resource',
      'Non-Scarce Items',
      'Fertilizer',
      'Pesticides',
      'Fungicides',
      'Seeds',
      'Tools',
      'Equipment',
      'Irrigation',
    ];

    for (final category in categories) {
      final categoryItems = _items.where((item) => item.category == category);
      stats[category] = CategoryStats(
        itemCount: categoryItems.length,
        totalQuantity: categoryItems.fold(
            0.0, (sum, item) => sum + item.quantityAvailable),
        totalValue: categoryItems.fold(0.0, (sum, item) => sum + item.totalValue),
      );
    }

    return stats;
  }
}

class CategoryStats {
  final int itemCount;
  final double totalQuantity;
  final double totalValue;

  CategoryStats({
    required this.itemCount,
    required this.totalQuantity,
    required this.totalValue,
  });
}
