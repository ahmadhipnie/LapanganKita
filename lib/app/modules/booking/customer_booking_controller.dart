import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lapangan_kita/app/modules/booking/customer_booking_model.dart'; // Adjust the path to your Debouncer utility

class CustomerBookingController extends GetxController {
  final RxBool isLoading = false.obs;

  final TextEditingController searchController = TextEditingController();
  final TextEditingController minPriceController = TextEditingController();
  final TextEditingController maxPriceController = TextEditingController();
  final RxString searchQuery = ''.obs;
  final RxString selectedCategory = ''.obs;
  final RxString selectedLocation = ''.obs;
  final RxList<String> availableCategories = <String>[].obs;
  final RxList<String> availableLocations = <String>[].obs;
  final RxList<Court> filteredCourts = <Court>[].obs;

  // Timestamp untuk force reload images
  final RxString _timestamp = DateTime.now().millisecondsSinceEpoch
      .toString()
      .obs;

  String getTimestampedImageUrl(String baseUrl) =>
      '$baseUrl?t=${_timestamp.value}';

  final List<Court> courts = [
    Court(
      name: 'Indoor Tennis Court',
      location: 'Kemang, South Jakarta',
      imageUrl: 'https://images.unsplash.com/photo-1506744038136-46273834b3fb',
      price: 240000,
      types: ['Tennis'],
      description:
          'Premium indoor tennis court with professional flooring and lighting. Perfect for both training and competitive play.',
      openingHours: {'monday-sunday': '06:00 - 22:00'},
      equipment: [
        Equipment(
          name: 'Tennis Racket',
          description: 'Rackets, balls,  and other equipment',
          price: 50000,
        ),
        Equipment(
          name: 'Towel rental',
          description: 'Clean towels for after yout game',
          price: 25000,
        ),
        Equipment(
          name: 'Grip Tape',
          description: 'Secure storage for your belongings',
          price: 15000,
        ),
      ],
      latitude: -6.2088,
      longitude: 106.8456,
    ),
    Court(
      name: 'Outdoor Tennis Court',
      location: 'Kemang, South Jakarta',
      types: ['Tennis'],
      price: 200000,
      imageUrl: 'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b',
      description:
          'Premium indoor tennis court with professional flooring and lighting. Perfect for both training and competitive play.',
      openingHours: {'monday-sunday': '06:00 - 22:00'},
      equipment: [
        Equipment(
          name: 'Tennis Racket',
          description: 'Rackets, balls,  and other equipment',
          price: 50000,
        ),
        Equipment(
          name: 'Towel rental',
          description: 'Clean towels for after yout game',
          price: 25000,
        ),
        Equipment(
          name: 'Grip Tape',
          description: 'Secure storage for your belongings',
          price: 15000,
        ),
      ],
      latitude: -6.2088,
      longitude: 106.8456,
    ),
    Court(
      name: 'Padel Court',
      location: 'Kemang, South Jakarta',
      types: ['Padel'],
      price: 220000,
      imageUrl: 'https://images.unsplash.com/photo-1546519638-68e109498ffc',
      description:
          'Premium indoor tennis court with professional flooring and lighting. Perfect for both training and competitive play.',
      openingHours: {'monday-sunday': '06:00 - 22:00'},
      equipment: [
        Equipment(
          name: 'Tennis Racket',
          description: 'Rackets, balls,  and other equipment',
          price: 50000,
        ),
        Equipment(
          name: 'Towel rental',
          description: 'Clean towels for after yout game',
          price: 25000,
        ),
        Equipment(
          name: 'Grip Tape',
          description: 'Secure storage for your belongings',
          price: 15000,
        ),
      ],
      latitude: -6.2088,
      longitude: 106.8456,
    ),
    Court(
      name: 'Multi Sport Court',
      location: 'Kemang, South Jakarta',
      types: ['Tennis', 'Padel'],
      price: 300000,
      imageUrl: 'https://images.unsplash.com/photo-1461896836934-ffe607ba8211',
      description:
          'Premium indoor tennis court with professional flooring and lighting. Perfect for both training and competitive play.',
      openingHours: {'monday-sunday': '06:00 - 22:00'},
      equipment: [
        Equipment(
          name: 'Tennis Racket',
          description: 'Rackets, balls,  and other equipment',
          price: 50000,
        ),
        Equipment(
          name: 'Towel rental',
          description: 'Clean towels for after yout game',
          price: 25000,
        ),
        Equipment(
          name: 'Grip Tape',
          description: 'Secure storage for your belongings',
          price: 15000,
        ),
      ],
      latitude: -6.2088,
      longitude: 106.8456,
    ),
    Court(
      name: 'Premium Futsal Court',
      location: 'Senayan, Central Jakarta',
      types: ['Futsal'],
      price: 100000,
      imageUrl: 'https://images.unsplash.com/photo-1520877880798-5ee004e3f11e',
      description:
          'Premium indoor tennis court with professional flooring and lighting. Perfect for both training and competitive play.',
      openingHours: {'monday-sunday': '06:00 - 22:00'},
      equipment: [
        Equipment(
          name: 'Tennis Racket',
          description: 'Rackets, balls,  and other equipment',
          price: 50000,
        ),
        Equipment(
          name: 'Towel rental',
          description: 'Clean towels for after yout game',
          price: 25000,
        ),
        Equipment(
          name: 'Grip Tape',
          description: 'Secure storage for your belongings',
          price: 15000,
        ),
      ],
      latitude: -6.2088,
      longitude: 106.8456,
    ),
    Court(
      name: 'Basketball Court',
      location: 'Wikwok, Surabaya',
      types: ['Basketball'],
      price: 180000,
      imageUrl: 'https://images.unsplash.com/photo-1549060279-7e168fce7090',
      description:
          'Premium indoor tennis court with professional flooring and lighting. Perfect for both training and competitive play.',
      openingHours: {'monday-sunday': '06:00 - 22:00'},
      equipment: [
        Equipment(
          name: 'Tennis Racket',
          description: 'Rackets, balls,  and other equipment',
          price: 50000,
        ),
        Equipment(
          name: 'Towel rental',
          description: 'Clean towels for after yout game',
          price: 25000,
        ),
        Equipment(
          name: 'Grip Tape',
          description: 'Secure storage for your belongings',
          price: 15000,
        ),
      ],
      latitude: -6.2088,
      longitude: 106.8456,
    ),
  ];

  @override
  void onInit() {
    super.onInit();
    filteredCourts.assignAll(courts);

    // Extract available categories and locations
    _extractAvailableOptions();

    // Listen to search query changes
    ever(searchQuery, (_) => filterCourts());

    // Add debounce untuk search
    debounce(
      searchQuery,
      (_) => filterCourts(),
      time: const Duration(milliseconds: 300),
    );
  }

  // @override
  // void onClose() {
  //   searchController.dispose();
  //   minPriceController.dispose();
  //   maxPriceController.dispose();
  //   super.onClose();
  // }

  // Method untuk extract kota dari location string
  String _extractCity(String location) {
    // Split by comma and take the last part (city name)
    final parts = location.split(',');
    if (parts.length > 1) {
      return parts.last.trim();
    }
    return location.trim();
  }

  void _extractAvailableOptions() {
    // Extract unique categories dari types
    final categories = courts.expand((court) => court.types).toSet().toList();
    availableCategories.assignAll(categories);

    // Extract unique locations (hanya nama kota)
    final locations = courts
        .map((court) => _extractCity(court.location))
        .toSet()
        .toList();
    availableLocations.assignAll(locations);
  }

  // Method untuk filter courts berdasarkan search query
  void filterCourts() {
    if (searchQuery.value.isEmpty) {
      filteredCourts.assignAll(courts);
      return;
    }

    final query = searchQuery.value.toLowerCase();

    final results = courts.where((court) {
      // Cek nama court
      if (court.name.toLowerCase().contains(query)) {
        return true;
      }

      // Cek lokasi court
      if (court.location.toLowerCase().contains(query)) {
        return true;
      }

      // Cek kategori/types
      if (court.types.any((type) => type.toLowerCase().contains(query))) {
        return true;
      }

      // Cek kombinasi kata-kata
      final queryWords = query.split(' ');
      for (final word in queryWords) {
        if (word.length > 2) {
          if (court.name.toLowerCase().contains(word) ||
              court.location.toLowerCase().contains(word) ||
              court.types.any((type) => type.toLowerCase().contains(word))) {
            return true;
          }
        }
      }

      return false;
    }).toList();

    filteredCourts.assignAll(results);
  }

  void applyFilters() {
    var results = courts;

    // Apply search filter
    if (searchQuery.value.isNotEmpty) {
      final query = searchQuery.value.toLowerCase();
      results = results.where((court) {
        return court.name.toLowerCase().contains(query) ||
            court.location.toLowerCase().contains(query) ||
            court.types.any((type) => type.toLowerCase().contains(query)) ||
            _extractCity(court.location).toLowerCase().contains(query);
      }).toList();
    }

    // Apply category filter
    if (selectedCategory.value.isNotEmpty) {
      results = results.where((court) {
        return court.types.contains(selectedCategory.value);
      }).toList();
    }

    // Apply location filter (berdasarkan kota saja)
    if (selectedLocation.value.isNotEmpty) {
      results = results.where((court) {
        return _extractCity(court.location) == selectedLocation.value;
      }).toList();
    }

    // Apply price filter
    final minPrice = double.tryParse(minPriceController.text) ?? 0;
    final maxPrice =
        double.tryParse(maxPriceController.text) ?? double.maxFinite;

    if (minPrice > 0 || maxPrice < double.maxFinite) {
      results = results.where((court) {
        return court.price >= minPrice && court.price <= maxPrice;
      }).toList();
    }

    filteredCourts.assignAll(results);
  }

  // Method untuk set category filter
  void setCategoryFilter(String category) {
    selectedCategory.value = category;
    applyFilters();
  }

  // Method untuk set location filter
  void setLocationFilter(String location) {
    selectedLocation.value = location;
    applyFilters();
  }

  // Method untuk clear semua filter
  void clearFilters() {
    searchQuery.value = '';
    searchController.clear();
    selectedCategory.value = '';
    selectedLocation.value = '';
    minPriceController.clear();
    maxPriceController.clear();
    filteredCourts.assignAll(courts);
  }

  // Method untuk refresh data
  Future<void> refreshData() async {
    isLoading.value = true;

    // Update timestamp untuk force reload images
    _timestamp.value = DateTime.now().millisecondsSinceEpoch.toString();

    // Simulate API call atau data refresh
    await Future.delayed(const Duration(seconds: 2));

    // Reset search dan filter
    searchQuery.value = '';
    searchController.clear();
    filteredCourts.assignAll(courts);

    isLoading.value = false;

    Get.snackbar(
      'Success',
      'Data refreshed successfully',
      snackPosition: SnackPosition.TOP,
    );
  }

  // Method untuk clear search
  void clearSearch() {
    searchQuery.value = '';
    searchController.clear();
    filteredCourts.assignAll(courts);
  }

  // Method untuk search courts
  List<Court> searchCourts(String query) {
    if (query.isEmpty) return courts;
    return courts
        .where(
          (court) =>
              court.name.toLowerCase().contains(query.toLowerCase()) ||
              court.location.toLowerCase().contains(query.toLowerCase()) ||
              court.types.any(
                (type) => type.toLowerCase().contains(query.toLowerCase()),
              ),
        )
        .toList();
  }
}
