import 'package:redescomunicacionais/app/modules/user/data/model/user_model.dart';
import 'package:redescomunicacionais/app/modules/user/data/provider/user_provider.dart';
import 'package:redescomunicacionais/app/modules/mesh/model/public_key_model.dart';

class UserRepository {
  UserRepository();
  final UserProvider _userProvider = UserProvider();

  Future<void> createUserDoc(
      String email, String name, String uid, String urlImage) {
    return _userProvider.createUserDoc(email, name, uid, urlImage);
  }

  Future<void> updateRole(String userId, String role, String adminEmail, Map<String, String> operationsCities) {
    return _userProvider.updateUserRole(userId, role, adminEmail, operationsCities);
  }

  Future<List<UserModel>> getAllUsersFromFirebase() {
    return _userProvider.getAllUsersFromFirebase();
  }

  Future<UserModel> getCurrentUserFromHive() {
    return _userProvider.getCurrentUserFromHive();
  }


  Future<void> deleteCurrentUserFromHive() {
    return _userProvider.deleteCurrentUserFromHive();
  }

  Future<void> deleteCurrentUserAccountFromFirebase() {
    return _userProvider.deleteCurrentUserAccountFromFirebase();
  }

  Future<void> updateUserNameToFirebase(String userId, String name) {
    return _userProvider.updateUserNameToFirebase(userId, name);
  }

  Future<String?> getPrivateKeyInStorage() async {
    return await _userProvider.getPrivateKeyInStorage();
  }

  Future<void> createPublicKeyInFirebase(PublicKeyModel publicKeyModel) async {
    return _userProvider.createPublicKeyInFirebase(publicKeyModel);
  }

  Future<void> createPublicKey(PublicKeyModel publicKeyModel) async {
    return _userProvider.savePublicKey(publicKeyModel);
  }

  Future<bool> updatePublicKeyInFirebase(
      String email, String newPublicKey) async {
    return _userProvider.updatePublicKeyInFirebase(email, newPublicKey);
  }

   Future<void> saveLocalSelectedCity(String cityName) async {
    return _userProvider.saveLocalSelectedCity(cityName);}

     Future<void> clearLocalSelectedCity() async {
    return _userProvider.clearLocalSelectedCity();
  }
}
