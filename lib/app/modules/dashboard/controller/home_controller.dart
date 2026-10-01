import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:redescomunicacionais/app/modules/mesh/services/nearby_service.dart';
import 'package:redescomunicacionais/app/modules/news/controller/news_controller.dart';
import 'package:redescomunicacionais/app/modules/news/data/repository/news_repository.dart';
import 'package:redescomunicacionais/app/modules/user/data/repository/user_repository.dart';
import 'package:redescomunicacionais/app/modules/user/data/model/user_model.dart';
import 'package:redescomunicacionais/app/modules/user/utils/userRoles.dart';
import 'package:redescomunicacionais/app/routes/app_routes.dart';
import 'package:redescomunicacionais/app/modules/connections/controller/connections_controller.dart';

class HomeController extends GetxController {
  NewsController? _newsController;
  NewsController get newsController =>
      _newsController ??= Get.find<NewsController>();

  late ConnectionsController connectionsController;

  final UserRepository _userRepository = UserRepository();
  final NewsRepository _newsRepository = NewsRepository();

  UserModel user = UserModel.empty();

  final RxString appVersion = 'Carregando...'.obs;
  final RxString connectionTypeLabel = 'Sem conexão'.obs;
  final RxnString selectedCity = RxnString(null);


  RxBool isRevisionMode = false.obs;
  RxBool isDraftMode = false.obs;
  RxBool isRejectedMode = false.obs;
  RxBool isDeletedMode = false.obs;
  RxBool isPublishedMode = true.obs;

  bool isAnonymousUser = true;

  /// chave usada para forçar recriação de widgets
  final RxInt _recreateKey = 0.obs;
  int get recreateKey => _recreateKey.value;
  void forceRecreate() => _recreateKey.value++;

  @override
  Future<void> onInit() async {
    connectionsController = Get.find<ConnectionsController>();
    user = await _userRepository.getCurrentUserFromHive();
    if (user.role == UserRoles.guest) {
      isAnonymousUser = true;
    } else {
      isAnonymousUser = false;
    }
    _loadPackageInfo();
    _checkSavedCity(); 
    super.onInit();
  }

  Future<void> _loadPackageInfo() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      appVersion.value = packageInfo.version;
    } catch (e) {
      appVersion.value = '--';
    }
  }

  void filterNewsByName(String name) {
    newsController.publishedNewsList.value = newsController.publishedNewsList
        .where((news) => news.title.toLowerCase().contains(name.toLowerCase()))
        .toList();
  }

  Future<void> refreshDashboardData() async {
    try {
      await _newsRepository.syncNewsHiveAndFirebase(user);
      await newsController.getPublicNewsFromHive(null);
      await newsController.getOuthersNewsFromHive();
      forceRecreate();
    } catch (e) {
      Get.snackbar(
        'Erro',
        'Não foi possível atualizar os dados. Verifique sua conexão.',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  void goUserGuide() {
    Get.toNamed(Routes.WEB_VIEW, arguments: {
      'url': 'https://redescomunicacionaislocais.uff.br/guia-do-usuario/',
      'title': 'Guia do Usuário'
    });
  }

  void goFAQ() {
    Get.toNamed(Routes.WEB_VIEW, arguments: {
      'url':
          'https://github.com/Redes-Comunicacionais-Locais/redescomunicacionais/wiki/Perguntas-Frequentes',
      'title': 'Perguntas Frequentes'
    });
  }

  void goAboutUs() {
    Get.toNamed(Routes.WEB_VIEW, arguments: {
      'url': 'https://redescomunicacionaislocais.uff.br/',
      'title': 'Sobre Nós',
    });
  }

   // Busca no Hive se o usuário já escolheu a cidade anteriormente
  Future<void> _checkSavedCity() async {
    UserModel currentUser = await _userRepository.getCurrentUserFromHive();
    
    if (currentUser.selectedAppCity != null && currentUser.selectedAppCity!.isNotEmpty) {
      selectedCity.value = currentUser.selectedAppCity;
      debugPrint("Cidade carregada automaticamente do Hive: ${selectedCity.value}");
    }
  }

  // Função para ser chamada pelos botões da interface (HomePage)
  Future<void> updateSelectedCity(String? cityName) async {
    selectedCity.value = cityName;
    
    if (cityName != null) {
      // Salva a nova cidade no Hive
      await _userRepository.saveLocalSelectedCity(cityName);
    } else {
      // Se passou null (clicou em voltar/alterar), limpa a cidade do Hive
      await _userRepository.clearLocalSelectedCity();
    }
  }

  // Método para iniciar os testes
  void initiateEpidemicNetwork() async {
    final nearbyService = Get.find<NearbyService>();
    
    // Inicia a rede passando um nome para o aparelho (útil para identificar nos testes)
    await nearbyService.startEpidemicMesh('Celular_Teste_01');
  }

  // Método para parar a rede após os testes
  void stopEpidemicSpread
() async {
    final nearbyService = Get.find<NearbyService>();
    await nearbyService.stopAll();
  }

}
