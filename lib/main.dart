import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:get/get.dart';
import 'package:lapangan_kita/app/themes/color_theme.dart';
import 'package:lapangan_kita/app/data/services/session_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app/routes/app_pages.dart';
import 'app/routes/app_routes.dart';

void main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  final prefs = await SharedPreferences.getInstance();
  final hasCompletedOnboarding = prefs.getBool("onboarding") ?? false;

  Get.put<SessionService>(SessionService(prefs), permanent: true);

  runApp(MyApp(hasCompletedOnboarding: hasCompletedOnboarding));

  FlutterNativeSplash.remove();
}

class MyApp extends StatelessWidget {
  final bool hasCompletedOnboarding;
  const MyApp({super.key, this.hasCompletedOnboarding = false});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'LapanganKita',
      initialRoute: hasCompletedOnboarding
          ? AppRoutes.LOGIN
          : AppRoutes.ONBOARDING,
      getPages: AppPages.pages,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary),
        useMaterial3: true,
      ),
    );
  }
}
