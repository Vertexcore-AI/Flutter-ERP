// Helper function to check if two dates are the same day
bool isSameDay(DateTime date1, DateTime date2) {
  return date1.year == date2.year &&
      date1.month == date2.month &&
      date1.day == date2.day;
}

// ============================================================================
// WATER MANAGEMENT MODEL
// ============================================================================
class WaterManagement {
  final int id;
  final int cropId;
  final DateTime wateringDate;
  final String wateringType; // BY_PLANT | ENTIRE_CROP
  final String wateringMethod; // Drip | Sprinkler | Manual
  final int numberOfPlants;
  final double waterPerPlant;
  final String waterUnit; // ml | liters
  final double totalWaterUsed;
  final String? notes;

  WaterManagement({
    required this.id,
    required this.cropId,
    required this.wateringDate,
    required this.wateringType,
    required this.wateringMethod,
    required this.numberOfPlants,
    required this.waterPerPlant,
    required this.waterUnit,
    required this.totalWaterUsed,
    this.notes,
  });

  factory WaterManagement.fromJson(Map<String, dynamic> json) {
    return WaterManagement(
      id: json['id'],
      cropId: json['crop_id'],
      wateringDate: DateTime.parse(json['watering_date']),
      wateringType: json['watering_type'],
      wateringMethod: json['watering_method'],
      numberOfPlants: json['number_of_plants'],
      waterPerPlant: (json['water_per_plant'] as num).toDouble(),
      waterUnit: json['water_unit'],
      totalWaterUsed: (json['total_water_used'] as num).toDouble(),
      notes: json['notes'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'crop_id': cropId,
      'watering_date': wateringDate.toIso8601String().split('T')[0],
      'watering_type': wateringType,
      'watering_method': wateringMethod,
      'number_of_plants': numberOfPlants,
      'water_per_plant': waterPerPlant,
      'water_unit': waterUnit,
      'total_water_used': totalWaterUsed,
      'notes': notes,
    };
  }
}

// ============================================================================
// INVENTORY ITEM MODEL (for nested relationships)
// ============================================================================
class InventoryItem {
  final int id;
  final String itemName;
  final String category;
  final String unit;
  final double? quantityAvailable;

  InventoryItem({
    required this.id,
    required this.itemName,
    required this.category,
    required this.unit,
    this.quantityAvailable,
  });

  factory InventoryItem.fromJson(Map<String, dynamic> json) {
    return InventoryItem(
      id: json['id'],
      itemName: json['item_name'],
      category: json['category'],
      unit: json['unit'],
      quantityAvailable: json['quantity_available'] != null
          ? (json['quantity_available'] as num).toDouble()
          : null,
    );
  }
}

// ============================================================================
// FERTILIZER MANAGEMENT MODEL
// ============================================================================
class FertilizerManagement {
  final int id;
  final int cropId;
  final int? inventoryId;
  final DateTime applicationDate;
  final String applicationType; // BY_PLANT | ENTIRE_CROP
  final String applicationMethod;
  final int numberOfPlants;
  final double amountPerPlant;
  final String unit;
  final double totalAmountUsed;
  final String? notes;
  final InventoryItem? inventory; // Nested relationship

  FertilizerManagement({
    required this.id,
    required this.cropId,
    this.inventoryId,
    required this.applicationDate,
    required this.applicationType,
    required this.applicationMethod,
    required this.numberOfPlants,
    required this.amountPerPlant,
    required this.unit,
    required this.totalAmountUsed,
    this.notes,
    this.inventory,
  });

  factory FertilizerManagement.fromJson(Map<String, dynamic> json) {
    return FertilizerManagement(
      id: json['id'],
      cropId: json['crop_id'],
      inventoryId: json['inventory_id'],
      applicationDate: DateTime.parse(json['application_date']),
      applicationType: json['application_type'],
      applicationMethod: json['application_method'],
      numberOfPlants: json['number_of_plants'],
      amountPerPlant: (json['amount_per_plant'] as num).toDouble(),
      unit: json['unit'],
      totalAmountUsed: (json['total_amount_used'] as num).toDouble(),
      notes: json['notes'],
      inventory: json['inventory'] != null
          ? InventoryItem.fromJson(json['inventory'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'crop_id': cropId,
      'inventory_id': inventoryId,
      'application_date': applicationDate.toIso8601String().split('T')[0],
      'application_type': applicationType,
      'application_method': applicationMethod,
      'number_of_plants': numberOfPlants,
      'amount_per_plant': amountPerPlant,
      'unit': unit,
      'total_amount_used': totalAmountUsed,
      'notes': notes,
    };
  }

  // Helper: Get display name for fertilizer
  String get displayName => inventory?.itemName ?? 'Fertilizer';
}

// ============================================================================
// PESTICIDE MANAGEMENT MODEL
// ============================================================================
class PesticideManagement {
  final int id;
  final int cropId;
  final int? inventoryId;
  final DateTime applicationDate;
  final String applicationType; // BY_PLANT | ENTIRE_CROP
  final String applicationMethod;
  final int numberOfPlants;
  final double amountPerPlant;
  final String unit;
  final double totalAmountUsed;
  final String? notes;
  final InventoryItem? inventory; // Nested relationship

  PesticideManagement({
    required this.id,
    required this.cropId,
    this.inventoryId,
    required this.applicationDate,
    required this.applicationType,
    required this.applicationMethod,
    required this.numberOfPlants,
    required this.amountPerPlant,
    required this.unit,
    required this.totalAmountUsed,
    this.notes,
    this.inventory,
  });

  factory PesticideManagement.fromJson(Map<String, dynamic> json) {
    return PesticideManagement(
      id: json['id'],
      cropId: json['crop_id'],
      inventoryId: json['inventory_id'],
      applicationDate: DateTime.parse(json['application_date']),
      applicationType: json['application_type'],
      applicationMethod: json['application_method'],
      numberOfPlants: json['number_of_plants'],
      amountPerPlant: (json['amount_per_plant'] as num).toDouble(),
      unit: json['unit'],
      totalAmountUsed: (json['total_amount_used'] as num).toDouble(),
      notes: json['notes'],
      inventory: json['inventory'] != null
          ? InventoryItem.fromJson(json['inventory'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'crop_id': cropId,
      'inventory_id': inventoryId,
      'application_date': applicationDate.toIso8601String().split('T')[0],
      'application_type': applicationType,
      'application_method': applicationMethod,
      'number_of_plants': numberOfPlants,
      'amount_per_plant': amountPerPlant,
      'unit': unit,
      'total_amount_used': totalAmountUsed,
      'notes': notes,
    };
  }

  // Helper: Get display name for pesticide
  String get displayName => inventory?.itemName ?? 'Pesticide';
}

// ============================================================================
// FUNGICIDE MANAGEMENT MODEL
// ============================================================================
class FungicideManagement {
  final int id;
  final int cropId;
  final int? inventoryId;
  final DateTime applicationDate;
  final String applicationType; // BY_PLANT | ENTIRE_CROP
  final String applicationMethod;
  final int numberOfPlants;
  final double amountPerPlant;
  final String unit;
  final double totalAmountUsed;
  final String? notes;
  final InventoryItem? inventory; // Nested relationship

  FungicideManagement({
    required this.id,
    required this.cropId,
    this.inventoryId,
    required this.applicationDate,
    required this.applicationType,
    required this.applicationMethod,
    required this.numberOfPlants,
    required this.amountPerPlant,
    required this.unit,
    required this.totalAmountUsed,
    this.notes,
    this.inventory,
  });

  factory FungicideManagement.fromJson(Map<String, dynamic> json) {
    return FungicideManagement(
      id: json['id'],
      cropId: json['crop_id'],
      inventoryId: json['inventory_id'],
      applicationDate: DateTime.parse(json['application_date']),
      applicationType: json['application_type'],
      applicationMethod: json['application_method'],
      numberOfPlants: json['number_of_plants'],
      amountPerPlant: (json['amount_per_plant'] as num).toDouble(),
      unit: json['unit'],
      totalAmountUsed: (json['total_amount_used'] as num).toDouble(),
      notes: json['notes'],
      inventory: json['inventory'] != null
          ? InventoryItem.fromJson(json['inventory'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'crop_id': cropId,
      'inventory_id': inventoryId,
      'application_date': applicationDate.toIso8601String().split('T')[0],
      'application_type': applicationType,
      'application_method': applicationMethod,
      'number_of_plants': numberOfPlants,
      'amount_per_plant': amountPerPlant,
      'unit': unit,
      'total_amount_used': totalAmountUsed,
      'notes': notes,
    };
  }

  // Helper: Get display name for fungicide
  String get displayName => inventory?.itemName ?? 'Fungicide';
}

// ============================================================================
// MAINTENANCE REPORT MODEL
// ============================================================================
class MaintenanceReport {
  final int id;
  final int cropId;
  final String maintenanceName;
  final double upgradeCost;
  final DateTime maintenanceDate;
  final String? notes;

  MaintenanceReport({
    required this.id,
    required this.cropId,
    required this.maintenanceName,
    required this.upgradeCost,
    required this.maintenanceDate,
    this.notes,
  });

  factory MaintenanceReport.fromJson(Map<String, dynamic> json) {
    return MaintenanceReport(
      id: json['id'],
      cropId: json['crop_id'],
      maintenanceName: json['maintenance_name'],
      upgradeCost: (json['upgrade_cost'] as num).toDouble(),
      maintenanceDate: DateTime.parse(json['maintenance_date']),
      notes: json['notes'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'crop_id': cropId,
      'maintenance_name': maintenanceName,
      'upgrade_cost': upgradeCost,
      'maintenance_date': maintenanceDate.toIso8601String().split('T')[0],
      'notes': notes,
    };
  }
}

// ============================================================================
// CROP MAINTENANCE MODEL
// ============================================================================
class CropMaintenance {
  final int id;
  final int cropId;
  final double maintenanceCost;
  final double yearlyDecayRate;
  final double yearlyDecayCost;
  final double yearlyUsableAmount;
  final double monthlyDecayRate;
  final double monthlyDecayCost;
  final double monthlyUsableAmount;
  final double dailyDecayRate;
  final double dailyDecayCost;
  final double dailyUsableAmount;
  final List<MaintenanceReport>? maintenanceReports;

  CropMaintenance({
    required this.id,
    required this.cropId,
    required this.maintenanceCost,
    required this.yearlyDecayRate,
    required this.yearlyDecayCost,
    required this.yearlyUsableAmount,
    required this.monthlyDecayRate,
    required this.monthlyDecayCost,
    required this.monthlyUsableAmount,
    required this.dailyDecayRate,
    required this.dailyDecayCost,
    required this.dailyUsableAmount,
    this.maintenanceReports,
  });

  factory CropMaintenance.fromJson(Map<String, dynamic> json) {
    return CropMaintenance(
      id: json['id'],
      cropId: json['crop_id'],
      maintenanceCost: (json['maintenance_cost'] as num).toDouble(),
      yearlyDecayRate: (json['yearly_decay_rate'] as num).toDouble(),
      yearlyDecayCost: (json['yearly_decay_cost'] as num).toDouble(),
      yearlyUsableAmount: (json['yearly_usable_amount'] as num).toDouble(),
      monthlyDecayRate: (json['monthly_decay_rate'] as num).toDouble(),
      monthlyDecayCost: (json['monthly_decay_cost'] as num).toDouble(),
      monthlyUsableAmount: (json['monthly_usable_amount'] as num).toDouble(),
      dailyDecayRate: (json['daily_decay_rate'] as num).toDouble(),
      dailyDecayCost: (json['daily_decay_cost'] as num).toDouble(),
      dailyUsableAmount: (json['daily_usable_amount'] as num).toDouble(),
      maintenanceReports: json['maintenance_reports'] != null
          ? (json['maintenance_reports'] as List)
              .map((report) => MaintenanceReport.fromJson(report))
              .toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'crop_id': cropId,
      'maintenance_cost': maintenanceCost,
      'yearly_decay_rate': yearlyDecayRate,
    };
  }

  // Helper: Get total maintenance cost (base + upgrades)
  double get totalMaintenanceCost {
    if (maintenanceReports == null || maintenanceReports!.isEmpty) {
      return maintenanceCost;
    }
    final upgradesTotal = maintenanceReports!
        .fold(0.0, (sum, report) => sum + report.upgradeCost);
    return maintenanceCost + upgradesTotal;
  }
}
