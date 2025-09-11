import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:get/get.dart';
import 'onboarding_controller.dart';

class OnboardingView extends GetView<OnboardingController> {
  const OnboardingView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 0,
        automaticallyImplyLeading: false,
        shadowColor: Colors.transparent,
        backgroundColor: Color(0xFFf5f5f5),
        bottomOpacity: 0.0,
        elevation: 0.0,
      ),
      body: Container(
        color: Color(0xFFf5f5f5),
        child: SafeArea(
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(),
                Obx(
                  () => Text(
                    controller.currentItem.title,
                    style: Theme.of(context).textTheme.titleLarge,
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 6),
                Obx(
                  () => Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 26),
                    child: Text(
                      controller.currentItem.description,
                      textAlign: TextAlign.center,
                      maxLines: 4,
                      style: Theme.of(context).textTheme.labelLarge,
                    ),
                  ),
                ),
                const Spacer(),
                CarouselSlider.builder(
                  carouselController: controller.carouselSliderController,
                  itemCount: controller.onboardingData.length,
                  options: CarouselOptions(
                    viewportFraction: 1.0,
                    enableInfiniteScroll: false,
                    initialPage: 0,
                    onPageChanged: (index, _) {
                      controller.onPageChanged(index);
                    },
                  ),
                  itemBuilder: (context, index, realIndex) {
                    final item = controller.onboardingData[index];
                    return ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.asset(
                        item.image,
                        fit: BoxFit.cover,
                        width: 350,
                        height: 350,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            width: 250,
                            height: 250,
                            color: Colors.grey[300],
                            child: const Icon(Icons.image, size: 50),
                          );
                        },
                      ),
                    );
                  },
                ),
                const Spacer(),
                Obx(
                  () => Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Obx(() => buildIndicator()),
                      if (!controller.isLastPage) const Spacer(),
                      SizedBox(
                        width: controller.isLastPage ? 140 : 100,
                        height: 48,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2563EB),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          onPressed: controller.nextPage,
                          child: Text(
                            controller.isLastPage ? "Get Started" : "Next",
                            style: Theme.of(context).textTheme.bodyMedium!
                                .copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildIndicator() => AnimatedSmoothIndicator(
    activeIndex: controller.currentSlider.value,
    count: controller.onboardingData.length,
    effect: const SlideEffect(
      radius: 5,
      spacing: 8,
      dotWidth: 48,
      dotHeight: 6,
      activeDotColor: Color(0xFF2563EB),
      dotColor: Color(0xFFA6A0AD),
      paintStyle: PaintingStyle.fill,
    ),
  );
}
