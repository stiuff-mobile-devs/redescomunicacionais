import 'package:get/get.dart';
import 'package:redescomunicacionais/app/modules/dashboard/controller/home_controller.dart';
import 'package:redescomunicacionais/app/modules/user/data/model/user_model.dart';
import 'package:redescomunicacionais/app/modules/user/data/repository/user_repository.dart';
import 'package:flutter/material.dart';
import 'package:redescomunicacionais/app/routes/app_routes.dart';
import 'package:redescomunicacionais/app/modules/utils/components/friendly_exception.dart';
import 'package:redescomunicacionais/app/modules/utils/popups/app_popups.dart';
import 'package:redescomunicacionais/app/modules/utils/translations/locale_keys.dart';

class UserController extends GetxController {
  final UserRepository _repository = UserRepository();

  RxBool isAdmin = false.obs;
  RxBool isEditor = false.obs;
  RxBool isLoading = false.obs;
  RxBool isDataLoading = true.obs;
  RxBool isSavingData = false.obs;
  RxBool isDeletingAccount = false.obs;

  final Rx<UserModel> currentUser = UserModel.empty().obs;


  @override
  Future<void> onInit() async {
    super.onInit();
    await _reloadCurrentUser();
    isDataLoading.value = false;
  }

  Future<void> _reloadCurrentUser() async {
    currentUser.value = await _repository.getCurrentUserFromHive();
    currentUser.refresh();
  }

  Future<void> saveCurrentUserName(String newName) async {
    if (newName.trim().isEmpty) {
      AppPopups.warning(LocaleKeys.invalidName.tr);
      return;
    }

    isSavingData.value = true;

    try {
      final UserModel user = await _repository.getCurrentUserFromHive();
      await _repository.updateUserNameToFirebase(user.id!, newName.trim());
      await _reloadCurrentUser();
      _refreshMenuUser();

      AppPopups.success(LocaleKeys.nameUpdatedSuccess.tr);
    } catch (e) {
      debugPrint('Erro ao atualizar o nome: $e');
      AppPopups.error(_errorMessage(e, LocaleKeys.nameUpdateError));
    } finally {
      isSavingData.value = false;
    }
  }

  // Salva a cidade favorita e já aplica o filtro na Home, se ela estiver aberta
  Future<void> updateFavoriteCity(String cityName) async {
    if (Get.isRegistered<HomeController>()) {
      await Get.find<HomeController>().updateSelectedCity(cityName);
    } else {
      await _repository.saveLocalSelectedCity(cityName);
    }
    await _reloadCurrentUser();
  }

  // Atualiza o usuário exibido no menu da Home
  void _refreshMenuUser() {
    if (!Get.isRegistered<HomeController>()) return;

    final homeController = Get.find<HomeController>();
    homeController.user = currentUser.value;
    homeController.update();
  }

  Future<void> deleteCurrentUserAccount() async {
    try {
      isDeletingAccount.value = true;
      await _repository.deleteCurrentUserDocFromFirebase();
      Get.offAllNamed(Routes.LOGIN);
      AppPopups.success(LocaleKeys.accountDeletedSuccess.tr);
    } catch (e) {
      debugPrint('Erro ao excluir a conta: $e');
      AppPopups.error(_errorMessage(e, LocaleKeys.accountDeleteError));
    } finally {
      isDeletingAccount.value = false;
    }
  }

  // Mensagem para o usuário: a específica do erro, se houver, ou a genérica.
  // O detalhe técnico do erro vai só para o log.
  String _errorMessage(Object error, String fallbackKey) {
    if (error is FriendlyException) return error.messageKey.tr;
    return fallbackKey.tr;
  }
}
