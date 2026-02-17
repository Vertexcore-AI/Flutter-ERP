class CropCategory {
  final int id;
  final String name;
  final String? description;
  final String? icon;
  final int sortOrder;

  CropCategory({
    required this.id,
    required this.name,
    this.description,
    this.icon,
    required this.sortOrder,
  });

  factory CropCategory.fromJson(Map<String, dynamic> json) {
    return CropCategory(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      icon: json['icon'],
      sortOrder: json['sort_order'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'icon': icon,
      'sort_order': sortOrder,
    };
  }
}

class CropType {
  final int id;
  final int cropCategoryId;
  final String name;
  final String? scientificName;
  final String? description;
  final CropCategory? cropCategory; // For nested responses

  CropType({
    required this.id,
    required this.cropCategoryId,
    required this.name,
    this.scientificName,
    this.description,
    this.cropCategory,
  });

  factory CropType.fromJson(Map<String, dynamic> json) {
    return CropType(
      id: json['id'],
      cropCategoryId: json['crop_category_id'],
      name: json['name'],
      scientificName: json['scientific_name'],
      description: json['description'],
      cropCategory: json['crop_category'] != null
          ? CropCategory.fromJson(json['crop_category'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'crop_category_id': cropCategoryId,
      'name': name,
      'scientific_name': scientificName,
      'description': description,
    };
  }
}
