import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

class SignInApple {
  late final fb.FirebaseAuth _auth = fb.FirebaseAuth.instance;

  Future<User?> signInWithApple() async {
    final credential = await SignInWithApple.getAppleIDCredential(
      scopes: [
        AppleIDAuthorizationScopes.email,
        AppleIDAuthorizationScopes.fullName,
      ],
      webAuthenticationOptions: WebAuthenticationOptions(
        clientId: 'com.example.redescomunicacionaisid',
        redirectUri: Uri.parse(
          'https://redescomunicacionais.firebaseapp.com/__/auth/handler',
        ),
      ),
    );

    final oAuthCredential = OAuthProvider("apple.com").credential(
      idToken: credential.identityToken,
      accessToken: credential.authorizationCode,
    );

    final userCredential = await _auth.signInWithCredential(oAuthCredential);
    final user = userCredential.user;
    if (user != null) {
      // O usuário foi autenticado com sucesso
      print('Usuário autenticado: ${user.email}');
    } else {
      // A autenticação falhou
      print('Falha na autenticação');
    }
    return user;
  }
}
