import 'package:get/get.dart';
import 'package:redescomunicacionais/app/modules/dashboard/controller/home_controller.dart';
import 'package:redescomunicacionais/app/modules/utils/news/news_list_mode.dart';
import 'package:redescomunicacionais/app/routes/app_routes.dart';

class NewsCenterController extends GetxController {
  late HomeController _homeController;

  @override
  void onInit() {
    _homeController = Get.find<HomeController>();
    super.onInit();
  }

  // Abre a Home editorial já filtrada. É empilhada sobre a central, então o
  // "voltar" (seta da AppBar ou do sistema) retorna para cá, e a Home do feed
  // público não é afetada.
  void openNewsMode(NewsListMode mode) {
    _homeController.editorialMode.value = mode;
    Get.toNamed(
      Routes.HOME,
      arguments: {'editorial': true},
      preventDuplicates: false,
    );
  }
}
