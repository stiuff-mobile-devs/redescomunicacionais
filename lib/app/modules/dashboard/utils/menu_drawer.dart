import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:redescomunicacionais/app/modules/dashboard/controller/home_controller.dart';
import 'package:redescomunicacionais/app/modules/login/controller/login_controller.dart';
import 'package:redescomunicacionais/app/modules/user/controller/user_controller.dart';
import 'package:redescomunicacionais/app/routes/app_routes.dart';

class MenuPage extends StatelessWidget {
  final HomeController _homeController = Get.find<HomeController>();
  final UserController _userController = Get.find<UserController>();
  final bool isHorizontal;
  final double? iconSize;
  final bool? isTablet;

  MenuPage({
    super.key,
    this.isHorizontal = false,
    this.iconSize,
    this.isTablet = false,
  });

  static const List<Locale> _availableLocales = [
    Locale('pt', 'BR'),
    Locale('en', 'US'),
    Locale('it', 'IT'),
    Locale('es', 'ES'),
  ];

  Locale _safeCurrentLocale() {
    final current = Get.locale ?? Get.deviceLocale;
    return _availableLocales.firstWhere(
      (locale) =>
          locale.languageCode == current?.languageCode &&
          locale.countryCode == current?.countryCode,
      orElse: () => _availableLocales.first,
    );
  }

  @override
  Widget build(BuildContext context) {
    return isHorizontal
        ? _buildHorizontalMenu(context)
        : _buildDrawerMenu(context);
  }

  /// Menu para layout vertical (Drawer)
  Widget _buildDrawerMenu(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.black,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
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
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundImage: NetworkImage(_homeController.user.urlImage ??
                      'https://cdn.business2community.com/wp-content/uploads/2017/08/blank-profile-picture-973460_640.png'),
                ),
                const SizedBox(width: 16),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${_homeController.user.name}',
                      style: const TextStyle(
                        fontSize: 10.0,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Montserrat',
                      ),
                    ),
                    Text(
                      _homeController.user.email,
                      style: const TextStyle(
                        fontSize: 10.0,
                        color: Colors.white,
                        fontStyle: FontStyle.italic,
                        fontFamily: 'Montserrat',
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          _buildCreateNewsItem(context, isDrawer: true),
          _buildAdminItem(context, isDrawer: true),
        //  _buildReviewItem(context, isDrawer: true),
        //  _buildDraftsItem(context, isDrawer: true),
         ListTile(
            leading: const Icon(Icons.newspaper, color: Colors.white),
            title: Text(
              'Central da notícia'.tr,
              style: const TextStyle(color: Colors.white),
            ),
            onTap: () {
              Get.toNamed(Routes.NEWSCENTER);
            },
          ),
          ListTile(
            leading: const Icon(Icons.chat_bubble_outline, color: Colors.white),
            title: Text(
              'Central de Comnunicação'.tr,
              style: const TextStyle(color: Colors.white),
            ),
            onTap: () {
              Get.toNamed(Routes.CENTRAL_DE_COMUNICACAO);
            },
          ),
          ListTile(
            leading: const Icon(Icons.person_outline, color: Colors.white),
            title: Text(
              'Seus Dados'.tr,
              style: const TextStyle(color: Colors.white),
            ),
            onTap: () {
              Navigator.pop(context);
              Get.toNamed(Routes.USER);
            },
          ),
          ListTile(
            leading: const Icon(Icons.info_outline, color: Colors.white),
            title: Text(
              'Sobre'.tr,
              style: const TextStyle(color: Colors.white),
            ),
            onTap: () {
              Navigator.pop(context);
              _showAboutDialog(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.language, color: Colors.white),
            title: Text(
              'language'.tr,
              style: const TextStyle(color: Colors.white),
            ),
            trailing: DropdownButtonHideUnderline(
              child: DropdownButton<Locale>(
                dropdownColor: Colors.black,
                value: _safeCurrentLocale(),
                iconEnabledColor: Colors.white,
                style: const TextStyle(color: Colors.white),
                items: [
                  DropdownMenuItem(
                    value: const Locale('pt', 'BR'),
                    child: Text('language_portuguese_brazil'.tr),
                  ),
                  DropdownMenuItem(
                    value: const Locale('en', 'US'),
                    child: Text('language_english_us'.tr),
                  ),
                  DropdownMenuItem(
                    value: const Locale('it', 'IT'),
                    child: Text('language_italian'.tr),
                  ),
                  DropdownMenuItem(
                    value: const Locale('es', 'ES'),
                    child: Text('language_spanish'.tr),
                  ),
                ],
                onChanged: (newValue) {
                  if (newValue != null) {
                    Get.updateLocale(newValue);
                  }
                },
              ),
            ),
          ),
          ListTile(
            leading: Icon(
              _homeController.isAnonymousUser ? Icons.login : Icons.exit_to_app,
              color: Colors.white,
            ),
            title: Text(
              _homeController.isAnonymousUser ? 'Entrar'.tr : 'Sair'.tr,
              style: const TextStyle(color: Colors.white),
            ),
            onTap: () {
              LoginController().logout();
            },
          ),
        ],
      ),
    );
  }

  /// Menu para layout horizontal
  Widget _buildHorizontalMenu(BuildContext context) {
    return Column(
      children: [
        // Header com perfil
        Container(
          padding: EdgeInsets.symmetric(
            vertical: isTablet! ? 15.0 : 12.0,
            horizontal: isTablet! ? 15.0 : 10.0,
          ),
          child: Column(
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: isTablet! ? 25 : 20,
                    backgroundImage: _homeController.user.urlImage != null
                        ? NetworkImage(_homeController.user.urlImage!)
                        : const NetworkImage(
                            'https://cdn.business2community.com/wp-content/uploads/2017/08/blank-profile-picture-973460_640.png'),
                  ),
                  SizedBox(width: isTablet! ? 12.0 : 8.0),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _homeController.user.name ?? 'rcl_user'.tr,
                          style: TextStyle(
                            fontSize: isTablet! ? 12.0 : 10.0,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          _homeController.user.email,
                          style: TextStyle(
                            fontSize: isTablet! ? 10.0 : 8.0,
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
              SizedBox(height: isTablet! ? 15.0 : 10.0),
              Divider(
                color: Colors.white.withOpacity(0.3),
                thickness: 1.0,
              ),
            ],
          ),
        ),
        // Menu items
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
                  title: 'help'.tr,
                  onTap: () => _homeController.goUserGuide(),
                ),
                _buildHorizontalMenuTile(
                  icon: Icons.search,
                  title: 'filter_news'.tr,
                  onTap: () => _showFilterDialog(context),
                ),
                SizedBox(height: isTablet! ? 15.0 : 10.0),
                Divider(color: Colors.white.withOpacity(0.2), thickness: 0.5),
                SizedBox(height: isTablet! ? 15.0 : 10.0),
                _buildCreateNewsItem(context, isDrawer: false),
                _buildAdminItem(context, isDrawer: false),
               // _buildReviewItem(context, isDrawer: false),
                //_buildDraftsItem(context, isDrawer: false),
                SizedBox(height: isTablet! ? 15.0 : 10.0),
                Divider(color: Colors.white.withOpacity(0.2), thickness: 0.5),
                SizedBox(height: isTablet! ? 15.0 : 10.0),
                _buildHorizontalMenuTile(
                  icon: Icons.chat_bubble_outline,
                  title: 'Central da notícia'.tr,
                  onTap: () => Get.toNamed(Routes.NEWSCENTER),
                ),
                _buildHorizontalMenuTile(
                  icon: Icons.chat_bubble_outline,
                  title: 'Central de Comnunicação'.tr,
                  onTap: () => Get.toNamed(Routes.CENTRAL_DE_COMUNICACAO),
                ),
                _buildHorizontalMenuTile(
                  icon: Icons.info_outline,
                  title: 'Sobre'.tr,
                  onTap: () => _showAboutDialog(context),
                ),
                _buildHorizontalMenuTile(
                  icon: Icons.person_outline,
                  title: 'Seus Dados'.tr,
                  onTap: () => Get.toNamed(Routes.USER),
                ),
                _buildHorizontalMenuTile(
                  icon: Icons.language,
                  title: 'language'.tr,
                  onTap: () => _showLanguageDialog(context),
                ),
                _buildHorizontalMenuTile(
                  icon: _homeController.isAnonymousUser
                      ? Icons.login
                      : Icons.exit_to_app,
                  title:
                      _homeController.isAnonymousUser ? 'Entrar'.tr : 'Sair'.tr,
                  onTap: () => LoginController().logout(),
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

  /// Build item para Criar Matéria com verificação de permissão
  Widget _buildCreateNewsItem(BuildContext context, {required bool isDrawer}) {
    return Obx(() {
      _userController.loadUserRole(_homeController.user.id);
      final hasPermission =
          _userController.isAdmin.value || _userController.isEditor.value;

      if (isDrawer) {
        return ListTile(
          leading: Icon(
            hasPermission ? Icons.article_outlined : Icons.lock_outline,
            color: hasPermission ? Colors.white : Colors.red,
          ),
          title: Text(
            'Criar Matéria'.tr,
            style: const TextStyle(color: Colors.white),
          ),
          onTap: hasPermission
              ? () {
                  Navigator.pop(context);
                  Get.toNamed(Routes.CREATE_NEWS);
                }
              : null,
        );
      } else {
        return _buildHorizontalMenuTile(
          icon: hasPermission ? Icons.article_outlined : Icons.lock_outline,
          title: 'Criar Matéria'.tr,
          onTap: hasPermission ? () => Get.toNamed(Routes.CREATE_NEWS) : null,
          iconColor: hasPermission ? Colors.white : Colors.red,
        );
      }
    });
  }

  /// Build item para Admin com verificação de permissão
  Widget _buildAdminItem(BuildContext context, {required bool isDrawer}) {
    return Obx(() {
      _userController.loadUserRole(_homeController.user.id);
      final isAdmin = _userController.isAdmin.value;

      if (isDrawer) {
        return ListTile(
          leading: Icon(
            isAdmin ? Icons.person_outline : Icons.lock_outline,
            color: isAdmin ? Colors.white : Colors.red,
          ),
          title: Text(
            'Admin'.tr,
            style: const TextStyle(color: Colors.white),
          ),
          onTap: isAdmin
              ? () {
                  Navigator.pop(context);
                  Get.toNamed(Routes.ADMIN);
                }
              : null,
        );
      } else {
        return _buildHorizontalMenuTile(
          icon: isAdmin ? Icons.person_outline : Icons.lock_outline,
          title: 'Admin'.tr,
          onTap: isAdmin ? () => Get.toNamed(Routes.ADMIN) : null,
          iconColor: isAdmin ? Colors.white : Colors.red,
        );
      }
    });
  }

  /// Build item para Matérias para Revisão com verificação de permissão
  Widget _buildReviewItem(BuildContext context, {required bool isDrawer}) {
    return Obx(() {
      _userController.loadUserRole(_homeController.user.id);
      final hasPermission =
          _userController.isEditor.value || _userController.isAdmin.value;

      if (isDrawer) {
        return ListTile(
          leading: Icon(
            Icons.reviews_outlined,
            color: hasPermission ? Colors.white : Colors.red,
          ),
          title: Text(
            'Matérias para Revisão'.tr,
            style: const TextStyle(color: Colors.white),
          ),
          onTap: hasPermission
              ? () {
                  Navigator.pop(context);
                  _homeController.isRevisionMode.value = true;
                  _homeController.isDraftMode.value = false;
                }
              : null,
        );
      } else {
        return _buildHorizontalMenuTile(
          icon: Icons.reviews_outlined,
          title: 'Matérias para Revisão'.tr,
          onTap: hasPermission
              ? () {
                  _homeController.isRevisionMode.value = true;
                  _homeController.isDraftMode.value = false;
                }
              : null,
          iconColor: hasPermission ? Colors.white : Colors.red,
        );
      }
    });
  }

  /// Build item para Meus Rascunhos com verificação de permissão
  Widget _buildDraftsItem(BuildContext context, {required bool isDrawer}) {
    return Obx(() {
      _userController.loadUserRole(_homeController.user.id);
      final hasPermission =
          _userController.isEditor.value || _userController.isAdmin.value;

      if (isDrawer) {
        return ListTile(
          leading: Icon(
            Icons.drafts_outlined,
            color: hasPermission ? Colors.white : Colors.red,
          ),
          title: Text(
            'Meus Rascunhos'.tr,
            style: const TextStyle(color: Colors.white),
          ),
          onTap: hasPermission
              ? () {
                  Navigator.pop(context);
                  _homeController.isDraftMode.value = true;
                  _homeController.isRevisionMode.value = false;
                }
              : null,
        );
      } else {
        return _buildHorizontalMenuTile(
          icon: Icons.drafts_outlined,
          title: 'Meus Rascunhos'.tr,
          onTap: hasPermission
              ? () {
                  _homeController.isDraftMode.value = true;
                  _homeController.isRevisionMode.value = false;
                }
              : null,
          iconColor: hasPermission ? Colors.white : Colors.red,
        );
      }
    });
  }

  /// Builder para itens de menu no layout horizontal
  Widget _buildHorizontalMenuTile({
    required IconData icon,
    required String title,
    VoidCallback? onTap,
    Color iconColor = Colors.white,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(
          vertical: isTablet! ? 10.0 : 8.0,
          horizontal: isTablet! ? 8.0 : 6.0,
        ),
        child: Row(
          children: [
            Icon(icon, color: iconColor, size: iconSize),
            SizedBox(width: isTablet! ? 12.0 : 10.0),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  color: Colors.white,
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

  /// Dialog "Sobre"
  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.black,
          title: Text(
            'Sobre'.tr,
            style: const TextStyle(color: Colors.white),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.info, color: Colors.blue),
                title: Text(
                  'Quem Somos?'.tr,
                  style: const TextStyle(color: Colors.white),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _homeController.goAboutUs();
                },
              ),
              ListTile(
                leading: const Icon(Icons.book, color: Colors.blue),
                title: Text(
                  'Guia do Usuário'.tr,
                  style: const TextStyle(color: Colors.white),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _homeController.goUserGuide();
                },
              ),
              ListTile(
                leading: const Icon(Icons.help, color: Colors.blue),
                title: Text(
                  'Perguntas Frequentes'.tr,
                  style: const TextStyle(color: Colors.white),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _homeController.goFAQ();
                },
              ),
              const SizedBox(height: 16),
              Center(
                child: Obx(
                  () => Text(
                    '${'version_label'.tr}: ${_homeController.appVersion.value}',
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

  /// Dialog para filtro de notícias
  void _showFilterDialog(BuildContext context) {
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
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('cancel'.tr),
            ),
            TextButton(
              onPressed: () {
                _homeController.filterNewsByName(searchController.text);
                Navigator.of(context).pop();
              },
              child: Text('filter'.tr),
            ),
          ],
        );
      },
    );
  }

  /// Dialog para trocar idioma
  void _showLanguageDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.black,
          title: Text(
            'language'.tr,
            style: const TextStyle(color: Colors.white),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildLanguageOption(
                'language_portuguese_brazil'.tr,
                const Locale('pt', 'BR'),
              ),
              _buildLanguageOption(
                'language_english_us'.tr,
                const Locale('en', 'US'),
              ),
              _buildLanguageOption(
                'language_italian'.tr,
                const Locale('it', 'IT'),
              ),
              _buildLanguageOption(
                'language_spanish'.tr,
                const Locale('es', 'ES'),
              ),
            ],
          ),
        );
      },
    );
  }

  /// Option de idioma
  Widget _buildLanguageOption(String label, Locale locale) {
    return InkWell(
      onTap: () {
        Get.updateLocale(locale);
        Navigator.pop(Get.context!);
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Text(
          label,
          style: const TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}
