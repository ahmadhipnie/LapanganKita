import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:get/get.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:lapangan_kita/app/themes/color_theme.dart';
// import 'package:lapangan_kita/app/data/services/session_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app/routes/app_pages.dart';
import 'app/routes/app_routes.dart';
import 'app/services/local_storage_service.dart';

void main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  final prefs = await SharedPreferences.getInstance();
  final hasCompletedOnboarding = prefs.getBool("onboarding") ?? false;

  await LocalStorageService.init();
  await dotenv.load(fileName: ".env");
  await initializeDateFormatting('id_ID', null);

  final localStorage = LocalStorageService.instance;
  await Future.delayed(const Duration(milliseconds: 100));
  final isLoggedIn = localStorage.isLoggedIn;
  final userRole = localStorage.getUserRole();

  runApp(
    MyApp(
      hasCompletedOnboarding: hasCompletedOnboarding,
      isLoggedIn: isLoggedIn,
      userRole: userRole,
    ),
  );
  // Get.put<SessionService>(SessionService(prefs), permanent: true);

  //   runApp(MyApp(hasCompletedOnboarding: hasCompletedOnboarding));

  FlutterNativeSplash.remove();
}

class MyApp extends StatelessWidget {
  final bool hasCompletedOnboarding;
  final bool isLoggedIn;
  final String? userRole;
  const MyApp({
    super.key,
    this.hasCompletedOnboarding = false,
    required this.isLoggedIn,
    this.userRole,
  });

  String _getDashboardRoute() {
    switch (userRole?.toLowerCase()) {
      case 'field_owner':
      case 'field_manager':
        return AppRoutes.FIELD_MANAGER_NAVIGATION;
      case 'admin':
        return AppRoutes.FIELD_ADMIN_NAVIGATION;
      case 'user':
        return AppRoutes.CUSTOMER_NAVIGATION;
      default:
        return AppRoutes.FIELD_MANAGER_NAVIGATION; // fallback
    }
  }

  @override
  Widget build(BuildContext context) {
    String initialRoute;

    if (isLoggedIn) {
      // Jika sudah login, langsung ke dashboard sesuai role
      initialRoute = _getDashboardRoute();
    } else if (hasCompletedOnboarding) {
      // Jika sudah onboarding tapi belum login, ke login
      initialRoute = AppRoutes.LOGIN;
    } else {
      // Jika belum onboarding, ke onboarding
      initialRoute = AppRoutes.ONBOARDING;
    }

    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'LapanganKita',
      initialRoute: initialRoute,
      getPages: AppPages.pages,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary),
        useMaterial3: true,
      ),
    );
  }
}
