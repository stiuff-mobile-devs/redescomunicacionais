import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:redescomunicacionais/app/modules/dashboard/controller/home_controller.dart';
import 'package:redescomunicacionais/app/modules/login/controller/login_controller.dart';
import 'package:redescomunicacionais/app/modules/user/controller/user_controller.dart';
import 'package:redescomunicacionais/app/routes/app_routes.dart';

class MenuPage extends StatelessWidget {
  final HomeController _homeController = Get.find<HomeController>();
  final UserController _userController = Get.find<UserController>();

  MenuPage({super.key});

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
          Obx(() {
            _userController.loadUserRole(_homeController.user.id);
            if (_userController.isAdmin.value ||
                _userController.isEditor.value) {
              return ListTile(
                leading:
                    const Icon(Icons.article_outlined, color: Colors.white),
                title: Text(
                  'Criar Matéria'.tr,
                  style: TextStyle(color: Colors.white),
                ),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, Routes.CREATE_NEWS);
                },
              );
            } else {
              return ListTile(
                leading: Icon(Icons.lock_outline, color: Colors.red),
                title: Text(
                  'Criar Matéria'.tr,
                  style: TextStyle(color: Colors.white),
                ),
              );
            }
          }),
          Obx(() {
            _userController.loadUserRole(_homeController.user.id);
            if (_userController.isAdmin.value) {
              return ListTile(
                leading: const Icon(Icons.person_outline, color: Colors.white),
                title: Text(
                  'Admin'.tr,
                  style: TextStyle(color: Colors.white),
                ),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, Routes.ADMIN);
                },
              );
            } else {
              return ListTile(
                leading: Icon(Icons.lock_outline, color: Colors.red),
                title: Text(
                  'Admin'.tr,
                  style: TextStyle(color: Colors.white),
                ),
              );
            }
          }),
          Obx(() {
            _userController.loadUserRole(_homeController.user.id);
            if (_userController.isEditor.value ||
                _userController.isAdmin.value) {
              return ListTile(
                leading:
                    const Icon(Icons.reviews_outlined, color: Colors.white),
                title: Text(
                  'Matérias para Revisão'.tr,
                  style: TextStyle(color: Colors.white),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _homeController.isRevisionMode.value = true;
                },
              );
            } else {
              return ListTile(
                leading: Icon(Icons.reviews_outlined, color: Colors.red),
                title: Text(
                  'Matérias para Revisão'.tr,
                  style: TextStyle(color: Colors.white),
                ),
              );
            }
          }),
          ListTile(
            leading: const Icon(Icons.chat_bubble_outline, color: Colors.white),
            title: Text(
              'Central de Comnunicação'.tr,
              style: TextStyle(color: Colors.white),
            ),
            onTap: () {
              Get.toNamed(Routes.CENTRAL_DE_COMUNICACAO);
            },
          ),
          ListTile(
            leading: const Icon(Icons.person_outline, color: Colors.white),
            title: Text(
              'Seus Dados'.tr,
              style: TextStyle(color: Colors.white),
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
              style: TextStyle(color: Colors.white),
            ),
            onTap: () {
              Navigator.pop(context);

              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    backgroundColor: Colors.black,
                    title: Text(
                      'Sobre'.tr,
                      style: TextStyle(color: Colors.white),
                    ),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ListTile(
                          leading: const Icon(Icons.info, color: Colors.blue),
                          title: Text(
                            'Quem Somos?'.tr,
                            style: TextStyle(color: Colors.white),
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
                            style: TextStyle(color: Colors.white),
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
                            style: TextStyle(color: Colors.white),
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
                    value: Locale('pt', 'BR'),
                    child: Text('language_portuguese_brazil'.tr),
                  ),
                  DropdownMenuItem(
                    value: Locale('en', 'US'),
                    child: Text('language_english_us'.tr),
                  ),
                  DropdownMenuItem(
                    value: Locale('it', 'IT'),
                    child: Text('language_italian'.tr),
                  ),
                  DropdownMenuItem(
                    value: Locale('es', 'ES'),
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
}
