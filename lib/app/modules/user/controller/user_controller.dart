import 'package:get/get.dart';
import 'package:redescomunicacionais/app/modules/user/data/model/user_model.dart';
import 'package:redescomunicacionais/app/modules/user/data/provider/user_provider.dart';
import 'package:redescomunicacionais/app/modules/user/data/repository/user_repository.dart';
import 'package:flutter/material.dart';

class UserController extends GetxController {
  final UserRepository _repository = UserRepository();
  RxBool isAdmin = false.obs;
  RxBool isEditor = false.obs;
  RxBool isLoading = false.obs;

  final RxList<Map<String, dynamic>> allUsers = <Map<String, dynamic>>[].obs;

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

  Future<void> loadUserRole(String email) async {
    try {
      isLoading.value = true;
      UserRole role = await _repository.getUserRole(email);
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

  Future<UserModel?> getCurrentUser() {
    return _repository.getCurrentUser();
  }
}
