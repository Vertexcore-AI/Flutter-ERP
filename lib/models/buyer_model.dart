import 'package:intl/intl.dart';

/// Buyer Model
/// Represents a buyer/company with location data
class Buyer {
  final int id;
  final String name;
  final double? latitude;
  final double? longitude;
  final String city;
  final String province;
  final String? postalCode;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Buyer({
    required this.id,
    required this.name,
    this.latitude,
    this.longitude,
    required this.city,
    required this.province,
    this.postalCode,
    this.createdAt,
    this.updatedAt,
  });

  // JSON Deserialization
  factory Buyer.fromJson(Map<String, dynamic> json) {
    return Buyer(
      id: json['id'],
      name: json['name'],
      latitude: json['latitude'] != null
          ? double.tryParse(json['latitude'].toString())
          : null,
      longitude: json['longitude'] != null
          ? double.tryParse(json['longitude'].toString())
          : null,
      city: json['city'] ?? '',
      province: json['province'] ?? '',
      postalCode: json['postal_code'],
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
      'latitude': latitude,
      'longitude': longitude,
      'city': city,
      'province': province,
      'postal_code': postalCode,
    };
  }

  // Create payload for API (without id, timestamps)
  Map<String, dynamic> toCreatePayload() {
    final payload = <String, dynamic>{
      'name': name,
      'city': city,
      'province': province,
    };

    if (latitude != null) {
      payload['latitude'] = latitude;
    }

    if (longitude != null) {
      payload['longitude'] = longitude;
    }

    if (postalCode != null && postalCode!.isNotEmpty) {
      payload['postal_code'] = postalCode;
    }

    return payload;
  }

  // Update payload (only changed fields)
  Map<String, dynamic> toUpdatePayload({
    String? newName,
    String? newCity,
    String? newProvince,
    String? newPostalCode,
    double? newLatitude,
    double? newLongitude,
    bool clearCoordinates = false,
  }) {
    final payload = <String, dynamic>{};

    if (newName != null && newName != name) {
      payload['name'] = newName;
    }

    if (newCity != null && newCity != city) {
      payload['city'] = newCity;
    }

    if (newProvince != null && newProvince != province) {
      payload['province'] = newProvince;
    }

    if (newPostalCode != null && newPostalCode != postalCode) {
      payload['postal_code'] = newPostalCode;
    }

    if (clearCoordinates) {
      payload['latitude'] = null;
      payload['longitude'] = null;
    } else {
      if (newLatitude != null && newLatitude != latitude) {
        payload['latitude'] = newLatitude;
      }

      if (newLongitude != null && newLongitude != longitude) {
        payload['longitude'] = newLongitude;
      }
    }

    return payload;
  }

  // Helper: Formatted location string
  String formattedLocation() {
    final parts = <String>[];

    if (city.isNotEmpty) parts.add(city);
    if (province.isNotEmpty) parts.add(province);

    return parts.join(', ');
  }

  // Helper: Full location with postal code
  String fullLocation() {
    final location = formattedLocation();
    if (postalCode != null && postalCode!.isNotEmpty) {
      return '$location $postalCode';
    }
    return location;
  }

  // Helper: Check if buyer has coordinates
  bool hasCoordinates() {
    return latitude != null && longitude != null;
  }

  // Helper: Formatted creation date
  String formattedCreatedAt() {
    if (createdAt == null) return '';
    return DateFormat('MMM dd, yyyy').format(createdAt!);
  }

  // Copy with method for updating individual fields
  Buyer copyWith({
    int? id,
    String? name,
    double? latitude,
    double? longitude,
    String? city,
    String? province,
    String? postalCode,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Buyer(
      id: id ?? this.id,
      name: name ?? this.name,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      city: city ?? this.city,
      province: province ?? this.province,
      postalCode: postalCode ?? this.postalCode,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
