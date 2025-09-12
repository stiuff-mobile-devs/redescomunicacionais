import 'package:get/get.dart';
import 'package:redescomunicacionais/app/modules/user/data/repository/user_repository.dart';
import 'package:flutter/material.dart';

class UserController extends GetxController {
  final UserRepository _repository = UserRepository();
  var isAdmin = false.obs;
  var isEditor = false.obs;
  var isLoading = false.obs;

  final RxList<Map<String, dynamic>> allUsers = <Map<String, dynamic>>[].obs;

  Future<void> addProfile(String email, String profile) async {
    try {
      isLoading(true);
      await _repository.addProfile(email, profile);
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
      isLoading(false);
    }
  }

  Future<void> loadUserRole(String email) async {
    final role = await _repository.getUserRole(email);
    if (role == UserRole.admin) {
      isAdmin.value = true;
    } else if (role == UserRole.editor) {
      isEditor.value = true;
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
}
