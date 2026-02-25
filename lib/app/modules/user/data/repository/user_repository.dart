import 'package:redescomunicacionais/app/modules/user/data/model/user_model.dart';
import 'package:redescomunicacionais/app/modules/user/data/provider/user_provider.dart';

class UserRepository {
  UserRepository();
  final UserProvider _userProvider = UserProvider();

  Future<UserModel> createUserDoc(
      String email, String name, String uid, String urlImage) {
    return _userProvider.createUserDoc(email, name, uid, urlImage);
  }

  Future<void> addProfile(String email, String profile, String adminEmail) {
    return _userProvider.addProfile(email, profile, adminEmail);
  }

  Future<void> updateRoleDocument(
      String userId, String role, String updatedBy) {
    return _userProvider.updateRoleDocument(userId, role, updatedBy);
  }

  Future<UserRole> getUserRole(String uid) {
    return _userProvider.getUserRole(uid);
  }

  Future<List<Map<String, dynamic>>> getAllUsers() {
    return _userProvider.getAllUsers();
  }

  Future<UserModel> getCurrentUser() {
    return _userProvider.getCurrentUserFromHive();
  }

  updateUserInFirebase(UserModel user) {
    return _userProvider.updateUserInFirebase(user);
  }

  updateUserInHive(UserModel user) {
    return _userProvider.updateUserInHive(user);
  }

  Future<void> deleteCurrentUserFromHive() {
    return _userProvider.deleteCurrentUserFromHive();
  }
}
