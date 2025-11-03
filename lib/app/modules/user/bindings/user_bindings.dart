import 'package:get/get.dart';
import 'package:redescomunicacionais/app/modules/user/controller/user_controller.dart';

class UserBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut<UserController>(() => UserController());
  }
}
