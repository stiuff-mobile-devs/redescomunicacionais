import 'package:get/get.dart';
import 'package:redescomunicacionais/app/services/version_service.dart';

class VersionBindings implements Bindings {
  @override
  Future<void> dependencies() async {
    // Registra a instância do serviço primeiro
    final versionService = VersionService();
    Get.put<VersionService>(versionService, permanent: true);

    // Depois chama a inicialização (aguarde se for assíncrono)
    await versionService.init();
  }
}
