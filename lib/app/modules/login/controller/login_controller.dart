import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pointycastle/api.dart';
import 'package:redescomunicacionais/app/modules/user/data/model/user_model.dart';
import 'package:redescomunicacionais/app/modules/user/data/repository/user_repository.dart';
import 'package:redescomunicacionais/app/modules/login/data/repository/login_repository.dart';
import 'package:redescomunicacionais/app/modules/user/utils/userRoles.dart';
import 'package:redescomunicacionais/app/routes/app_routes.dart';
import 'package:redescomunicacionais/app/modules/mesh/services/key_storage_service.dart';
import 'package:redescomunicacionais/app/modules/mesh/services/keys_service.dart';
import 'package:redescomunicacionais/app/modules/mesh/model/public_key_model.dart';
import 'package:redescomunicacionais/app/utils/components/popups.dart';
import 'package:package_info_plus/package_info_plus.dart';

class LoginController extends GetxController {
  final LoginRepository _repository = LoginRepository();
  final UserRepository _userRepository = UserRepository();
  final RxString appVersion = 'Carregando...'.obs;

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

  Future<void> loginGoogle() async {
    try {
      await _repository.logoutGoogle();
      await _repository.signInGoogle();
      await _createKeys();
      Get.offAllNamed(Routes.HOME);
    } catch (e) {
      debugPrint("Erro de Login: $e");

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (Get.context != null) {
          PopUps.snackbar(
            texto:
                'Ocorreu um erro ao tentar fazer login com o Google. Por favor, tente novamente.'
                    .tr,
            cor: Colors.red,
          );
        }
      });
    }
  }

  void loginMicrosoft() async {
    try {
      await _repository.logoutGoogle();
      await _repository.logoutMicrosoft();
      await _createKeys();
      Get.offAllNamed(Routes.HOME);
    } catch (e) {
      debugPrint("Erro de Login Microsoft: $e");

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (Get.context != null) {
          PopUps.snackbar(
            texto:
                "Ocorreu um erro ao tentar fazer login com o Microsoft. Por favor, tente novamente."
                    .tr,
            cor: Colors.red,
          );
        }
      });
    }
  }

  Future<void> tryLogin() async {
     try {
      await _repository.trySignInGoogle().timeout(const Duration(seconds: 10),
          onTimeout: () =>
              throw Exception("Tempo esgotado para login silencioso"));
      await _createKeys();
    } catch (e) {
      final user = await _userRepository.getCurrentUserFromHive();
      if (user.role == UserRoles.guest) {
        await loginAnonymous();
      }
    }

    Get.offAllNamed(Routes.HOME);
  }

  Future<void> tryLoginMicrosoft() async {
    try {
      await _repository.trySignInMicrosoft();
      await _createKeys();
    } catch (e) {
      final user = await _userRepository.getCurrentUserFromHive();
      if (user.role == UserRoles.guest) {
        await loginAnonymous();
      }
    }
    Get.offAllNamed(Routes.HOME);
  }

  void logout() async {
    await _repository.logoutMicrosoft();
    await _repository.logoutGoogle();
    await _userRepository.deleteCurrentUserFromHive();
    Get.offAllNamed(Routes.LOGIN);
  }

  void loginApple() async {
    try {
      await _repository.logoutGoogle();
      await _repository.logoutMicrosoft();
      await _repository.signInAppleAuth();
      await _createKeys();
      Get.offAllNamed(Routes.HOME);
    } catch (e) {
      debugPrint("Erro de Login Apple: $e");

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (Get.context != null) {
          PopUps.snackbar(
            texto:
                'Ocorreu um erro ao tentar fazer login com o Apple. Por favor, tente novamente.'
                    .tr,
            cor: Colors.red,
          );
        }
      });
    }
  }

  Future<void> loginAnonymous() async {
    await _repository.logoutGoogle();
    await _repository.logoutMicrosoft();
    UserModel anonymousUser = UserModel.empty();
    await _repository.createUserDocInHive(anonymousUser);
    Get.offAllNamed(Routes.HOME);
  }

  Future<void> _createKeys() async {
    final storage = KeyStorageService();
    String privateKey = '';
    try {
      privateKey = await _userRepository.getPrivateKeyInStorage() ?? '';
    } catch (e) {
      debugPrint("Erro ao buscar chave privada do usuario");
    }

    if (privateKey.isEmpty) {
      try {
        final user = await _userRepository.getCurrentUserFromHive();

        final keys = KeysServices.generateKeyPair();

        final privateKeyString = KeysServices.exportPrivateKey(keys.privateKey);
        final publicKeyString = KeysServices.exportPublicKey(keys.publicKey);

        bool isUpdatePublicKey = await _userRepository
            .updatePublicKeyInFirebase(user.email, publicKeyString);

        if (!isUpdatePublicKey) {
          final publicKeyModel =
              await _createPublicKeyModel(publicKeyString, user);
          await _userRepository.createPublicKey(publicKeyModel);
        }

        await storage.savePrivateKey(privateKeyString);
      } catch (e) {
        debugPrint("Erro ao criar e salvar chave privada do usuario");
      }
    }
  }

  Future<PublicKeyModel> _createPublicKeyModel(
      String publicKeyString, UserModel user) async {
    try {
      return PublicKeyModel(
        id: user.email,
        email: user.email,
        publicKey: publicKeyString,
        createdAt: DateTime.now(),
        lastUpdated: DateTime.now(),
      );
    } catch (e) {
      throw Exception("Erro ao criar public Key Model");
    }
  }
}
