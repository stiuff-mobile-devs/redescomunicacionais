import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:crypto/crypto.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:redescomunicacionais/app/config/secrets.dart';
import 'package:redescomunicacionais/app/modules/user/data/model/user_model.dart';
import 'package:redescomunicacionais/app/modules/user/data/repository/user_repository.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

class SignInApple {
  FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final UserRepository _userRepository = UserRepository();

  Future<UserModel?> signInWithApple() async {
    UserCredential credential;
    UserModel? userModel;

    if (Platform.isIOS) {
      credential = await _whenPlatformApple();
    } else {
      // Para outras plataformas, como Android ou Web
      var appleProvider = AppleAuthProvider();
      credential = await _firebaseAuth.signInWithProvider(appleProvider);
    }

    if (credential.user != null) {
      debugPrint("Apple sign-in successful: ${credential.user?.email}");

      await _onAppleSignIn(credential);
      final refreshedUser = FirebaseAuth.instance.currentUser;
      if (refreshedUser != null) {
        userModel = await _createUserDoc(refreshedUser);
      }
    } else {
      debugPrint("Apple sign-in failed or cancelled.");
    }

    return userModel;
  }

  Future<UserCredential> _whenPlatformApple() async {
    //Em fluxos de login (como Apple Sign In), esse nonce serve para proteger contra replay e garantir que o token recebido foi emitido para essa tentativa especifica.
    String generateNonce([int length = 32]) {
      const charset =
          '0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._';
      final random = Random.secure();
      return List.generate(
          length, (_) => charset[random.nextInt(charset.length)]).join();
    }

    // O SHA256 do nonce é o que é enviado para o provedor de autenticação (Apple, nesse caso) e depois verificado quando o token é recebido.
    String sha256ofString(String input) {
      final bytes = utf8.encode(input);
      final digest = sha256.convert(bytes);
      return digest.toString();
    }

    final rawNonce = generateNonce();
    final nonce = sha256ofString(rawNonce);

    final credential = await SignInWithApple.getAppleIDCredential(
      scopes: [
        AppleIDAuthorizationScopes.email,
        AppleIDAuthorizationScopes.fullName,
      ],
      webAuthenticationOptions: WebAuthenticationOptions(
        clientId: Secrets.appleClientId,
        redirectUri: Uri.parse(Secrets.appleRedirectUri),
      ),
      nonce: nonce,
    );

    final appleOauthProvider = OAuthProvider(
      "apple.com",
    );

    appleOauthProvider.setScopes([
      'email',
      'name',
    ]);

    final oauthCredential = appleOauthProvider.credential(
      idToken: credential.identityToken,
      rawNonce: rawNonce,
    );

    UserCredential auth =
        await FirebaseAuth.instance.signInWithCredential(oauthCredential);
    if (auth.user != null) {
      if (auth.user != null) {
        if (auth.user?.email == null && credential.email != null) {
          await auth.user?.updateEmail(credential.email!);
        }

        if (auth.user?.displayName == null &&
            credential.givenName != null &&
            credential.familyName != null) {
          await auth.user?.updateDisplayName(
              '${credential.givenName} ${credential.familyName}');
        }
      }
    }
    return auth;
  }

  _onAppleSignIn(UserCredential credential) async {
    try {
      if (credential.user != null) {
        await credential.user!.reload();
        _firebaseAuth = FirebaseAuth.instance;
      }
    } catch (err) {
      debugPrint("onAppleSignIn: $err");
    }
  }

  Future<UserModel?> _createUserDoc(
    User userCredential,
  ) async {
    try {
      return await _userRepository.createUserDoc(
        userCredential.email ?? '',
        userCredential.displayName ?? '',
        userCredential.uid,
        userCredential.photoURL ?? '',
      );
    } catch (err) {
      debugPrint(err.toString());
      return null;
    }
  }
}
