import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lapangan_kita/app/modules/booking/customer_booking_controller.dart';

class CustomerBookingView extends GetView<CustomerBookingController> {
  const CustomerBookingView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Center(child: Text('Ini Halaman Booking')));
  }
}
