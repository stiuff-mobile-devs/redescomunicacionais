import 'package:get/get.dart';
import 'package:redescomunicacionais/app/modules/login/controller/login_controller.dart';

class LoginBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut<LoginController>(() => LoginController());
  }
}