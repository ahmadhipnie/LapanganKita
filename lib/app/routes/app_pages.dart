import 'package:get/get.dart';
import 'package:lapangan_kita/app/bindings/onboarding_binding.dart';
import 'package:lapangan_kita/app/modules/onboarding/onboarding_view.dart';
import '../modules/login/login_view.dart';
import '../modules/login/login_controller.dart';
import '../bindings/login_binding.dart';
import 'app_routes.dart';
import '../modules/login/login_view.dart';
import '../bindings/login_binding.dart';
import 'app_routes.dart';
import '../modules/register/register_view.dart';
import '../bindings/register_binding.dart';
import '../modules/register/customer_register_view.dart';
import '../bindings/customer_register_binding.dart';
import '../modules/register/fieldManager_register_view.dart';
import '../bindings/fieldManager_register_binding.dart';

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
    GetPage(
      name: AppRoutes.REGISTER,
      page: () => RegisterView(),
      binding: RegisterBinding(),
    ),
    GetPage(
      name: AppRoutes.CUSTOMER_REGISTER,
      page: () => CustomerRegisterView(),
      binding: CustomerRegisterBinding(),
    ),
    GetPage(
      name: AppRoutes.FIELD_MANAGER_REGISTER,
      page: () => FieldManagerRegisterView(),
      binding: FieldManagerRegisterBinding(),
    ),
  ];
}
