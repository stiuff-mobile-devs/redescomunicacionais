import 'package:get/get.dart';
import 'package:redescomunicacionais/app/modules/user/data/model/user_model.dart';
import 'package:redescomunicacionais/app/modules/user/data/repository/user_repository.dart';
import 'package:flutter/material.dart';
import 'package:redescomunicacionais/app/routes/app_routes.dart';
import 'package:redescomunicacionais/app/utils/components/popups.dart';

class UserController extends GetxController {
  final UserRepository _repository = UserRepository();

  RxBool isAdmin = false.obs;
  RxBool isEditor = false.obs;
  RxBool isLoading = false.obs;
  RxBool isDataLoading = true.obs;
  RxBool isSavingData = false.obs;
  RxBool isDeletingAccount = false.obs;

  UserModel currentUser = UserModel.empty();


  @override
  Future<void> onInit() async {
    currentUser = await _repository.getCurrentUserFromHive();
    super.onInit();
  }


  Future<void> saveCurrentUserName(String newName) async {
    isSavingData.value = true;

    UserModel currentUser = await _repository.getCurrentUserFromHive();

    if (newName.trim().isEmpty) {
      PopUps.snackbar(
        texto: 'Informe um nome válido.',
        cor: Colors.orange,
      );
      return;
    }

    try {
      await _repository.updateUserNameToFirebase(
          currentUser.id!, newName.trim());

    } catch (e) {
      PopUps.snackbar(
        texto: 'Não foi possível atualizar o nome: $e',
        cor: Colors.red,
      );
    } finally {
      isSavingData.value = false;
    }
  }

  Future<void> deleteCurrentUserAccount() async {
    try {
      isDeletingAccount.value = true;
      await _repository.deleteCurrentUserDocFromFirebase();
      Get.offAllNamed(Routes.LOGIN);
      PopUps.snackbar(
        texto: 'Sua conta foi excluída com sucesso.',
        cor: Colors.green,
      );
    } catch (e) {
      PopUps.snackbar(
        texto: 'Não foi possível excluir a conta: $e',
        cor: Colors.red,
      );
    } finally {
      isDeletingAccount.value = false;
    }
  }
}
