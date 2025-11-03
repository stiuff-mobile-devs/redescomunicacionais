import 'package:redescomunicacionais/app/modules/user/data/model/user_model.dart';
import 'package:redescomunicacionais/app/modules/login/data/provider/sign_in.dart';

class LoginRepository {
  final SignInService signInService = SignInService();

  Future<UserModel?> signInGoogle() {
    return signInService.signInGoogle();
  }

  Future<UserModel?> trySignInGoogle() {
    return signInService.trySignInGoogle();
  }

  logoutGoogle() {
    signInService.logoutGoogle();
  }

  Future<UserModel?> signInMicrosoft() async {
    return signInService.signInMicrosoft();
  }

  Future<UserModel?> trySignInMicrosoft() {
    return signInService.trySignInMicrosoft();
  }

  logoutMicrosoft() {
    signInService.logoutMicrosoft();
  }
}
