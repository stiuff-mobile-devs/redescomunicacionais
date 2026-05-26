import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:redescomunicacionais/app/modules/user/controller/user_controller.dart';
import 'package:redescomunicacionais/app/modules/user/data/model/user_model.dart';
import 'package:redescomunicacionais/app/modules/user/data/repository/user_repository.dart';
import 'package:redescomunicacionais/app/modules/login/data/repository/login_repository.dart';
import 'package:redescomunicacionais/app/routes/app_routes.dart';
import 'package:redescomunicacionais/app/utils/components/popups.dart';
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
      UserModel user = await _repository.signInGoogle();
      Get.offNamed(Routes.HOME, arguments: user);
    } catch (e) {
      // Use debugPrint ao invés de snackbar para erros de inicialização
      debugPrint("Erro de Login: $e");

      // Só mostre snackbar se o contexto estiver disponível
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (Get.context != null) {
          PopUps.snackbar(
            texto: e.toString(),
            cor: Colors.red,
          );
        }
      });
    }
  }

  void loginMicrosoft() async {
    try {
      _repository.logoutGoogle();
      UserModel user = await _repository.signInMicrosoft();
        Get.offNamed(Routes.HOME, arguments: user);
      
    } catch (e) {
      debugPrint("Erro de Login Microsoft: $e");

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (Get.context != null) {
          PopUps.snackbar(
            texto: e.toString(),
            cor: Colors.red,
          );
        }
      });
    }
  }

  Future<void> tryLogin() async {
    try {
      UserModel user = await _repository
          .trySignInGoogle()
          .timeout(const Duration(seconds: 10), onTimeout: () => throw Exception("Tempo esgotado para login silencioso"));

        Get.offNamed(Routes.HOME, arguments: user);
    } catch (e) {
      debugPrint("Erro no tryLogin: $e");
      loginAnonymous();
    }
  }

  Future<void> tryLoginMicrosoft() async {
    try{
       UserModel hasLogged = await _repository.trySignInMicrosoft();
      Get.offNamed(Routes.HOME, arguments: hasLogged);
    }
    catch(e){
      debugPrint("Erro no tryLoginMicrosoft: $e");
      loginAnonymous();
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
      UserModel user = await _repository.signInAppleAuth();
        Get.offNamed(Routes.HOME, arguments: user);
    } catch (e) {
      debugPrint("Erro de Login Apple: $e");

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (Get.context != null) {
          PopUps.snackbar(
            texto: e.toString(),
            cor: Colors.red,
          );
        }
      });
    }
  }

  void loginAnonymous() async {
    final anonymousUser = UserModel.empty();
     await _repository.createUserDocInHive(anonymousUser);
    Get.offNamed(Routes.HOME, arguments: anonymousUser);
  }
}
