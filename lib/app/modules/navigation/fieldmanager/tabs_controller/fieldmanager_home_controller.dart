import 'package:get/get.dart';

import '../../../../data/models/field_model.dart';
import '../../../../data/models/performance_report_model.dart';
import '../../../../data/models/place_model.dart';
import '../../../../data/network/api_client.dart';
import '../../../../data/repositories/field_repository.dart';
import '../../../../data/repositories/place_repository.dart';
import '../../../../data/repositories/report_repository.dart';
import '../../../../data/services/session_service.dart';

class FieldManagerHomeController extends GetxController {
  FieldManagerHomeController({
    PlaceRepository? placeRepository,
    SessionService? sessionService,
    FieldRepository? fieldRepository,
    ReportRepository? reportRepository,
  }) : _placeRepository = placeRepository ?? Get.find<PlaceRepository>(),
       _sessionService = sessionService ?? Get.find<SessionService>(),
       _fieldRepository = fieldRepository ?? Get.find<FieldRepository>(),
       _reportRepository = reportRepository ?? Get.find<ReportRepository>();

  final PlaceRepository _placeRepository;
  final SessionService _sessionService;
  final FieldRepository _fieldRepository;
  final ReportRepository _reportRepository;

  RxList<Map<String, dynamic>> fields = <Map<String, dynamic>>[].obs;
  final RxBool isLoadingFields = false.obs;
  final RxString fieldsError = ''.obs;
  int? _lastFetchedPlaceId;

  final RxList<PlaceModel> places = <PlaceModel>[].obs;

  RxInt balance = 0.obs;
  int _baseBalance = 0;
  RxBool hasPlace = false.obs;
  final Rxn<PlaceModel> place = Rxn<PlaceModel>();
  final RxBool isLoadingPlace = false.obs;
  final RxString placeError = ''.obs;

  // UI filters
  RxString searchQuery = ''.obs;
  // 'All', 'Available', 'Not Available'
  RxString filterStatus = 'All'.obs;

  // Profit recap
  RxInt profitToday = 0.obs;
  RxInt profitWeek = 0.obs;
  RxInt profitMonth = 0.obs;

  // Recent transactions
  RxList<PerformanceTransaction> recentTransactions =
      <PerformanceTransaction>[].obs;

  // Controls whether to show all transactions or only a few on the home view
  RxBool showAllTransactions = false.obs;

  final RxBool isLoadingReport = false.obs;
  final RxString reportError = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchPlacesForOwner();
  }

  void setPlace(
    PlaceModel? newPlace, {
    bool syncCollection = true,
    bool refreshReport = true,
  }) {
    final resolvedPhoto = _resolvePhotoUrl(newPlace?.placePhoto);
    final resolvedPlace = newPlace?.copyWith(placePhoto: resolvedPhoto);

    final previousPlaceId = place.value?.id;
    place.value = resolvedPlace;
    hasPlace.value = resolvedPlace != null;
    balance.value = resolvedPlace?.balance ?? 0;
    _baseBalance = resolvedPlace?.balance ?? 0;

    if (resolvedPlace == null) {
      if (syncCollection) {
        places.clear();
      }
      fields.clear();
      fieldsError.value = '';
      _lastFetchedPlaceId = null;
      _baseBalance = 0;
      if (refreshReport) {
        _resetPerformanceReport();
      }
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
    if (refreshReport) {
      fetchPerformanceReport(silent: true);
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
    final user = _sessionService.rememberedUser;
    if (user == null) {
      setPlace(null);
      placeError.value = 'Sesi berakhir. Silakan masuk kembali.';
      _resetPerformanceReport(error: 'Unable to identify the current user.');
      return;
    }

    isLoadingPlace.value = true;
    placeError.value = '';

    try {
      final results = await _placeRepository.getPlacesByOwner(userId: user.id);
      final resolvedPlaces = results
          .map((p) => p.copyWith(placePhoto: _resolvePhotoUrl(p.placePhoto)))
          .toList();

      places.assignAll(resolvedPlaces);
      if (resolvedPlaces.isNotEmpty) {
        setPlace(
          resolvedPlaces.first,
          syncCollection: false,
          refreshReport: false,
        );
        await fetchPerformanceReport();
      } else {
        setPlace(null, syncCollection: false, refreshReport: true);
      }
    } on PlaceException catch (e) {
      placeError.value = e.message;
      setPlace(null, syncCollection: false, refreshReport: true);
      _resetPerformanceReport(error: e.message);
    } catch (_) {
      placeError.value = 'Gagal memuat data tempat. Coba lagi nanti.';
      setPlace(null, syncCollection: false, refreshReport: true);
      _resetPerformanceReport(
        error: 'Gagal memuat laporan performa. Coba lagi nanti.',
      );
    } finally {
      isLoadingPlace.value = false;
    }
  }

  Future<void> fetchPerformanceReport({bool silent = false}) async {
    final user = _sessionService.rememberedUser;
    if (user == null) {
      _resetPerformanceReport(error: 'Sesi berakhir. Silakan masuk kembali.');
      return;
    }

    if (!silent) {
      isLoadingReport.value = true;
    }
    reportError.value = '';

    try {
      final report = await _reportRepository.getOwnerPerformanceReport(
        ownerId: user.id,
      );
      profitToday.value = report.profitToday;
      profitWeek.value = report.profitWeek;
      profitMonth.value = report.profitMonth;
      recentTransactions.assignAll(report.transactions);

      final totalCompleted = report.transactions.fold<int>(
        0,
        (sum, tx) => sum + tx.amount,
      );
      final currentPlaceBalance = place.value?.balance ?? _baseBalance;
      final computedBalance = totalCompleted >= currentPlaceBalance
          ? totalCompleted
          : currentPlaceBalance;
      balance.value = computedBalance;
    } on ReportException catch (e) {
      _resetPerformanceReport(error: e.message);
    } catch (_) {
      _resetPerformanceReport(
        error: 'Gagal memuat laporan performa. Coba lagi nanti.',
      );
    } finally {
      if (!silent) {
        isLoadingReport.value = false;
      }
    }
  }

  void _resetPerformanceReport({String? error}) {
    profitToday.value = 0;
    profitWeek.value = 0;
    profitMonth.value = 0;
    recentTransactions.clear();
    reportError.value = (error ?? '').trim();
  }
}
