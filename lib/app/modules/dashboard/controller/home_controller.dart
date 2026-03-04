import 'package:get/get.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:redescomunicacionais/app/modules/news/controller/news_controller.dart';
import 'package:redescomunicacionais/app/services/location_service.dart';
import 'package:redescomunicacionais/app/modules/user/controller/user_controller.dart';
import 'package:redescomunicacionais/app/modules/user/data/model/user_model.dart';
import 'package:redescomunicacionais/app/routes/app_routes.dart';

class HomeController extends GetxController {
  late UserModel user;

  bool get isAnonymousUser => user.id.isEmpty && user.email.isEmpty;

  late LocationService locationService;
  late UserController userController;
  NewsController? _newsController;
  NewsController get newsController =>
      _newsController ??= Get.find<NewsController>();

  final RxString appVersion = 'Carregando...'.obs;

  RxBool isLoadingLocation = false.obs;
  RxBool isRevisionMode = false.obs;

  /// chave usada para forçar recriação de widgets
  final RxInt _recreateKey = 0.obs;
  int get recreateKey => _recreateKey.value;
  void forceRecreate() => _recreateKey.value++;

  @override
  Future<void> onInit() async {
    locationService = Get.find<LocationService>();
    userController = Get.find<UserController>();
    _loadPackageInfo();

    user = await userController.getCurrentUser();

    isLoadingLocation.value = true;
    await locationService.requestLocation(user);
    isLoadingLocation.value = false;

    super.onInit();
  }

  Future<void> _loadPackageInfo() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      appVersion.value = packageInfo.version;
    } catch (_) {
      appVersion.value = '--';
    }
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

  void filterNewsByName(String name) {
    newsController.newss.value = newsController.newss
        .where((news) => news.title.toLowerCase().contains(name.toLowerCase()))
        .toList();
  }
}
