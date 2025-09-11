import 'package:get/get.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'onboarding_model.dart';

class OnboardingController extends GetxController {
  final CarouselSliderController carouselSliderController =
      CarouselSliderController();

  final RxInt currentSlider = 0.obs;

  // Data dummy onboarding
  final List<OnboardingItem> onboardingData = [
    OnboardingItem(
      image: 'assets/images/onboarding1.jpg',
      title: 'Simply Your Reservation',
      description:
          "Find and book sports fields effortlessly. Whether it's football, basketball, tennis or any other sport. LapanganKita helps you secure your sport with just a few taps.",
    ),
    OnboardingItem(
      image: 'assets/images/onboarding2.jpg',
      title: 'Connect with Players',
      description:
          'Looking for teammmates or opponents? Join a community of sports enthusiasts, organize matches, and make new friends who share your passion.',
    ),
  ];

  void nextPage() {
    if (currentSlider.value < onboardingData.length - 1) {
      currentSlider.value++;
      carouselSliderController.nextPage();
    } else {
      completeOnboarding();
    }
  }

  void onPageChanged(int index) {
    currentSlider.value = index;
  }

  Future<void> completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool("onboarding", true);
    Get.offAllNamed('/login');
  }

  bool get isLastPage => currentSlider.value == onboardingData.length - 1;

  // Get current onboarding item
  OnboardingItem get currentItem => onboardingData[currentSlider.value];
}
