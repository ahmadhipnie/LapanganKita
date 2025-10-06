import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:lapangan_kita/app/modules/booking/customer_booking_controller.dart';
import 'package:lapangan_kita/app/data/models/customer/history/customer_history_model.dart';
import 'package:lapangan_kita/app/modules/home/customer_home_controller.dart';
import 'package:lapangan_kita/app/themes/color_theme.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class CustomerHomeView extends GetView<CustomerHomeController> {
  const CustomerHomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.neutralColor,
      appBar: AppBar(
        backgroundColor: AppColors.neutralColor,
        actionsPadding: const EdgeInsets.only(right: 16),
        title: const Text(
          'LapanganKita',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              Get.toNamed('/customer/profile');
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Obx(() {
          if (controller.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }
          return RefreshIndicator(
            onRefresh: () async {
              await controller.refreshData();
            },
            color: const Color(0xFF2563EB),
            backgroundColor: Colors.white,
            displacement: 40,
            strokeWidth: 2,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  _buildCarouselSection(),
                  const SizedBox(height: 16),
                  _buildSmoothIndicator(),

                  // Popular Categories Section
                  _buildPopularCategories(),

                  // Your Recent Activity Section
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Your Recent Activity',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),

                  // Recent Activity Widget
                  _recentActivity(controller: controller),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }

  // Carousel Widget
  Widget _buildCarouselSection() {
    return CarouselSlider(
      carouselController: controller.carouselController,
      options: controller.carouselOptions,
      items: controller.imgList.asMap().entries.map((entry) {
        final index = entry.key;
        final imageUrl = entry.value;
        return GestureDetector(
          onTap: () {
            controller.showImageDialog(index, Get.context!);
          },
          child: Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Image
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.network(
                    imageUrl,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Center(
                        child: CircularProgressIndicator(
                          value: loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded /
                                    loadingProgress.expectedTotalBytes!
                              : null,
                        ),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.grey[300],
                        child: const Icon(
                          Icons.error,
                          color: Colors.red,
                          size: 40,
                        ),
                      );
                    },
                  ),
                ),

                // Gradient Overlay
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [
                        Colors.black.withValues(alpha: 0.2),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),

                // Title
                Positioned(
                  bottom: 16,
                  left: 16,
                  right: 16,
                  child: Text(
                    controller.titleList[index],
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  // Indicators Widget
  Widget _buildSmoothIndicator() {
    return Obx(
      () => AnimatedSmoothIndicator(
        activeIndex: controller.currentIndex.value,
        count: controller.imgList.length,
        effect: SlideEffect(
          radius: 5,
          spacing: 8,
          dotWidth: 16,
          dotHeight: 6,
          activeDotColor: AppColors.secondary,
          dotColor: Colors.grey.shade300,
          paintStyle: PaintingStyle.fill,
        ),
      ),
    );
  }

  Widget _buildPopularCategories() {
    return Obx(() {
      final bookingController = Get.find<CustomerBookingController>();

      // Tampilkan loading jika data courts masih loading
      if (bookingController.isLoading.value &&
          bookingController.allCourts.isEmpty) {
        return const SizedBox(
          height: 140,
          child: Center(child: CircularProgressIndicator()),
        );
      }

      // Tampilkan empty state jika tidak ada data
      if (bookingController.allCourts.isEmpty) {
        return const Padding(
          padding: EdgeInsets.all(16),
          child: Text(
            'No courts available',
            style: TextStyle(color: Colors.grey),
          ),
        );
      }

      final categories = controller.popularCategoriesWithIcon;

      if (categories.isEmpty) {
        return const SizedBox();
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Text(
              'Popular Categories',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          SizedBox(
            height: 116,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: categories.map((category) {
                return _buildCategoryIconCard(
                  category['name'],
                  category['count'],
                  category['icon'],
                  category['color'],
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 16),
        ],
      );
    });
  }

  // Widget untuk Card dengan Icon
  Widget _buildCategoryIconCard(
    String category,
    int count,
    IconData icon,
    Color color,
  ) {
    return Container(
      width: 100,
      margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.2),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          // Gunakan method navigateToBookingWithCategory dari home controller
          controller.navigateToBookingWithCategory(category);
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icon dengan background circle
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 30, color: color),
            ),
            const SizedBox(height: 8),

            // Category Name
            Text(
              category,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),

            // Court Count
            Text(
              '$count ${count > 1 ? 'courts' : 'court'}',
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _recentActivity({required CustomerHomeController controller}) {
    return Obx(() {
      if (controller.isRecentBookingsLoading) {
        return const Center(child: CircularProgressIndicator());
      }

      final recentBookings = controller.getRecentBookings();

      if (recentBookings.isEmpty) {
        return const SizedBox(); // Tidak tampilkan apa-apa jika tidak ada booking
      }

      return Container(
        margin: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withValues(alpha: 0.2),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ...recentBookings.map(
              (booking) => _buildRecentBookingItem(booking),
            ),
            const SizedBox(height: 8),
            Center(
              child: TextButton(
                onPressed: () {
                  // Navigate to full history page
                  Get.offAllNamed(
                    '/customer/navigation',
                    arguments: {'initialTab': 3},
                  );
                },
                child: const Text(
                  'View All Bookings',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildRecentBookingItem(BookingHistory booking) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey, width: 0.2)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  booking.courtName,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),

                Text(
                  _formatDate(booking.date),
                  style: TextStyle(color: Colors.grey[600], fontSize: 14),
                ),

                Text(
                  _formatTimeRange(booking),
                  style: TextStyle(color: Colors.grey[600], fontSize: 14),
                ),

                Text(
                  booking.location,
                  style: TextStyle(color: Colors.grey[600], fontSize: 14),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Wrap(
                  spacing: 8,
                  children: booking.types.map((type) {
                    return Chip(
                      label: Text(
                        type,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.white,
                        ),
                      ),
                      backgroundColor: AppColors.secondary,
                      visualDensity: VisualDensity.compact,
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          _buildStatusChip(booking.status),
        ],
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color backgroundColor;
    Color textColor;

    switch (status) {
      case 'approved':
        backgroundColor = Colors.green[100]!;
        textColor = Colors.green[800]!;
        break;
      case 'rejected':
        backgroundColor = Colors.red[100]!;
        textColor = Colors.red[800]!;
        break;
      default: // pending
        backgroundColor = Colors.orange[100]!;
        textColor = Colors.orange[800]!;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(
          color: textColor,
          fontWeight: FontWeight.bold,
          fontSize: 10,
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return DateFormat('EEEE, dd MMM yyyy').format(date);
  }

  String _formatTimeRange(BookingHistory booking) {
    final startTime = booking.startTime;
    final startHour = int.parse(startTime.split(':')[0]);
    final endHour = startHour + booking.duration;

    return '$startTime - ${endHour.toString().padLeft(2, '0')}:00';
  }
}
