import 'dart:io';

class AddOnPayload {
  const AddOnPayload({
    required this.name,
    required this.pricePerHour,
    required this.stock,
    required this.description,
    required this.placeId,
    required this.userId,
    this.photo,
  });

  final String name;
  final int pricePerHour;
  final int stock;
  final String description;
  final int placeId;
  final int userId;
  final File? photo;
}

class AddOnUpdatePayload {
  const AddOnUpdatePayload({
    required this.id,
    required this.name,
    required this.pricePerHour,
    required this.stock,
    required this.description,
    required this.userId,
    this.placeId,
    this.photo,
  });

  final int id;
  final String name;
  final int pricePerHour;
  final int stock;
  final String description;
  final int userId;
  final int? placeId;
  final File? photo;
}

class AddOnModel {
  const AddOnModel({
    required this.id,
    required this.name,
    required this.pricePerHour,
    required this.stock,
    required this.description,
    this.photo,
    this.placeId,
    this.userId,
    this.createdAt,
    this.updatedAt,
  });

  final int id;
  final String name;
  final int pricePerHour;
  final int stock;
  final String description;
  final String? photo;
  final int? placeId;
  final int? userId;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  AddOnModel copyWith({
    int? id,
    String? name,
    int? pricePerHour,
    int? stock,
    String? description,
    String? photo,
    int? placeId,
    int? userId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return AddOnModel(
      id: id ?? this.id,
      name: name ?? this.name,
      pricePerHour: pricePerHour ?? this.pricePerHour,
      stock: stock ?? this.stock,
      description: description ?? this.description,
      photo: photo ?? this.photo,
      placeId: placeId ?? this.placeId,
      userId: userId ?? this.userId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  factory AddOnModel.fromJson(Map<String, dynamic> json) {
    int parseInt(dynamic value) {
      if (value == null) return 0;
      if (value is int) return value;
      if (value is double) return value.toInt();
      if (value is String) {
        return int.tryParse(value) ?? 0;
      }
      return 0;
    }

    DateTime? parseDate(dynamic value) {
      if (value == null) return null;
      if (value is String && value.isEmpty) return null;
      return DateTime.tryParse(value.toString());
    }

    Map<String, dynamic> source = json;

    if (json['add_on'] is Map<String, dynamic>) {
      source = Map<String, dynamic>.from(json['add_on'] as Map);
    }

    return AddOnModel(
      id: parseInt(source['id'] ?? source['id_add_on']),
      name: source['add_on_name']?.toString() ?? '',
      pricePerHour: parseInt(source['price_per_hour']),
      stock: parseInt(source['stock']),
      description: source['add_on_description']?.toString() ?? '',
      photo: source['add_on_photo']?.toString(),
      placeId: (source['place_id'] is int)
          ? source['place_id'] as int
          : int.tryParse(source['place_id']?.toString() ?? ''),
      userId: (source['id_users'] is int)
          ? source['id_users'] as int
          : int.tryParse(source['id_users']?.toString() ?? ''),
      createdAt: parseDate(source['created_at']),
      updatedAt: parseDate(source['updated_at']),
    );
  }
}

class AddOnResponse {
  const AddOnResponse({
    required this.success,
    required this.message,
    this.data,
    this.addOn,
  });

  final bool success;
  final String message;
  final Map<String, dynamic>? data;
  final AddOnModel? addOn;

  factory AddOnResponse.fromJson(Map<String, dynamic> json) {
    Map<String, dynamic>? rawData;
    AddOnModel? addOn;

    if (json['data'] is Map) {
      rawData = Map<String, dynamic>.from(json['data'] as Map);
      try {
        addOn = AddOnModel.fromJson(rawData);
      } catch (_) {
        addOn = null;
      }
    }

    return AddOnResponse(
      success: json['success'] == true,
      message: json['message']?.toString() ?? '',
      data: rawData,
      addOn: addOn,
    );
  }
}
