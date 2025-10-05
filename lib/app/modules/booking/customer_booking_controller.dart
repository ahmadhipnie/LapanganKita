import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../data/models/customer/booking/court_model.dart';
import '../../data/repositories/court_repositoy.dart';

class CustomerBookingController extends GetxController {
  final CourtRepository _courtRepository = Get.find<CourtRepository>();

  final RxBool isLoading = false.obs;
  final RxBool hasError = false.obs;
  final RxString errorMessage = ''.obs;

  final TextEditingController searchController = TextEditingController();
  final TextEditingController minPriceController = TextEditingController();
  final TextEditingController maxPriceController = TextEditingController();
  final RxString searchQuery = ''.obs;
  final RxString selectedCategory = ''.obs;
  final RxString selectedLocation = ''.obs;
  final RxList<String> availableCategories = <String>[].obs;
  final RxList<String> availableLocations = <String>[].obs;
  final RxList<Court> filteredCourts = <Court>[].obs;
  final RxList<Court> allCourts = <Court>[].obs;

  // Timestamp untuk force reload images
  final RxString _timestamp = DateTime.now().millisecondsSinceEpoch
      .toString()
      .obs;

  String getTimestamp() => _timestamp.value;

  @override
  void onInit() {
    super.onInit();
    _loadCourts();

    // Listen to search query changes dengan debounce
    debounce(
      searchQuery,
      (_) => filterCourts(),
      time: const Duration(milliseconds: 300),
    );
  }

  void refreshFilterChips() {
    update(); // Trigger GetBuilder rebuild
  }

  // ✅ METHOD UNTUK SET CATEGORY FILTER DARI EXTERNAL
  void setCategoryFilterFromExternal(String category) {
    print('🎯 Setting category filter from external: $category');
    selectedCategory.value = category;

    // ✅ PASTIKAN FILTER DIEKSEKUSI SETELAH STATE BERUBAH
    WidgetsBinding.instance.addPostFrameCallback((_) {
      filterCourts();
      refreshFilterChips();
    });

    print('🎯 Current selected category: ${selectedCategory.value}');
  }

  // ✅ LOAD DATA FROM API
  Future<void> _loadCourts() async {
    isLoading.value = true;
    hasError.value = false;
    errorMessage.value = '';

    try {
      final courts = await _courtRepository.getCourts();
      allCourts.assignAll(courts);
      filteredCourts.assignAll(courts);

      // Extract available categories and locations
      _extractAvailableOptions();
    } on CourtException catch (e) {
      hasError.value = true;
      errorMessage.value = e.message;
      Get.snackbar('Error', e.message);
    } catch (e) {
      hasError.value = true;
      errorMessage.value = 'Failed to load courts: $e';
      Get.snackbar('Error', 'Failed to load courts: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Method untuk extract kota dari location string
  String _extractCity(String location) {
    final parts = location.split(',');
    if (parts.length > 1) {
      return parts.last.trim();
    }
    return location.trim();
  }

  void _extractAvailableOptions() {
    // Extract unique categories dari field_type
    final categories = allCourts
        .expand((court) => court.types)
        .toSet()
        .toList();
    availableCategories.assignAll(categories);

    // Extract unique locations (hanya nama kota)
    final locations = allCourts
        .map((court) => _extractCity(court.location))
        .where((city) => city.isNotEmpty)
        .toSet()
        .toList();
    availableLocations.assignAll(locations);
  }

  // ✅ METHOD FILTER COURTS
  void filterCourts() {
    print('🔄 Starting filterCourts...');
    print('📊 All courts count: ${allCourts.length}');
    print('🎯 Selected category: ${selectedCategory.value}');

    // Step 1: Filter hanya yang available
    var results = allCourts
        .where((court) => court.status == 'available')
        .toList();
    print('✅ Available courts: ${results.length}');

    // Step 2: Apply category filter jika ada
    if (selectedCategory.value.isNotEmpty) {
      results = results.where((court) {
        final hasCategory = court.types.contains(selectedCategory.value);
        print(
          '🔍 Court "${court.name}" has category ${selectedCategory.value}: $hasCategory',
        );
        return hasCategory;
      }).toList();
      print('✅ After category filter: ${results.length} courts');
    }

    // Step 3: Apply search filter jika ada
    if (searchQuery.value.isNotEmpty) {
      final query = searchQuery.value.toLowerCase();
      results = results.where((court) {
        return court.name.toLowerCase().contains(query) ||
            court.location.toLowerCase().contains(query) ||
            court.types.any((type) => type.toLowerCase().contains(query)) ||
            court.placeName.toLowerCase().contains(query);
      }).toList();
      print('✅ After search filter: ${results.length} courts');
    }

    // Step 4: Apply location filter jika ada
    if (selectedLocation.value.isNotEmpty) {
      results = results.where((court) {
        return _extractCity(court.location) == selectedLocation.value;
      }).toList();
      print('✅ After location filter: ${results.length} courts');
    }

    // Step 5: Apply price filter jika ada
    final minPrice = double.tryParse(minPriceController.text) ?? 0;
    final maxPrice =
        double.tryParse(maxPriceController.text) ?? double.maxFinite;

    if (minPrice > 0 || maxPrice < double.maxFinite) {
      results = results.where((court) {
        return court.price >= minPrice && court.price <= maxPrice;
      }).toList();
      print('✅ After price filter: ${results.length} courts');
    }

    // ✅ PASTIKAN ASSIGN KE filteredCourts
    filteredCourts.assignAll(results);
    print('🎯 Final filtered courts: ${filteredCourts.length}');

    // Force UI update
    update(['courts_list']);
  }

  // Method untuk set category filter
  void setCategoryFilter(String category) {
    selectedCategory.value = category;
    filterCourts();
  }

  // Method untuk set location filter
  void setLocationFilter(String location) {
    selectedLocation.value = location;
    filterCourts();
  }

  // Method untuk apply filters dari dialog
  void applyFilters() {
    filterCourts();
  }

  // Method untuk clear semua filter
  // void clearFilters() {
  //   searchQuery.value = '';
  //   searchController.clear();
  //   selectedCategory.value = '';
  //   selectedLocation.value = '';
  //   minPriceController.clear();
  //   maxPriceController.clear();
  //   filteredCourts.assignAll(allCourts);
  // }
  void clearFilters() {
    print('🔄 Clearing all filters');
    searchQuery.value = '';
    searchController.clear();
    selectedCategory.value = '';
    selectedLocation.value = '';
    minPriceController.clear();
    maxPriceController.clear();

    // Kembali ke available courts saja
    filteredCourts.assignAll(
      allCourts.where((court) => court.status == 'available').toList(),
    );

    refreshFilterChips();
    update(['courts_list']);
    print(
      '✅ Filters cleared, showing ${filteredCourts.length} available courts',
    );
  }

  // ✅ METHOD REFRESH DATA
  Future<void> refreshData() async {
    isLoading.value = true;
    hasError.value = false;

    // Update timestamp untuk force reload images
    _timestamp.value = DateTime.now().millisecondsSinceEpoch.toString();

    try {
      await _loadCourts();

      Get.snackbar(
        'Success',
        'Data refreshed successfully',
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 2),
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to refresh data: $e',
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 3),
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Method untuk clear search
  void clearSearch() {
    searchQuery.value = '';
    searchController.clear();
    filteredCourts.assignAll(allCourts);
  }

  // Method untuk search courts
  List<Court> searchCourts(String query) {
    if (query.isEmpty) return allCourts;
    return allCourts
        .where(
          (court) =>
              court.name.toLowerCase().contains(query.toLowerCase()) ||
              court.location.toLowerCase().contains(query.toLowerCase()) ||
              court.types.any(
                (type) => type.toLowerCase().contains(query.toLowerCase()),
              ) ||
              court.placeName.toLowerCase().contains(query.toLowerCase()),
        )
        .toList();
  }
}
