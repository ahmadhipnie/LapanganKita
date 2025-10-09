import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import 'package:lapangan_kita/app/data/models/place_model.dart';
import 'package:lapangan_kita/app/data/repositories/place_repository.dart';

class FieldadminFieldController extends GetxController {
  FieldadminFieldController({PlaceRepository? placeRepository})
      : _placeRepository = placeRepository ?? Get.find<PlaceRepository>();

  final PlaceRepository _placeRepository;

  final RxList<PlaceModel> places = <PlaceModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  final RxString filterStatus = 'All'.obs;
  final RxString searchQuery = ''.obs;

  static final NumberFormat _currencyFormatter = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  static final DateFormat _dateFormatter = DateFormat('dd MMM yyyy', 'id_ID');

  @override
  void onInit() {
    super.onInit();
    fetchPlaces();
  }

  Future<void> fetchPlaces() async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      final results = await _placeRepository.getAllPlaces();
      places.assignAll(results);
    } on PlaceException catch (e) {
      errorMessage.value = e.message;
      places.clear();
    } catch (e) {
      errorMessage.value = 'Gagal memuat data field. Silakan coba lagi.';
      places.clear();
      debugPrint('Error fetching places: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refreshPlaces() => fetchPlaces();

  List<PlaceModel> get filteredPlaces {
    final query = searchQuery.value.trim().toLowerCase();
    
    var list = places.toList();

    // TODO: Implementasi filter berdasarkan status approval ketika field status tersedia
    // if (filterStatus.value != 'All') {
    //   list = list.where((place) => place.status == filterStatus.value).toList();
    // }

    if (query.isNotEmpty) {
      list = list.where((place) {
        return place.placeName.toLowerCase().contains(query) ||
            place.address.toLowerCase().contains(query) ||
            (place.ownerName?.toLowerCase().contains(query) ?? false) ||
            (place.ownerEmail?.toLowerCase().contains(query) ?? false);
      }).toList();
    }

    list.sort((a, b) {
      final dateA = a.createdAt ?? DateTime.now();
      final dateB = b.createdAt ?? DateTime.now();
      return dateB.compareTo(dateA);
    });

    return list;
  }

  Future<void> approveField(PlaceModel place) async {
    try {
      // TODO: Implementasi approve field ketika endpoint tersedia
      // Untuk sementara, tampilkan pesan bahwa fitur sedang dikembangkan
      Get.snackbar(
        'Info',
        'Fitur approve field akan segera tersedia. Endpoint API diperlukan.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.blue.shade100,
        colorText: Colors.blue.shade900,
      );
      
      // Contoh implementasi ketika endpoint sudah tersedia:
      // await _placeRepository.updatePlaceStatus(
      //   placeId: place.id,
      //   status: 'approved',
      // );
      // await fetchPlaces();
      // Get.snackbar(
      //   'Berhasil',
      //   'Field ${place.placeName} telah disetujui.',
      //   snackPosition: SnackPosition.BOTTOM,
      //   backgroundColor: Colors.green.shade100,
      //   colorText: Colors.green.shade900,
      // );
    } catch (e) {
      Get.snackbar(
        'Gagal',
        'Tidak dapat menyetujui field. Silakan coba lagi.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade900,
      );
    }
  }

  Future<void> rejectField(PlaceModel place, String reason) async {
    try {
      // TODO: Implementasi reject field ketika endpoint tersedia
      Get.snackbar(
        'Info',
        'Fitur reject field akan segera tersedia. Endpoint API diperlukan.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.blue.shade100,
        colorText: Colors.blue.shade900,
      );
      
      // Contoh implementasi ketika endpoint sudah tersedia:
      // await _placeRepository.updatePlaceStatus(
      //   placeId: place.id,
      //   status: 'rejected',
      //   note: reason,
      // );
      // await fetchPlaces();
      // Get.snackbar(
      //   'Berhasil',
      //   'Field ${place.placeName} telah ditolak.',
      //   snackPosition: SnackPosition.BOTTOM,
      //   backgroundColor: Colors.orange.shade100,
      //   colorText: Colors.orange.shade900,
      // );
    } catch (e) {
      Get.snackbar(
        'Gagal',
        'Tidak dapat menolak field. Silakan coba lagi.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade900,
      );
    }
  }

  String formatCurrency(num amount) => _currencyFormatter.format(amount);

  String formatDate(DateTime? date) {
    if (date == null) return '-';
    return _dateFormatter.format(date.toLocal());
  }
}
