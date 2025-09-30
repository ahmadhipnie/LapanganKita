class UserModel {
  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.gender,
    required this.address,
    required this.dateOfBirth,
    required this.accountNumber,
    required this.bankType,
    required this.role,
    required this.isVerified,
    required this.createdAt,
    required this.updatedAt,
  });

  final int id;
  final String name;
  final String email;
  final String? gender;
  final String? address;
  final DateTime? dateOfBirth;
  final String? accountNumber;
  final String? bankType;
  final String role;
  final bool? isVerified;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  factory UserModel.fromJson(Map<String, dynamic> json) {
    DateTime? parseNullableDate(dynamic value) {
      if (value == null) return null;
      if (value is String && value.isEmpty) return null;
      return DateTime.tryParse(value.toString());
    }

    bool? parseNullableBool(dynamic value) {
      if (value == null) return null;
      if (value is bool) return value;
      if (value is num) return value != 0;
      if (value is String) {
        final lower = value.toLowerCase();
        if (lower == 'true') return true;
        if (lower == 'false') return false;
      }
      return null;
    }

    return UserModel(
      id: json['id'] as int,
      name: json['name']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      gender: json['gender']?.toString(),
      address: json['address']?.toString(),
      dateOfBirth: parseNullableDate(json['date_of_birth']),
      accountNumber: json['account_number']?.toString(),
      bankType: json['bank_type']?.toString(),
      role: json['role']?.toString() ?? '',
      isVerified: parseNullableBool(json['is_verified']),
      createdAt: parseNullableDate(json['created_at']),
      updatedAt: parseNullableDate(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    String? formatDate(DateTime? date) => date?.toIso8601String();

    return {
      'id': id,
      'name': name,
      'email': email,
      'gender': gender,
      'address': address,
      'date_of_birth': formatDate(dateOfBirth),
      'account_number': accountNumber,
      'bank_type': bankType,
      'role': role,
      'is_verified': isVerified,
      'created_at': formatDate(createdAt),
      'updated_at': formatDate(updatedAt),
    };
  }
}
