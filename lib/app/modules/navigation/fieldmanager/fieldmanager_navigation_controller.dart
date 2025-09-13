import 'package:get/get.dart';

enum FieldManagerBottomNavItem { home, booking, history, profile }

class FieldManagerNavigationController extends GetxController {
  final RxInt currentIndex = 0.obs;
  final Rx<FieldManagerBottomNavItem> currentTab =
      FieldManagerBottomNavItem.home.obs;

  void changeTab(int index) {
    currentIndex.value = index;
    currentTab.value = FieldManagerBottomNavItem.values[index];
  }

  void changeTabByEnum(FieldManagerBottomNavItem tab) {
    final index = FieldManagerBottomNavItem.values.indexOf(tab);
    currentIndex.value = index;
    currentTab.value = tab;
  }

  void changeTabByName(String tabName) {
    final tab = FieldManagerBottomNavItem.values.firstWhere(
      (tab) => tab.toString().split('.').last == tabName,
      orElse: () => FieldManagerBottomNavItem.home,
    );
    changeTabByEnum(tab);
  }

  String get currentTabName => currentTab.value.toString().split('.').last;
}
