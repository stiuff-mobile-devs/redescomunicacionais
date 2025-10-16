import 'package:get/get.dart';
import 'package:redescomunicacionais/app/data/services/location_service.dart';
import 'package:redescomunicacionais/app/modules/dashboard/controller/home_controller.dart';

class HomeBinding implements Bindings {
  @override
  void dependencies() {
    Get.put(LocationService(), permanent: true);
    Get.lazyPut<HomeController>(() => HomeController());
  }
}
