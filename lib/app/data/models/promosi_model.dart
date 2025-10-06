import 'package:intl/intl.dart';

class PromosiModel {
  const PromosiModel({
    required this.id,
    required this.filePhoto,
    required this.filePhotoUrl,
    required this.createdAt,
    required this.updatedAt,
  });

  final int id;
  final String filePhoto;
  final String filePhotoUrl;
  final DateTime createdAt;
  final DateTime updatedAt;

  factory PromosiModel.fromJson(Map<String, dynamic> json) {
    int parseInt(dynamic value) {
      if (value is int) return value;
      if (value is double) return value.round();
      if (value is String) {
        return int.tryParse(value) ?? 0;
      }
      return 0;
    }

    DateTime parseDate(dynamic value) {
      if (value == null) return DateTime.fromMillisecondsSinceEpoch(0);
      if (value is DateTime) return value.toLocal();
      final parsed = DateTime.tryParse(value.toString());
      return (parsed ?? DateTime.fromMillisecondsSinceEpoch(0)).toLocal();
    }

    String readString(dynamic value) {
      if (value == null) return '';
      return value.toString();
    }

    return PromosiModel(
      id: parseInt(json['id'] ?? json['promosi_id']),
      filePhoto: readString(json['file_photo']),
      filePhotoUrl: readString(json['file_photo_url']),
      createdAt: parseDate(json['created_at']),
      updatedAt: parseDate(json['updated_at'] ?? json['created_at']),
    );
  }

  String formattedDate({String pattern = 'dd MMM yyyy, HH:mm'}) {
    final formatter = DateFormat(pattern, 'id_ID');
    return formatter.format(createdAt.toLocal());
  }

  PromosiModel copyWith({
    int? id,
    String? filePhoto,
    String? filePhotoUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return PromosiModel(
      id: id ?? this.id,
      filePhoto: filePhoto ?? this.filePhoto,
      filePhotoUrl: filePhotoUrl ?? this.filePhotoUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
