import 'package:get/get.dart';
import 'package:redescomunicacionais/app/modules/dashboard/controller/home_controller.dart';
import 'package:redescomunicacionais/app/modules/mesh/services/nearby_service.dart';

class HomeBinding implements Bindings {
  @override
  void dependencies() {
    //Get.put(LocationService(), permanent: true);
    Get.lazyPut<HomeController>(() => HomeController());
     Get.lazyPut<NearbyService>(() => NearbyService());
  }
}
