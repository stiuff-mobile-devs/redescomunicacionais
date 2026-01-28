import 'package:get/get.dart';
import 'package:redescomunicacionais/app/services/version_service.dart';

class VersionBindings implements Bindings {
  @override
  void dependencies() {
    // Registra o serviço usando Get.putAsync para aguardar a inicialização
    Get.putAsync<VersionService>(
      () async => await VersionService().init(),
      permanent: true,
    );
  }
}
