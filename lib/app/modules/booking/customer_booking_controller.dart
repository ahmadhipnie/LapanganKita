import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../data/helper/error_helper.dart';
import '../../data/repositories/court_repositoy.dart';

class CustomerBookingController extends GetxController {
  final CourtRepository _courtRepository = Get.find();
  final errorHandler = ErrorHandler();

  final RxBool isLoading = false.obs;
  final RxBool hasError = false.obs;
  final RxString errorMessage = ''.obs;

  final TextEditingController searchController = TextEditingController();
  final TextEditingController minPriceController = TextEditingController();
  final TextEditingController maxPriceController = TextEditingController();
  final TextEditingController locationController =
      TextEditingController(); // ✅ TAMBAH CONTROLLER LOCATION

  final RxString searchQuery = ''.obs;
  final RxString selectedCategory = ''.obs;
  final RxString selectedLocation = ''.obs;

  // ✅ TANPA TYPE PARAMETER (seperti kode asli)
  final RxList availableCategories = [].obs;
  final RxList availableLocations = [].obs;
  final RxList filteredCourts = [].obs;
  final RxList allCourts = [].obs;

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

  // ✅ LOAD DATA FROM API dengan ErrorHandler
  Future<void> _loadCourts() async {
    isLoading.value = true;
    errorHandler.clearError(hasError: hasError, errorMessage: errorMessage);

    try {
      final courts = await errorHandler.handleFutureError(
        future: _courtRepository.getCourts(),
        context: 'Failed to load courts',
        hasError: hasError,
        errorMessage: errorMessage,
        showSnackbar: false,
        fallbackValue: [],
      );

      allCourts.assignAll(courts);

      // ✅ INISIALISASI filteredCourts HANYA DENGAN AVAILABLE
      final availableCourts = courts
          .where((court) => court.status == 'available')
          .toList();
      filteredCourts.assignAll(availableCourts);

      print('Filtered courts: ${filteredCourts.length}');

      // Extract available categories and locations
      _extractAvailableOptions();
    } catch (e) {
      print('Error loading courts: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Method untuk extract kota dari location string
  String _extractCity(String location) {
    try {
      final parts = location.split(',');
      if (parts.length > 1) {
        return parts.last.trim();
      }
      return location.trim();
    } catch (e) {
      return location;
    }
  }

  void _extractAvailableOptions() {
    try {
      // ✅ EXTRACT HANYA DARI AVAILABLE COURTS
      final availableCourts = allCourts
          .where((court) => court.status == 'available')
          .toList();

      // Extract unique categories dari field_type
      final categories = availableCourts
          .expand((court) => court.types)
          .toSet()
          .toList();
      availableCategories.assignAll(categories);

      // Extract unique locations (hanya nama kota)
      final locations = availableCourts
          .map((court) => _extractCity(court.location))
          .where((city) => city.isNotEmpty)
          .toSet()
          .toList();
      availableLocations.assignAll(locations);

      print('✅ Available categories: $categories');
      print('✅ Available locations: $locations');
    } catch (e) {
      errorHandler.handleGeneralError(
        context: 'Failed to extract filter options',
        error: e,
        showSnackbar: false,
      );
    }
  }

  // ✅ METHOD FILTER COURTS YANG DIPERBAIKI
  void filterCourts() {
    try {
      print('🔄 Starting filterCourts...');
      print('📊 All courts count: ${allCourts.length}');
      print('🎯 Selected category: ${selectedCategory.value}');
      print('🎯 Selected location: ${selectedLocation.value}');

      // ✅ FILTER HANYA YANG AVAILABLE
      var results = allCourts
          .where((court) => court.status == 'available')
          .toList();
      print('✅ Available courts: ${results.length}');

      // Step 2: Apply category filter jika ada
      if (selectedCategory.value.isNotEmpty) {
        results = results.where((court) {
          final hasCategory = court.types.any(
            (type) =>
                type.toLowerCase() == selectedCategory.value.toLowerCase(),
          );
          return hasCategory;
        }).toList();
        print('✅ After category filter: ${results.length} courts');
      }

      // Step 3: Apply location filter jika ada
      if (selectedLocation.value.isNotEmpty) {
        results = results.where((court) {
          final courtCity = _extractCity(court.location).toLowerCase();
          final filterCity = selectedLocation.value.toLowerCase();
          return courtCity.contains(filterCity);
        }).toList();
        print('✅ After location filter: ${results.length} courts');
      }

      // Step 4: Apply price filter jika ada
      if (minPriceController.text.isNotEmpty ||
          maxPriceController.text.isNotEmpty) {
        final minPrice = double.tryParse(minPriceController.text) ?? 0;
        final maxPrice =
            double.tryParse(maxPriceController.text) ?? double.infinity;

        results = results.where((court) {
          return court.price >= minPrice && court.price <= maxPrice;
        }).toList();
        print('✅ After price filter: ${results.length} courts');
      }

      // Step 5: Apply search filter jika ada
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

      filteredCourts.assignAll(results);
      print('🎯 Final filtered courts: ${filteredCourts.length}');
    } catch (e) {
      errorHandler.handleGeneralError(
        context: 'Failed to filter courts',
        error: e,
        showSnackbar: true,
      );
    }
  }

  // Method untuk set category filter
  void setCategoryFilter(String category) {
    try {
      selectedCategory.value = category;
      filterCourts();
    } catch (e) {
      errorHandler.handleGeneralError(
        context: 'Failed to set category filter',
        error: e,
        showSnackbar: true,
      );
    }
  }

  // Method untuk set location filter
  void setLocationFilter(String location) {
    try {
      selectedLocation.value = location;
      locationController.text = location; // ✅ UPDATE CONTROLLER TEXT
      filterCourts();
    } catch (e) {
      errorHandler.handleGeneralError(
        context: 'Failed to set location filter',
        error: e,
        showSnackbar: true,
      );
    }
  }

  // Method untuk apply filters dari dialog
  void applyFilters() {
    try {
      // ✅ UPDATE LOCATION DARI TEXT FIELD
      selectedLocation.value = locationController.text.trim();
      filterCourts();
      Get.back(); // ✅ TUTUP DIALOG SETELAH APPLY
      errorHandler.showSuccessMessage('Filters applied successfully');
    } catch (e) {
      errorHandler.handleGeneralError(
        context: 'Failed to apply filters',
        error: e,
        showSnackbar: true,
      );
    }
  }

  // Method untuk clear semua filter
  void clearFilters() {
    try {
      print('🔄 Clearing all filters');
      searchQuery.value = '';
      searchController.clear();
      selectedCategory.value = '';
      selectedLocation.value = '';
      locationController.clear(); // ✅ CLEAR LOCATION CONTROLLER
      minPriceController.clear();
      maxPriceController.clear();

      // ✅ PASTIKAN HANYA AVAILABLE YANG DITAMPILKAN
      final availableCourts = allCourts
          .where((court) => court.status == 'available')
          .toList();
      filteredCourts.assignAll(availableCourts);

      refreshFilterChips();
      update(['courts_list']);
      errorHandler.showSuccessMessage('All filters cleared');
      print(
        '✅ Filters cleared, showing ${filteredCourts.length} available courts',
      );
    } catch (e) {
      errorHandler.handleGeneralError(
        context: 'Failed to clear filters',
        error: e,
        showSnackbar: true,
      );
    }
  }

  // ✅ METHOD REFRESH DATA
  Future<void> refreshData() async {
    isLoading.value = true;
    errorHandler.clearError(hasError: hasError, errorMessage: errorMessage);
    _timestamp.value = DateTime.now().millisecondsSinceEpoch.toString();

    try {
      await _loadCourts();
    } catch (e) {
      print('Error refreshing data: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Method untuk clear search
  void clearSearch() {
    try {
      searchQuery.value = '';
      searchController.clear();
      filterCourts();
      errorHandler.showSuccessMessage('Search cleared');
    } catch (e) {
      errorHandler.handleGeneralError(
        context: 'Failed to clear search',
        error: e,
        showSnackbar: true,
      );
    }
  }

  // @override
  // void onClose() {
  //   searchController.dispose();
  //   minPriceController.dispose();
  //   maxPriceController.dispose();
  //   locationController.dispose(); // ✅ DISPOSE LOCATION CONTROLLER
  //   super.onClose();
  // }

  // Method untuk check jika ada data
  bool get hasData => allCourts.isNotEmpty;

  // Method untuk check jika sedang loading
  bool get isDataLoading => isLoading.value;

  // Method untuk check jika ada error
  bool get hasDataError => hasError.value;

  // Method untuk retry loading data
  Future<void> retryLoadData() async {
    await _loadCourts();
  }
}
