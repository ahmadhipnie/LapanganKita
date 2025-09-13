import 'package:lapangan_kita/app/modules/navigation/fieldmanager/fieldmanager_navigation_view.dart';
import 'package:lapangan_kita/app/bindings/fieldmanager_navigation_binding.dart';
import 'package:get/get.dart';
import 'package:lapangan_kita/app/bindings/customer_booking.dart';
import 'package:lapangan_kita/app/bindings/customer_community_binding.dart';
import 'package:lapangan_kita/app/bindings/customer_history_binding.dart';
import 'package:lapangan_kita/app/bindings/customer_home_binding.dart';
import 'package:lapangan_kita/app/bindings/customer_navigation_binding.dart';
import 'package:lapangan_kita/app/bindings/customer_profile.dart';
import 'package:lapangan_kita/app/bindings/onboarding_binding.dart';
import 'package:lapangan_kita/app/bindings/otp_binding.dart';
import 'package:lapangan_kita/app/modules/booking/customer_booking_view.dart';
import 'package:lapangan_kita/app/modules/community/customer_community_view.dart';
import 'package:lapangan_kita/app/modules/history/customer_history_view.dart';
import 'package:lapangan_kita/app/modules/home/customer_home_view.dart';
import 'package:lapangan_kita/app/modules/navigation/customer_navigation_view.dart';
import 'package:lapangan_kita/app/modules/onboarding/onboarding_view.dart';
import 'package:lapangan_kita/app/modules/profile/customer_profile_view.dart';
import 'package:lapangan_kita/app/modules/register/otp_view.dart';
import '../modules/login/login_view.dart';
import '../bindings/login_binding.dart';
import 'app_routes.dart';
import '../modules/register/register_view.dart';
import '../bindings/register_binding.dart';
import '../modules/register/customer_register_view.dart';
import '../bindings/customer_register_binding.dart';

import '../modules/register/fieldManager_register_view.dart';
import '../bindings/fieldManager_register_binding.dart';

import '../modules/place/place_form_view.dart';
import '../bindings/place_form_binding.dart';
import '../modules/field/field_add_view.dart';
import '../bindings/field_add_binding.dart';

class AppPages {
  static final pages = <GetPage>[
    GetPage(
      name: AppRoutes.FIELD_MANAGER_NAVIGATION,
      page: () => FieldManagerNavigationView(),
      binding: FieldManagerNavigationBinding(),
    ),
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
    GetPage(name: AppRoutes.OTP, page: () => OtpView(), binding: OTPBinding()),
    GetPage(
      name: AppRoutes.PLACE_FORM,
      page: () => PlaceFormView(),
      binding: PlaceFormBinding(),
    ),
    GetPage(
      name: AppRoutes.FIELD_ADD,
      page: () => FieldAddView(),
      binding: FieldAddBinding(),
    ),
    GetPage(
      name: AppRoutes.CUSTOMER_NAVIGATION,
      page: () => CustomerNavigationView(),
      binding: CustomerNavigationBinding(),
    ),
    GetPage(
      name: AppRoutes.CUSTOMER_HOME,
      page: () => CustomerHomeView(),
      binding: CustomerHomeBinding(),
    ),
    GetPage(
      name: AppRoutes.CUSTOMER_BOOKING,
      page: () => CustomerBookingView(),
      binding: CustomerBookingBinding(),
    ),
    GetPage(
      name: AppRoutes.CUSTOMER_COMMUNITY,
      page: () => CustomerCommunityView(),
      binding: CustomerCommunityBinding(),
    ),
    GetPage(
      name: AppRoutes.CUSTOMER_HISTORY,
      page: () => CustomerHistoryView(),
      binding: CustomerHistoryBinding(),
    ),
    GetPage(
      name: AppRoutes.CUSTOMER_PROFILE,
      page: () => CustomerProfileView(),
      binding: CustomerProfileBinding(),
    ),
  ];
}
