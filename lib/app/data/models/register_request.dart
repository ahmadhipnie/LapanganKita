class RegisterRequest {
  const RegisterRequest({
    required this.name,
    required this.email,
    required this.password,
    required this.gender,
    required this.address,
    required this.dateOfBirth,
    required this.accountNumber,
    required this.bankType,
    required this.role,
  });

  final String name;
  final String email;
  final String password;
  final String gender;
  final String address;
  final String dateOfBirth;
  final String accountNumber;
  final String bankType;
  final String role;

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
      'password': password,
      'gender': gender,
      'address': address,
      'date_of_birth': dateOfBirth,
      'account_number': accountNumber,
      'bank_type': bankType,
      'role': role,
    };
  }
}
