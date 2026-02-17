import 'package:flutter/material.dart';
import 'farm_model.dart';
import 'crop_category_model.dart';
import '../constants/app_constants.dart';

class Crop {
  final int id;
  final String name; // Auto-populated from farm name
  final String? category; // Auto-populated from farm
  final String? area; // Auto-populated from farm
  final String cropType; // e.g., "Cherry Tomatoes"
  final String? location; // Auto-populated from farm
  final DateTime startDate;
  final DateTime? expectedHarvestDate;
  final int plants;
  final String? totalHarvest;
  final String status; // Planned, Active, Harvested, Closed
  final String? notes;
  final String? waterUsage; // Backend returns string like "0 liters"
  final double? totalWaterUsed;
  final int farmId; // Required
  final Farm? farm; // Nested farm object (for display)
  final int? cropCategoryId; // NEW
  final int? cropTypeId; // NEW
  final CropCategory? cropCategory; // NEW - Nested category object
  final CropType? cropTypeObj; // NEW - Renamed to avoid conflict with cropType string
  final int? perenualId; // Perenual plant species ID
  final Map<String, dynamic>? perenualData; // Cached API response
  final String? perenualImageUrl; // Primary crop image URL
  final DateTime? perenualCachedAt; // Last API fetch timestamp
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Crop({
    required this.id,
    required this.name,
    this.category,
    this.area,
    required this.cropType,
    this.location,
    required this.startDate,
    this.expectedHarvestDate,
    required this.plants,
    this.totalHarvest,
    required this.status,
    this.notes,
    this.waterUsage,
    this.totalWaterUsed,
    required this.farmId,
    this.farm,
    this.cropCategoryId,
    this.cropTypeId,
    this.cropCategory,
    this.cropTypeObj,
    this.perenualId,
    this.perenualData,
    this.perenualImageUrl,
    this.perenualCachedAt,
    this.createdAt,
    this.updatedAt,
  });

  // JSON Deserialization
  factory Crop.fromJson(Map<String, dynamic> json) {
    // Handle crop_type which can be either a string or an object (when eager-loaded)
    String? cropTypeString;
    CropType? cropTypeObject;

    if (json['crop_type'] != null) {
      if (json['crop_type'] is String) {
        cropTypeString = json['crop_type'];
      } else if (json['crop_type'] is Map) {
        cropTypeObject = CropType.fromJson(json['crop_type']);
        cropTypeString = cropTypeObject.name;
      }
    }

    return Crop(
      id: json['id'],
      name: json['name'],
      category: json['category'],
      area: json['area'],
      cropType: cropTypeString ?? 'Unknown',
      location: json['location'],
      startDate: DateTime.parse(json['start_date']),
      expectedHarvestDate: json['expected_harvest_date'] != null
          ? DateTime.parse(json['expected_harvest_date'])
          : null,
      plants: json['plants'],
      totalHarvest: json['total_harvest']?.toString(),
      status: json['status'],
      notes: json['notes'],
      waterUsage: json['water_usage']?.toString(), // Backend returns string like "0 liters"
      totalWaterUsed: json['total_water_used'] != null
          ? (json['total_water_used'] as num).toDouble()
          : null,
      farmId: json['farm_id'],
      farm: json['farm'] != null ? Farm.fromJson(json['farm']) : null,
      cropCategoryId: json['crop_category_id'],
      cropTypeId: json['crop_type_id'],
      cropCategory: json['crop_category'] != null
          ? CropCategory.fromJson(json['crop_category'])
          : null,
      cropTypeObj: cropTypeObject, // Use the already parsed object
      perenualId: json['perenual_id'],
      perenualData: json['perenual_data'],
      perenualImageUrl: json['perenual_image_url'],
      perenualCachedAt: json['perenual_cached_at'] != null
          ? DateTime.parse(json['perenual_cached_at'])
          : null,
      createdAt:
          json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
      updatedAt:
          json['updated_at'] != null ? DateTime.parse(json['updated_at']) : null,
    );
  }

  // JSON Serialization (for API requests)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'area': area,
      'crop_type': cropType,
      'location': location,
      'start_date': startDate.toIso8601String().split('T')[0], // YYYY-MM-DD
      'expected_harvest_date': expectedHarvestDate?.toIso8601String().split('T')[0],
      'plants': plants,
      'total_harvest': totalHarvest,
      'status': status,
      'notes': notes,
      'water_usage': waterUsage,
      'total_water_used': totalWaterUsed,
      'farm_id': farmId,
    };
  }

  // Helper: Get status color based on status
  Color get statusColor {
    switch (status) {
      case 'Planned':
        return Colors.blue;
      case 'Active':
        return AppConstants.limeGreen;
      case 'Harvested':
        return Colors.orange;
      case 'Closed':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }

  // Helper: Calculate days until harvest
  int? get daysUntilHarvest {
    if (expectedHarvestDate == null) return null;
    final now = DateTime.now();
    return expectedHarvestDate!.difference(now).inDays;
  }

  // Helper: Display area with category
  String get displayArea {
    if (area == null || category == null) return 'N/A';
    return '$area - $category';
  }

  // Helper: Display farm name
  String get displayFarm {
    return farm?.name ?? 'Unknown Farm';
  }

  // Helper: Format start date
  String get formattedStartDate {
    return '${startDate.day}/${startDate.month}/${startDate.year}';
  }

  // Helper: Format expected harvest date
  String? get formattedExpectedHarvestDate {
    if (expectedHarvestDate == null) return null;
    return '${expectedHarvestDate!.day}/${expectedHarvestDate!.month}/${expectedHarvestDate!.year}';
  }

  // Helper: Get status badge background color (with opacity)
  Color get statusBackgroundColor {
    return statusColor.withValues(alpha: 0.1);
  }

  // Helper: Get status badge border color
  Color get statusBorderColor {
    return statusColor.withValues(alpha: 0.3);
  }

  // Helper: Get crop image URL (for display in UI)
  String? get cropImageUrl => perenualImageUrl;

  // Helper: Get care requirements data
  Map<String, dynamic>? get careRequirements =>
      perenualData?['care_requirements'];

  // Helper: Get watering frequency
  String? get wateringFrequency => careRequirements?['watering'];

  // Helper: Get sunlight needs
  List<String>? get sunlightNeeds =>
      (careRequirements?['sunlight'] as List?)?.cast<String>();

  // Helper: Get soil types
  List<String>? get soilTypes =>
      (careRequirements?['soil'] as List?)?.cast<String>();

  // Helper: Get growth rate
  String? get growthRate => perenualData?['growth']?['growth_rate'];

  // Helper: Get care level
  String? get careLevel => perenualData?['growth']?['care_level'];

  // Helper: Get scientific name
  String? get scientificName => perenualData?['scientific_name'];

  // Helper: Check if edible
  bool? get isEdible => perenualData?['edibility']?['edible_fruit'];

  // Helper: Check if poisonous to humans
  bool? get isPoisonous => perenualData?['edibility']?['poisonous_to_humans'];
}

// Crop status constants
class CropStatus {
  static const String planned = 'Planned';
  static const String active = 'Active';
  static const String harvested = 'Harvested';
  static const String closed = 'Closed';

  static const List<String> all = [
    planned,
    active,
    harvested,
    closed,
  ];
}
