class WaterManagement {
  final int id;
  final int cropId;
  final DateTime wateringDate;
  final String wateringType; // BY_PLANT | ENTIRE_CROP
  final String? wateringMethod; // Drip | Sprinkler | Manual
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
    this.wateringMethod,
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
      waterPerPlant: double.parse(json['water_per_plant'].toString()),
      waterUnit: json['water_unit'],
      totalWaterUsed: double.parse(json['total_water_used'].toString()),
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
