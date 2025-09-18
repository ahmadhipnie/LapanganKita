import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lapangan_kita/app/modules/booking/customer_booking_view.dart';
import 'package:lapangan_kita/app/modules/community/customer_community_view.dart';
import 'package:lapangan_kita/app/modules/history/customer_history_view.dart';
import 'package:lapangan_kita/app/modules/home/customer_home_view.dart';
import 'package:lapangan_kita/app/modules/navigation/customer_navigation_controller.dart';
import 'package:lapangan_kita/app/themes/color_theme.dart';

class CustomerNavigationView extends GetView<CustomerNavigationController> {
  CustomerNavigationView({super.key});

  final List<Widget> _pages = [
    CustomerHomeView(), // index 0
    CustomerBookingView(), // index 1
    CustomerCommunityView(), // index 2
    CustomerHistoryView(), // index 3
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.neutralColor,
      body: Obx(() => _pages[controller.currentIndex.value]),
      bottomNavigationBar: Obx(
        () => BottomNavigationBar(
          currentIndex: controller.currentIndex.value,
          onTap: controller.changeTab,
          type: BottomNavigationBarType.fixed,
          selectedItemColor: AppColors.primary,
          unselectedItemColor: Colors.grey[500],
          backgroundColor: AppColors.neutralColor,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
            BottomNavigationBarItem(
              icon: Icon(Icons.calendar_today),
              label: 'Booking',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.people),
              label: 'Community',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.calendar_month_outlined),
              label: 'My Booking',
            ),
          ],
        ),
      ),
    );
  }
}
