import 'package:get/get.dart';
import 'package:redescomunicacionais/app/modules/mesh/security/package_service.dart';
import 'package:redescomunicacionais/app/modules/news/controller/news_controller.dart';
import 'package:redescomunicacionais/app/modules/news/controller/news_form_controller.dart';

class NewsBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut<NewsController>(() => NewsController());
    Get.lazyPut<OfflinePackageService>(() => OfflinePackageService());
  }
}

// Só nas rotas do formulário (criar/editar): cada abertura ganha um
// controller novo, que é descartado ao sair da tela
class NewsFormBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut<NewsFormController>(() => NewsFormController());
  }
}
