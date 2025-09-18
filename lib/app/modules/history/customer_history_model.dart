import 'package:intl/intl.dart';

class BookingHistory {
  final String id;
  final String courtName;
  final String courtImageUrl;
  final String location;
  final DateTime date;
  final String startTime;
  final int duration;
  final double totalAmount;
  final String status; // pending, approved, rejected
  final Map<String, int> equipment;
  final double courtPrice;
  final double equipmentTotal;

  BookingHistory({
    required this.id,
    required this.courtName,
    required this.courtImageUrl,
    required this.location,
    required this.date,
    required this.startTime,
    required this.duration,
    required this.totalAmount,
    required this.status,
    required this.equipment,
    required this.courtPrice,
    required this.equipmentTotal,
  });
}