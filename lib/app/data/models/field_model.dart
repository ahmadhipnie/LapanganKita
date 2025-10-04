class FieldModel {
  const FieldModel({
    required this.id,
    required this.fieldName,
    required this.openingTime,
    required this.closingTime,
    required this.pricePerHour,
    required this.description,
    required this.fieldType,
    required this.fieldPhoto,
    required this.status,
    required this.maxPerson,
    required this.placeId,
    this.createdAt,
    this.updatedAt,
    this.placeName,
    this.placeAddress,
    this.placeOwnerName,
  });

  final int id;
  final String fieldName;
  final String openingTime;
  final String closingTime;
  final int pricePerHour;
  final String description;
  final String fieldType;
  final String? fieldPhoto;
  final String status;
  final int maxPerson;
  final int placeId;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String? placeName;
  final String? placeAddress;
  final String? placeOwnerName;

  factory FieldModel.fromJson(Map<String, dynamic> json) {
    int parseInt(dynamic value) {
      if (value == null) return 0;
      if (value is int) return value;
      if (value is double) return value.toInt();
      if (value is String) {
        return int.tryParse(value) ?? 0;
      }
      return 0;
    }

    String parseString(dynamic value) => value?.toString() ?? '';

    DateTime? parseDate(dynamic value) {
      if (value == null) return null;
      if (value is String && value.isEmpty) return null;
      return DateTime.tryParse(value.toString());
    }

    return FieldModel(
      id: parseInt(json['id']),
      fieldName: parseString(json['field_name']),
      openingTime: parseString(json['opening_time']),
      closingTime: parseString(json['closing_time']),
      pricePerHour: parseInt(json['price_per_hour']),
      description: parseString(json['description']),
      fieldType: parseString(json['field_type']),
      fieldPhoto: json['field_photo']?.toString(),
      status: parseString(json['status']),
      maxPerson: parseInt(json['max_person']),
      placeId: parseInt(json['id_place'] ?? json['place_id']),
      createdAt: parseDate(json['created_at']),
      updatedAt: parseDate(json['updated_at']),
      placeName: json['place_name']?.toString(),
      placeAddress: json['place_address']?.toString(),
      placeOwnerName: json['place_owner_name']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'field_name': fieldName,
      'opening_time': openingTime,
      'closing_time': closingTime,
      'price_per_hour': pricePerHour,
      'description': description,
      'field_type': fieldType,
      'field_photo': fieldPhoto,
      'status': status,
      'max_person': maxPerson,
      'id_place': placeId,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'place_name': placeName,
      'place_address': placeAddress,
      'place_owner_name': placeOwnerName,
    };
  }
}
