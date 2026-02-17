import 'ai_division_model.dart';

class User {
  final int id;
  final String username;
  final String? fullName;
  final DateTime? dateOfBirth;
  final AIDivision? aiDivision;
  final bool slGapCertified;
  final String? slGapCertificateNumber;
  final String? location;
  final bool profileCompleted;
  final String role;

  User({
    required this.id,
    required this.username,
    this.fullName,
    this.dateOfBirth,
    this.aiDivision,
    required this.slGapCertified,
    this.slGapCertificateNumber,
    this.location,
    required this.profileCompleted,
    required this.role,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      username: json['username'],
      fullName: json['full_name'],
      dateOfBirth: json['date_of_birth'] != null
          ? DateTime.parse(json['date_of_birth'])
          : null,
      aiDivision: json['ai_division'] != null
          ? AIDivision.fromJson(json['ai_division'])
          : null,
      slGapCertified: json['sl_gap_certified'] ?? false,
      slGapCertificateNumber: json['sl_gap_certificate_number'],
      location: json['location'],
      profileCompleted: json['profile_completed'] ?? false,
      role: json['role'] ?? 'farmer',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'full_name': fullName,
      'date_of_birth': dateOfBirth?.toIso8601String().split('T')[0],
      'ai_division_id': aiDivision?.id,
      'sl_gap_certified': slGapCertified,
      'sl_gap_certificate_number': slGapCertificateNumber,
      'location': location,
      'profile_completed': profileCompleted,
      'role': role,
    };
  }
}
