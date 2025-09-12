import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:redescomunicacionais/app/modules/dashboard/controller/home_controller.dart';
import 'package:redescomunicacionais/app/controller/location_controller.dart';
import 'package:redescomunicacionais/app/modules/news/controller/news_controller.dart';
import 'package:redescomunicacionais/app/modules/login/controller/login_controller.dart';
import 'package:redescomunicacionais/app/modules/user/controller/user_controller.dart';
import 'package:redescomunicacionais/app/controller/version_controller.dart';
import 'package:redescomunicacionais/app/services/device_detector_service.dart';
import 'package:redescomunicacionais/app/utils/responsive_utils.dart';
import 'package:redescomunicacionais/app/modules/news/utils/news_widget.dart';
import 'package:redescomunicacionais/app/utils/theme/menu_drawer.dart';
import 'package:redescomunicacionais/app/routes/app_routes.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final HomeController _homeController = Get.put(HomeController());
  final LocationController _locationController = Get.put(LocationController());
  final UserController _userController = Get.put(UserController());
  final VersionController _versionController = Get.put(VersionController());
  final DeviceDetectorService deviceDetector = DeviceDetectorService.instance;
  int timeRefresh = 30; // Intervalo de refresh automático em minutos

  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();

  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    _startAutoRefresh();
  }

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    final double screenWidth = screenSize.width;
    final double screenHeight = screenSize.height;
    final bool isTablet = ResponsiveUtils.isTablet(screenWidth);
    final bool useHorizontalLayout =
        ResponsiveUtils.shouldUseHorizontalLayout(screenWidth, screenHeight);

    // Calcula tamanhos responsivos usando a classe utilitária
    double appBarTitleSize = ResponsiveUtils.calculateAppBarTitleSize(
        screenWidth, isTablet, useHorizontalLayout);
    double iconSize = ResponsiveUtils.calculateIconSize(screenWidth, isTablet);
    double bottomBarHeight =
        ResponsiveUtils.calculateBottomBarHeight(screenHeight, isTablet);
    double bottomBarFontSize =
        ResponsiveUtils.calculateBottomBarFontSize(screenWidth, isTablet);

    return Scaffold(
      appBar: useHorizontalLayout
          ? null
          : AppBar(
              title: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  "Redes Comunicacionais Locais",
                  style: TextStyle(
                    fontSize: appBarTitleSize,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              iconTheme: IconThemeData(
                color: Colors.white,
                size: iconSize,
              ),
              centerTitle: true,
              elevation: isTablet ? 8.0 : 4.0,
              toolbarHeight: isTablet ? 70.0 : 56.0,
              actions: [
                IconButton(
                  iconSize: iconSize,
                  icon: const Icon(Icons.cloud_queue),
                  onPressed: () {
                    _showSyncDialog(context);
                  },
                ),
                IconButton(
                  iconSize: iconSize,
                  icon: const Icon(Icons.help_outline),
                  onPressed: () {
                    _homeController.goUserGuide();
                  },
                ),
              ],
            ),
      drawer: useHorizontalLayout ? null : MenuPage(),
      body: useHorizontalLayout
          ? _buildHorizontalLayout(
              context,
              screenWidth,
              screenHeight,
              isTablet,
              appBarTitleSize,
              iconSize,
            )
          : _buildVerticalLayout(
              context,
              screenHeight,
              isTablet,
            ),
      bottomNavigationBar: useHorizontalLayout
          ? null
          : Container(
              color: Colors.black,
              height: bottomBarHeight,
              padding: EdgeInsets.symmetric(
                horizontal: screenWidth * (isTablet ? 0.05 : 0.02),
                vertical: isTablet ? 8.0 : 4.0,
              ),
              child: Center(
                child: Obx(() => FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        _locationController.city.value,
                        style: TextStyle(
                          fontSize: bottomBarFontSize,
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    )),
              ),
            ),
    );
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  void _startAutoRefresh() {
    _refreshTimer = Timer.periodic(Duration(minutes: timeRefresh), (timer) {
      _onRefreshSilent();
    });
  }

  Future<void> _onRefreshSilent() async {
    try {
      await _locationController.getUserLocation();

      try {
        final newsController = Get.find<NewsController>();
        await newsController.getNewsFromFirebase();
      } catch (e) {
        // NewsController ainda não foi inicializado, ignore
      }

      if (mounted) {
        setState(() {});
      }
    } catch (e) {
      // Falha silenciosa para não incomodar o usuário
      print("Erro no refresh automático: $e");
    }
  }

  Future<void> _onRefresh() async {
    try {
      // Sempre atualiza a localização no refresh manual
      // Se a localização não está disponível, chama requestLocation que mostrará o popup
      if (_locationController.city.value.isEmpty ||
          _locationController.city.value == "Permissão negada" ||
          _locationController.city.value == "Erro ao obter localização") {
        bool locationResult = await _locationController.requestLocation();

        // Se o usuário escolheu "Sair", não continua com a atualização
        if (!locationResult) {
          return;
        }
      } else {
        // Se já tem localização, atualiza silenciosamente
        await _locationController.getUserLocation();
      }

      // Recarrega as notícias se o controller existir
      try {
        final newsController = Get.find<NewsController>();
        await newsController.getNewsFromFirebase();
      } catch (e) {
        // NewsController ainda não foi inicializado, ignore
      }

      // Força a reconstrução da interface
      setState(() {});
    } catch (e) {
      // Tratamento de erro geral
      Get.snackbar(
        'Erro',
        'Erro ao atualizar dados',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  void _showSyncDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return ResponsiveUtils.createResponsiveDialog(
          context: context,
          title: "Sincronismo",
          content: "Módulo em desenvolvimento, em breve teremos novidades.",
          onConfirm: () => Navigator.of(context).pop(),
          confirmText: "Fechar",
        );
      },
    );
  }

  // Layout horizontal para web e landscape
  Widget _buildHorizontalLayout(
    BuildContext context,
    double screenWidth,
    double screenHeight,
    bool isTablet,
    double appBarTitleSize,
    double iconSize,
  ) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [
            Colors.blue,
            Colors.black,
          ],
        ),
      ),
      child: Row(
        children: [
          // Lado esquerdo - AppBar vertical
          Container(
            width: screenWidth * (isTablet ? 0.25 : 0.2),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.3),
              border: Border(
                right: BorderSide(
                  color: Colors.white.withOpacity(0.2),
                  width: 1.0,
                ),
              ),
            ),
            child: Column(
              children: [
                // Título do aplicativo
                Container(
                  padding: EdgeInsets.symmetric(
                    vertical: isTablet ? 15.0 : 12.0,
                    horizontal: isTablet ? 15.0 : 10.0,
                  ),
                  child: Text(
                    "Redes Comunicacionais Locais",
                    style: TextStyle(
                      fontSize: isTablet ? 16.0 : 14.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),

                // Divisor após o título
                Divider(
                  color: Colors.white.withOpacity(0.3),
                  thickness: 1.0,
                  indent: isTablet ? 15.0 : 10.0,
                  endIndent: isTablet ? 15.0 : 10.0,
                ),

                // Header do sidebar com perfil do usuário
                Container(
                  padding: EdgeInsets.symmetric(
                    vertical: isTablet ? 15.0 : 12.0,
                    horizontal: isTablet ? 15.0 : 10.0,
                  ),
                  child: Column(
                    children: [
                      // Avatar e info do usuário
                      Row(
                        children: [
                          CircleAvatar(
                            radius: isTablet ? 25 : 20,
                            backgroundImage: NetworkImage(_homeController
                                    .user.urlImage ??
                                'https://cdn.business2community.com/wp-content/uploads/2017/08/blank-profile-picture-973460_640.png'),
                          ),
                          SizedBox(width: isTablet ? 12.0 : 8.0),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _homeController.user.name ?? '',
                                  style: TextStyle(
                                    fontSize: isTablet ? 12.0 : 10.0,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  _homeController.user.email,
                                  style: TextStyle(
                                    fontSize: isTablet ? 10.0 : 8.0,
                                    color: Colors.white70,
                                    fontStyle: FontStyle.italic,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: isTablet ? 15.0 : 10.0),
                      Divider(
                        color: Colors.white.withOpacity(0.3),
                        thickness: 1.0,
                      ),
                    ],
                  ),
                ),

                // Menu de opções
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.symmetric(
                      horizontal: isTablet ? 10.0 : 8.0,
                    ),
                    child: Column(
                      children: [
                        SizedBox(height: isTablet ? 10.0 : 8.0),

                        // Sincronismo
                        _buildMenuTile(
                          icon: Icons.cloud_queue,
                          title: "Sincronismo",
                          onTap: () => _showSyncDialog(context),
                          iconSize: iconSize,
                          isTablet: isTablet,
                        ),

                        // Ajuda
                        _buildMenuTile(
                          icon: Icons.help_outline,
                          title: "Ajuda",
                          onTap: () => _homeController.goUserGuide(),
                          iconSize: iconSize,
                          isTablet: isTablet,
                        ),

                        SizedBox(height: isTablet ? 15.0 : 10.0),
                        Divider(
                            color: Colors.white.withOpacity(0.2),
                            thickness: 0.5),
                        SizedBox(height: isTablet ? 15.0 : 10.0),

                        // Criar Notícia (com verificação de permissão)
                        Obx(() {
                          _userController
                              .loadUserRole(_homeController.user.email);
                          return _buildMenuTile(
                            icon: _userController.isAdmin.value ||
                                    _userController.isEditor.value
                                ? Icons.article_outlined
                                : Icons.lock_outline,
                            title: "Criar Matéria",
                            onTap: (_userController.isAdmin.value ||
                                    _userController.isEditor.value)
                                ? () => Navigator.pushNamed(
                                    context, Routes.CREATE_NEWS)
                                : null,
                            iconSize: iconSize,
                            isTablet: isTablet,
                            iconColor: (_userController.isAdmin.value ||
                                    _userController.isEditor.value)
                                ? Colors.white
                                : Colors.red,
                          );
                        }),

                        // Admin (com verificação de permissão)
                        Obx(() {
                          _userController
                              .loadUserRole(_homeController.user.email);
                          return _buildMenuTile(
                            icon: _userController.isAdmin.value
                                ? Icons.person_outline
                                : Icons.lock_outline,
                            title: "Admin",
                            onTap: _userController.isAdmin.value
                                ? () =>
                                    Navigator.pushNamed(context, Routes.ADMIN)
                                : null,
                            iconSize: iconSize,
                            isTablet: isTablet,
                            iconColor: _userController.isAdmin.value
                                ? Colors.white
                                : Colors.red,
                          );
                        }),

                        SizedBox(height: isTablet ? 15.0 : 10.0),
                        Divider(
                            color: Colors.white.withOpacity(0.2),
                            thickness: 0.5),
                        SizedBox(height: isTablet ? 15.0 : 10.0),

                        // Sobre
                        _buildMenuTile(
                          icon: Icons.info_outline,
                          title: "Sobre",
                          onTap: () => _showAboutDialog(context),
                          iconSize: iconSize,
                          isTablet: isTablet,
                        ),

                        // Sair
                        _buildMenuTile(
                          icon: Icons.exit_to_app,
                          title: "Sair",
                          onTap: () => LoginController().logout(),
                          iconSize: iconSize,
                          isTablet: isTablet,
                          iconColor: Colors.red,
                        ),

                        SizedBox(height: isTablet ? 20.0 : 15.0),
                      ],
                    ),
                  ),
                ),

                // Footer com localização
                Container(
                  padding: EdgeInsets.all(isTablet ? 15.0 : 10.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Divider(
                        color: Colors.white.withOpacity(0.3),
                        thickness: 1.0,
                      ),
                      SizedBox(height: isTablet ? 8.0 : 6.0),
                      Obx(() => Text(
                            _locationController.city.value,
                            style: TextStyle(
                              fontSize: isTablet ? 12.0 : 10.0,
                              color: Colors.white.withOpacity(0.8),
                              fontWeight: FontWeight.w500,
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          )),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Lado direito - Conteúdo principal
          Expanded(
            child: RefreshIndicator(
              key: _refreshIndicatorKey,
              onRefresh: _onRefresh,
              child: FutureBuilder(
                future: _locationController.requestLocation(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                      child: CircularProgressIndicator(
                        strokeWidth: isTablet ? 6.0 : 4.0,
                        color: Colors.white,
                      ),
                    );
                  } else if (snapshot.hasData && snapshot.data == true) {
                    return NewsWidget();
                  } else {
                    return _buildErrorState(context, screenHeight, isTablet);
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Layout vertical para mobile portrait
  Widget _buildVerticalLayout(
    BuildContext context,
    double screenHeight,
    bool isTablet,
  ) {
    return RefreshIndicator(
      key: _refreshIndicatorKey,
      onRefresh: _onRefresh,
      child: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
                colors: [
                  Colors.blue,
                  Colors.black,
                ],
              ),
            ),
          ),
          FutureBuilder(
            future: _locationController.requestLocation(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(
                  child: CircularProgressIndicator(
                    strokeWidth: isTablet ? 6.0 : 4.0,
                    color: Colors.white,
                  ),
                );
              } else if (snapshot.hasData && snapshot.data == true) {
                return NewsWidget();
              } else {
                return _buildErrorState(context, screenHeight, isTablet);
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMenuTile({
    required IconData icon,
    required String title,
    required VoidCallback? onTap,
    required double iconSize,
    required bool isTablet,
    Color? iconColor,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: iconColor ?? Colors.white,
        size: iconSize * 0.8,
      ),
      title: Text(
        title,
        style: TextStyle(
          color: Colors.white,
          fontSize: isTablet ? 13.0 : 11.0,
          fontWeight: FontWeight.w500,
        ),
      ),
      onTap: onTap,
      dense: true,
      contentPadding: EdgeInsets.symmetric(
        horizontal: isTablet ? 16.0 : 12.0,
        vertical: isTablet ? 4.0 : 2.0,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
      ),
      hoverColor: Colors.white.withOpacity(0.1),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.black,
          title: const Text(
            'Sobre',
            style: TextStyle(color: Colors.white),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.info, color: Colors.blue),
                title: const Text(
                  'Quem Somos?',
                  style: TextStyle(color: Colors.white),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _homeController.goAboutUs();
                },
              ),
              ListTile(
                leading: const Icon(Icons.book, color: Colors.blue),
                title: const Text(
                  'Guia do Usuário',
                  style: TextStyle(color: Colors.white),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _homeController.goUserGuide();
                },
              ),
              ListTile(
                leading: const Icon(Icons.help, color: Colors.blue),
                title: const Text(
                  'Perguntas Frequentes',
                  style: TextStyle(color: Colors.white),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _homeController.goFAQ();
                },
              ),
              const SizedBox(height: 16),
              Center(
                child: Text(
                  'Versão: ${_versionController.version}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildErrorState(
      BuildContext context, double screenHeight, bool isTablet) {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Container(
        height: screenHeight - (isTablet ? 250 : 200),
        padding: ResponsiveUtils.calculateResponsivePadding(
          MediaQuery.of(context).size.width,
          screenHeight,
          isTablet,
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.location_off,
                size: isTablet ? 80.0 : 60.0,
                color: Colors.white.withOpacity(0.7),
              ),
              SizedBox(height: isTablet ? 30.0 : 20.0),
              Text(
                "Localização não disponível",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: isTablet ? 24.0 : 20.0,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: isTablet ? 16.0 : 12.0),
              Text(
                "Verifique as permissões e tente novamente.\n\nArraste para baixo para tentar novamente.",
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: isTablet ? 16.0 : 14.0,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
