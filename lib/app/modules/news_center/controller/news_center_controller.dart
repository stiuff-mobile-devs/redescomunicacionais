import 'package:get/get.dart';
import 'package:redescomunicacionais/app/modules/dashboard/controller/home_controller.dart';
import 'package:redescomunicacionais/app/modules/news/controller/news_controller.dart';
import 'package:redescomunicacionais/app/modules/utils/news/news_list_mode.dart';
import 'package:redescomunicacionais/app/routes/app_routes.dart';

class NewsCenterController extends GetxController {
  late HomeController _homeController;
  late NewsController _newsController;

  @override
  void onInit() {
    _homeController = Get.find<HomeController>();
    _newsController = Get.find<NewsController>();
    super.onInit();
  }

  // Quantidade de matérias de cada lista da central. Lê as listas reativas
  // do NewsController (montadas do Hive), então atualiza sozinho num Obx.
  int countFor(NewsListMode mode) => _newsController.getNewsForMode(mode).length;

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
