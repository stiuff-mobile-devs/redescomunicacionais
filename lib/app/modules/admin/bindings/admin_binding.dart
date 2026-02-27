import 'package:get/get.dart';
import 'package:redescomunicacionais/app/modules/admin/controller/admin_controller.dart';

class AdminBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AdminController>(() => AdminController());
  }
}
