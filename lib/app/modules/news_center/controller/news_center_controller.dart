import 'package:get/get.dart';
import 'package:redescomunicacionais/app/modules/dashboard/controller/home_controller.dart';
import 'package:redescomunicacionais/app/routes/app_routes.dart';

class NewsCenterController extends GetxController {

  late HomeController _homeController;

  @override
  void onInit() {
    _homeController = Get.find<HomeController>();
    super.onInit();
  }
  void openNewsMode(String mode) {
    switch (mode) {
      case 'revision':
        _homeController.isRevisionMode.value = true;
        _homeController.isDraftMode.value = false;
        _homeController.isRejectedMode.value = false;
        _homeController.isDeletedMode.value = false;
        break;
      case 'drafts':
        _homeController.isRevisionMode.value = false;
        _homeController.isDraftMode.value = true;
        _homeController.isRejectedMode.value = false;
        _homeController.isDeletedMode.value = false;
        break;
      case 'rejected':
        _homeController.isRevisionMode.value = false;
        _homeController.isDraftMode.value = false;
        _homeController.isRejectedMode.value = true;
        _homeController.isDeletedMode.value = false;
        break;
      case 'deleted':
        _homeController.isRevisionMode.value = false;
        _homeController.isDraftMode.value = false;
        _homeController.isRejectedMode.value = false;
        _homeController.isDeletedMode.value = true;
        break;
    }
    Get.toNamed(Routes.HOME);
  }

 
}
