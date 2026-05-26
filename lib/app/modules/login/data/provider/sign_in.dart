import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:redescomunicacionais/app/config/secrets.dart';
import 'package:redescomunicacionais/app/modules/user/data/model/user_model.dart';
import 'package:redescomunicacionais/app/modules/user/data/repository/user_repository.dart';

class SignInService {
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;
  late final Future<void> _init = _googleSignIn.initialize(
    serverClientId: Secrets.googleServerClientId,
  );
  late final fb.FirebaseAuth _auth = fb.FirebaseAuth.instance;
  final UserRepository _userRepository = UserRepository();

  SignInService();

  Future<UserModel> signInGoogle() async {
    try {
      await _init;
      var account = await _googleSignIn.authenticate();
      return _signIn(account);
    } catch (e) {
      debugPrint('Error initializing GoogleSignIn: $e');
      throw Exception("Erro ao fazer login com Google");
    }
  }

  Future<UserModel> _signIn(GoogleSignInAccount account) async {
    try {
      final GoogleSignInAuthentication googleAuth = account.authentication;
      final authCredential = fb.GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
      );
      var userCredential = await _auth.signInWithCredential(authCredential);

      return await _createUserDoc(
          userCredential, account.displayName, account.photoUrl);
    } catch (e) {
      debugPrint('Error during Google sign-in: $e');
      throw Exception("Erro ao fazer login com Google");
    }
  }

  Future<UserModel> _createUserDoc(
    fb.UserCredential userCredential,
    String? displayName,
    String? photoUrl,
  ) async {
    try {
      return await _userRepository.createUserDoc(
        userCredential.user!.email ?? '',
        displayName ?? userCredential.user!.displayName ?? '',
        userCredential.user!.uid,
        photoUrl ?? userCredential.user!.photoURL ?? '',
      );
    } catch (err) {
      debugPrint(err.toString());
      throw Exception("Erro ao criar documento do usuário");
    }
  }

  Future<UserModel> trySignInGoogle() async {
    final User? firebaseUser = FirebaseAuth.instance.currentUser;

    if (firebaseUser != null) {
      try {
        // Busca o documento completo do usuário no Firestore
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(firebaseUser.uid)
            .get();

        if (userDoc.exists) {
          return await _userRepository.createUserDoc(
            firebaseUser.email ?? '',
            userDoc.get('name') ?? '',
            userDoc.get('id') ?? firebaseUser.uid,
            userDoc.get('urlImage') ?? firebaseUser.photoURL ?? '',
          );

        }
      } catch (err) {
        debugPrint("Erro ao buscar dados do usuário: $err");
      }
    }

    return await _trySignSilentlyInGoogle();
  }

  Future<UserModel> _trySignSilentlyInGoogle() async {
    try {
      final Future<GoogleSignInAccount?>? account =
          _googleSignIn.attemptLightweightAuthentication();

      if (account == null) {
        throw Exception("Erro ao tentar fazer login silenciosamente");
      }

      final googleUser = await account;

      if(googleUser == null) {
        debugPrint("Nenhum usuário encontrado durante login silencioso.");
        throw Exception("Nenhum usuário encontrado durante login silencioso");
      }
      else{
        debugPrint("Usuário encontrado durante login silencioso: ${googleUser.email}");

        return await _signIn(googleUser);
      }
    } catch (e) {
      debugPrint('Error initializing GoogleSignIn: $e');
      throw Exception("Erro ao tentar fazer login silenciosamente");
    }
  }

  Future<void> logoutGoogle() async {
    await _googleSignIn.signOut();
    await FirebaseAuth.instance.signOut();
  }

  Future<UserModel> signInMicrosoft() async {
    final microsoftProvider = OAuthProvider("microsoft.com");
    try {
      final UserCredential userCredential =
          await FirebaseAuth.instance.signInWithProvider(microsoftProvider);
      final user = userCredential.user;

      if (user != null) {
        return await _userRepository.createUserDoc(
          userCredential.user!.email!,
          userCredential.user!.displayName!,
          userCredential.user!.uid,
          userCredential.user!.photoURL!,
        );
      }
    } on FirebaseAuthException catch (e) {
      debugPrint("Erro no login com Microsoft: ${e.message}");
    } catch (err) {
      debugPrint(err.toString());
    }
    throw Exception("Erro ao fazer login com Microsoft");
  }

  Future<UserModel> trySignInMicrosoft() async {
    final User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      try {
        debugPrint("Usuário já estava logado: ${user.email}");
        return await _userRepository.createUserDoc(
          user.email!,
          user.displayName!,
          user.uid,
          user.photoURL!,
        );
      } catch (err) {
        debugPrint("Erro ao verificar usuário silenciosamente: $err");
        throw Exception("Erro ao verificar usuário silenciosamente");
      }
    }

    debugPrint("Nenhum usuário logado.");
    throw Exception("Nenhum usuário logado");
  }

  Future<void> logoutMicrosoft() async {
    try {
      // O método signOut serve para todos os provedores.
      await FirebaseAuth.instance.signOut();
      debugPrint("Usuário deslogado com sucesso! 👋");
    } catch (e) {
      debugPrint("Erro ao fazer logout: $e");
    }
  }
}
