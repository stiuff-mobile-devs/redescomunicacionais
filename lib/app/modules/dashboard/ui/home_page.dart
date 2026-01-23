import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:redescomunicacionais/app/modules/dashboard/controller/home_controller.dart';
import 'package:redescomunicacionais/app/modules/login/controller/login_controller.dart';
import 'package:redescomunicacionais/app/modules/news/ui/news_windows.page.dart';
import 'package:redescomunicacionais/app/routes/app_routes.dart';
import 'package:redescomunicacionais/app/utils/responsive_utils.dart';
import 'package:redescomunicacionais/app/utils/theme/color_pallete.dart';
import 'package:redescomunicacionais/app/utils/theme/menu_drawer.dart';

class HomePage extends GetView<HomeController> {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    // Logicas de responsividade
    final Size screenSize = MediaQuery.of(context).size;
    final double screenWidth = screenSize.width;
    final double screenHeight = screenSize.height;
    final bool isTablet = ResponsiveUtils.isTablet(screenWidth);
    final bool useHorizontalLayout =
        ResponsiveUtils.shouldUseHorizontalLayout(screenWidth, screenHeight);

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
              centerTitle: true,
              elevation: isTablet ? 8.0 : 4.0,
              foregroundColor: Colors.white,
              title: FittedBox(
                fit: BoxFit.scaleDown,
                child: Obx(() => Text(
                      controller.isRevisionMode.value
                          ? "Revisão de Matérias"
                          : "Redes Comunicacionais Locais",
                      style: TextStyle(
                        fontSize: appBarTitleSize,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    )),
              ),
              shape: const RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.vertical(bottom: Radius.circular(10)),
              ),
              flexibleSpace: Container(
                decoration: BoxDecoration(
                  gradient: AppColors.appBarTopGradient(),
                ),
              ),
              iconTheme: IconThemeData(
                color: Colors.white,
                size: iconSize,
              ),
              toolbarHeight: isTablet ? 70.0 : 56.0,
              actions: [
                Obx(() => controller.isRevisionMode.value
                    ? IconButton(
                        onPressed: () {
                          controller.isRevisionMode.value = false;
                        },
                        icon:
                            const Icon(Icons.arrow_back, color: Colors.orange),
                      )
                    : const SizedBox.shrink()),
                IconButton(
                  iconSize: iconSize,
                  icon: const Icon(Icons.help_outline),
                  onPressed: () {
                    controller.goUserGuide();
                  },
                ),
                IconButton(
                  iconSize: iconSize,
                  icon: const Icon(Icons.search),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        TextEditingController searchController = TextEditingController();
                        return AlertDialog(
                          title: const Text('Filtrar Notícias'),
                          content: TextField(
                            controller: searchController,
                            decoration: const InputDecoration(
                              hintText: 'Digite o nome da notícia',
                            ),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child: const Text('Cancelar'),
                            ),
                            TextButton(
                              onPressed: () {
                                controller.filterNewsByName(searchController.text);
                                Navigator.of(context).pop();
                              },
                              child: const Text('Filtrar'),
                            ),
                          ],
                        );
                      },
                    );
                  },
                ),
              ],
            ),
      drawer: useHorizontalLayout ? null : MenuPage(),
      body: RefreshIndicator(
        onRefresh: () async {
          await controller.newsController.getNewsFromFirebase();
          controller.forceRecreate();
        },
        child: Obx(
          () => controller.isLoadingLocation.value
              ? Container(
                  decoration: BoxDecoration(
                    gradient: AppColors.darkBlueToBlackGradient(),
                  ),
                  child: const Center(
                    child: CircularProgressIndicator(),
                  ),
                )
              : useHorizontalLayout
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
        ),
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
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Obx(() => Text(
                        controller.locationService.city.value,
                        style: TextStyle(
                          fontSize: bottomBarFontSize,
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      )),
                ),
              ),
            ),
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
      decoration: BoxDecoration(
        gradient: AppColors.darkBlueToBlackGradient(),
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
                  child: Obx(() => Text(
                        controller.isRevisionMode.value
                            ? "Revisão de Matérias"
                            : "Redes Comunicacionais Locais",
                        style: TextStyle(
                          fontSize: isTablet ? 16.0 : 14.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      )),
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
                            backgroundImage: controller.user.urlImage != null
                                ? NetworkImage(controller.user.urlImage!)
                                : NetworkImage(
                                    'https://cdn.business2community.com/wp-content/uploads/2017/08/blank-profile-picture-973460_640.png'),
                          ),
                          SizedBox(width: isTablet ? 12.0 : 8.0),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  controller.user.name ?? 'Usuário RCL',
                                  style: TextStyle(
                                    fontSize: isTablet ? 12.0 : 10.0,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  controller.user.email,
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
                        // Ajuda
                        _buildMenuTile(
                          icon: Icons.help_outline,
                          title: "Ajuda",
                          onTap: () => controller.goUserGuide(),
                          iconSize: iconSize,
                          isTablet: isTablet,
                        ),
                        
                        // Filtrar Notícias
                        _buildMenuTile(
                          icon: Icons.search,
                          title: "Filtrar Notícias",
                          onTap: () {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                TextEditingController searchController = TextEditingController();
                                return AlertDialog(
                                  title: const Text('Filtrar Notícias'),
                                  content: TextField(
                                    controller: searchController,
                                    decoration: const InputDecoration(
                                      hintText: 'Digite o nome da notícia',
                                    ),
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                      child: const Text('Cancelar'),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        controller.filterNewsByName(searchController.text);
                                        Navigator.of(context).pop();
                                      },
                                      child: const Text('Filtrar'),
                                    ),
                                  ],
                                );
                              },
                            );
                          },
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
                          controller.userController
                              .loadUserRole(controller.user.email);
                          return _buildMenuTile(
                            icon: controller.userController.isAdmin.value ||
                                    controller.userController.isEditor.value
                                ? Icons.article_outlined
                                : Icons.lock_outline,
                            title: "Criar Matéria",
                            onTap: (controller.userController.isAdmin.value ||
                                    controller.userController.isEditor.value)
                                ? () => Get.toNamed(Routes.CREATE_NEWS)
                                : null,
                            iconSize: iconSize,
                            isTablet: isTablet,
                            iconColor: (controller
                                        .userController.isAdmin.value ||
                                    controller.userController.isEditor.value)
                                ? Colors.white
                                : Colors.red,
                          );
                        }),

                        // Admin (com verificação de permissão)
                        Obx(() {
                          controller.userController
                              .loadUserRole(controller.user.email);
                          return _buildMenuTile(
                            icon: controller.userController.isAdmin.value
                                ? Icons.person_outline
                                : Icons.lock_outline,
                            title: "Admin",
                            onTap: controller.userController.isAdmin.value
                                ? () => Get.toNamed(Routes.ADMIN)
                                : null,
                            iconSize: iconSize,
                            isTablet: isTablet,
                            iconColor: controller.userController.isAdmin.value
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
                            controller.locationService.city.value,
                            style: TextStyle(
                              fontSize: isTablet ? 12.0 : 10.0,
                              color: Colors.white.withOpacity(0.8),
                              fontWeight: FontWeight.w500,
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ))
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Lado direito - Conteúdo principal
          Expanded(
            child: NewsWindowsPage(
              key: ValueKey(controller.recreateKey),
              isRevisionMode: controller.isRevisionMode,
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
    return Container(
      decoration: BoxDecoration(
        gradient: AppColors.darkBlueToBlackGradient(),
      ),
      child: NewsWindowsPage(
        key: ValueKey(controller.recreateKey),
        isRevisionMode: controller.isRevisionMode,
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
                  controller.goAboutUs();
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
                  controller.goUserGuide();
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
                  controller.goFAQ();
                },
              ),
              const SizedBox(height: 16),
              Center(
                child: Text(
                  'Versão: ${controller.versionService.version}',
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
}
