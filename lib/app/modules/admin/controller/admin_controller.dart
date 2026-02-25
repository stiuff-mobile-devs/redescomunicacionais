import 'package:get/get.dart';
import 'package:redescomunicacionais/app/modules/user/controller/user_controller.dart';
import 'package:redescomunicacionais/app/modules/user/data/model/user_model.dart';

class AdminController extends GetxController {
  AdminController();

  final UserController _userController = Get.find<UserController>();
  UserModel? user;

  // Filtro de role (todos, user, editor, admin)
  RxString selectedRoleFilter = 'todos'.obs;

  @override
  void onInit() {
    _loadInitialData();
    // Listener para atualizar quando a lista de usuários mudar
    ever(_userController.allUsers, (_) {
      update();
    });
    super.onInit();
  }

  Future<void> _loadInitialData() async {
    // Carrega a lista de usuários ao iniciar a página
    user = await _userController.getCurrentUser() ?? UserModel.empty();
    _userController.loadAllUsers();
  }

  void loadAllUsers() {
    _userController.loadAllUsers();
  }

  RxBool isLoadingUserController() {
    return _userController.isLoading;
  }

  RxList<Map<String, dynamic>> getAllUsers() {
    return _userController.allUsers;
  }

  void addProfile(String email, String profile, String? adminEmail) {
    _userController.addProfile(email, profile, adminEmail ?? '');
  }

  Future<void> updateRoleDocument(
      String userId, String role, String updatedBy) async {
    await _userController.updateRoleDocument(userId, role, updatedBy);
  }

  List<Map<String, dynamic>> getFilteredAndSortedUsers() {
    List<Map<String, dynamic>> users = _userController.allUsers.toList();

    // Filtrar por role
    if (selectedRoleFilter.value != 'todos') {
      users = users
          .where((user) =>
              (user['role'] ?? 'user').toLowerCase() ==
              selectedRoleFilter.value)
          .toList();
    }

    // Ordenar alfabeticamente por email
    users.sort((a, b) {
      String emailA = (a['email'] ?? '').toLowerCase();
      String emailB = (b['email'] ?? '').toLowerCase();
      return emailA.compareTo(emailB);
    });

    return users;
  }

  void setRoleFilter(String role) {
    selectedRoleFilter.value = role;
    update(); // Notifica GetBuilder
  }
}
