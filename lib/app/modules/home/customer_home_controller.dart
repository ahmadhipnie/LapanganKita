import 'package:carousel_slider/carousel_controller.dart';
import 'package:carousel_slider/carousel_options.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lapangan_kita/app/modules/booking/customer_booking_controller.dart';
import 'package:lapangan_kita/app/modules/history/customer_history_controller.dart';
import 'package:lapangan_kita/app/modules/history/customer_history_model.dart';

class CustomerHomeController extends GetxController {
  // Tambahkan controller untuk history
  final CustomerHistoryController historyController =
      Get.find<CustomerHistoryController>();

  // Carousel controller
  final CarouselSliderController carouselController =
      CarouselSliderController();

  // Current active index
  final RxInt currentIndex = 0.obs;

  // Loading state untuk refresh
  final RxBool isLoading = false.obs;

  // Timestamp untuk force reload images
  final RxString _timestamp = DateTime.now().millisecondsSinceEpoch
      .toString()
      .obs;

  // Image data untuk carousel dengan timestamp parameter
  List<String> get imgList => [
    'https://images.unsplash.com/photo-1520877880798-5ee004e3f11e?w=500&t=$_timestamp',
    'https://i.pinimg.com/736x/b4/4e/64/b44e64a9790169f518b6c8f612263944.jpg?w=500&t=$_timestamp',
    'https://images.unsplash.com/photo-1551632811-561732d1e306?w=500&t=$_timestamp',
    'https://i.pinimg.com/736x/6d/4f/27/6d4f277d10b4fc819d17d3f1a3f217b7.jpg?w=500&t=$_timestamp',
  ];

  // Title untuk setiap slide
  final List<String> titleList = [
    'Lapangan Futsal Premium',
    'Lapangan Basket Standar NBA',
    'Lapangan Tenis Berstandar Internasional',
    'Lapangan Voli Pantai & Indoor',
  ];

  // Options untuk carousel
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

  // Method untuk refresh data
  Future<void> refreshData() async {
    isLoading.value = true;

    // Update timestamp untuk force reload images
    _timestamp.value = DateTime.now().millisecondsSinceEpoch.toString();

    // Simulate API call atau data refresh
    await Future.delayed(const Duration(seconds: 2));

    // Di sini Anda bisa update data dari API
    // Contoh: imgList = await ApiService.getNewImages();

    isLoading.value = false;
  }

  void navigateToBookingWithCategory(String category) {
    // Dapatkan instance dari CustomerBookingController
    Get.offAllNamed('/customer/navigation', arguments: {'initialTab': 1});
    Future.delayed(const Duration(milliseconds: 100), () {
      final bookingController = Get.find<CustomerBookingController>();
      bookingController.setCategoryFilter(category);
    });
    // Navigate ke halaman booking
  }

  // Get popular categories with count and icon
  List<Map<String, dynamic>> get popularCategoriesWithIcon {
    final bookingController = Get.find<CustomerBookingController>();
    final Map<String, int> categoryCount = {};

    for (final court in bookingController.courts) {
      for (final type in court.types) {
        categoryCount[type] = (categoryCount[type] ?? 0) + 1;
      }
    }

    return categoryCount.entries.map((entry) {
      return {
        'name': entry.key,
        'count': entry.value,
        'icon': _getCategoryIcon(entry.key),
        'color': _getCategoryColor(entry.key),
      };
    }).toList();
  }

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
      default:
        return Colors.grey;
    }
  }

  List<BookingHistory> getRecentBookings() {
    if (historyController.bookings.isEmpty) return [];

    // Ambil 3 booking terbaru (diurutkan dari yang terbaru)
    final allBookings = List<BookingHistory>.from(historyController.bookings);
    allBookings.sort((a, b) => b.date.compareTo(a.date));

    return allBookings.take(3).toList();
  }

  // Check if recent bookings are loading
  bool get isRecentBookingsLoading => historyController.isLoading.value;

  // Refresh both home and history data
  Future<void> refreshAllData() async {
    await Future.wait([refreshData(), historyController.refreshData()]);
  }

  // Tambahkan method untuk show image dialog
  void showImageDialog(int index, BuildContext context) {
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
                // Image Container
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.network(
                      imgList[index],
                      fit: BoxFit.contain,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Container(
                          width: double.infinity,
                          height: 400,
                          color: Colors.grey[300],
                          child: Center(
                            child: CircularProgressIndicator(
                              value: loadingProgress.expectedTotalBytes != null
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
                          child: const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.error, color: Colors.red, size: 40),
                              SizedBox(height: 8),
                              Text(
                                'Failed to load image',
                                style: TextStyle(color: Colors.red),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ),
                // Close Button
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.5),
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: const Icon(
                        Icons.close,
                        color: Colors.white,
                        size: 24,
                      ),
                      onPressed: () {
                        Get.back();
                      },
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
  }
}
