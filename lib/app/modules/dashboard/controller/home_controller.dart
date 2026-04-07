import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:get/get.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
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
  final RxString connectionTypeLabel = 'Sem conexão'.obs;

  RxBool isLoadingLocation = false.obs;
  RxBool isRevisionMode = false.obs;
  RxBool isDraftMode = false.obs;
  RxBool isMyDraftsMode = false.obs;
  RxBool isRejectedMode = false.obs;
  RxBool isDeletedMode = false.obs;
  final RxBool isOnline = false.obs;

  final Rxn<DateTime> lastConnectivityCheckAt = Rxn<DateTime>();
  final Rxn<DateTime> lastOnlineAt = Rxn<DateTime>();
  final RxInt minutesSinceLastOnline = 0.obs;

  Timer? _onlineTimer;
  Timer? _connectivityTimer;
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;

  final Connectivity _connectivity = Connectivity();

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

    await checkConnectivityStatus();
    _startConnectivityMonitor();
    _startOnlineTimer();

    super.onInit();
  }


  @override
  Future<void> onReady() async {
    // Revalida quando a Home fica visível.
    await checkConnectivityStatus();
    super.onReady();
  }

  @override
  void onClose() {
    _onlineTimer?.cancel();
    _connectivityTimer?.cancel();
    _connectivitySubscription?.cancel();
    super.onClose();
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

  Future<void> refreshDashboardData() async {
    try {
      await newsController.getNewsFromFirebase();
      forceRecreate();
    } finally {
      // Garante checagem real de conexão em todo pull-to-refresh.
      await checkConnectivityStatus();
    }
  }

  Future<void> checkConnectivityStatus() async {
    final connectivityResults = await _connectivity.checkConnectivity();
    final bool hasNetworkInterface =
        connectivityResults.any((result) => result != ConnectivityResult.none);

    bool hasInternetAccess = false;
    if (hasNetworkInterface) {
      hasInternetAccess = await InternetConnection().hasInternetAccess;
    }

    isOnline.value = hasInternetAccess;
    connectionTypeLabel.value = _mapConnectionType(connectivityResults);
    lastConnectivityCheckAt.value = DateTime.now();

    if (hasInternetAccess) {
      markOnlineNow();
      return;
    }

    final lastOnline = lastOnlineAt.value;
    minutesSinceLastOnline.value = lastOnline == null
        ? 999
        : DateTime.now().difference(lastOnline).inMinutes;
  }

  void markOnlineNow() {
    lastOnlineAt.value = DateTime.now();
    minutesSinceLastOnline.value = 0;
  }

  void _startOnlineTimer() {
    _onlineTimer?.cancel();
    _onlineTimer = Timer.periodic(const Duration(minutes: 1), (_) {
      final lastOnline = lastOnlineAt.value;
      if (lastOnline == null) {
        minutesSinceLastOnline.value = 999;
        return;
      }

      minutesSinceLastOnline.value =
          DateTime.now().difference(lastOnline).inMinutes;
    });
  }

  void _startConnectivityMonitor() {
    _connectivitySubscription?.cancel();
    _connectivitySubscription =
        _connectivity.onConnectivityChanged.listen((_) async {
      await checkConnectivityStatus();
    });

    _connectivityTimer?.cancel();
    _connectivityTimer = Timer.periodic(const Duration(minutes: 5), (_) async {
      await checkConnectivityStatus();
    });
  }

  String _mapConnectionType(List<ConnectivityResult> connectivityResults) {
    if (connectivityResults.contains(ConnectivityResult.wifi)) {
      return 'Wi-Fi';
    }

    if (connectivityResults.contains(ConnectivityResult.mobile)) {
      return 'Dados móveis';
    }

    if (connectivityResults.contains(ConnectivityResult.ethernet)) {
      return 'Ethernet';
    }

    if (connectivityResults.contains(ConnectivityResult.bluetooth)) {
      return 'Bluetooth';
    }

    if (connectivityResults.contains(ConnectivityResult.vpn)) {
      return 'VPN';
    }

    if (connectivityResults.contains(ConnectivityResult.other)) {
      return 'Outra rede';
    }

    return 'Sem conexão';
  }
}
