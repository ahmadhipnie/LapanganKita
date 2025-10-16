class PlaceModel {
  const PlaceModel({
    required this.id,
    required this.placeName,
    required this.address,
    required this.balance,
    this.placePhoto,
    this.userId,
    this.createdAt,
    this.updatedAt,
    this.ownerName,
    this.ownerEmail,
  });

  final int id;
  final String placeName;
  final String address;
  final int balance;
  final String? placePhoto;
  final int? userId;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String? ownerName;
  final String? ownerEmail;

  PlaceModel copyWith({
    int? id,
    String? placeName,
    String? address,
    int? balance,
    String? placePhoto,
    int? userId,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? ownerName,
    String? ownerEmail,
  }) {
    return PlaceModel(
      id: id ?? this.id,
      placeName: placeName ?? this.placeName,
      address: address ?? this.address,
      balance: balance ?? this.balance,
      placePhoto: placePhoto ?? this.placePhoto,
      userId: userId ?? this.userId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      ownerName: ownerName ?? this.ownerName,
      ownerEmail: ownerEmail ?? this.ownerEmail,
    );
  }

  factory PlaceModel.fromJson(Map<String, dynamic> json) {
    DateTime? parseNullableDate(dynamic value) {
      if (value == null) return null;
      if (value is String && value.isEmpty) return null;
      return DateTime.tryParse(value.toString());
    }

    int parseInt(dynamic value) {
      if (value == null) return 0;
      if (value is int) return value;
      if (value is double) return value.toInt();
      if (value is String) {
        return int.tryParse(value) ?? 0;
      }
      return 0;
    }

    return PlaceModel(
      id: parseInt(json['id']),
      placeName: json['place_name']?.toString() ?? '',
      address: json['address']?.toString() ?? '',
      balance: parseInt(json['balance']),
      placePhoto: json['place_photo']?.toString(),
      userId: json['id_users'] is int
          ? json['id_users'] as int
          : int.tryParse(json['id_users']?.toString() ?? ''),
      createdAt: parseNullableDate(json['created_at']),
      updatedAt: parseNullableDate(json['updated_at']),
      ownerName: json['owner_name']?.toString(),
      ownerEmail: json['owner_email']?.toString(),
    );
  }
}
