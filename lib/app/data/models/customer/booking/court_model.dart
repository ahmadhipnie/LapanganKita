class Court {
  final int id;
  final String name;
  final String location;
  final String imageUrl;
  final double price;
  final List<String> types;
  final String description;
  final Map<String, String> openingHours;
  final List<Equipment> equipment;
  final String mapsUrl;
  final String openingTime;
  final String closingTime;
  final String fieldType;
  final String status;
  final int maxPerson;
  final int placeId;
  final String placeName;
  final String placeAddress;
  final String placeOwnerName;
  final String isVerifiedAdmin; // ADD THIS

  Court({
    required this.id,
    required this.name,
    required this.location,
    required this.imageUrl,
    required this.price,
    required this.types,
    required this.description,
    required this.openingHours,
    required this.equipment,
    required this.mapsUrl,
    required this.openingTime,
    required this.closingTime,
    required this.fieldType,
    required this.status,
    required this.maxPerson,
    required this.placeId,
    required this.placeName,
    required this.placeAddress,
    required this.placeOwnerName,
    required this.isVerifiedAdmin, // ADD THIS
  });

  factory Court.fromJson(Map<String, dynamic> json) {
    return Court(
      id: json['id'] ?? 0,
      name: json['field_name'] ?? '',
      location: json['place_address'] ?? '',
      imageUrl: json['field_photo'] ?? '',
      price: (json['price_per_hour'] as num?)?.toDouble() ?? 0.0,
      types: _parseFieldTypes(json['field_type'] ?? ''),
      description: json['description'] ?? '',
      openingHours: {
        'monday-sunday':
            '${json['opening_time'] ?? ''} - ${json['closing_time'] ?? ''}',
      },
      equipment: [],
      mapsUrl: '',
      openingTime: json['opening_time'] ?? '',
      closingTime: json['closing_time'] ?? '',
      fieldType: json['field_type'] ?? '',
      status: json['status'] ?? '',
      maxPerson: json['max_person'] ?? 0,
      placeId: json['id_place'] ?? 0,
      placeName: json['place_name'] ?? '',
      placeAddress: json['place_address'] ?? '',
      placeOwnerName: json['place_owner_name'] ?? '',
      isVerifiedAdmin: json['is_verified_admin'] ?? 'pending', // ADD THIS
    );
  }

  static List<String> _parseFieldTypes(String fieldType) {
    if (fieldType.isEmpty) return ['Unknown'];
    switch (fieldType.toLowerCase()) {
      case 'futsal':
        return ['Futsal'];
      case 'mini soccer':
        return ['Mini Soccer'];
      case 'basketball':
      case 'basket':
        return ['Basketball'];
      case 'tennis':
        return ['Tennis'];
      case 'badminton':
        return ['Badminton'];
      case 'volleyball':
      case 'voli':
        return ['Volleyball'];
      default:
        return [fieldType];
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'field_name': name,
      'place_address': location,
      'field_photo': imageUrl,
      'price_per_hour': price,
      'field_type': fieldType,
      'description': description,
      'opening_time': openingTime,
      'closing_time': closingTime,
      'status': status,
      'max_person': maxPerson,
      'id_place': placeId,
      'place_name': placeName,
      'place_owner_name': placeOwnerName,
      'is_verified_admin': isVerifiedAdmin, // ADD THIS
    };
  }
}

class Equipment {
  final String name;
  final String description;
  final double price;

  Equipment({
    required this.name,
    required this.description,
    required this.price,
  });

  factory Equipment.fromJson(Map<String, dynamic> json) {
    return Equipment(
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {'name': name, 'description': description, 'price': price};
  }
}

class ApiResponse {
  final bool success;
  final String message;
  final List<dynamic> data;

  ApiResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory ApiResponse.fromJson(Map<String, dynamic> json) {
    return ApiResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: json['data'] ?? [],
    );
  }
}
