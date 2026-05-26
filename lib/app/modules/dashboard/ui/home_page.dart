import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:redescomunicacionais/app/modules/dashboard/controller/home_controller.dart';
import 'package:redescomunicacionais/app/modules/connections/controller/connections_controller.dart';
import 'package:redescomunicacionais/app/routes/app_routes.dart';
import 'package:redescomunicacionais/app/modules/news/ui/news_windows.page.dart';
import 'package:redescomunicacionais/app/utils/responsive_utils.dart';
import 'package:redescomunicacionais/app/utils/theme/color_pallete.dart';
import 'package:redescomunicacionais/app/modules/dashboard/utils/menu_drawer.dart';
import 'package:redescomunicacionais/app/utils/widgets/blinking_loading_icon.dart';

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
              centerTitle: false,
              elevation: isTablet ? 8.0 : 4.0,
              foregroundColor: Colors.white,
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
                return Row(
                  children: [
                    SizedBox(width: isTablet ? 10.0 : 8.0),
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            titleText,
                            style: TextStyle(
                              fontSize: appBarTitleSize,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              }),
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
                          controller.isMyDraftsMode.value = false;
                        },
                        icon:
                            const Icon(Icons.arrow_back, color: Colors.orange),
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
                        color: conn.isInternetConnected.value ? Colors.green : Colors.red,
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
                        TextEditingController searchController =
                            TextEditingController();
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
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child: Text('cancel'.tr),
                            ),
                            TextButton(
                              onPressed: () {
                                controller
                                    .filterNewsByName(searchController.text);
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
      body: RefreshIndicator(
        onRefresh: () async {
          await controller.refreshDashboardData();
        },
        child: Obx(
          () => controller.isLoadingLocation.value
              ? Container(
                  decoration: BoxDecoration(
                    gradient: AppColors.darkBlueToBlackGradient(),
                  ),
                  child: const Center(
                    child: BlinkingLoadingIcon(
                      size: 38,
                      color: Colors.white,
                    ),
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
          // Menu responsivo para layout horizontal
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
            child: Stack(
              children: [
                MenuPage(
                  isHorizontal: true,
                  iconSize: iconSize,
                  isTablet: isTablet,
                ),
                // Footer com localização no final do sidebar
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    padding: EdgeInsets.all(isTablet ? 15.0 : 10.0),
                    decoration: BoxDecoration(
                      border: Border(
                        top: BorderSide(
                          color: Colors.white.withOpacity(0.2),
                          width: 1.0,
                        ),
                      ),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
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
                ),
              ],
            ),
          ),

          // Lado direito - Conteúdo principal
          Expanded(
            child: NewsWindowsPage(
              key: ValueKey(controller.recreateKey),
              isRevisionMode: controller.isRevisionMode,
              isDraftMode: controller.isDraftMode,
              isRejectedMode: controller.isRejectedMode,
              isDeletedMode: controller.isDeletedMode,
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
        isDraftMode: controller.isDraftMode,
        isRejectedMode: controller.isRejectedMode,
        isDeletedMode: controller.isDeletedMode,
      ),
    );
  }

 

 
}

