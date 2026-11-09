import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:redescomunicacionais/app/modules/dashboard/controller/home_controller.dart';
import 'package:redescomunicacionais/app/modules/mesh/console_page.dart';
import 'package:redescomunicacionais/app/routes/app_routes.dart';
import 'package:redescomunicacionais/app/modules/news/ui/news_widgets.dart';
import 'package:redescomunicacionais/app/modules/utils/responsive_utils.dart';
import 'package:redescomunicacionais/app/modules/utils/app_bar/app_bars.dart';
import 'package:redescomunicacionais/app/modules/utils/news/news_list_mode.dart';
import 'package:redescomunicacionais/app/modules/utils/theme/color_pallete.dart';
import 'package:redescomunicacionais/app/modules/utils/dashboard/menu_drawer.dart';
import 'package:redescomunicacionais/app/modules/utils/theme/theme_controller.dart';
import 'package:redescomunicacionais/app/modules/utils/translations/locale_keys.dart';
import 'package:redescomunicacionais/app/modules/utils/widgets/city_selector_widget.dart';

class HomePage extends GetView<HomeController> {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    // A Home editorial (aberta pela central da matéria) recebe
    // {'editorial': true}. Lido da própria rota: com duas Homes na pilha,
    // cada uma mantém o seu modo.
    final routeArgs = ModalRoute.of(context)?.settings.arguments;
    final bool isEditorial = routeArgs is Map && routeArgs['editorial'] == true;

    // Lógicas de responsividade
    final Size screenSize = MediaQuery.of(context).size;
    final double screenWidth = screenSize.width;
    final double screenHeight = screenSize.height;
    final bool isTablet = ResponsiveUtils.isTablet(screenWidth);
    // O modo editorial usa sempre o layout vertical (o menu lateral é do feed)
    final bool useHorizontalLayout = !isEditorial &&
        ResponsiveUtils.shouldUseHorizontalLayout(screenWidth, screenHeight);

    double appBarTitleSize = ResponsiveUtils.calculateAppBarTitleSize(
        screenWidth, isTablet, useHorizontalLayout).clamp(16.0, 24.0);
    double iconSize = ResponsiveUtils.calculateIconSize(screenWidth, isTablet).clamp(20.0, 28.0);

    final theme = Theme.of(context);

    return Scaffold(
      appBar: isEditorial
          ? _buildEditorialAppBar(iconSize)
          : useHorizontalLayout
              ? null
              : AppBars.build(
                  title: LocaleKeys.appShortName.tr,
                  centerTitle: false,
                  actions: [
                    _buildConnectionAction(iconSize),
                    IconButton(
                      tooltip: LocaleKeys.filterNews.tr,
                      icon: const Icon(Icons.search),
                      onPressed: controller.openNewsFilter,
                    ),
                    IconButton(
                      tooltip: LocaleKeys.userGuide.tr,
                      icon: const Icon(Icons.help_outline),
                      onPressed: controller.goUserGuide,
                    ),
                  ],
                ),
      drawer: !useHorizontalLayout && !isEditorial ? MenuPage() : null,

      // === BOTÃO FLUTUANTE QUE ABRE A TELA DO CONSOLE ===
      floatingActionButton: isEditorial
          ? null
          : FloatingActionButton.extended(
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
          if (!isEditorial && controller.selectedCity.value == null) {
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
                      LocaleKeys.chooseCityToViewNews.tr,
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
                        label: Text(
                          LocaleKeys.viewAllCities.tr,
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
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
              : _buildVerticalLayout(context, isEditorial);
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
                            LocaleKeys.changeCity.tr,
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

  Widget _buildVerticalLayout(BuildContext context, bool isEditorial) {
    final mode =
        isEditorial ? controller.editorialMode.value : NewsListMode.published;

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
          if (!isEditorial)
            _buildCityIndicatorHeader(context)
          else if (controller.selectedCity.value != null)
            _buildCityIndicatorHeader(context, showChangeButton: false),
          Expanded(
            // Troca suave da lista ao mudar o filtro editorial
            child: AnimatedSwitcher(
              duration: AppBars.toneAnimation,
              child: NewsWidgets(
                key: ValueKey('${controller.recreateKey}-${mode.name}'),
                selectedCity: controller.selectedCity.value,
                mode: mode,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // AppBar da Home editorial: seta para voltar à central, cor do modo e
  // filtros para trocar de lista sem sair da tela
  PreferredSizeWidget _buildEditorialAppBar(double iconSize) {
    PreferredSizeWidget build(NewsListMode mode) => AppBars.build(
          title: mode.title,
          tone: mode.tone,
          leading: IconButton(
            tooltip: LocaleKeys.backToNewsCenter.tr,
            icon: const Icon(Icons.arrow_back_rounded),
            onPressed: () => Get.back(),
          ),
          actions: [_buildConnectionAction(iconSize)],
          bottom: _EditorialModeFilter(controller: controller),
        );

    return PreferredSize(
      preferredSize: build(controller.editorialMode.value).preferredSize,
      child: Obx(() => build(controller.editorialMode.value)),
    );
  }

  Widget _buildConnectionAction(double iconSize) {
    return Obx(() {
      final conn = controller.connectionsController;
      return IconButton(
        tooltip: LocaleKeys.connections.tr,
        onPressed: () => Get.toNamed(Routes.CONNECTIONS),
        icon: Icon(
          Icons.wifi,
          color: conn.isInternetConnected.value
              ? Colors.greenAccent
              : Colors.redAccent,
          size: iconSize,
        ),
      );
    });
  }

  Widget _buildCityIndicatorHeader(BuildContext context,
      {bool showChangeButton = true}) {
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
                LocaleKeys.cityLabel.trParams({
                  // 'Todas' é o valor interno de "sem filtro"
                  'city': controller.selectedCity.value == 'Todas'
                      ? LocaleKeys.allCities.tr
                      : controller.selectedCity.value ?? '',
                }),
                style: TextStyle(
                  color: isLight ? Colors.black87 : Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          if (showChangeButton)
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
              LocaleKeys.change.tr,
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

// Filtros da Home editorial (Em revisão · Rascunhos · Rejeitadas · Excluídas)
class _EditorialModeFilter extends StatelessWidget
    implements PreferredSizeWidget {
  const _EditorialModeFilter({required this.controller});

  final HomeController controller;

  @override
  Size get preferredSize => const Size.fromHeight(52);

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;

    return SizedBox(
      height: preferredSize.height,
      child: Obx(() {
        final current = controller.editorialMode.value;
        final foreground = AppBars.foregroundColor(current.tone, brightness);

        return ListView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.fromLTRB(12, 0, 12, 10),
          children: NewsListMode.editorialModes.map((mode) {
            final bool selected = mode == current;
            final Color contentColor =
                selected ? mode.tone.color : foreground;

            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ChoiceChip(
                selected: selected,
                showCheckmark: false,
                onSelected: (_) => controller.editorialMode.value = mode,
                avatar: Icon(mode.icon, size: 18, color: contentColor),
                label: Text(mode.shortLabel),
                labelStyle: TextStyle(
                  color: contentColor,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                ),
                backgroundColor: foreground.withValues(alpha: 0.12),
                selectedColor: Colors.white,
                side: BorderSide(color: foreground.withValues(alpha: 0.25)),
                shape: const StadiumBorder(),
                visualDensity: VisualDensity.compact,
              ),
            );
          }).toList(),
        );
      }),
    );
  }
}
