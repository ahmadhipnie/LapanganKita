import 'package:get/get.dart';
import 'package:lapangan_kita/app/data/models/user_model.dart';

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
    
    final arguments = Get.arguments;
    if (arguments != null) {
      if (arguments is Map) {
        if (arguments['initialTab'] != null) {
          currentIndex.value = arguments['initialTab'];
        }
      } else if (arguments is UserModel) {
      }
    }
  }

  // Get current tab name
  String get currentTabName => currentTab.value.toString().split('.').last;
}
