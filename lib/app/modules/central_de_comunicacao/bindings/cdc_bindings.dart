import 'package:get/get.dart';
import 'package:redescomunicacionais/app/modules/central_de_comunicacao/controller/cdc_controller.dart';

class CentralDeComunicacaoBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CentralDeComunicacaoController>(
        () => CentralDeComunicacaoController());
  }
}
