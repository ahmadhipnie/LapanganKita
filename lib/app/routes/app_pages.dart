import 'package:lapangan_kita/app/bindings/customer_booking_detail_binding.dart';
import 'package:lapangan_kita/app/bindings/fieldadmin_binding/fieldadmin_history_binding.dart';
import 'package:lapangan_kita/app/bindings/fieldadmin_binding/fieldadmin_navigation_binding.dart';
import 'package:lapangan_kita/app/bindings/fieldadmin_binding/fieldadmin_transaction_binding.dart';
import 'package:lapangan_kita/app/bindings/fieldadmin_binding/fieldadmin_withdraw_binding.dart';
import 'package:lapangan_kita/app/modules/booking/customer_booking_detail_view.dart';
import 'package:lapangan_kita/app/bindings/edit_field_fieldmanager_binding.dart';
import 'package:lapangan_kita/app/modules/edit_field_fieldmanager/edit_field_fieldmanager_view.dart';
import 'package:lapangan_kita/app/modules/edit_profile_fieldmanager/edit_profile_fieldmanager_view.dart';
import 'package:lapangan_kita/app/bindings/edit_profile_fieldmanager_binding.dart';
import 'package:lapangan_kita/app/modules/navigation/fieldadmin/fieldadmin_navigation_view.dart';
import 'package:lapangan_kita/app/modules/navigation/fieldadmin/tabs/fieldadmin_history_view.dart';
import 'package:lapangan_kita/app/modules/navigation/fieldadmin/tabs/fieldadmin_transaction_view.dart';
import 'package:lapangan_kita/app/modules/navigation/fieldadmin/tabs/fieldadmin_withdraw_view.dart';
import 'package:lapangan_kita/app/modules/navigation/fieldmanager/fieldmanager_navigation_view.dart';
import 'package:lapangan_kita/app/bindings/fieldmanager_tabs_binding.dart';
import 'package:lapangan_kita/app/bindings/fieldmanager_navigation_binding.dart';
import 'package:get/get.dart';
import 'package:lapangan_kita/app/bindings/customer_booking_binding.dart';
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
      bindings: [FieldManagerNavigationBinding(), FieldManagerTabsBinding()],
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
    GetPage(
      name: AppRoutes.EDIT_PROFILE_FIELD_MANAGER,
      page: () => EditProfileFieldmanagerView(),
      binding: EditProfileFieldmanagerBinding(),
    ),
    // Edit Field (Field Manager)
    GetPage(
      name: AppRoutes.EDIT_FIELD_FIELDMANAGER,
      page: () => const EditFieldFieldmanagerView(),
      binding: EditFieldFieldmanagerBinding(),
    ),
    GetPage(
      name: AppRoutes.CUSTOMER_BOOKING_DETAIL,
      page: () => CustomerBookingDetailView(),
      binding: CustomerBookingDetailBinding(),
    ),
    GetPage(
      name: AppRoutes.FIELD_ADMIN_NAVIGATION,
      page: () => FieldadminNavigationView(),
      binding: FieldadminNavigationBinding(),
    ),
    GetPage(
      name: AppRoutes.FIELD_ADMIN_WITHDRAW,
      page: () => FieldadminWithdrawView(),
      binding: FieldadminWithdrawBinding(),
    ),
    GetPage(
      name: AppRoutes.FIELD_ADMIN_TRANSACTION,
      page: () => FieldadminTransactionView(),
      binding: FieldadminTransactionBinding(),
    ),
    GetPage(
      name: AppRoutes.FIELD_ADMIN_HISTORY,
      page: () => FieldadminHistoryView(),
      binding: FieldadminHistoryBinding(),
    ),
  ];
}
