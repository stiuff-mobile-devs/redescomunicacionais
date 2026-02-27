import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:redescomunicacionais/app/modules/user/controller/user_controller.dart';
import 'package:redescomunicacionais/app/modules/user/data/model/user_model.dart';
import 'package:redescomunicacionais/app/modules/user/data/repository/user_repository.dart';
import 'package:redescomunicacionais/app/modules/login/data/repository/login_repository.dart';
import 'package:redescomunicacionais/app/routes/app_routes.dart';
import 'package:package_info_plus/package_info_plus.dart';

class LoginController extends GetxController {
  final LoginRepository _repository = LoginRepository();
  final RxString appVersion = 'Carregando...'.obs;

  final UserRepository _userRepository = UserRepository();

  @override
  void onInit() {
    super.onInit();
    _loadPackageInfo();
  }

  Future<void> _loadPackageInfo() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      appVersion.value = packageInfo.version;
    } catch (_) {
      appVersion.value = '--';
    }
  }

  Future<void> _persistAndSyncUser(UserModel user) async {
    await _userRepository.updateUserInHive(user);

    if (Get.isRegistered<UserController>()) {
      final userController = Get.find<UserController>();
      userController.currentUser.value = user;
      userController.nameController.text = user.name ?? '';
    }
  }

  void _clearUserState() {
    if (Get.isRegistered<UserController>()) {
      final userController = Get.find<UserController>();
      userController.currentUser.value = null;
      userController.nameController.clear();
    }
  }

  void loginGoogle() async {
    try {
      _repository.logoutGoogle();
      final user = await _repository.signInGoogle();
      if (user != null) {
        await _persistAndSyncUser(user);
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
      _repository.logoutGoogle();
      final user = await _repository.signInMicrosoft();
      if (user != null) {
        await _persistAndSyncUser(user);
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
    try {
      final user = await _repository
          .trySignInGoogle()
          .timeout(const Duration(seconds: 10), onTimeout: () => null);

      if (user != null) {
        await _persistAndSyncUser(user);
        Get.offNamed(Routes.HOME, arguments: user);
      } else {
        Get.offNamed(Routes.LOGIN);
      }
    } catch (e) {
      debugPrint("Erro no tryLogin: $e");
      Get.offNamed(Routes.LOGIN);
    }
  }

  tryLoginMicrosoft() async {
    var hasLogged = await _repository.trySignInMicrosoft();
    if (hasLogged != null) {
      await _persistAndSyncUser(hasLogged);
      Get.offNamed(Routes.HOME, arguments: hasLogged);
    } else {
      Get.offNamed(Routes.LOGIN);
    }
  }

  void logout() async {
    await _repository.logoutMicrosoft();
    await _repository.logoutGoogle();
    await _userRepository.deleteCurrentUserFromHive();
    _clearUserState();
    Get.offAllNamed(Routes.LOGIN);
  }

  void loginApple() async {
    try {
      final user = await _repository.signInAppleAuth();
      if (user != null) {
        await _persistAndSyncUser(user);
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
      debugPrint("Erro de Login Apple: $e");

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

  void loginAnonymous() async {
    final anonymousUser = UserModel.empty();
    await _persistAndSyncUser(anonymousUser);
    Get.offNamed(Routes.HOME, arguments: anonymousUser);
  }
}
