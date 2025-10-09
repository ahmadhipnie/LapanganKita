import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AuthController extends GetxController with GetSingleTickerProviderStateMixin {
  late TabController tabController;
  
  // Observable untuk selected tab
  final RxInt currentTabIndex = 0.obs;
  
  // Observable untuk register type
  final RxString selectedRegisterType = ''.obs; // '', 'customer', 'field_manager'

  @override
  void onInit() {
    super.onInit();
    tabController = TabController(length: 2, vsync: this);
    
    // Listen to tab changes
    tabController.addListener(() {
      currentTabIndex.value = tabController.index;
      
      // Reset register type ketika pindah tab
      if (tabController.index == 0) {
        selectedRegisterType.value = '';
      }
    });
  }

  void switchToRegisterTab() {
    tabController.animateTo(1);
  }

  void switchToLoginTab() {
    tabController.animateTo(0);
  }

  void selectRegisterType(String type) {
    selectedRegisterType.value = type;
  }

  void resetRegisterType() {
    selectedRegisterType.value = '';
  }

  @override
  void onClose() {
    tabController.dispose();
    super.onClose();
  }
}
