import 'package:get/get.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:lapangan_kita/app/data/models/withdraw_summary_model.dart';
import 'package:lapangan_kita/app/data/models/withdraw_model.dart';
import 'package:lapangan_kita/app/data/network/api_client.dart';
import 'package:lapangan_kita/app/data/repositories/withdraw_repository.dart';
import 'package:lapangan_kita/app/modules/navigation/fieldmanager/tabs_controller/fieldmanager_profile_controller.dart';
import 'package:lapangan_kita/app/services/local_storage_service.dart';

class FieldmanagerWithdrawController extends GetxController {
  FieldmanagerWithdrawController({
    WithdrawRepository? withdrawRepository,
    LocalStorageService? storageService,
  }) : _withdrawRepository = withdrawRepository ?? _ensureWithdrawRepository(),
       _storageService = storageService ?? LocalStorageService.instance;

  final WithdrawRepository _withdrawRepository;
  final LocalStorageService _storageService;

  static const int _withdrawReadyThreshold = 100000;
  static bool _localeInitialized = false;

  final balance = 0.obs;
  final canWithdraw = false.obs;

  final bankName = 'Mandiri'.obs;
  final bankAccountNumber = '0123456789'.obs;
  final bankAccountHolder = 'Budi Pengelola'.obs;

  final Rxn<WithdrawUserInfo> userInfo = Rxn<WithdrawUserInfo>();
  final Rxn<WithdrawHistorySummary> historySummary =
      Rxn<WithdrawHistorySummary>();
  final RxList<WithdrawModel> withdrawHistory = <WithdrawModel>[].obs;

  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  final RxString withdrawError = ''.obs;

  static final NumberFormat _currencyFormatter = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  @override
  void onInit() {
    super.onInit();
    _hydrateFromArguments();
    _loadProfileData();
    fetchBalanceSummary();
  }

  void _hydrateFromArguments() {
    final args = Get.arguments;
    if (args is Map) {
      final b = args['balance'];
      if (b is int) balance.value = b;
      final bank = args['bank_name'];
      if (bank is String && bank.isNotEmpty) bankName.value = bank;
      final account = args['bank_account'];
      if (account is String && account.isNotEmpty) {
        bankAccountNumber.value = account;
      }
    }
  }

  void _loadProfileData() {
    try {
      final profile = Get.find<FieldManagerProfileController>();
      if (profile.name.value.isNotEmpty) {
        bankAccountHolder.value = profile.name.value;
      }
    } catch (_) {
      // Ignore when profile controller is not registered
    }
  }

  Future<void> fetchBalanceSummary() async {
    await _ensureLocaleInitialized();

    final userId = _storageService.userId;
    if (userId <= 0) {
      errorMessage.value = 'User data not found.';
      historySummary.value = null;
      withdrawHistory.clear();
      withdrawError.value = '';
      balance.value = 0;
      canWithdraw.value = false;
      return;
    }

    isLoading.value = true;
    errorMessage.value = '';
    withdrawError.value = '';

    try {
      final result = await _withdrawRepository.getBalanceSummary(
        userId: userId,
      );
      await _fetchWithdrawHistory(userId: userId);
      _applySummary(result);
    } on WithdrawException catch (e) {
      errorMessage.value = e.message;
      historySummary.value = null;
      withdrawHistory.clear();
    } catch (_) {
      errorMessage.value =
          'Failed to load balance summary. Please try again later.';
      historySummary.value = null;
      withdrawHistory.clear();
    } finally {
      isLoading.value = false;
    }
  }

  void _applySummary(WithdrawBalanceSummary value) {
    userInfo.value = value.userInfo;
    historySummary.value = value.history;

    final info = value.balanceSummary;
    balance.value = info.totalBalance;
    canWithdraw.value = balance.value >= _withdrawReadyThreshold;

    if (value.userInfo.name.isNotEmpty) {
      bankAccountHolder.value = value.userInfo.name;
    }
  }

  Future<void> _ensureLocaleInitialized() async {
    if (_localeInitialized) return;
    try {
      await initializeDateFormatting('id_ID', null);
      _localeInitialized = true;
    } catch (_) {
      try {
        await initializeDateFormatting('en_US', null);
        _localeInitialized = true;
      } catch (_) {
        // Ignore failure and rely on default locale to avoid crash
      }
    }
  }

  Future<void> _fetchWithdrawHistory({required int userId}) async {
    try {
      final results = await _withdrawRepository.getWithdraws();
      final filtered = results.where((item) => item.userId == userId).toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
      withdrawHistory.assignAll(filtered);
      withdrawError.value = '';
    } on WithdrawException catch (e) {
      withdrawHistory.clear();
      withdrawError.value = e.message;
    } catch (_) {
      withdrawHistory.clear();
      withdrawError.value =
          'Failed to load withdrawal history. Please try again later.';
    }
  }

  String formatCurrency(int amount) => _currencyFormatter.format(amount);

  String get autoWithdrawSummary {
    // final thresholdDisplay = formatCurrency(_withdrawReadyThreshold);
    // final currentBalanceDisplay = formatCurrency(balance.value);

    // if (canWithdraw.value) {
    //   return 'Saldo tersedia ($currentBalanceDisplay) telah mencapai batas minimal $thresholdDisplay dan siap ditarik ke rekening terdaftar.';
    // }

    // if (balance.value <= 0) {
    //   return 'Saldo belum tersedia. Terima pembayaran dari pelanggan terlebih dahulu sebelum melakukan penarikan.';
    // }

    // return 'Saldo saat ini $currentBalanceDisplay. Penarikan akan tersedia setelah saldo mencapai minimal $thresholdDisplay.';
    return 'Balance withdrawals will be made automatically every week';
  }

  int get totalWithdraws {
    final summaryTotal = historySummary.value?.totalWithdraws;
    if (summaryTotal != null && summaryTotal > 0) {
      return summaryTotal;
    }
    return withdrawHistory.length;
  }

  int get totalWithdrawn {
    final summaryAmount = historySummary.value?.totalWithdrawn;
    if (summaryAmount != null && summaryAmount > 0) {
      return summaryAmount;
    }
    return withdrawHistory.fold<int>(0, (sum, item) => sum + item.amount);
  }

  String get totalWithdrawnDisplay => formatCurrency(totalWithdrawn);

  bool get hasHistory => withdrawHistory.isNotEmpty;

  int get withdrawReadyThreshold => _withdrawReadyThreshold;

  static WithdrawRepository _ensureWithdrawRepository() {
    if (Get.isRegistered<WithdrawRepository>()) {
      try {
        return Get.find<WithdrawRepository>();
      } catch (_) {
        // fall through to rebuild repository
      }
    }

    final repository = WithdrawRepository(_ensureApiClient());
    if (Get.isRegistered<WithdrawRepository>()) {
      Get.replace<WithdrawRepository>(repository);
    } else {
      Get.put<WithdrawRepository>(repository, permanent: true);
    }
    return repository;
  }

  static ApiClient _ensureApiClient() {
    if (Get.isRegistered<ApiClient>()) {
      try {
        return Get.find<ApiClient>();
      } catch (_) {
        // fall through to rebuild client
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
}
