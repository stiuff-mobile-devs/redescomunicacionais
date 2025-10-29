import 'package:get/get.dart';
import 'package:redescomunicacionais/app/data/services/location_service.dart';
import 'package:redescomunicacionais/app/data/services/version_service.dart';
import 'package:redescomunicacionais/app/modules/user/controller/user_controller.dart';
import 'package:redescomunicacionais/app/modules/user/data/model/user_model.dart';
import 'package:redescomunicacionais/app/routes/app_routes.dart';

class HomeController extends GetxController {
  late final UserModel user;

  late final VersionService versionService;
  late final LocationService locationService;
  late final UserController userController;

  RxBool isLoadingLocation = false.obs;

  /// chave usada para forçar recriação de widgets
  final RxInt _recreateKey = 0.obs;
  int get recreateKey => _recreateKey.value;
  void forceRecreate() => _recreateKey.value++;

  @override
  Future<void> onInit() async {
    versionService = Get.find<VersionService>();
    locationService = Get.find<LocationService>();
    userController = Get.find<UserController>();
    user = await userController.getCurrentUser() ??
        UserModel(id: '', email: '', role: '', createdAt: null, status: '');
    isLoadingLocation.value = true;
    await locationService.requestLocation();
    isLoadingLocation.value = false;
    super.onInit();
  }

  void goInfo() {
    Get.toNamed(Routes.WEB_VIEW, arguments: {
      'url':
          'https://github.com/Redes-Comunicacionais-Locais/redescomunicacionais/wiki',
      'title': 'RCL'
    });
  }

  void goInfoTeam() {
    Get.toNamed(Routes.WEB_VIEW, arguments: {
      'url':
          'https://github.com/Redes-Comunicacionais-Locais/redescomunicacionais/wiki/Equipe',
      'title': 'RCL'
    });
  }

  void goProjectStructure() {
    Get.toNamed(Routes.WEB_VIEW, arguments: {
      'url':
          'https://github.com/Redes-Comunicacionais-Locais/redescomunicacionais/wiki/Estrutura-do-Projeto',
      'title': 'RCL'
    });
  }

  void goUserGuide() {
    Get.toNamed(Routes.WEB_VIEW, arguments: {
      'url': 'https://redescomunicacionaislocais.uff.br/guia-do-usuario/',
      'title': 'Guia do Usuário'
    });
  }

  void goInstallationConfig() {
    Get.toNamed(Routes.WEB_VIEW, arguments: {
      'url':
          'https://github.com/Redes-Comunicacionais-Locais/redescomunicacionais/wiki/Instala%C3%A7%C3%A3o-e-Configura%C3%A7%C3%A3o',
      'title': 'RCL'
    });
  }

  void goFAQ() {
    Get.toNamed(Routes.WEB_VIEW, arguments: {
      'url':
          'https://github.com/Redes-Comunicacionais-Locais/redescomunicacionais/wiki/Perguntas-Frequentes',
      'title': 'Perguntas Frequentes'
    });
  }

  void goPrivacyPolicy() {
    Get.toNamed(Routes.WEB_VIEW, arguments: {
      'url':
          'https://redescomunicacionaislocais.uff.br/politica-de-privacidade/',
      'title': 'RCL'
    });
  }

  void goAboutUs() {
    Get.toNamed(Routes.WEB_VIEW, arguments: {
      'url': 'https://redescomunicacionaislocais.uff.br/',
      'title': 'Sobre Nós',
    });
  }
}
