// import 'package:get/get.dart';

// import '../../../../data/models/field_model.dart';
// import '../../../../data/models/place_model.dart';
// import '../../../../data/network/api_client.dart';
// import '../../../../data/repositories/field_repository.dart';
// import '../../../../data/repositories/place_repository.dart';
// import '../../../../data/services/session_service.dart';

// class FieldManagerHomeController extends GetxController {
//   FieldManagerHomeController({
//     PlaceRepository? placeRepository,
//     SessionService? sessionService,
//     FieldRepository? fieldRepository,
//   }) : _placeRepository = placeRepository ?? Get.find<PlaceRepository>(),
//        _sessionService = sessionService ?? Get.find<SessionService>(),
//        _fieldRepository = fieldRepository ?? Get.find<FieldRepository>();

//   final PlaceRepository _placeRepository;
//   final SessionService _sessionService;
//   final FieldRepository _fieldRepository;

//   RxList<Map<String, dynamic>> fields = <Map<String, dynamic>>[].obs;
//   final RxBool isLoadingFields = false.obs;
//   final RxString fieldsError = ''.obs;
//   int? _lastFetchedPlaceId;

//   final RxList<PlaceModel> places = <PlaceModel>[].obs;

//   RxInt balance = 0.obs;
//   RxBool hasPlace = false.obs;
//   final Rxn<PlaceModel> place = Rxn<PlaceModel>();
//   final RxBool isLoadingPlace = false.obs;
//   final RxString placeError = ''.obs;

//   // UI filters
//   RxString searchQuery = ''.obs;
//   // 'All', 'Available', 'Not Available'
//   RxString filterStatus = 'All'.obs;

//   // Profit recap
//   RxInt profitToday = 0.obs;
//   RxInt profitWeek = 0.obs;
//   RxInt profitMonth = 0.obs;

//   // Recent transactions
//   RxList<Map<String, dynamic>> recentTransactions =
//       <Map<String, dynamic>>[].obs;

//   // Controls whether to show all transactions or only a few on the home view
//   RxBool showAllTransactions = false.obs;

//   @override
//   void onInit() {
//     super.onInit();
//     fetchPlacesForOwner();
//   }

//   void setPlace(PlaceModel? newPlace, {bool syncCollection = true}) {
//     final resolvedPhoto = _resolvePhotoUrl(newPlace?.placePhoto);
//     final resolvedPlace = newPlace?.copyWith(placePhoto: resolvedPhoto);

//     final previousPlaceId = place.value?.id;
//     place.value = resolvedPlace;
//     hasPlace.value = resolvedPlace != null;
//     balance.value = resolvedPlace?.balance ?? 0;

//     if (resolvedPlace == null) {
//       if (syncCollection) {
//         places.clear();
//       }
//       fields.clear();
//       fieldsError.value = '';
//       _lastFetchedPlaceId = null;
//       return;
//     }

//     if (syncCollection) {
//       final index = places.indexWhere((p) => p.id == resolvedPlace.id);
//       if (index >= 0) {
//         places[index] = resolvedPlace;
//         places.refresh();
//       } else {
//         places.insert(0, resolvedPlace);
//       }
//     }

//     if (resolvedPlace.id != previousPlaceId) {
//       fetchFieldsForPlace(placeId: resolvedPlace.id);
//     }
//   }

//   Map<String, dynamic> _mapFieldToUi(FieldModel field) {
//     return {
//       'id': field.id,
//       'name': field.fieldName,
//       'openHour': _formatDisplayTime(field.openingTime),
//       'closeHour': _formatDisplayTime(field.closingTime),
//       'price': field.pricePerHour,
//       'description': field.description.isNotEmpty
//           ? field.description
//           : 'Deskripsi belum tersedia.',
//       'type': _formatFieldType(field.fieldType),
//       'photo': _resolvePhotoUrl(field.fieldPhoto),
//       'status': _mapStatus(field.status),
//       'maxPerson': field.maxPerson,
//       'placeId': field.placeId,
//       'placeName': field.placeName,
//       'placeAddress': field.placeAddress,
//       'placeOwnerName': field.placeOwnerName,
//     };
//   }

//   String _formatDisplayTime(String raw) {
//     if (raw.isEmpty) return raw;
//     final parts = raw.split(':');
//     if (parts.length >= 2) {
//       return '${parts[0]}:${parts[1]}';
//     }
//     return raw;
//   }

//   String _mapStatus(String raw) {
//     final normalized = raw.toLowerCase();
//     if (normalized == 'tersedia' || normalized == 'available') {
//       return 'Available';
//     }
//     if (normalized == 'tidak tersedia' || normalized == 'not available') {
//       return 'Not Available';
//     }
//     return raw.isEmpty ? 'Unknown' : raw;
//   }

//   String? _resolvePhotoUrl(String? rawPath) {
//     if (rawPath == null || rawPath.isEmpty) return null;
//     if (rawPath.startsWith('http')) return rawPath;
//     final uri = Uri.parse(ApiClient.baseUrl);
//     final buffer = StringBuffer()
//       ..write(uri.scheme)
//       ..write('://')
//       ..write(uri.host);
//     if (uri.hasPort && uri.port != 80 && uri.port != 443) {
//       buffer.write(':${uri.port}');
//     }
//     final normalized = rawPath.startsWith('/') ? rawPath : '/$rawPath';
//     return '${buffer.toString()}$normalized';
//   }

//   String _formatFieldType(String raw) {
//     if (raw.isEmpty) return raw;
//     final cleaned = raw.replaceAll('_', ' ');
//     final words = cleaned.split(RegExp(r'\s+')).where((w) => w.isNotEmpty);
//     return words
//         .map(
//           (word) =>
//               word.substring(0, 1).toUpperCase() +
//               word.substring(1).toLowerCase(),
//         )
//         .join(' ');
//   }

//   Future<void> fetchFieldsForPlace({int? placeId, bool force = false}) async {
//     final targetPlaceId = placeId ?? place.value?.id;
//     if (targetPlaceId == null) {
//       fields.clear();
//       fieldsError.value = '';
//       _lastFetchedPlaceId = null;
//       return;
//     }

//     if (!force && _lastFetchedPlaceId == targetPlaceId && fields.isNotEmpty) {
//       return;
//     }

//     isLoadingFields.value = true;
//     fieldsError.value = '';

//     try {
//       final results = await _fieldRepository.getFieldsByPlace(
//         placeId: targetPlaceId,
//       );
//       fields.assignAll(results.map(_mapFieldToUi).toList());
//       _lastFetchedPlaceId = targetPlaceId;
//     } on FieldException catch (e) {
//       fieldsError.value = e.message;
//       fields.clear();
//     } catch (_) {
//       fieldsError.value = 'Gagal memuat data field. Coba lagi nanti.';
//       fields.clear();
//     } finally {
//       isLoadingFields.value = false;
//     }
//   }

//   void addOrUpdateField(FieldModel field) {
//     final mapped = _mapFieldToUi(field);
//     final index = fields.indexWhere((item) => item['id'] == field.id);
//     if (index >= 0) {
//       fields[index] = mapped;
//       fields.refresh();
//     } else {
//       fields.insert(0, mapped);
//     }
//   }

//   void refreshFields() {
//     final currentPlaceId = place.value?.id;
//     if (currentPlaceId == null) {
//       Get.snackbar(
//         'Register place first',
//         'Silakan daftar tempat sebelum memuat data lapangan.',
//         snackPosition: SnackPosition.BOTTOM,
//       );
//       return;
//     }

//     fetchFieldsForPlace(placeId: currentPlaceId, force: true);
//   }

//   Future<void> fetchPlacesForOwner() async {
//     final user = _sessionService.rememberedUser;
//     if (user == null) {
//       setPlace(null);
//       placeError.value = 'Sesi berakhir. Silakan masuk kembali.';
//       return;
//     }

//     isLoadingPlace.value = true;
//     placeError.value = '';

//     try {
//       final results = await _placeRepository.getPlacesByOwner(userId: user.id);
//       final resolvedPlaces = results
//           .map((p) => p.copyWith(placePhoto: _resolvePhotoUrl(p.placePhoto)))
//           .toList();

//       places.assignAll(resolvedPlaces);
//       if (resolvedPlaces.isNotEmpty) {
//         setPlace(resolvedPlaces.first, syncCollection: false);
//       } else {
//         setPlace(null, syncCollection: false);
//       }
//     } on PlaceException catch (e) {
//       placeError.value = e.message;
//       setPlace(null, syncCollection: false);
//     } catch (_) {
//       placeError.value = 'Gagal memuat data tempat. Coba lagi nanti.';
//       setPlace(null, syncCollection: false);
//     } finally {
//       isLoadingPlace.value = false;
//     }
//   }
// }

import 'package:get/get.dart';
import '../../../../data/models/field_model.dart';
import '../../../../data/models/place_model.dart';
import '../../../../data/network/api_client.dart';
import '../../../../data/repositories/field_repository.dart';
import '../../../../data/repositories/place_repository.dart';
import '../../../../services/local_storage_service.dart';

class FieldManagerHomeController extends GetxController {
  FieldManagerHomeController({
    PlaceRepository? placeRepository,
    FieldRepository? fieldRepository,
  }) : _placeRepository = placeRepository ?? Get.find<PlaceRepository>(),
       _fieldRepository = fieldRepository ?? Get.find<FieldRepository>();

  final PlaceRepository _placeRepository;
  final FieldRepository _fieldRepository;
  final LocalStorageService _localStorage = LocalStorageService.instance;

  RxList<Map<String, dynamic>> fields = <Map<String, dynamic>>[].obs;
  final RxBool isLoadingFields = false.obs;
  final RxString fieldsError = ''.obs;
  int? _lastFetchedPlaceId;

  final RxList<PlaceModel> places = <PlaceModel>[].obs;

  RxInt balance = 0.obs;
  RxBool hasPlace = false.obs;
  final Rxn<PlaceModel> place = Rxn<PlaceModel>();
  final RxBool isLoadingPlace = false.obs;
  final RxString placeError = ''.obs;

  // UI filters
  RxString searchQuery = ''.obs;
  RxString filterStatus = 'All'.obs;

  // Profit recap
  RxInt profitToday = 0.obs;
  RxInt profitWeek = 0.obs;
  RxInt profitMonth = 0.obs;

  // Recent transactions
  RxList<Map<String, dynamic>> recentTransactions =
      <Map<String, dynamic>>[].obs;

  // Controls whether to show all transactions or only a few on the home view
  RxBool showAllTransactions = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchPlacesForOwner();
  }

  /// Get user ID from LocalStorage
  int get _userId {
    final userData = _localStorage.getUserData();
    return int.tryParse(userData?['id']?.toString() ?? '0') ?? 0;
  }

  void setPlace(PlaceModel? newPlace, {bool syncCollection = true}) {
    final resolvedPhoto = _resolvePhotoUrl(newPlace?.placePhoto);
    final resolvedPlace = newPlace?.copyWith(placePhoto: resolvedPhoto);

    final previousPlaceId = place.value?.id;
    place.value = resolvedPlace;
    hasPlace.value = resolvedPlace != null;
    balance.value = resolvedPlace?.balance ?? 0;

    if (resolvedPlace == null) {
      if (syncCollection) {
        places.clear();
      }
      fields.clear();
      fieldsError.value = '';
      _lastFetchedPlaceId = null;
      return;
    }

    if (syncCollection) {
      final index = places.indexWhere((p) => p.id == resolvedPlace.id);
      if (index >= 0) {
        places[index] = resolvedPlace;
        places.refresh();
      } else {
        places.insert(0, resolvedPlace);
      }
    }

    if (resolvedPlace.id != previousPlaceId) {
      fetchFieldsForPlace(placeId: resolvedPlace.id);
    }
  }

  Map<String, dynamic> _mapFieldToUi(FieldModel field) {
    return {
      'id': field.id,
      'name': field.fieldName,
      'openHour': _formatDisplayTime(field.openingTime),
      'closeHour': _formatDisplayTime(field.closingTime),
      'price': field.pricePerHour,
      'description': field.description.isNotEmpty
          ? field.description
          : 'Deskripsi belum tersedia.',
      'type': _formatFieldType(field.fieldType),
      'photo': _resolvePhotoUrl(field.fieldPhoto),
      'status': _mapStatus(field.status),
      'maxPerson': field.maxPerson,
      'placeId': field.placeId,
      'placeName': field.placeName,
      'placeAddress': field.placeAddress,
      'placeOwnerName': field.placeOwnerName,
    };
  }

  String _formatDisplayTime(String raw) {
    if (raw.isEmpty) return raw;
    final parts = raw.split(':');
    if (parts.length >= 2) {
      return '${parts[0]}:${parts[1]}';
    }
    return raw;
  }

  String _mapStatus(String raw) {
    final normalized = raw.toLowerCase();
    if (normalized == 'tersedia' || normalized == 'available') {
      return 'Available';
    }
    if (normalized == 'tidak tersedia' || normalized == 'not available') {
      return 'Not Available';
    }
    return raw.isEmpty ? 'Unknown' : raw;
  }

  String? _resolvePhotoUrl(String? rawPath) {
    if (rawPath == null || rawPath.isEmpty) return null;
    if (rawPath.startsWith('http')) return rawPath;
    final uri = Uri.parse(ApiClient.baseUrl);
    final buffer = StringBuffer()
      ..write(uri.scheme)
      ..write('://')
      ..write(uri.host);
    if (uri.hasPort && uri.port != 80 && uri.port != 443) {
      buffer.write(':${uri.port}');
    }
    final normalized = rawPath.startsWith('/') ? rawPath : '/$rawPath';
    return '${buffer.toString()}$normalized';
  }

  String _formatFieldType(String raw) {
    if (raw.isEmpty) return raw;
    final cleaned = raw.replaceAll('_', ' ');
    final words = cleaned.split(RegExp(r'\s+')).where((w) => w.isNotEmpty);
    return words
        .map(
          (word) =>
              word.substring(0, 1).toUpperCase() +
              word.substring(1).toLowerCase(),
        )
        .join(' ');
  }

  Future<void> fetchFieldsForPlace({int? placeId, bool force = false}) async {
    final targetPlaceId = placeId ?? place.value?.id;
    if (targetPlaceId == null) {
      fields.clear();
      fieldsError.value = '';
      _lastFetchedPlaceId = null;
      return;
    }

    if (!force && _lastFetchedPlaceId == targetPlaceId && fields.isNotEmpty) {
      return;
    }

    isLoadingFields.value = true;
    fieldsError.value = '';

    try {
      final results = await _fieldRepository.getFieldsByPlace(
        placeId: targetPlaceId,
      );
      fields.assignAll(results.map(_mapFieldToUi).toList());
      _lastFetchedPlaceId = targetPlaceId;
    } on FieldException catch (e) {
      fieldsError.value = e.message;
      fields.clear();
    } catch (_) {
      fieldsError.value = 'Gagal memuat data field. Coba lagi nanti.';
      fields.clear();
    } finally {
      isLoadingFields.value = false;
    }
  }

  void addOrUpdateField(FieldModel field) {
    final mapped = _mapFieldToUi(field);
    final index = fields.indexWhere((item) => item['id'] == field.id);
    if (index >= 0) {
      fields[index] = mapped;
      fields.refresh();
    } else {
      fields.insert(0, mapped);
    }
  }

  void refreshFields() {
    final currentPlaceId = place.value?.id;
    if (currentPlaceId == null) {
      Get.snackbar(
        'Register place first',
        'Silakan daftar tempat sebelum memuat data lapangan.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    fetchFieldsForPlace(placeId: currentPlaceId, force: true);
  }

  Future<void> fetchPlacesForOwner() async {
    // ✅ PERBAIKAN: Gunakan LocalStorageService untuk mendapatkan user data
    if (!_localStorage.isLoggedIn) {
      setPlace(null);
      placeError.value = 'Sesi berakhir. Silakan masuk kembali.';
      return;
    }

    final userData = _localStorage.getUserData();
    if (userData == null) {
      setPlace(null);
      placeError.value = 'Data pengguna tidak ditemukan.';
      return;
    }

    final userId = _userId;
    if (userId == 0) {
      setPlace(null);
      placeError.value = 'ID pengguna tidak valid.';
      return;
    }

    isLoadingPlace.value = true;
    placeError.value = '';

    try {
      final results = await _placeRepository.getPlacesByOwner(userId: userId);
      final resolvedPlaces = results
          .map((p) => p.copyWith(placePhoto: _resolvePhotoUrl(p.placePhoto)))
          .toList();

      places.assignAll(resolvedPlaces);
      if (resolvedPlaces.isNotEmpty) {
        setPlace(resolvedPlaces.first, syncCollection: false);
      } else {
        setPlace(null, syncCollection: false);
      }
    } on PlaceException catch (e) {
      placeError.value = e.message;
      setPlace(null, syncCollection: false);
    } catch (_) {
      placeError.value = 'Gagal memuat data tempat. Coba lagi nanti.';
      setPlace(null, syncCollection: false);
    } finally {
      isLoadingPlace.value = false;
    }
  }

  /// Check if user is logged in and has valid session
  bool get isUserValid {
    return _localStorage.isLoggedIn && _userId > 0;
  }

  /// Get user name from LocalStorage
  String get userName => _localStorage.userName;

  /// Get user role from LocalStorage
  String get userRole => _localStorage.userRole;
}
