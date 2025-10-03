class UpdateProfileRequest {
  final String name;
  final String email;
  final String? gender;
  final String? address;
  final String? dateOfBirth;
  final String? accountNumber;
  final String? bankType;
  final String? role;

  UpdateProfileRequest({
    required this.name,
    required this.email,
    this.gender,
    this.address,
    this.dateOfBirth,
    this.accountNumber,
    this.bankType,
    this.role,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
      'gender': gender,
      'address': address,
      'date_of_birth': dateOfBirth,
      'account_number': accountNumber,
      'bank_type': bankType,
      'role': role,
    };
  }
}
