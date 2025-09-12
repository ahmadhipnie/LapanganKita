import 'package:get/get.dart';

enum BottomNavItem { home, booking, community, history, profile}

class CustomerNavigationController  extends GetxController{
  final RxInt currentIndex = 0.obs;
  final Rx<BottomNavItem> currentTab = BottomNavItem.home.obs;

  // Method untuk ganti tab dari mana saja
  void changeTab(int index) {
    currentIndex.value = index;
    currentTab.value = BottomNavItem.values[index];
  }

  // Method untuk ganti tab by enum
  void changeTabByEnum(BottomNavItem tab) {
    final index = BottomNavItem.values.indexOf(tab);
    currentIndex.value = index;
    currentTab.value = tab;
  }

  // Method untuk ganti tab by name
  void changeTabByName(String tabName) {
    final tab = BottomNavItem.values.firstWhere(
      (tab) => tab.toString().split('.').last == tabName,
      orElse: () => BottomNavItem.home,
    );
    changeTabByEnum(tab);
  }

  // Get current tab name
  String get currentTabName => currentTab.value.toString().split('.').last;
}