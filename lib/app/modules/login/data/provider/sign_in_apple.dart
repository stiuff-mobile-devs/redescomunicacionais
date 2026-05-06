import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:redescomunicacionais/app/modules/user/data/model/user_model.dart';
import 'package:redescomunicacionais/app/modules/user/data/repository/user_repository.dart';

class SignInApple {
  late FirebaseAuth _firebaseAuth;
  final UserRepository _userRepository = UserRepository();

  SignInApple() {
    _firebaseAuth = FirebaseAuth.instance;
  }

  Future<UserModel> signInWithApple() async {
    try {
      // Usa o provider nativo do Firebase em todas as plataformas
      final appleProvider = AppleAuthProvider();
      appleProvider.addScope('email');
      appleProvider.addScope('name');

      final credential = await _firebaseAuth.signInWithProvider(appleProvider);

      if (credential.user != null) {
        debugPrint("Apple sign-in successful: ${credential.user?.email}");
        await _onAppleSignIn(credential);

        final refreshedUser = FirebaseAuth.instance.currentUser;
        if (refreshedUser != null) {
          return await _createUserDoc(refreshedUser);
        }
      } else {
        debugPrint("Apple sign-in failed or cancelled.");
      }
    } catch (e) {
      debugPrint("Erro de Login Apple: $e");
      rethrow;
    }

      throw Exception("Erro ao fazer login com Apple");
  }

  Future<void> _onAppleSignIn(UserCredential credential) async {
    try {
      if (credential.user != null) {
        await credential.user!.reload();
        _firebaseAuth = FirebaseAuth.instance;
        debugPrint("Apple sign-in processado com sucesso");
      }
    } catch (err) {
      debugPrint("Erro em _onAppleSignIn: $err");
      rethrow;
    }
  }

  Future<UserModel> _createUserDoc(User userCredential) async {
    try {
      return await _userRepository.createUserDoc(
        userCredential.email ?? '',
        userCredential.displayName ?? '',
        userCredential.uid,
        userCredential.photoURL ?? '',
      );
    } catch (err) {
      debugPrint("Erro ao criar documento do usuário: $err");
      throw Exception("Erro ao criar documento do usuário");
    }
  }
}
