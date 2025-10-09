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

  double _screenWidth(BuildContext context) =>
      MediaQuery.of(context).size.width;
  bool _isSmallScreen(BuildContext context) => _screenWidth(context) < 600;

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
          if (controller.isLoading.value && controller.sliderImages.isEmpty) {
            return _buildLoadingState();
          }

          if (controller.hasError.value && controller.sliderImages.isEmpty) {
            return _buildErrorState(controller.errorMessage.value);
          }

          return RefreshIndicator(
            onRefresh: () async {
              await controller.refreshData();
            },
            color: const Color(0xFF2563EB),
            backgroundColor: Colors.white,
            displacement: 40,
            strokeWidth: 2,
            child: _buildContent(),
          );
        }),
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text(
            'Loading data...',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.grey[500]),
            const SizedBox(height: 16),
            Text(
              controller.getFriendlyMessage(message),
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () => controller.refreshData(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                  ),
                  child: const Text('Try Again'),
                ),
                const SizedBox(width: 12),
                TextButton(
                  onPressed: () {
                    controller.clearError();
                    Get.offAllNamed('/customer/navigation');
                  },
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                  ),
                  child: const Text('Go Back'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Column(
        children: [
          _buildCarouselSection(),
          const SizedBox(height: 16),
          _buildSmoothIndicator(),

          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Popular Categories',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          _buildPopularCategories(),

          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Your Recent Activity',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
          ),

          _recentActivity(controller: controller),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildCarouselSection() {
    return Obx(() {
      final images = controller.imgList;
      final isRemoteLoading = controller.isSliderLoading.value;
      final sliderError = controller.sliderError.value;

      if (images.isEmpty) {
        return Container(
          height: 180,
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: Colors.grey[200],
          ),
          child: Center(
            child: isRemoteLoading
                ? const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 8),
                      Text(
                        'Loading promotions...',
                        style: TextStyle(color: Colors.black54),
                      ),
                    ],
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.image_search,
                        size: 48,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 8),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          sliderError.isNotEmpty
                              ? controller.getFriendlyMessage(sliderError)
                              : 'No promotions available yet',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
          ),
        );
      }

      return CarouselSlider(
        carouselController: controller.carouselController,
        options: controller.carouselOptions,
        items: images.asMap().entries.map((entry) {
          final index = entry.key;
          final imageUrl = entry.value;
          final title = controller.slideTitleForIndex(index);

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
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.network(
                      imageUrl,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Container(
                          color: Colors.grey[200],
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
                          color: Colors.grey[200],
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.broken_image,
                                size: 48,
                                color: Colors.grey[400],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Failed to load image',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),

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

                  Positioned(
                    bottom: 16,
                    left: 16,
                    right: 16,
                    child: Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),

                  if (isRemoteLoading)
                    Positioned(
                      top: 12,
                      right: 12,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.3),
                          shape: BoxShape.circle,
                        ),
                        child: const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          );
        }).toList(),
      );
    });
  }

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

  // ✅ PERBAIKAN: Popular Categories - Responsif & Adaptif
  Widget _buildPopularCategories() {
    return Obx(() {
      try {
        final bookingController = Get.find<CustomerBookingController>();

        if (bookingController.isLoading.value &&
            bookingController.allCourts.isEmpty) {
          return SizedBox(
            height: 140,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 8),
                  Text(
                    'Loading categories...',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: _isSmallScreen(Get.context!) ? 14 : 16,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        if (bookingController.allCourts.isEmpty) {
          return Padding(
            padding: EdgeInsets.all(_isSmallScreen(Get.context!) ? 16 : 24),
            child: Column(
              children: [
                Icon(
                  Icons.sports,
                  size: _isSmallScreen(Get.context!) ? 48 : 64,
                  color: Colors.grey,
                ),
                const SizedBox(height: 8),
                Text(
                  'No courts available yet',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: _isSmallScreen(Get.context!) ? 14 : 16,
                  ),
                ),
              ],
            ),
          );
        }

        final categories = controller.popularCategoriesWithIcon;

        if (categories.isEmpty) {
          return const SizedBox();
        }

        return LayoutBuilder(
          builder: (context, constraints) {
            final screenWidth = constraints.maxWidth;
            final isSmall = screenWidth < 600;
            final isMedium = screenWidth >= 600 && screenWidth < 1024;

            double cardWidth;
            double cardHeight;
            double iconSize;
            double fontSize;
            double countFontSize;

            if (isSmall) {
              cardWidth = 100;
              cardHeight = 116;
              iconSize = 28;
              fontSize = 13;
              countFontSize = 11;
            } else if (isMedium) {
              cardWidth = 120;
              cardHeight = 140;
              iconSize = 34;
              fontSize = 15;
              countFontSize = 12;
            } else {
              cardWidth = 140;
              cardHeight = 160;
              iconSize = 40;
              fontSize = 16;
              countFontSize = 13;
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: cardHeight,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: EdgeInsets.symmetric(
                      horizontal: isSmall ? 16 : (isMedium ? 20 : 24),
                    ),
                    physics: const BouncingScrollPhysics(),
                    itemCount: categories.length,
                    itemBuilder: (context, index) {
                      final category = categories[index];
                      return _buildCategoryIconCard(
                        category['name'],
                        category['count'],
                        category['icon'],
                        category['color'],
                        width: cardWidth,
                        height: cardHeight,
                        iconSize: iconSize,
                        fontSize: fontSize,
                        countFontSize: countFontSize,
                        isSmall: isSmall,
                      );
                    },
                  ),
                ),
                SizedBox(height: isSmall ? 16 : (isMedium ? 20 : 24)),
              ],
            );
          },
        );
      } catch (e) {
        return Padding(
          padding: EdgeInsets.all(_isSmallScreen(Get.context!) ? 16 : 24),
          child: Column(
            children: [
              Icon(
                Icons.error_outline,
                size: _isSmallScreen(Get.context!) ? 48 : 64,
                color: Colors.grey,
              ),
              const SizedBox(height: 8),
              Text(
                'Failed to load categories',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: _isSmallScreen(Get.context!) ? 14 : 16,
                ),
              ),
            ],
          ),
        );
      }
    });
  }

  Widget _buildCategoryIconCard(
    String category,
    int count,
    IconData icon,
    Color color, {
    required double width,
    required double height,
    required double iconSize,
    required double fontSize,
    required double countFontSize,
    required bool isSmall,
  }) {
    return Container(
      width: width,
      height: height,
      margin: EdgeInsets.only(right: isSmall ? 10 : 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(isSmall ? 12 : 16),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.15),
            blurRadius: isSmall ? 4 : 8,
            offset: Offset(0, isSmall ? 2 : 3),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(isSmall ? 12 : 16),
          onTap: () {
            controller.navigateToBookingWithCategory(category);
          },
          // ✅ PERBAIKAN: Ganti Column dengan FittedBox wrapper untuk prevent overflow
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: isSmall ? 6 : 10,
              vertical: isSmall ? 8 : 12,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min, // ✅ PENTING: Gunakan min size
              children: [
                // Icon with background circle
                Container(
                  width: iconSize + (isSmall ? 14 : 18),
                  height: iconSize + (isSmall ? 14 : 18),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, size: iconSize, color: color),
                ),
                SizedBox(height: isSmall ? 6 : 8), // ✅ Kurangi spacing
                // Category Name - dengan Flexible untuk prevent overflow
                Flexible(
                  child: Text(
                    category,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: fontSize,
                      color: Colors.black87,
                      height: 1.2, // ✅ Kurangi line height
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                SizedBox(height: isSmall ? 2 : 3), // ✅ Kurangi spacing
                // Court Count - dengan Flexible untuk prevent overflow
                Flexible(
                  child: Text(
                    '$count ${count > 1 ? 'courts' : 'court'}',
                    style: TextStyle(
                      fontSize: countFontSize,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w400,
                      height: 1.2, // ✅ Kurangi line height
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
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
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              const SizedBox(height: 60),
              Icon(Icons.history, size: 48, color: Colors.grey[400]),
              const SizedBox(height: 8),
              const Text(
                'No recent bookings yet',
                style: TextStyle(color: Colors.grey),
              ),
            ],
          ),
        );
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
      default:
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
