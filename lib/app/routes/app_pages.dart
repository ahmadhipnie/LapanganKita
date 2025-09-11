import 'package:get/get.dart';
import 'package:lapangan_kita/app/bindings/onboarding_binding.dart';
import 'package:lapangan_kita/app/modules/onboarding/onboarding_view.dart';
import '../modules/login/login_view.dart';
import '../modules/login/login_controller.dart';
import '../bindings/login_binding.dart';
import 'app_routes.dart';

class AppPages {
  static final pages = <GetPage>[
    GetPage(
      name: AppRoutes.LOGIN,
      page: () => LoginView(),
      binding: LoginBinding(),
    ),
    GetPage(
      name: AppRoutes.ONBOARDING,
      page: () => OnboardingView(),
      binding: OnboardingBinding(),
    ),
  ];
}
