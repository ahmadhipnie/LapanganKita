import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lapangan_kita/app/modules/home/customer_home_controller.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class CustomerHomeView extends GetView<CustomerHomeController> {
  const CustomerHomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
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
            child: Column(
              children: [
                _buildCarouselSection(),
                const SizedBox(height: 16),
                _buildSmoothIndicator(),
                Expanded(
                  child: ListView(
                    children: [
                      // Your other content here
                      const SizedBox(height: 20),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          'Lapangan Terpopuler',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      // Add more content...
                    ],
                  ),
                ),
              ],
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
        return Container(
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
        effect: const SlideEffect(
          radius: 5,
          spacing: 8,
          dotWidth: 16,
          dotHeight: 6,
          activeDotColor: Color(0xFF2563EB),
          dotColor: Color(0xFFA6A0AD),
          paintStyle: PaintingStyle.fill,
        ),
      ),
    );
  }
}
