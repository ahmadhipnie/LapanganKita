import 'package:carousel_slider/carousel_controller.dart';
import 'package:carousel_slider/carousel_options.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CustomerHomeController extends GetxController {
  // Carousel controller
  final CarouselSliderController carouselController =
      CarouselSliderController();

  // Current active index
  final RxInt currentIndex = 0.obs;

  // Loading state untuk refresh
  final RxBool isLoading = false.obs;

  // Timestamp untuk force reload images
  final RxString _timestamp = DateTime.now().millisecondsSinceEpoch
      .toString()
      .obs;

  // Image data untuk carousel dengan timestamp parameter
  List<String> get imgList => [
    'https://images.unsplash.com/photo-1520877880798-5ee004e3f11e?w=500&t=$_timestamp',
    'https://i.pinimg.com/736x/b4/4e/64/b44e64a9790169f518b6c8f612263944.jpg?w=500&t=$_timestamp',
    'https://images.unsplash.com/photo-1551632811-561732d1e306?w=500&t=$_timestamp',
    'https://i.pinimg.com/736x/6d/4f/27/6d4f277d10b4fc819d17d3f1a3f217b7.jpg?w=500&t=$_timestamp',
  ];

  // Title untuk setiap slide
  final List<String> titleList = [
    'Lapangan Futsal Premium',
    'Lapangan Basket Standar NBA',
    'Lapangan Tenis Berstandar Internasional',
    'Lapangan Voli Pantai & Indoor',
  ];

  // Options untuk carousel
  CarouselOptions get carouselOptions => CarouselOptions(
    autoPlay: true,
    enlargeCenterPage: true,
    viewportFraction: 0.9,
    aspectRatio: 2.0,
    initialPage: 0,
    autoPlayInterval: const Duration(seconds: 5),
    autoPlayAnimationDuration: const Duration(milliseconds: 800),
    autoPlayCurve: Curves.fastOutSlowIn,
    enlargeFactor: 0.3,
    scrollDirection: Axis.horizontal,
    onPageChanged: (index, reason) {
      currentIndex.value = index;
    },
  );

  // Method untuk refresh data
  Future<void> refreshData() async {
    isLoading.value = true;

    // Update timestamp untuk force reload images
    _timestamp.value = DateTime.now().millisecondsSinceEpoch.toString();

    // Simulate API call atau data refresh
    await Future.delayed(const Duration(seconds: 2));

    // Di sini Anda bisa update data dari API
    // Contoh: imgList = await ApiService.getNewImages();

    isLoading.value = false;
  }
}
