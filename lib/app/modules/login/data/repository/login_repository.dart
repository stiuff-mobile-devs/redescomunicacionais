import 'package:redescomunicacionais/app/modules/login/data/provider/sign_in_apple.dart';
import 'package:redescomunicacionais/app/modules/user/data/model/user_model.dart';
import 'package:redescomunicacionais/app/modules/login/data/provider/sign_in.dart';
import 'package:redescomunicacionais/app/modules/user/data/provider/user_provider.dart';

class LoginRepository {
  final SignInService signInService = SignInService();
  final SignInApple signInApple = SignInApple();
  final UserProvider userProvider = UserProvider();

  Future<UserModel> signInGoogle() {
    return signInService.signInGoogle();
  }

  Future<UserModel> trySignInGoogle() {
    return signInService.trySignInGoogle();
  }

  logoutGoogle() {
    signInService.logoutGoogle();
  }

  Future<UserModel> signInMicrosoft() async {
    return signInService.signInMicrosoft();
  }

  Future<UserModel> trySignInMicrosoft() {
    return signInService.trySignInMicrosoft();
  }

  logoutMicrosoft() {
    signInService.logoutMicrosoft();
  }

  Future<UserModel> signInAppleAuth() async {
    return await signInApple.signInWithApple();
  }

  Future<String> createUserDocInHive(UserModel user) async {
    return await userProvider.createUserDocInHive(user);
  }
}
