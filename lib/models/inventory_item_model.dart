class InventoryItem {
  final int id;
  final String itemName;
  final String category;
  final String inventoryType; // Consumable, Asset, Service
  final String? sourceResource; // Batch number
  final int quantityPurchased;
  final int quantityAvailable;
  final String unit;
  final double unitPrice;
  final String purchaseDate;

  InventoryItem({
    required this.id,
    required this.itemName,
    required this.category,
    required this.inventoryType,
    this.sourceResource,
    required this.quantityPurchased,
    required this.quantityAvailable,
    required this.unit,
    required this.unitPrice,
    required this.purchaseDate,
  });

  // Computed properties
  double get totalValue => quantityAvailable * unitPrice;
  double get percentAvailable =>
      quantityPurchased > 0 ? (quantityAvailable / quantityPurchased) * 100 : 0;

  factory InventoryItem.fromJson(Map<String, dynamic> json) {
    return InventoryItem(
      id: json['id'],
      itemName: json['item_name'],
      category: json['category'],
      inventoryType: json['inventory_type'] ?? 'Consumable',
      sourceResource: json['source_resource'],
      quantityPurchased: json['quantity_purchased'] ?? 0,
      quantityAvailable: json['quantity_available'] ?? 0,
      unit: json['unit'],
      unitPrice: json['unit_price'] != null
          ? double.parse(json['unit_price'].toString())
          : 0.0,
      purchaseDate: json['purchase_date'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'item_name': itemName,
      'category': category,
      'inventory_type': inventoryType,
      'source_resource': sourceResource,
      'quantity_purchased': quantityPurchased,
      'quantity_available': quantityAvailable,
      'unit': unit,
      'unit_price': unitPrice,
      'purchase_date': purchaseDate,
    };
  }
}
