import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:redescomunicacionais/app/modules/dashboard/controller/home_controller.dart';
import 'package:redescomunicacionais/app/modules/login/controller/login_controller.dart';
import 'package:redescomunicacionais/app/modules/user/controller/user_controller.dart';
import 'package:redescomunicacionais/app/data/services/version_service.dart';
import 'package:redescomunicacionais/app/routes/app_routes.dart';

class MenuPage extends StatelessWidget {
  final HomeController _homeController = Get.find<HomeController>();
  final UserController _userController = Get.find<UserController>();
  final VersionService _versionController = Get.find<VersionService>();

  MenuPage({super.key});

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
            _userController.loadUserRole(_homeController.user.email);
            if (_userController.isAdmin.value ||
                _userController.isEditor.value) {
              return ListTile(
                leading:
                    const Icon(Icons.article_outlined, color: Colors.white),
                title: const Text(
                  'Criar Matéria',
                  style: TextStyle(color: Colors.white),
                ),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, Routes.CREATE_NEWS);
                },
              );
            } else {
              return const ListTile(
                leading: Icon(Icons.lock_outline, color: Colors.red),
                title: Text(
                  'Criar Matéria',
                  style: TextStyle(color: Colors.white),
                ),
              );
            }
          }),
          Obx(() {
            _userController.loadUserRole(_homeController.user.email);
            if (_userController.isAdmin.value) {
              return ListTile(
                leading: const Icon(Icons.person_outline, color: Colors.white),
                title: const Text(
                  'Admin',
                  style: TextStyle(color: Colors.white),
                ),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, Routes.ADMIN);
                },
              );
            } else {
              return const ListTile(
                leading: Icon(Icons.lock_outline, color: Colors.red),
                title: Text(
                  'Admin',
                  style: TextStyle(color: Colors.white),
                ),
              );
            }
          }),
          Obx(() {
            _userController.loadUserRole(_homeController.user.email);
            if (_userController.isEditor.value ||
                _userController.isAdmin.value) {
              return ListTile(
                leading:
                    const Icon(Icons.reviews_outlined, color: Colors.white),
                title: const Text(
                  'Matérias para Revisão',
                  style: TextStyle(color: Colors.white),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _homeController.isRevisionMode.value = true;
                },
              );
            } else {
              return const ListTile(
                leading: Icon(Icons.reviews_outlined, color: Colors.red),
                title: Text(
                  'Matérias para Revisão',
                  style: TextStyle(color: Colors.white),
                ),
              );
            }
          }),
          ListTile(
            leading: const Icon(Icons.chat_bubble_outline, color: Colors.white),
            title: const Text(
              'Central de Comnunicação',
              style: TextStyle(color: Colors.white),
            ),
            onTap: () {
              Get.toNamed(Routes.CENTRAL_DE_COMUNICACAO);
            },
          ),
          ListTile(
            leading: const Icon(Icons.info_outline, color: Colors.white),
            title: const Text(
              'Sobre',
              style: TextStyle(color: Colors.white),
            ),
            onTap: () {
              Navigator.pop(context);

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
            },
          ),
          ListTile(
            leading: const Icon(Icons.exit_to_app, color: Colors.white),
            title: const Text(
              'Sair',
              style: TextStyle(color: Colors.white),
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
