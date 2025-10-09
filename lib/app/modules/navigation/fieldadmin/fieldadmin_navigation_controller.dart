import 'package:get/get.dart';

enum BottomNavItem { transaction, field, promosi, logout }

class FieldadminNavigationController extends GetxController {
  final RxInt currentIndex = 0.obs;
  final Rx<BottomNavItem> currentTab = BottomNavItem.transaction.obs;

  // Method untuk ganti tab dari mana saja
  void changeTab(int index) {
    currentIndex.value = index;
    currentTab.value = BottomNavItem.values[index];
  }

  @override
  void onInit() {
    super.onInit();

    final args = Get.arguments;

    if (args is Map) {
      final initial = args['initialTab'];

      if (initial is int &&
          initial >= 0 &&
          initial < BottomNavItem.values.length) {
        changeTab(initial);
      } else if (initial is BottomNavItem) {
        changeTab(initial.index);
      }
    }
  }

  // Get current tab name
  String get currentTabName => currentTab.value.toString().split('.').last;
}
