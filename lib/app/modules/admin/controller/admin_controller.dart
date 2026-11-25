import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:redescomunicacionais/app/modules/user/data/model/user_model.dart';
import 'package:redescomunicacionais/app/modules/user/data/repository/user_repository.dart';

class AdminController extends GetxController {
  AdminController();

  UserRepository userRepository = UserRepository();
  List<UserModel> users = [];
  UserModel user = UserModel.empty();
  final RxnString selectedCity = RxnString(null);


  RxBool isLoading = false.obs;

  // Filtro de role (todos, user, editor, admin)
  RxString selectedRoleFilter = 'todos'.obs;

  @override
  void onInit() {
    _loadInitialData();
    super.onInit();
  }

  Future<void> _loadInitialData() async {
    user = await userRepository.getCurrentUserFromHive();
    await loadAllUsers();
  }

  Future<void> loadAllUsers() async {
    isLoading.value = true;
    try {
      users = await userRepository.getAllUsersFromFirebase();
    } catch (e) {
      debugPrint("Erro ao carregar usuários: $e");
    } finally {
      isLoading.value = false;
    }
  }
}
