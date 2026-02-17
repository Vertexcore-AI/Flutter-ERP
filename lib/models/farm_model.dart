class Farm {
  final int id;
  final String name;
  final String mainCategory;
  final String category;
  final String area;
  final String areaUnit;
  final String? location;
  final double? latitude;
  final double? longitude;
  final String? notes;
  final String? imagePath;
  final int? cropsCount;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Farm({
    required this.id,
    required this.name,
    required this.mainCategory,
    required this.category,
    required this.area,
    required this.areaUnit,
    this.location,
    this.latitude,
    this.longitude,
    this.notes,
    this.imagePath,
    this.cropsCount,
    this.createdAt,
    this.updatedAt,
  });

  // JSON Deserialization
  factory Farm.fromJson(Map<String, dynamic> json) {
    return Farm(
      id: json['id'],
      name: json['name'],
      mainCategory: json['main_category'],
      category: json['category'],
      area: json['area'],
      areaUnit: json['area_unit'],
      location: json['location'],
      latitude: json['latitude'] != null ? (json['latitude'] as num).toDouble() : null,
      longitude: json['longitude'] != null ? (json['longitude'] as num).toDouble() : null,
      notes: json['notes'],
      imagePath: json['image_path'],
      cropsCount: json['crops_count'],
      createdAt: json['created_at'] != null
        ? DateTime.parse(json['created_at'])
        : null,
      updatedAt: json['updated_at'] != null
        ? DateTime.parse(json['updated_at'])
        : null,
    );
  }

  // JSON Serialization
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'main_category': mainCategory,
      'category': category,
      'area': area,
      'area_unit': areaUnit,
      'location': location,
      'latitude': latitude,
      'longitude': longitude,
      'notes': notes,
      'image_path': imagePath,
      'crops_count': cropsCount,
    };
  }

  // Helper to get full image URL
  String? getImageUrl(String baseUrl) {
    if (imagePath == null) return null;
    return '$baseUrl/storage/$imagePath';
  }

  // Display area with unit
  String get displayArea => '$area $areaUnit';
}

// Category constants matching Next.js implementation
class FarmCategories {
  static const List<String> mainCategories = [
    'Protected Farming',
    'Outdoor Farming',
  ];

  static const Map<String, List<String>> subCategories = {
    'Protected Farming': [
      'Green House',
      'Poly Tunnel',
      'Net / Shading House',
      'Other',
    ],
    'Outdoor Farming': [
      'Other',
      'Spices',
      'Vegetable',
      'Tea Plantation',
      'Coconut Plantation',
      'Fruit',
      'Flowers',
    ],
  };

  static const Map<String, List<String>> areaUnits = {
    'Protected Farming': ['sqf'],
    'Outdoor Farming': ['perches', 'acres'],
  };
}
