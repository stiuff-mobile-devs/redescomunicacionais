import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:redescomunicacionais/app/modules/dashboard/controller/home_controller.dart';
import 'package:redescomunicacionais/app/modules/login/controller/login_controller.dart';
import 'package:redescomunicacionais/app/modules/user/utils/userRoles.dart';
import 'package:redescomunicacionais/app/routes/app_routes.dart';
import 'package:redescomunicacionais/app/utils/theme/color_pallete.dart';
import 'package:redescomunicacionais/app/utils/theme/theme_controller.dart';
import 'package:redescomunicacionais/app/utils/translations/app_translations.dart';
import 'package:redescomunicacionais/app/utils/translations/locale_keys.dart';

class MenuPage extends GetView<HomeController> {
  final bool isHorizontal;
  final double? iconSize;
  final bool? isTablet;

  const MenuPage({
    super.key,
    this.isHorizontal = false,
    this.iconSize,
    this.isTablet = false,
  });

  // Nome do idioma no idioma atual (ex.: "Inglês (EUA)")
  String _localeLabel(Locale locale) =>
      (AppTranslation.localeLabelKeys[locale.toString()] ?? '').tr;

  @override
  Widget build(BuildContext context) {
    return GetBuilder<HomeController>(
      builder: (_) {
        return isHorizontal
            ? _buildHorizontalMenu(context)
            : _buildDrawerMenu(context);
      },
    );
  }

  Widget _buildDrawerMenu(BuildContext context) {
    final theme = Theme.of(context);
    final themeController = Get.find<ThemeController>();
    final isLight = themeController.isLight;

    return Drawer(
      child: Container(
        decoration: isLight
            ? BoxDecoration(
          color: theme.scaffoldBackgroundColor,
        )
            : BoxDecoration(
          gradient: AppColors.darkBlueToBlackGradient(),
        ),
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              child: InkWell(
                // Abre o perfil do usuário (convidado não tem perfil)
                onTap: controller.isAnonymousUser
                    ? null
                    : () {
                        Get.back();
                        Get.toNamed(Routes.USER);
                      },
                borderRadius: BorderRadius.circular(12),
                child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor:
                    theme.colorScheme.surfaceContainerHighest,
                    backgroundImage: NetworkImage(
                      _profileImageUrl,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _profileName,
                          style: TextStyle(
                            fontSize: 13.0,
                            color: theme.colorScheme.onSurface,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Montserrat',
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          _profileEmail,
                          style: TextStyle(
                            fontSize: 10.0,
                            color: theme.colorScheme.onSurfaceVariant,
                            fontStyle: FontStyle.italic,
                            fontFamily: 'Montserrat',
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  if (!controller.isAnonymousUser)
                    Icon(
                      Icons.chevron_right,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                ],
              ),
              ),
            ),

            // ADMIN
            _buildAdminItem(
              context,
              isDrawer: true,
            ),

            // CENTRAL DA MATÉRIA
            _buildRestrictedMenuItem(
              context,
              icon: Icons.newspaper,
              title: LocaleKeys.newsCenter.tr,
              onTap: () => Get.toNamed(Routes.NEWSCENTER),
            ),

            // CENTRAL DE COMUNICAÇÃO
            if (!controller.isAnonymousUser)
              ListTile(
                leading: Icon(
                  Icons.chat_bubble_outline,
                  color: theme.colorScheme.onSurface,
                ),
                title: Text(
                  LocaleKeys.communicationCenter.tr,
                  style: TextStyle(
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                onTap: () {
                  Get.back();
                  Get.toNamed(
                    Routes.CENTRAL_DE_COMUNICACAO,
                  );
                },
              ),

            // TEMA
            ListTile(
              leading: Icon(
                Icons.palette_outlined,
                color: theme.colorScheme.onSurface,
              ),
              title: Text(
                LocaleKeys.theme.tr,
                style: TextStyle(
                  color: theme.colorScheme.onSurface,
                ),
              ),
              onTap: () {
                _showThemeSelector(context);
              },
            ),

            // CONEXÕES
            ListTile(
              leading: Icon(
                Icons.wifi,
                color: theme.colorScheme.onSurface,
              ),
              title: Text(
                LocaleKeys.connections.tr,
                style: TextStyle(
                  color: theme.colorScheme.onSurface,
                ),
              ),
              onTap: () {
                Get.back();
                Get.toNamed(Routes.CONNECTIONS);
              },
            ),

            // SOBRE
            ListTile(
              leading: Icon(
                Icons.info_outline,
                color: theme.colorScheme.onSurface,
              ),
              title: Text(
                LocaleKeys.about.tr,
                style: TextStyle(
                  color: theme.colorScheme.onSurface,
                ),
              ),
              onTap: () {
                Get.back();
                _showAboutDialog(context);
              },
            ),

            // IDIOMA
            ListTile(
              leading: Icon(
                Icons.language,
                color: theme.colorScheme.onSurface,
              ),
              title: Text(
                LocaleKeys.language.tr,
                style: TextStyle(
                  color: theme.colorScheme.onSurface,
                ),
              ),
              trailing: DropdownButtonHideUnderline(
                child: DropdownButton<Locale>(
                  dropdownColor: theme.colorScheme.surface,
                  value: AppTranslation.currentLocale,
                  iconEnabledColor: theme.colorScheme.onSurface,
                  style: TextStyle(
                    color: theme.colorScheme.onSurface,
                  ),
                  items: AppTranslation.supportedLocales
                      .map((locale) => DropdownMenuItem(
                            value: locale,
                            child: Text(_localeLabel(locale)),
                          ))
                      .toList(),
                  onChanged: (newValue) {
                    if (newValue != null) {
                      AppTranslation.changeLocale(newValue);
                    }
                  },
                ),
              ),
            ),

            // SAIR
            ListTile(
              leading: Icon(
                controller.isAnonymousUser
                    ? Icons.login
                    : Icons.exit_to_app,
                color: theme.colorScheme.onSurface,
              ),
              title: Text(
                controller.isAnonymousUser
                    ? LocaleKeys.login.tr
                    : LocaleKeys.logout.tr,
                style: TextStyle(
                  color: theme.colorScheme.onSurface,
                ),
              ),
              onTap: () {
                Get.back();

                if (controller.isAnonymousUser) {
                  Get.toNamed(Routes.LOGIN);
                } else {
                  LoginController().logout();
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHorizontalMenu(BuildContext context) {
    final theme = Theme.of(context);
    final isLight = Get.find<ThemeController>().isLight;

    return Column(
      children: [
        Container(
          padding: EdgeInsets.symmetric(
            vertical: isTablet! ? 15.0 : 12.0,
            horizontal: isTablet! ? 15.0 : 10.0,
          ),
          child: Column(
            children: [
              InkWell(
                // Abre o perfil do usuário (convidado não tem perfil)
                onTap: controller.isAnonymousUser
                    ? null
                    : () => Get.toNamed(Routes.USER),
                borderRadius: BorderRadius.circular(12),
                child: Row(
                children: [
                  CircleAvatar(
                    radius: isTablet! ? 25 : 20,
                    backgroundColor: theme.colorScheme.surfaceContainerHighest,
                    backgroundImage: NetworkImage(_profileImageUrl),
                  ),
                  SizedBox(width: isTablet! ? 12.0 : 8.0),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _profileName,
                          style: TextStyle(
                            fontSize: isTablet! ? 12.0 : 10.0,
                            color: theme.colorScheme.onSurface,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          _profileEmail,
                          style: TextStyle(
                            fontSize: isTablet! ? 10.0 : 8.0,
                            color: theme.colorScheme.onSurfaceVariant,
                            fontStyle: FontStyle.italic,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  if (!controller.isAnonymousUser)
                    Icon(
                      Icons.chevron_right,
                      size: iconSize,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                ],
              ),
              ),
              SizedBox(height: isTablet! ? 15.0 : 10.0),
              Divider(
                color: theme.colorScheme.outline.withOpacity(0.3),
                thickness: 1.0,
              ),
            ],
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: isTablet! ? 10.0 : 8.0,
            ),
            child: Column(
              children: [
                SizedBox(height: isTablet! ? 10.0 : 8.0),
                _buildHorizontalMenuTile(
                  icon: Icons.help_outline,
                  title: LocaleKeys.help.tr,
                  onTap: () => controller.goUserGuide(),
                ),
                _buildHorizontalMenuTile(
                  icon: Icons.search,
                  title: LocaleKeys.filterNews.tr,
                  onTap: () => _showFilterDialog(context),
                ),
                SizedBox(height: isTablet! ? 15.0 : 10.0),
                Divider(
                  color: theme.colorScheme.outline.withOpacity(0.2),
                  thickness: 0.5,
                ),
                SizedBox(height: isTablet! ? 15.0 : 10.0),
                _buildAdminItem(context, isDrawer: false),
                SizedBox(height: isTablet! ? 15.0 : 10.0),
                Divider(
                  color: theme.colorScheme.outline.withOpacity(0.2),
                  thickness: 0.5,
                ),
                SizedBox(height: isTablet! ? 15.0 : 10.0),
                _buildRestrictedHorizontalMenuTile(
                  icon: Icons.newspaper,
                  title: LocaleKeys.newsCenter.tr,
                  onTap: () => Get.toNamed(Routes.NEWSCENTER),
                ),
                if (!controller.isAnonymousUser)
                  _buildHorizontalMenuTile(
                    icon: Icons.chat_bubble_outline,
                    title: LocaleKeys.communicationCenter.tr,
                    onTap: () => Get.toNamed(Routes.CENTRAL_DE_COMUNICACAO),
                  ),

                _buildHorizontalMenuTile(
                  icon: Icons.palette_outlined,
                  title: LocaleKeys.theme.tr,
                  onTap: () => _showThemeSelector(context),
                ),

                _buildHorizontalMenuTile(
                  icon: Icons.language,
                  title: LocaleKeys.language.tr,
                  onTap: () => _showLanguageDialog(context),
                ),
                _buildHorizontalMenuTile(
                  icon: controller.isAnonymousUser
                      ? Icons.login
                      : Icons.exit_to_app,
                  title: controller.isAnonymousUser
                      ? LocaleKeys.login.tr
                      : LocaleKeys.logout.tr,
                  onTap: () {
                    if (controller.isAnonymousUser) {
                      Get.toNamed(Routes.LOGIN);
                    } else {
                      LoginController().logout();
                    }
                  },
                  iconColor: Colors.red,
                ),
                SizedBox(height: isTablet! ? 20.0 : 15.0),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAdminItem(BuildContext context, {required bool isDrawer}) {
    if (controller.user.role != UserRoles.admin) {
      return const SizedBox.shrink();
    }

    if (isDrawer) {
      return ListTile(
        leading: Icon(
          Icons.person_outline,
          color: Theme.of(context).colorScheme.onSurface,
        ),
        title: Text(
          LocaleKeys.admin.tr,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        onTap: () {
          Get.back();
          Get.toNamed(Routes.ADMIN);
        },
      );
    }

    return _buildHorizontalMenuTile(
      icon: Icons.person_outline,
      title: LocaleKeys.admin.tr,
      onTap: () => Get.toNamed(Routes.ADMIN),
    );
  }

  Widget _buildRestrictedMenuItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    if (controller.user.role != UserRoles.admin &&
        controller.user.role != UserRoles.editor) {
      return const SizedBox.shrink();
    }

    return ListTile(
      leading: Icon(
        icon,
        color: Theme.of(context).colorScheme.onSurface,
      ),
      title: Text(
        title,
        style: TextStyle(
          color: Theme.of(context).colorScheme.onSurface,
        ),
      ),
      onTap: () {
        Get.back();
        onTap();
      },
    );
  }

  Widget _buildRestrictedHorizontalMenuTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    if (controller.user.role != UserRoles.admin &&
        controller.user.role != UserRoles.editor) {
      return const SizedBox.shrink();
    }

    return _buildHorizontalMenuTile(
      icon: icon,
      title: title,
      onTap: onTap,
    );
  }

  Widget _buildHorizontalMenuTile({
    required IconData icon,
    required String title,
    VoidCallback? onTap,
    Color? iconColor,
  }) {
    final theme = Theme.of(Get.context!);

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(
          vertical: isTablet! ? 10.0 : 8.0,
          horizontal: isTablet! ? 8.0 : 6.0,
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: iconColor ?? theme.colorScheme.onSurface,
              size: iconSize,
            ),
            SizedBox(width: isTablet! ? 12.0 : 10.0),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  color: theme.colorScheme.onSurface,
                  fontSize: isTablet! ? 12.0 : 11.0,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showThemeSelector(BuildContext context) {
    final themeController = Get.find<ThemeController>();

    Get.bottomSheet(
      SafeArea(
        child: Material(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(20),
          ),
          child: Obx(
                () => Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 16),

                Text(
                  LocaleKeys.chooseTheme.tr,
                  style: Theme.of(context).textTheme.titleLarge,
                ),

                const SizedBox(height: 16),

                RadioListTile<bool>(
                  value: false,
                  groupValue: themeController.isLight,
                  title: Text(LocaleKeys.themeClassic.tr),
                  subtitle: Text(LocaleKeys.themeClassicDescription.tr),
                  onChanged: (_) {
                    themeController.setClassicTheme();
                    Get.back();
                  },
                ),

                RadioListTile<bool>(
                  value: true,
                  groupValue: themeController.isLight,
                  title: Text(LocaleKeys.themeLight.tr),
                  subtitle: Text(LocaleKeys.themeLightDescription.tr),
                  onChanged: (_) {
                    themeController.setWhiteTheme();
                    Get.back();
                  },
                ),

                const SizedBox(height: 8),
              ],
            ),
          ),
        ),
      ),
      isScrollControlled: true,
    );
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        final theme = Theme.of(context);

        return AlertDialog(
          backgroundColor: theme.colorScheme.surface,
          title: Text(
            LocaleKeys.about.tr,
            style: TextStyle(
              color: theme.colorScheme.onSurface,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.info, color: Colors.blue),
                title: Text(
                  LocaleKeys.whoWeAre.tr,
                  style: TextStyle(
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                onTap: () {
                  Get.back();
                  controller.goAboutUs();
                },
              ),
              ListTile(
                leading: const Icon(Icons.book, color: Colors.blue),
                title: Text(
                  LocaleKeys.userGuide.tr,
                  style: TextStyle(
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                onTap: () {
                  Get.back();
                  controller.goUserGuide();
                },
              ),
              ListTile(
                leading: const Icon(Icons.help, color: Colors.blue),
                title: Text(
                  LocaleKeys.faq.tr,
                  style: TextStyle(
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                onTap: () {
                  Get.back();
                  controller.goFAQ();
                },
              ),
              const SizedBox(height: 16),
              Center(
                child: Obx(
                  () => Text(
                    LocaleKeys.versionLabel
                        .trParams({'version': controller.appVersion.value}),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showFilterDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        final TextEditingController searchController = TextEditingController();
        return AlertDialog(
          title: Text(LocaleKeys.filterNews.tr),
          content: TextField(
            controller: searchController,
            decoration: InputDecoration(
              hintText: LocaleKeys.enterNewsName.tr,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Get.back();
              },
              child: Text(LocaleKeys.cancel.tr),
            ),
            TextButton(
              onPressed: () {
                controller.filterNewsByName(searchController.text);
                Get.back();
              },
              child: Text(LocaleKeys.filter.tr),
            ),
          ],
        );
      },
    );
  }

  void _showLanguageDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        final theme = Theme.of(context);

        return AlertDialog(
          backgroundColor: theme.colorScheme.surface,
          title: Text(
            LocaleKeys.language.tr,
            style: TextStyle(
              color: theme.colorScheme.onSurface,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: AppTranslation.supportedLocales
                .map((locale) =>
                    _buildLanguageOption(_localeLabel(locale), locale))
                .toList(),
          ),
        );
      },
    );
  }

  Widget _buildLanguageOption(String label, Locale locale) {
    final theme = Theme.of(Get.context!);

    return InkWell(
      onTap: () {
        AppTranslation.changeLocale(locale);
        Get.back();
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Text(
          label,
          style: TextStyle(
            color: theme.colorScheme.onSurface,
          ),
        ),
      ),
    );
  }

  String get _profileName {
    // O convidado tem nome fixo gravado no modelo; mostra o texto traduzido
    if (controller.isAnonymousUser) {
      return LocaleKeys.rclUser.tr;
    }

    final name = controller.user.name?.trim();
    if (name != null && name.isNotEmpty) {
      return name;
    }

    return controller.user.email!;
  }

  String get _profileEmail {
    if (controller.isAnonymousUser) {
      return LocaleKeys.guest.tr;
    }

    return controller.user.email!;
  }

  String get _profileImageUrl {
    final imageUrl = controller.user.urlImage?.trim();
    if (imageUrl != null && imageUrl.isNotEmpty) {
      return imageUrl;
    }

    return 'https://cdn.business2community.com/wp-content/uploads/2017/08/blank-profile-picture-973460_640.png';
  }
}
