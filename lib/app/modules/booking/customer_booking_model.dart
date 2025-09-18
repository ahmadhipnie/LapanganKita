class Court {
  final String name;
  final String location;
  final List<String> types;
  final double price;
  final String imageUrl;
  final String description;
  final Map<String, String> openingHours; // Hari: jam buka-tutup
  final List<Equipment> equipment;
  final double latitude;
  final double longitude;

  Court({
    required this.name,
    required this.location,
    required this.types,
    required this.price,
    required this.imageUrl,
    required this.description,
    required this.openingHours,
    required this.equipment,
    required this.latitude,
    required this.longitude,
  });
}

class Equipment {
  final String name;
  final String description;
  final double price;
  int quantity;

  Equipment( {required this.name, required this.price, required this.description, this.quantity = 0});
}
