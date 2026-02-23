import 'crop_model.dart';
import 'crop_cycle_models.dart';

/// Extended Crop model with management relationships for Crop Cycles screen
class CropCycle extends Crop {
  final List<WaterManagement> waterManagements;
  final List<FertilizerManagement> fertilizerManagements;
  final List<PesticideManagement> pesticideManagements;
  final List<FungicideManagement> fungicideManagements;
  final CropMaintenance? cropMaintenance;

  CropCycle({
    required super.id,
    required super.name,
    super.category,
    super.area,
    required super.cropType,
    super.location,
    required super.startDate,
    super.expectedHarvestDate,
    required super.plants,
    super.totalHarvest,
    required super.status,
    super.notes,
    super.waterUsage,
    super.totalWaterUsed,
    required super.farmId,
    super.farm,
    super.cropCategoryId,
    super.cropTypeId,
    super.cropCategory,
    super.cropTypeObj,
    super.perenualId,
    super.perenualData,
    super.perenualImageUrl,
    super.perenualCachedAt,
    super.createdAt,
    super.updatedAt,
    this.waterManagements = const [],
    this.fertilizerManagements = const [],
    this.pesticideManagements = const [],
    this.fungicideManagements = const [],
    this.cropMaintenance,
  });

  /// Create from JSON with eager-loaded relationships
  factory CropCycle.fromJson(Map<String, dynamic> json) {
    // Parse base Crop fields
    final baseCrop = Crop.fromJson(json);

    // Parse water managements
    final List<WaterManagement> waterMgmt = json['water_managements'] != null
        ? (json['water_managements'] as List)
            .map((item) => WaterManagement.fromJson(item))
            .toList()
        : [];

    // Parse fertilizer managements
    final List<FertilizerManagement> fertilizerMgmt =
        json['fertilizer_managements'] != null
            ? (json['fertilizer_managements'] as List)
                .map((item) => FertilizerManagement.fromJson(item))
                .toList()
            : [];

    // Parse pesticide managements
    final List<PesticideManagement> pesticideMgmt =
        json['pesticide_managements'] != null
            ? (json['pesticide_managements'] as List)
                .map((item) => PesticideManagement.fromJson(item))
                .toList()
            : [];

    // Parse fungicide managements
    final List<FungicideManagement> fungicideMgmt =
        json['fungicide_managements'] != null
            ? (json['fungicide_managements'] as List)
                .map((item) => FungicideManagement.fromJson(item))
                .toList()
            : [];

    // Parse crop maintenance (one-to-one relationship)
    final CropMaintenance? cropMaint = json['crop_maintenance'] != null
        ? CropMaintenance.fromJson(json['crop_maintenance'])
        : null;

    return CropCycle(
      id: baseCrop.id,
      name: baseCrop.name,
      category: baseCrop.category,
      area: baseCrop.area,
      cropType: baseCrop.cropType,
      location: baseCrop.location,
      startDate: baseCrop.startDate,
      expectedHarvestDate: baseCrop.expectedHarvestDate,
      plants: baseCrop.plants,
      totalHarvest: baseCrop.totalHarvest,
      status: baseCrop.status,
      notes: baseCrop.notes,
      waterUsage: baseCrop.waterUsage,
      totalWaterUsed: baseCrop.totalWaterUsed,
      farmId: baseCrop.farmId,
      farm: baseCrop.farm,
      cropCategoryId: baseCrop.cropCategoryId,
      cropTypeId: baseCrop.cropTypeId,
      cropCategory: baseCrop.cropCategory,
      cropTypeObj: baseCrop.cropTypeObj,
      perenualId: baseCrop.perenualId,
      perenualData: baseCrop.perenualData,
      perenualImageUrl: baseCrop.perenualImageUrl,
      perenualCachedAt: baseCrop.perenualCachedAt,
      createdAt: baseCrop.createdAt,
      updatedAt: baseCrop.updatedAt,
      waterManagements: waterMgmt,
      fertilizerManagements: fertilizerMgmt,
      pesticideManagements: pesticideMgmt,
      fungicideManagements: fungicideMgmt,
      cropMaintenance: cropMaint,
    );
  }

  // ============================================================================
  // COMPUTED PROPERTIES FOR UI DISPLAY
  // ============================================================================

  /// Get today's total watering amount
  double get todaysWatering {
    final today = DateTime.now();
    return waterManagements
        .where((log) => isSameDay(log.wateringDate, today))
        .fold(0.0, (sum, log) => sum + log.totalWaterUsed);
  }

  /// Get today's fertilizer applications
  List<FertilizerManagement> get todaysFertilizer {
    final today = DateTime.now();
    return fertilizerManagements
        .where((log) => isSameDay(log.applicationDate, today))
        .toList();
  }

  /// Get today's pesticide applications
  List<PesticideManagement> get todaysPesticide {
    final today = DateTime.now();
    return pesticideManagements
        .where((log) => isSameDay(log.applicationDate, today))
        .toList();
  }

  /// Get today's fungicide applications
  List<FungicideManagement> get todaysFungicide {
    final today = DateTime.now();
    return fungicideManagements
        .where((log) => isSameDay(log.applicationDate, today))
        .toList();
  }

  /// Get total water used (from all logs)
  double get totalWater {
    return waterManagements.fold(
        0.0, (sum, log) => sum + log.totalWaterUsed);
  }

  /// Get total fertilizer logs count
  int get fertilizerLogsCount => fertilizerManagements.length;

  /// Get total pesticide logs count
  int get pesticideLogsCount => pesticideManagements.length;

  /// Get total fungicide logs count
  int get fungicideLogsCount => fungicideManagements.length;

  /// Check if there's any today's activity
  bool get hasTodaysActivity {
    return todaysWatering > 0 ||
        todaysFertilizer.isNotEmpty ||
        todaysPesticide.isNotEmpty ||
        todaysFungicide.isNotEmpty;
  }
}
