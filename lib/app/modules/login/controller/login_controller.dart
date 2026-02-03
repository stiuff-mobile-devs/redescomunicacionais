import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:redescomunicacionais/app/services/version_service.dart';
import 'package:redescomunicacionais/app/modules/login/data/repository/login_repository.dart';
import 'package:redescomunicacionais/app/routes/app_routes.dart';
import 'dart:developer' as developer;

class LoginController extends GetxController {
  final LoginRepository repository = LoginRepository();

  late VersionService versionService;

  @override
  void onInit() {
    versionService = Get.find<VersionService>();
    super.onInit();
  }

  void loginGoogle() async {
    try {
      repository.logoutGoogle();
      final user = await repository.signInGoogle();

      if (user != null) {
        Get.offNamed(Routes.HOME, arguments: user);
      } else {
        // Espere o contexto estar disponível
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Get.snackbar(
            "Erro de Login",
            "Falha ao autenticar o usuário.",
            snackPosition: SnackPosition.BOTTOM,
          );
        });
      }
    } catch (e) {
      // Use debugPrint ao invés de snackbar para erros de inicialização
      debugPrint("Erro de Login: $e");

      // Só mostre snackbar se o contexto estiver disponível
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (Get.context != null) {
          Get.snackbar(
            "Erro de Login",
            e.toString(),
            snackPosition: SnackPosition.BOTTOM,
          );
        }
      });
    }
  }

  void loginMicrosoft() async {
    try {
      repository.logoutGoogle();
      final user = await repository.signInMicrosoft();

      if (user != null) {
        Get.offNamed(Routes.HOME, arguments: user);
      } else {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Get.snackbar(
            "Erro de Login",
            "Falha ao autenticar o usuário.",
            snackPosition: SnackPosition.BOTTOM,
          );
        });
      }
    } catch (e) {
      debugPrint("Erro de Login Microsoft: $e");

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (Get.context != null) {
          Get.snackbar(
            "Erro de Login",
            e.toString(),
            snackPosition: SnackPosition.BOTTOM,
          );
        }
      });
    }
  }

  tryLogin() async {
    var hasLogged = await repository.trySignInGoogle();
    if (hasLogged != null) {
      Get.offNamed(Routes.HOME, arguments: hasLogged);
    } else {
      Get.offNamed(Routes.LOGIN);
    }
  }

  tryLoginMicrosoft() async {
    var hasLogged = await repository.trySignInMicrosoft();
    if (hasLogged != null) {
      Get.offNamed(Routes.HOME, arguments: hasLogged);
    } else {
      Get.offNamed(Routes.LOGIN);
    }
  }

  void logout() {
    repository.logoutMicrosoft();
    repository.logoutGoogle();
    Get.offAllNamed(Routes.LOGIN);
  }
}
