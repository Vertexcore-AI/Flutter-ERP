import 'inventory_item_model.dart';

class FungicideManagement {
  final int id;
  final int cropId;
  final int inventoryId;
  final DateTime applicationDate;
  final String applicationType; // BY_PLANT | ENTIRE_CROP
  final String? applicationMethod;
  final int numberOfPlants;
  final double amountPerPlant;
  final String unit;
  final double totalAmountUsed;
  final String? notes;
  final InventoryItem? inventory;

  FungicideManagement({
    required this.id,
    required this.cropId,
    required this.inventoryId,
    required this.applicationDate,
    required this.applicationType,
    this.applicationMethod,
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
      amountPerPlant: double.parse(json['amount_per_plant'].toString()),
      unit: json['unit'],
      totalAmountUsed: double.parse(json['total_amount_used'].toString()),
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
}
