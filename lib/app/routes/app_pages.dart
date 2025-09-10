import 'package:get/get.dart';
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
  ];
}
