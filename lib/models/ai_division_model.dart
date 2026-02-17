class AIDivision {
  final int id;
  final String name;
  final String district;
  final String province;

  AIDivision({
    required this.id,
    required this.name,
    required this.district,
    required this.province,
  });

  factory AIDivision.fromJson(Map<String, dynamic> json) {
    return AIDivision(
      id: json['id'],
      name: json['name'],
      district: json['district'],
      province: json['province'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'district': district,
      'province': province,
    };
  }

  // Display format: "Division Name, District, Province"
  String get displayName => '$name, $district, $province';

  // Search-friendly string
  String get searchableText =>
      '${name.toLowerCase()} ${district.toLowerCase()} ${province.toLowerCase()}';
}
