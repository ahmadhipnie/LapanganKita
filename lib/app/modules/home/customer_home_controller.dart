import 'package:carousel_slider/carousel_controller.dart';
import 'package:carousel_slider/carousel_options.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lapangan_kita/app/data/helper/error_helper.dart';
import 'package:lapangan_kita/app/modules/booking/customer_booking_controller.dart';
import 'package:lapangan_kita/app/modules/history/customer_history_controller.dart';
import 'package:lapangan_kita/app/data/models/customer/history/customer_history_model.dart';
import 'package:lapangan_kita/app/data/models/promosi_slider_image.dart';
import 'package:lapangan_kita/app/data/repositories/promosi_repository.dart';
// import 'package:lapangan_kita/app/utils/error_handler.dart';

class CustomerHomeController extends GetxController {
  CustomerHomeController({PromosiRepository? promosiRepository})
    : _promosiRepository = promosiRepository ?? Get.find<PromosiRepository>();

  final PromosiRepository _promosiRepository;
  final errorHandler = ErrorHandler();

  // Observable variables
  final hasError = false.obs;
  final errorMessage = ''.obs;
  final isLoading = false.obs;
  final currentIndex = 0.obs;
  final sliderImages = <PromosiSliderImage>[].obs;
  final isSliderLoading = false.obs;
  final sliderError = ''.obs;
  final _timestamp = DateTime.now().millisecondsSinceEpoch.toString().obs;

  static const List<String> _fallbackImageUrls = [
    'https://images.unsplash.com/photo-1520877880798-5ee004e3f11e?w=500',
    'https://i.pinimg.com/736x/b4/4e/64/b44e64a9790169f518b6c8f612263944.jpg?w=500',
    'https://images.unsplash.com/photo-1551632811-561732d1e306?w=500',
    'https://i.pinimg.com/736x/6d/4f/27/6d4f277d10b4fc819d17d3f1a3f217b7.jpg?w=500',
  ];

  static const List<String> _fallbackTitles = [
    'Premium Futsal Field',
    'NBA Standard Basketball Court',
    'International Standard Tennis Court',
    'Beach & Indoor Volleyball Court',
  ];

  // Add controller for history
  final CustomerHistoryController historyController =
      Get.find<CustomerHistoryController>();

  // Carousel controller
  final CarouselSliderController carouselController =
      CarouselSliderController();

  String getFriendlyMessage(String message) =>
      errorHandler.getSimpleErrorMessage(message);

  // Image data for carousel with timestamp parameter
  List<String> get imgList {
    String appendTimestamp(String url) {
      if (url.isEmpty) return url;
      final separator = url.contains('?') ? '&' : '?';
      return '$url${separator}t=${_timestamp.value}';
    }

    final remoteImages = sliderImages
        .map((image) => appendTimestamp(image.imageUrl))
        .where((url) => url.isNotEmpty)
        .toList();

    if (remoteImages.isNotEmpty) {
      return remoteImages;
    }

    return _fallbackImageUrls.map(appendTimestamp).toList();
  }

  String slideTitleForIndex(int index) {
    if (sliderImages.length > index) {
      final image = sliderImages[index];
      final formatted = image.formattedDate(pattern: 'dd MMM yyyy • HH:mm');
      return 'Latest promo • $formatted';
    }

    if (_fallbackTitles.isNotEmpty) {
      return _fallbackTitles[index % _fallbackTitles.length];
    }

    return 'LapanganKita Promotions';
  }

  @override
  void onInit() {
    super.onInit();
    _initializeData();
  }

  // Method to initialize data with error handling
  Future<void> _initializeData() async {
    try {
      await fetchSliderImages();
    } catch (e) {
      handleError(context: 'Failed to load initial data', error: e);
    }
  }

  // Options for carousel
  CarouselOptions get carouselOptions => CarouselOptions(
    autoPlay: true,
    enlargeCenterPage: true,
    viewportFraction: 0.9,
    aspectRatio: 2.0,
    initialPage: 0,
    autoPlayInterval: const Duration(seconds: 5),
    autoPlayAnimationDuration: const Duration(milliseconds: 800),
    autoPlayCurve: Curves.fastOutSlowIn,
    enlargeFactor: 0.3,
    scrollDirection: Axis.horizontal,
    onPageChanged: (index, reason) {
      currentIndex.value = index;
    },
  );

  List<Map<String, dynamic>> get popularCategoriesWithIcon {
    try {
      final bookingController = Get.find<CustomerBookingController>();

      if (bookingController.allCourts.isEmpty) return [];

      final Map<String, int> categoryCount = {};

      final availableCourts = bookingController.allCourts
          .where((court) => court.status == 'available')
          .toList();

      for (final court in availableCourts) {
        for (final type in court.types) {
          categoryCount[type] = (categoryCount[type] ?? 0) + 1;
        }
      }

      final sortedCategories = categoryCount.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));

      return sortedCategories.map((entry) {
        return {
          'name': entry.key,
          'count': entry.value,
          'icon': _getCategoryIcon(entry.key),
          'color': _getCategoryColor(entry.key),
        };
      }).toList();
    } catch (e) {
      return [];
    }
  }

  // Getter untuk error state recent bookings
  bool get hasRecentBookingsError => historyController.hasError.value;
  String get recentBookingsErrorMessage => historyController.errorMessage.value;
  bool get isRecentBookingsLoading => historyController.isLoading.value;

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'tennis':
        return Icons.sports_tennis;
      case 'padel':
        return Icons.sports_tennis;
      case 'futsal':
        return Icons.sports_soccer;
      case 'basketball':
        return Icons.sports_basketball;
      case 'volleyball':
        return Icons.sports_volleyball;
      case 'badminton':
        return Icons.sports;
      case 'mini soccer':
        return Icons.sports_soccer;
      default:
        return Icons.sports;
    }
  }

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'tennis':
        return Colors.green;
      case 'padel':
        return Colors.orange;
      case 'futsal':
        return Colors.blue;
      case 'basketball':
        return Colors.red;
      case 'volleyball':
        return Colors.purple;
      case 'badminton':
        return Colors.teal;
      case 'mini soccer':
        return Colors.blue.shade700;
      default:
        return Colors.grey;
    }
  }

  // Method to refresh data with comprehensive error handling
  Future<void> refreshData() async {
    isLoading.value = true;
    errorHandler.clearError(hasError: hasError, errorMessage: errorMessage);
    sliderError.value = '';

    try {
      await Future.wait([
        fetchSliderImages(showNotification: false),
        _refreshBookingData(),
        _refreshRecentActivity(),
      ]);

      _timestamp.value = DateTime.now().millisecondsSinceEpoch.toString();
    } catch (e) {
      handleError(context: 'Failed to refresh data', error: e);
    } finally {
      isLoading.value = false;
    }
  }

  // Method to refresh booking data with error handling
  Future<void> _refreshBookingData() async {
    try {
      final bookingController = Get.find<CustomerBookingController>();
      await bookingController.refreshData();
    } catch (e) {
      print('Warning: Failed to refresh booking data: $e');
    }
  }

  // Method refresh recent activity yang simple
  Future<void> _refreshRecentActivity() async {
    try {
      await historyController.refreshData();
    } catch (e) {
      print('Error recent activity: $e');
    }
  }

  Future<void> fetchSliderImages({bool showNotification = false}) async {
    sliderError.value = '';
    isSliderLoading.value = true;

    try {
      final images = await _promosiRepository.getSliderImages();
      sliderImages.assignAll(images);
    } on PromosiException catch (e) {
      final userFriendlyMessage = errorHandler.getSimpleErrorMessage(e);
      sliderError.value = userFriendlyMessage;

      if (showNotification) {
        errorHandler.showErrorMessage(userFriendlyMessage);
      }
    } catch (e) {
      final userFriendlyMessage = errorHandler.getSimpleErrorMessage(e);
      sliderError.value = userFriendlyMessage;

      if (showNotification) {
        errorHandler.showErrorMessage(userFriendlyMessage);
      }
    } finally {
      isSliderLoading.value = false;
      _timestamp.value = DateTime.now().millisecondsSinceEpoch.toString();
    }
  }

  void _applyCategoryFilterWithRetry(String category, {int retryCount = 0}) {
    try {
      final bookingController = Get.find<CustomerBookingController>();

      if (bookingController.allCourts.isEmpty ||
          bookingController.isLoading.value) {
        if (retryCount < 5) {
          Future.delayed(const Duration(milliseconds: 500), () {
            _applyCategoryFilterWithRetry(category, retryCount: retryCount + 1);
          });
          return;
        } else {
          errorHandler.showWarningMessage(
            'Court data is not ready yet. Please try again.',
          );
          return;
        }
      }

      bookingController.setCategoryFilterFromExternal(category);
    } catch (e) {
      if (retryCount < 5) {
        Future.delayed(const Duration(milliseconds: 500), () {
          _applyCategoryFilterWithRetry(category, retryCount: retryCount + 1);
        });
      } else {
        handleError(context: 'Failed to apply category filter', error: e);
      }
    }
  }

  void navigateToBookingWithCategory(String category) {
    try {
      Get.offAllNamed('/customer/navigation', arguments: {'initialTab': 1});

      Future.delayed(const Duration(milliseconds: 800), () {
        _applyCategoryFilterWithRetry(category);
      });
    } catch (e) {
      handleError(context: 'Failed to navigate to booking page', error: e);
    }
  }

  List<BookingHistory> getRecentBookings() {
    try {
      // Cek apakah data ada di CustomerHistoryController
      final historyController = Get.find<CustomerHistoryController>();

      if (historyController.bookings.isEmpty) {
        return [];
      }

      // Ambil semua bookings
      final allBookings = List<BookingHistory>.from(historyController.bookings);

      // Sort: pending dulu, lalu by date (terbaru di atas)
      allBookings.sort((a, b) {
        // Pending priority
        if (a.status == 'pending' && b.status != 'pending') return -1;
        if (a.status != 'pending' && b.status == 'pending') return 1;

        // Sort by date descending (terbaru di atas)
        return b.date.compareTo(a.date);
      });

      // Ambil 5 terakhir
      final recent = allBookings.take(5).toList();

      return recent;
    } catch (e) {
      return [];
    }
  }

  // Refresh both home and history data with error handling
  Future<void> refreshAllData() async {
    try {
      await Future.wait([refreshData(), historyController.refreshData()]);
    } catch (e) {
      handleError(context: 'Failed to refresh all data', error: e);
    }
  }

  // Add method to show image dialog
  void showImageDialog(int index, BuildContext context) {
    try {
      final images = imgList;
      if (images.isEmpty || index < 0 || index >= images.length) return;

      showGeneralDialog(
        context: context,
        pageBuilder: (context, animation, secondaryAnimation) {
          return Dialog(
            backgroundColor: Colors.transparent,
            insetPadding: const EdgeInsets.all(20),
            child: ScaleTransition(
              scale: CurvedAnimation(
                parent: animation,
                curve: Curves.easeOutBack,
              ),
              child: Stack(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.network(
                        images[index],
                        fit: BoxFit.contain,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Container(
                            width: double.infinity,
                            height: 400,
                            color: Colors.grey[300],
                            child: Center(
                              child: CircularProgressIndicator(
                                value:
                                    loadingProgress.expectedTotalBytes != null
                                    ? loadingProgress.cumulativeBytesLoaded /
                                          loadingProgress.expectedTotalBytes!
                                    : null,
                              ),
                            ),
                          );
                        },
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            width: double.infinity,
                            height: 400,
                            color: Colors.grey[300],
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.error,
                                  color: Colors.red,
                                  size: 40,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  errorHandler.getSimpleErrorMessage(error),
                                  style: const TextStyle(color: Colors.red),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.5),
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: const Icon(
                          Icons.close,
                          color: Colors.white,
                          size: 24,
                        ),
                        onPressed: () => Get.back(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
        transitionDuration: const Duration(milliseconds: 400),
      );
    } catch (e) {
      handleError(context: 'Failed to display image', error: e);
    }
  }

  // Method to clear error state
  void clearError() {
    errorHandler.clearError(hasError: hasError, errorMessage: errorMessage);
    sliderError.value = '';
  }
}
