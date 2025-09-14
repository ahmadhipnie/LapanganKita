import 'package:get/get.dart';

enum BottomNavItem { home, booking, community, history, profile }

class CustomerNavigationController extends GetxController {
  final RxInt currentIndex = 0.obs;
  final Rx<BottomNavItem> currentTab = BottomNavItem.home.obs;

  // Method untuk ganti tab dari mana saja
  void changeTab(int index) {
    currentIndex.value = index;
    currentTab.value = BottomNavItem.values[index];
  }

  @override
  void onInit() {
    super.onInit();
    // Check jika ada arguments untuk initial tab
    final arguments = Get.arguments;
    if (arguments != null && arguments['initialTab'] != null) {
      currentIndex.value = arguments['initialTab'];
    }
  }

  // Get current tab name
  String get currentTabName => currentTab.value.toString().split('.').last;
}
