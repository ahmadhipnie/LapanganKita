import 'package:intl/intl.dart';

class PromosiSliderImage {
  const PromosiSliderImage({
    required this.id,
    required this.imageUrl,
    required this.createdAt,
  });

  final int id;
  final String imageUrl;
  final DateTime createdAt;

  factory PromosiSliderImage.fromJson(Map<String, dynamic> json) {
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

    String parseUrl(dynamic value) {
      if (value == null) return '';
      return value.toString();
    }

    return PromosiSliderImage(
      id: parseInt(json['id']),
      imageUrl: parseUrl(json['image_url']),
      createdAt: parseDate(json['created_at']),
    );
  }

  String formattedDate({String pattern = 'dd MMM yyyy'}) {
    final formatter = DateFormat(pattern, 'id_ID');
    return formatter.format(createdAt.toLocal());
  }
}
