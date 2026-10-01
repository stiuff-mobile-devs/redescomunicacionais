import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:redescomunicacionais/app/modules/dashboard/controller/home_controller.dart';
import 'package:redescomunicacionais/app/modules/mesh/console_page.dart';
import 'package:redescomunicacionais/app/routes/app_routes.dart';
import 'package:redescomunicacionais/app/modules/news/ui/news_widgets.dart';
import 'package:redescomunicacionais/app/utils/responsive_utils.dart';
import 'package:redescomunicacionais/app/utils/theme/color_pallete.dart';
import 'package:redescomunicacionais/app/modules/dashboard/utils/menu_drawer.dart';
import 'package:redescomunicacionais/app/utils/theme/theme_controller.dart';
import 'package:redescomunicacionais/app/utils/widgets/city_selector_widget.dart';

class HomePage extends GetView<HomeController> {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    // Lógicas de responsividade
    final Size screenSize = MediaQuery.of(context).size;
    final double screenWidth = screenSize.width;
    final double screenHeight = screenSize.height;
    final bool isTablet = ResponsiveUtils.isTablet(screenWidth);
    final bool useHorizontalLayout =
        ResponsiveUtils.shouldUseHorizontalLayout(screenWidth, screenHeight);

    double appBarTitleSize = ResponsiveUtils.calculateAppBarTitleSize(
        screenWidth, isTablet, useHorizontalLayout).clamp(16.0, 24.0);
    double iconSize = ResponsiveUtils.calculateIconSize(screenWidth, isTablet).clamp(20.0, 28.0);
    ResponsiveUtils.calculateBottomBarHeight(screenHeight, isTablet);
    ResponsiveUtils.calculateBottomBarFontSize(screenWidth, isTablet);

    final theme = Theme.of(context);

    return Scaffold(
      appBar: useHorizontalLayout
          ? null
          : AppBar(
              centerTitle: false,
              elevation: isTablet ? 8.0 : 4.0,
              foregroundColor: theme.colorScheme.onSurface,
              titleSpacing: isTablet ? 16.0 : 12.0,
              title: Obx(() {
                final titleText = controller.isRevisionMode.value
                    ? 'news_review'.tr
                    : controller.isDraftMode.value
                        ? 'Meus Rascunhos'.tr
                        : controller.isRejectedMode.value
                            ? 'Matérias rejeitadas'.tr
                            : controller.isDeletedMode.value
                                ? 'Matérias excluídas'.tr
                                : 'app_short_name'.tr;
                return Text(
                  titleText,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: appBarTitleSize,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                );
              }),
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(bottom: Radius.circular(10)),
              ),
              flexibleSpace: Get.find<ThemeController>().isLight
                  ? null
                  : Container(
                      decoration: BoxDecoration(
                        gradient: AppColors.appBarBottomGradient(),
                      ),
                    ),
              iconTheme: IconThemeData(
                color: theme.colorScheme.onSurface,
                size: iconSize,
              ),
              toolbarHeight: isTablet ? 82.0 : 74.0,
              actions: [
                Obx(() => controller.isRevisionMode.value ||
                        controller.isDraftMode.value ||
                        controller.isRejectedMode.value ||
                        controller.isDeletedMode.value
                    ? IconButton(
                        onPressed: () {
                          controller.isRevisionMode.value = false;
                          controller.isDraftMode.value = false;
                          controller.isRejectedMode.value = false;
                          controller.isDeletedMode.value = false;
                          controller.isPublishedMode.value = true;
                        },
                        icon: const Icon(Icons.arrow_back, color: Colors.orange),
                      )
                    : const SizedBox.shrink()),
                Obx(() {
                  final conn = controller.connectionsController;
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: IconButton(
                      onPressed: () => Get.toNamed(Routes.CONNECTIONS),
                      icon: Icon(
                        Icons.wifi,
                        color: conn.isInternetConnected.value
                            ? Colors.green
                            : Colors.red,
                        size: iconSize,
                      ),
                    ),
                  );
                }),
                IconButton(
                  iconSize: iconSize,
                  icon: const Icon(Icons.search),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        TextEditingController searchController = TextEditingController();
                        return AlertDialog(
                          title: Text('filter_news'.tr),
                          content: TextField(
                            controller: searchController,
                            decoration: InputDecoration(
                              hintText: 'enter_news_name'.tr,
                            ),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(),
                              child: Text('cancel'.tr),
                            ),
                            TextButton(
                              onPressed: () {
                                controller.filterNewsByName(searchController.text);
                                Navigator.of(context).pop();
                              },
                              child: Text('filter'.tr),
                            ),
                          ],
                        );
                      },
                    );
                  },
                ),
                IconButton(
                  iconSize: iconSize,
                  icon: const Icon(Icons.help_outline),
                  onPressed: () {
                    controller.goUserGuide();
                  },
                ),
              ],
            ),
      drawer: !useHorizontalLayout ? MenuPage() : null,
      
      // === BOTÃO FLUTUANTE QUE ABRE A TELA DO CONSOLE ===
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Get.to(() => const ConsolePage()), // Navega para a página dedicada
        icon: const Icon(Icons.bug_report),
        label: const Text('Console Mesh'),
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
      ),

      body: RefreshIndicator(
        onRefresh: () async {
          await controller.refreshDashboardData();
        },
        child: Obx(() {
          if (controller.selectedCity.value == null) {
            return Container(
              width: double.infinity,
              height: double.infinity,
              decoration: Get.find<ThemeController>().isLight 
              ? BoxDecoration(color: theme.scaffoldBackgroundColor)
              : BoxDecoration(
                gradient: AppColors.darkBlueToBlackGradient(),
              ),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      'Escolha a Cidade para Visualizar as Matérias'.tr,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 20,
                        color: theme.colorScheme.onSurface,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          controller.updateSelectedCity('Todas');
                        },
                        icon: const Icon(Icons.public, color: Colors.white),
                        label: const Text(
                          'Visualizar todas as cidades',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blueAccent.withOpacity(0.8),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: CitySelectorWidget(
                      onCitySelected: (String cityName) {
                        debugPrint('Cidade selecionada na Home: $cityName');
                        controller.updateSelectedCity(cityName);
                      },
                    ),
                  ),
                ],
              ),
            );
          }

          return useHorizontalLayout
              ? _buildHorizontalLayout(
                  context,
                  screenWidth,
                  screenHeight,
                  isTablet,
                  appBarTitleSize,
                  iconSize,
                )
              : _buildVerticalLayout(context);
        }),
      ),
    );
  }

  Widget _buildHorizontalLayout(
    BuildContext context,
    double screenWidth,
    double screenHeight,
    bool isTablet,
    double appBarTitleSize,
    double iconSize,
  ) {
    return Container(
      decoration: Get.find<ThemeController>().isLight 
      ? BoxDecoration(color: Theme.of(context).scaffoldBackgroundColor)
      : BoxDecoration(
        gradient: AppColors.darkBlueToBlackGradient(),
      ),
      child: Row(
        children: [
          Container(
            width: screenWidth * (isTablet ? 0.25 : 0.2),
            decoration: BoxDecoration(
              color: Get.find<ThemeController>().isLight ? Colors.transparent : Colors.black.withOpacity(0.3),
              border: Border(
                right: BorderSide(
                  color: Get.find<ThemeController>().isLight ? Colors.grey.shade300 : Colors.white.withOpacity(0.2),
                  width: 1.0,
                ),
              ),
            ),
            child: Stack(
              children: [
                MenuPage(
                  isHorizontal: true,
                  iconSize: iconSize,
                  isTablet: isTablet,
                ),
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    padding: EdgeInsets.all(isTablet ? 15.0 : 10.0),
                    decoration: BoxDecoration(
                      border: Border(
                        top: BorderSide(
                          color: Get.find<ThemeController>().isLight ? Colors.grey.shade300 : Colors.white.withOpacity(0.2),
                          width: 1.0,
                        ),
                      ),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextButton.icon(
                          onPressed: () => controller.updateSelectedCity(null),
                          icon: Icon(
                            Icons.arrow_back, 
                            color: Get.find<ThemeController>().isLight ? Colors.black54 : Colors.white70, 
                            size: 16
                          ),
                          label: Text(
                            'Trocar Cidade',
                            style: TextStyle(
                              fontSize: isTablet ? 12.0 : 10.0,
                              color: Get.find<ThemeController>().isLight ? Colors.black87 : Colors.white.withOpacity(0.8),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Column(
              children: [
                _buildCityIndicatorHeader(context),
                Expanded(
                  child: NewsWidgets(
                    key: ValueKey(controller.recreateKey),
                    selectedCity: controller.selectedCity.value,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVerticalLayout(BuildContext context) {
    return Container(
      color: Get.find<ThemeController>().isLight
          ? Colors.white
          : null,
      decoration: Get.find<ThemeController>().isLight
          ? null
          : BoxDecoration(
        gradient: AppColors.darkBlueToBlackGradient(),
      ),
      child: Column(
        children: [
          _buildCityIndicatorHeader(context),
          Expanded(
            child: NewsWidgets(
              key: ValueKey(controller.recreateKey),
              selectedCity: controller.selectedCity.value,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCityIndicatorHeader(BuildContext context) {
    final isLight = Get.find<ThemeController>().isLight;
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      color: isLight ? Colors.grey.shade200 : Colors.black.withOpacity(0.3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const Icon(Icons.location_on, color: Colors.blueAccent, size: 18),
              const SizedBox(width: 6),
              Text(
                'Cidade: ${controller.selectedCity.value}',
                style: TextStyle(
                  color: isLight ? Colors.black87 : Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          TextButton.icon(
            onPressed: () {
              controller.updateSelectedCity(null); 
            },
            icon: Icon(
              Icons.swap_horiz, 
              color: isLight ? Colors.black54 : Colors.white70, 
              size: 16
            ),
            label: Text(
              'Alterar',
              style: TextStyle(
                color: isLight ? Colors.black54 : Colors.white70, 
                fontSize: 13
              ),
            ),
          ),
        ],
      ),
    );
  }
}