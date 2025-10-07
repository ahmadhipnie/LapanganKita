import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../data/helper/error_helper.dart';
import '../../data/models/customer/booking/court_model.dart';
import '../../data/repositories/court_repositoy.dart';

class CustomerBookingController extends GetxController {
  final CourtRepository _courtRepository = Get.find<CourtRepository>();
  final errorHandler = ErrorHandler();

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

  // ✅ LOAD DATA FROM API dengan ErrorHandler
  Future<void> _loadCourts() async {
    isLoading.value = true;
    errorHandler.clearError(hasError: hasError, errorMessage: errorMessage);

    try {
      final courts = await errorHandler.handleFutureError<List<Court>>(
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

      // DEBUG
      for (final court in courts) {
        print(' - ${court.name}: ${court.status}');
      }
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

  // ✅ METHOD FILTER COURTS dengan error handling
  void filterCourts() {
    try {
      print('🔄 Starting filterCourts...');
      print('📊 All courts count: ${allCourts.length}');
      print('🎯 Selected category: ${selectedCategory.value}');

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

      // ... steps lainnya tetap sama

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

  // Method untuk set category filter dengan error handling
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

  // Method untuk set location filter dengan error handling
  void setLocationFilter(String location) {
    try {
      selectedLocation.value = location;
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
      filterCourts();
      errorHandler.showSuccessMessage('Filters applied successfully');
    } catch (e) {
      errorHandler.handleGeneralError(
        context: 'Failed to apply filters',
        error: e,
        showSnackbar: true,
      );
    }
  }

  // Method untuk clear semua filter dengan error handling
  void clearFilters() {
    try {
      print('🔄 Clearing all filters');
      searchQuery.value = '';
      searchController.clear();
      selectedCategory.value = '';
      selectedLocation.value = '';
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
      print(
        '✅ Available courts: ${availableCourts.map((c) => '${c.name} (${c.status})').toList()}',
      );
    } catch (e) {
      errorHandler.handleGeneralError(
        context: 'Failed to clear filters',
        error: e,
        showSnackbar: true,
      );
    }
  }

  // ✅ METHOD REFRESH DATA dengan ErrorHandler
  Future<void> refreshData() async {
    isLoading.value = true;
    errorHandler.clearError(hasError: hasError, errorMessage: errorMessage);

    // Update timestamp untuk force reload images
    _timestamp.value = DateTime.now().millisecondsSinceEpoch.toString();

    try {
      await _loadCourts();

      // Success message sudah ditangani di _loadCourts()
    } catch (e) {
      // Error sudah dihandle oleh _loadCourts()
      print('Error refreshing data: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Method untuk clear search dengan error handling
  void clearSearch() {
    try {
      searchQuery.value = '';
      searchController.clear();
      filteredCourts.assignAll(
        allCourts.where((court) => court.status == 'available').toList(),
      );

      errorHandler.showSuccessMessage('Search cleared');
    } catch (e) {
      errorHandler.handleGeneralError(
        context: 'Failed to clear search',
        error: e,
        showSnackbar: true,
      );
    }
  }

  // Method untuk search courts dengan error handling
  List<Court> searchCourts(String query) {
    try {
      // ✅ HANYA YANG AVAILABLE
      final availableCourts = allCourts
          .where((court) => court.status == 'available')
          .toList();

      if (query.isEmpty) {
        return availableCourts;
      }

      return availableCourts
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
    } catch (e) {
      errorHandler.handleGeneralError(
        context: 'Failed to search courts',
        error: e,
        showSnackbar: false,
      );
      return allCourts.where((court) => court.status == 'available').toList();
    }
  }

  // Method untuk force reload data (misal setelah login/logout)
  Future<void> forceReload() async {
    try {
      isLoading.value = true;
      errorHandler.clearError(hasError: hasError, errorMessage: errorMessage);

      // Clear semua data existing
      allCourts.clear();
      filteredCourts.clear();
      availableCategories.clear();
      availableLocations.clear();

      // Load ulang data
      await _loadCourts();

      errorHandler.showSuccessMessage('Data reloaded successfully');
    } catch (e) {
      errorHandler.handleGeneralError(
        context: 'Failed to reload data',
        error: e,
        showSnackbar: true,
      );
    } finally {
      isLoading.value = false;
    }
  }

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
