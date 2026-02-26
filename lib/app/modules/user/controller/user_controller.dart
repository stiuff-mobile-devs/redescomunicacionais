import 'package:get/get.dart';
import 'package:redescomunicacionais/app/modules/user/data/model/user_model.dart';
import 'package:redescomunicacionais/app/modules/user/data/provider/user_provider.dart';
import 'package:redescomunicacionais/app/modules/user/data/repository/user_repository.dart';
import 'package:flutter/material.dart';
import 'package:redescomunicacionais/app/routes/app_routes.dart';

class UserController extends GetxController {
  final UserRepository _repository = UserRepository();
  RxBool isAdmin = false.obs;
  RxBool isEditor = false.obs;
  RxBool isLoading = false.obs;

  final TextEditingController nameController = TextEditingController();
  Rxn<UserModel> currentUser = Rxn<UserModel>();
  RxBool isDataLoading = true.obs;
  RxBool isSavingData = false.obs;
  RxBool isDeletingAccount = false.obs;

  final RxList<Map<String, dynamic>> allUsers = <Map<String, dynamic>>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadCurrentUserData();
  }

  @override
  void onClose() {
    nameController.dispose();
    super.onClose();
  }

  Future<void> addProfile(
      String email, String profile, String adminEmail) async {
    try {
      isLoading.value = true;
      await _repository.addProfile(email, profile, adminEmail);
      Get.snackbar(
        'Sucesso',
        'Perfil adicionado com sucesso!',
        snackPosition: SnackPosition.BOTTOM,
        colorText: Colors.white,
        backgroundColor: Colors.green,
      );
    } catch (e) {
      Get.snackbar(
        'Erro',
        'Não foi possível cadastrar o perfil!',
        snackPosition: SnackPosition.BOTTOM,
        colorText: Colors.white,
        backgroundColor: Colors.red,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateRoleDocument(
      String userId, String role, String updatedBy) async {
    try {
      await _repository.updateRoleDocument(userId, role, updatedBy);
    } catch (e) {
      debugPrint("Erro ao atualizar documento de role: $e");
    }
  }

  Future<void> loadUserRole(String uid) async {
    try {
      isLoading.value = true;
      UserRole role = await _repository.getUserRole(uid);
      if (role == UserRole.admin) {
        isAdmin.value = true;
      } else if (role == UserRole.editor) {
        isEditor.value = true;
      }
    } catch (e) {
      debugPrint("Erro ao carregar role do usuário: $e");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadAllUsers() async {
    try {
      isLoading.value = true;
      List<Map<String, dynamic>> users = await _repository.getAllUsers();
      allUsers.value = users;
    } catch (e) {
      Get.snackbar("Erro", "Erro ao carregar usuários: $e");
    } finally {
      isLoading.value = false;
    }
  }

  Future<UserModel> getCurrentUser() {
    return _repository.getCurrentUser();
  }

  Future<void> updateUserInFirebase(UserModel user) {
    return _repository.updateUserInFirebase(user);
  }

  Future<void> updateUserInHive(UserModel user) {
    return _repository.updateUserInHive(user);
  }

  Future<void> loadCurrentUserData() async {
    try {
      isDataLoading.value = true;
      final user = await _repository.getCurrentUser();
      currentUser.value = user;
      nameController.text = user.name ?? '';
    } catch (e) {
      Get.snackbar(
        'Erro',
        'Não foi possível carregar seus dados.',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isDataLoading.value = false;
    }
  }

  Future<UserModel?> saveCurrentUserName() async {
    final name = nameController.text.trim();

    if (name.isEmpty) {
      Get.snackbar(
        'Atenção',
        'Informe um nome válido.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return null;
    }

    try {
      isSavingData.value = true;
      final updatedUser = await _repository.updateCurrentUserName(name);
      currentUser.value = updatedUser;
      Get.snackbar(
        'Sucesso',
        'Nome atualizado com sucesso.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return updatedUser;
    } catch (e) {
      Get.snackbar(
        'Erro',
        'Não foi possível atualizar o nome: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
      return null;
    } finally {
      isSavingData.value = false;
    }
  }

  Future<void> deleteCurrentUserAccount() async {
    try {
      isDeletingAccount.value = true;
      await _repository.deleteCurrentUserAccount();
      Get.offAllNamed(Routes.LOGIN);
      Get.snackbar(
        'Conta excluída',
        'Sua conta foi excluída com sucesso.',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'Erro',
        'Não foi possível excluir a conta: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isDeletingAccount.value = false;
    }
  }
}
