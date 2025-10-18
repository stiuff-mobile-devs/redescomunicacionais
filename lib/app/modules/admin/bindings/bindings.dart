import 'package:get/get.dart';
import 'package:redescomunicacionais/app/modules/admin/controller/controller.dart';

class AdminCRUDBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AdminCRUDController>(() => AdminCRUDController());
  }
}
