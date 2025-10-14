class UpdateProfileRequest {
  UpdateProfileRequest({
    required this.name,
    required this.email,
    this.gender,
    this.address,
    this.dateOfBirth,
    this.accountNumber,
    this.bankType,
    this.nomorTelepon,
    this.photoProfil,
    required this.role,
  });

  final String name;
  final String email;
  final String? gender;
  final String? address;
  final String? dateOfBirth;
  final String? accountNumber;
  final String? bankType;
  final String? nomorTelepon;
  final String? photoProfil;
  final String role;

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
      if (gender != null) 'gender': gender,
      if (address != null) 'address': address,
      if (dateOfBirth != null) 'date_of_birth': dateOfBirth,
      if (accountNumber != null) 'account_number': accountNumber,
      if (bankType != null) 'bank_type': bankType,
      if (nomorTelepon != null) 'nomor_telepon': nomorTelepon,
      if (photoProfil != null) 'photo_profil': photoProfil,
      'role': role,
    };
  }
}
