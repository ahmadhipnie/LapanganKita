import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'fieldmanager_navigation_controller.dart';

import 'package:lapangan_kita/app/modules/navigation/fieldmanager/tabs/fieldmanager_booking_view.dart';
import 'package:lapangan_kita/app/modules/navigation/fieldmanager/tabs/fieldmanager_kelola_view.dart';
import 'package:lapangan_kita/app/modules/navigation/fieldmanager/tabs/fieldmanager_history_view.dart';
import 'package:lapangan_kita/app/modules/navigation/fieldmanager/tabs/fieldmanager_navigation_profile_view.dart';

class FieldManagerNavigationView
    extends GetView<FieldManagerNavigationController> {
  FieldManagerNavigationView({super.key});

  final List<Widget> _pages = [
    FieldManagerKelolaView(),
    FieldManagerBookingView(),
    FieldManagerHistoryView(),
    FieldManagerNavigationProfileView(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(() => _pages[controller.currentIndex.value]),
      bottomNavigationBar: Obx(
        () => BottomNavigationBar(
          currentIndex: controller.currentIndex.value,
          onTap: controller.changeTab,
          type: BottomNavigationBarType.fixed,
          selectedItemColor: const Color(0xff2563EB),
          unselectedItemColor: Colors.grey,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.settings),
              label: 'Kelola',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.calendar_today),
              label: 'Booking',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.history),
              label: 'History',
            ),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
          ],
        ),
      ),
    );
  }
}
