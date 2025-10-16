import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import 'package:lapangan_kita/app/data/models/place_model.dart';
import 'package:lapangan_kita/app/data/models/withdraw_model.dart';
import 'package:lapangan_kita/app/data/models/withdraw_summary_model.dart';
import 'package:lapangan_kita/app/data/network/api_client.dart';
import 'package:lapangan_kita/app/data/repositories/place_repository.dart';
import 'package:lapangan_kita/app/data/repositories/withdraw_repository.dart';
import 'package:lapangan_kita/app/services/local_storage_service.dart';
import 'package:intl/date_symbol_data_local.dart';

class FieldadminWithdrawController extends GetxController {
  FieldadminWithdrawController({
    WithdrawRepository? withdrawRepository,
    PlaceRepository? placeRepository,
    LocalStorageService? storageService,
  }) : _withdrawRepository = withdrawRepository ?? _ensureWithdrawRepository(),
       _placeRepository = placeRepository ?? _ensurePlaceRepository(),
       _storageService = storageService ?? LocalStorageService.instance;

  final WithdrawRepository _withdrawRepository;
  final PlaceRepository _placeRepository;
  final LocalStorageService _storageService;

  final RxBool isLoading = false.obs;
  final RxBool isLoadingPlaces = false.obs;
  final RxBool isLoadingSummary = false.obs;
  final RxBool isLoadingUserWithdraws = false.obs;
  final RxString errorMessage = ''.obs;
  final RxString placeError = ''.obs;
  final RxString summaryError = ''.obs;
  final RxString userWithdrawError = ''.obs;

  final RxList<WithdrawModel> withdraws = <WithdrawModel>[].obs;
  final RxList<WithdrawModel> userWithdraws = <WithdrawModel>[].obs;
  final RxList<PlaceModel> _places = <PlaceModel>[].obs;
  final Rxn<WithdrawBalanceSummary> balanceSummary =
      Rxn<WithdrawBalanceSummary>();
  final RxInt minimumBalanceThreshold = 100000.obs;
  final RxMap<int, String> _userBankTypes = <int, String>{}.obs;
  final RxMap<int, String> _userAccountNumbers = <int, String>{}.obs;

  // UI state: search & status filter
  final RxString searchQuery = ''.obs;
  final RxString statusFilter = 'All'.obs; // All | Pending | Processed

  // Selected proof images per request id
  final RxMap<int, XFile?> proofImages = <int, XFile?>{}.obs;
  final RxMap<int, bool> _processingStates = <int, bool>{}.obs;
  final RxMap<int, bool> _autoProcessingStates = <int, bool>{}.obs;

  @override
  void onInit() {
    super.onInit();
    _initializeLocaleAndFetch();
  }

  Future<void> _initializeLocaleAndFetch() async {
    try {
      await initializeDateFormatting('id_ID', null);
    } catch (e) {
      debugPrint('Failed to initialize locale data: $e');
    }
    await Future.wait([fetchWithdraws(), fetchEligiblePlaces()]);
  }

  Future<void> fetchWithdraws() async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      final results = await _withdrawRepository.getWithdraws();
      withdraws.assignAll(results);
      _ingestWithdrawBankInfo(results);
    } on WithdrawException catch (e) {
      errorMessage.value = e.message;
      withdraws.clear();
    } catch (e) {
      debugPrint('Failed to fetch withdraws: $e');
      errorMessage.value =
          'Failed to load withdrawal data. Please try again later..';
      withdraws.clear();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refreshAll() async {
    await Future.wait([fetchWithdraws(), fetchEligiblePlaces()]);
  }

  Future<void> fetchEligiblePlaces() async {
    isLoadingPlaces.value = true;
    placeError.value = '';

    try {
      final results = await _placeRepository.getAllPlaces();
      _places.assignAll(results);
      await _prefetchBankInfoForPlaces(results);
    } on PlaceException catch (e) {
      placeError.value = e.message;
      _places.clear();
    } catch (e) {
      debugPrint('Failed to fetch places: $e');
      placeError.value = 'Failed to load field data. Please try again later.';
      _places.clear();
    } finally {
      isLoadingPlaces.value = false;
    }
  }

  Future<void> fetchBalanceSummaryForUser(int userId) async {
    isLoadingSummary.value = true;
    summaryError.value = '';

    try {
      final summary = await _withdrawRepository.getBalanceSummary(
        userId: userId,
      );
      balanceSummary.value = summary;
    } on WithdrawException catch (e) {
      summaryError.value = e.message;
      balanceSummary.value = null;
    } catch (e) {
      debugPrint('Failed to fetch balance summary: $e');
      summaryError.value =
          'Failed to load balance summary. Please try again later.';
      balanceSummary.value = null;
    } finally {
      isLoadingSummary.value = false;
    }
  }

  Future<void> fetchWithdrawsForUser(int userId) async {
    isLoadingUserWithdraws.value = true;
    userWithdrawError.value = '';

    try {
      final results = await _withdrawRepository.getUserWithdraws(
        userId: userId,
      );
      userWithdraws.assignAll(results);
      _ingestWithdrawBankInfo(results);
    } on WithdrawException catch (e) {
      userWithdrawError.value = e.message;
      userWithdraws.clear();
    } catch (e) {
      debugPrint('Failed to fetch user withdraws: $e');
      userWithdrawError.value =
          'Failed to load user withdrawal data. Please try again later.';
      userWithdraws.clear();
    } finally {
      isLoadingUserWithdraws.value = false;
    }
  }

  int get currentUserId => _storageService.userId;

  List<WithdrawModel> get filteredWithdraws {
    final status = statusFilter.value;
    final query = searchQuery.value.trim().toLowerCase();

    Iterable<WithdrawModel> items = withdraws;
    if (status != 'All') {
      items = items.where((item) => item.displayStatus == status);
    }

    if (query.isNotEmpty) {
      items = items.where((item) {
        final name = item.userName.toLowerCase();
        final email = item.userEmail.toLowerCase();
        final idString = '#${item.id}'.toLowerCase();
        final amount = item.amount.toString();
        final bankType = item.normalizedBankType.toLowerCase();
        final accountNumber = item.normalizedAccountNumber.toLowerCase();
        return name.contains(query) ||
            email.contains(query) ||
            idString.contains(query) ||
            amount.contains(query) ||
            bankType.contains(query) ||
            accountNumber.contains(query);
      });
    }

    return items.toList()..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  List<WithdrawModel> get pendingWithdraws =>
      filteredWithdraws.where((item) => !item.isProcessed).toList();

  List<WithdrawModel> get processedWithdraws =>
      filteredWithdraws.where((item) => item.isProcessed).toList();

  List<PlaceModel> get autoPendingPlaces {
    if (statusFilter.value == 'Processed') {
      return const <PlaceModel>[];
    }

    final threshold = minimumBalanceThreshold.value;
    final query = searchQuery.value.trim().toLowerCase();
    final pendingUserIds = withdraws
        .where((item) => !item.isProcessed)
        .map((item) => item.userId)
        .toSet();

    Iterable<PlaceModel> items = _places.where((place) {
      if (place.balance < threshold) {
        return false;
      }

      final ownerId = place.userId;
      if (ownerId != null && pendingUserIds.contains(ownerId)) {
        return false;
      }

      return true;
    });

    if (query.isNotEmpty) {
      items = items.where((place) {
        final name = place.placeName.toLowerCase();
        final owner = place.ownerName?.toLowerCase() ?? '';
        final email = place.ownerEmail?.toLowerCase() ?? '';
        final address = place.address.toLowerCase();
        final balanceString = place.balance.toString();
        return name.contains(query) ||
            owner.contains(query) ||
            email.contains(query) ||
            address.contains(query) ||
            balanceString.contains(query);
      });
    }

    final results = items.toList()
      ..sort((a, b) => b.balance.compareTo(a.balance));
    return results;
  }

  bool get hasSufficientBalance {
    final threshold = minimumBalanceThreshold.value;
    final hasEligibleWithdraw = pendingWithdraws.any(
      (withdraw) => withdraw.amount >= threshold,
    );
    return hasEligibleWithdraw || autoPendingPlaces.isNotEmpty;
  }

  static ApiClient _ensureApiClient() {
    if (Get.isRegistered<ApiClient>()) {
      try {
        return Get.find<ApiClient>();
      } catch (_) {
        // fall through to create fresh instance
      }
    }

    final client = ApiClient();
    if (Get.isRegistered<ApiClient>()) {
      Get.replace<ApiClient>(client);
    } else {
      Get.put<ApiClient>(client, permanent: true);
    }
    return client;
  }

  static WithdrawRepository _ensureWithdrawRepository() {
    if (Get.isRegistered<WithdrawRepository>()) {
      try {
        return Get.find<WithdrawRepository>();
      } catch (_) {
        // fall through to rebuilding
      }
    }

    final repo = WithdrawRepository(_ensureApiClient());
    if (Get.isRegistered<WithdrawRepository>()) {
      Get.replace<WithdrawRepository>(repo);
    } else {
      Get.put<WithdrawRepository>(repo, permanent: true);
    }
    return repo;
  }

  static PlaceRepository _ensurePlaceRepository() {
    if (Get.isRegistered<PlaceRepository>()) {
      try {
        return Get.find<PlaceRepository>();
      } catch (_) {
        // fall through to rebuilding
      }
    }

    final repo = PlaceRepository(_ensureApiClient());
    if (Get.isRegistered<PlaceRepository>()) {
      Get.replace<PlaceRepository>(repo);
    } else {
      Get.put<PlaceRepository>(repo, permanent: true);
    }
    return repo;
  }

  String? bankTypeForUser(int? userId) {
    if (userId == null) return null;
    final value = _userBankTypes[userId];
    if (value == null) return null;
    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }

  String? accountNumberForUser(int? userId) {
    if (userId == null) return null;
    final value = _userAccountNumbers[userId];
    if (value == null) return null;
    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }

  void _ingestWithdrawBankInfo(List<WithdrawModel> items) {
    for (final withdraw in items) {
      final bank = withdraw.normalizedBankType;
      final account = withdraw.normalizedAccountNumber;
      if (bank.isEmpty && account.isEmpty) {
        continue;
      }
      _storeBankInfo(withdraw.userId, {
        if (bank.isNotEmpty) 'bank_type': bank,
        if (account.isNotEmpty) 'account_number': account,
      });
    }
  }

  Future<void> _prefetchBankInfoForPlaces(List<PlaceModel> places) async {
    final userIds = places
        .map((place) => place.userId)
        .whereType<int>()
        .where((userId) => !_hasBankMeta(userId))
        .toSet();

    if (userIds.isEmpty) {
      return;
    }

    await Future.wait(
      userIds.map((userId) async {
        final info = await _withdrawRepository.getUserBankInfo(userId);
        if (info != null && info.isNotEmpty) {
          _storeBankInfo(userId, info);
        }
      }),
    );
  }

  void _storeBankInfo(int userId, Map<String, String> info) {
    final bank = info['bank_type'];
    final account = info['account_number'];

    if (bank != null && bank.trim().isNotEmpty) {
      _userBankTypes[userId] = bank;
    }

    if (account != null && account.trim().isNotEmpty) {
      _userAccountNumbers[userId] = account;
    }
  }

  bool _hasBankMeta(int userId) {
    final bank = _userBankTypes[userId]?.trim();
    final account = _userAccountNumbers[userId]?.trim();
    return (bank != null && bank.isNotEmpty) ||
        (account != null && account.isNotEmpty);
  }

  Future<void> pickProof(int id) async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      proofImages[id] = image;
    }
  }

  bool isProcessing(int id) => _processingStates[id] ?? false;
  bool isAutoProcessing(int placeId) => _autoProcessingStates[placeId] ?? false;

  void _setProcessing(int id, bool value) {
    if (value) {
      _processingStates[id] = true;
    } else {
      _processingStates.remove(id);
    }
  }

  void _setAutoProcessing(int placeId, bool value) {
    if (value) {
      _autoProcessingStates[placeId] = true;
    } else {
      _autoProcessingStates.remove(placeId);
    }
  }

  Future<void> approveWithProof(int id) async {
    final proof = proofImages[id];
    if (proof == null) {
      Get.snackbar('Proof required', 'Please upload transfer proof');
      return;
    }
    if (isProcessing(id)) {
      return;
    }

    _setProcessing(id, true);

    try {
      await _withdrawRepository.updateWithdraw(
        withdrawId: id,
        status: 'processed',
        proofPath: proof.path,
      );

      proofImages.remove(id);

      if (Get.isBottomSheetOpen ?? false) {
        Get.back();
      }

      await fetchWithdraws();

      Get.snackbar(
        'Withdraw approved',
        'Proof of transfer successfully uploaded.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFF16A34A),
        colorText: Colors.white,
      );
    } on WithdrawException catch (e) {
      Get.snackbar(
        'Failed to process withdrawal',
        e.message,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFDC2626),
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Failed to process withdrawal',
        'An unexpected error occurred. Please try again later.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFDC2626),
        colorText: Colors.white,
      );
    } finally {
      _setProcessing(id, false);
    }
  }

  Future<void> rejectRequest(int id) async {
    if (isProcessing(id)) {
      return;
    }

    _setProcessing(id, true);

    try {
      await _withdrawRepository.updateWithdraw(
        withdrawId: id,
        status: 'rejected',
      );

      proofImages.remove(id);

      if (Get.isBottomSheetOpen ?? false) {
        Get.back();
      }

      await fetchWithdraws();

      Get.snackbar(
        'Withdrawal rejected',
        'Withdrawal request #$id has been successfully rejected.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFDC2626),
        colorText: Colors.white,
      );
    } on WithdrawException catch (e) {
      Get.snackbar(
        'Failed to reject withdrawal',
        e.message,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFDC2626),
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Failed to reject withdrawal',
        'An unexpected error occurred. Please try again later.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFDC2626),
        colorText: Colors.white,
      );
    } finally {
      _setProcessing(id, false);
    }
  }

  Future<bool> submitAutoWithdraw({
    required PlaceModel place,
    required int amount,
    required String proofPath,
  }) async {
    if (amount < minimumBalanceThreshold.value) {
      Get.snackbar(
        'Nominal does not meet the requirements',
        'Minimum withdrawal is Rp ${minimumBalanceThreshold.value}.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFFCD34D),
        colorText: Colors.black87,
      );
      return false;
    }

    final ownerId = place.userId;
    if (ownerId == null) {
      Get.snackbar(
        'Incomplete data',
        'This field does not have a related Field Manager.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFDC2626),
        colorText: Colors.white,
      );
      return false;
    }

    if (isAutoProcessing(place.id)) {
      return false;
    }

    _setAutoProcessing(place.id, true);

    try {
      await _withdrawRepository.createWithdraw(
        userId: ownerId,
        amount: amount,
        proofPath: proofPath,
      );

      if (Get.isBottomSheetOpen ?? false) {
        Get.back();
      }

      await refreshAll();

      Get.snackbar(
        'Withdrawal created',
        'Withdrawal request has been successfully submitted.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFF16A34A),
        colorText: Colors.white,
      );

      return true;
    } on WithdrawException catch (e) {
      Get.snackbar(
        'Failed to create withdrawal',
        e.message,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFDC2626),
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Failed to create withdrawal',
        'An unexpected error occurred. Please try again later.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFDC2626),
        colorText: Colors.white,
      );
    } finally {
      _setAutoProcessing(place.id, false);
    }

    return false;
  }
}
