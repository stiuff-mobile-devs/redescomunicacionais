import 'package:get/get.dart';
import 'package:redescomunicacionais/app/modules/login/controller/login_controller.dart';

class SplashController extends GetxController {
  late final LoginController _loginController;
  @override
  void onInit() {
    _loginController = Get.find<LoginController>();
    _loginController.tryLogin();
    super.onInit();
  }
}
