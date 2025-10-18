import 'package:get/get.dart';
import 'package:redescomunicacionais/app/data/services/version_service.dart';

class SplashBindings implements Bindings {
  @override
  void dependencies() async {
    Get.put(() => VersionService().init(), permanent: true);
  }
}
