import 'package:get/get.dart';
import 'package:redescomunicacionais/app/controller/location_controller.dart';
import 'package:redescomunicacionais/app/modules/user/data/model/user_model.dart';
import 'package:redescomunicacionais/app/routes/app_routes.dart';

class HomeController extends GetxController {
  final UserModel user = Get.arguments;
  final LocationController locationController = Get.put(LocationController());

  @override
  void onInit() {
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
