import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:redescomunicacionais/app/config/secrets.dart';
import 'package:redescomunicacionais/app/modules/user/data/repository/user_repository.dart';
import 'package:redescomunicacionais/app/modules/utils/components/friendly_exception.dart';

class SignInService {
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;
  late final Future<void> _init = _googleSignIn.initialize(
    serverClientId: Secrets.googleServerClientId,
  );
  late final fb.FirebaseAuth _auth = fb.FirebaseAuth.instance;
  final UserRepository _userRepository = UserRepository();

  SignInService();

  Future<void> signInGoogle() async {
    try {
      await _init;
      var account = await _googleSignIn.authenticate();
      await _signIn(account);
    } on FriendlyException {
      rethrow;
    } catch (e) {
      debugPrint('Error initializing GoogleSignIn: $e');
      throw Exception("Erro ao fazer login com Google");
    }
  }

  Future<void> _signIn(GoogleSignInAccount account) async {
    try {
      final GoogleSignInAuthentication googleAuth = account.authentication;
      final authCredential = fb.GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
      );
      var userCredential = await _auth.signInWithCredential(authCredential);

      return await _createUserDoc(
          userCredential, account.displayName, account.photoUrl);
    } on FriendlyException {
      rethrow;
    } catch (e) {
      debugPrint('Error during Google sign-in: $e');
      throw Exception("Erro ao fazer login com Google");
    }
  }

  Future<void> _createUserDoc(
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
    } on FriendlyException {
      rethrow;
    } catch (err) {
      debugPrint(err.toString());
      throw Exception("Erro ao criar documento do usuário");
    }
  }

  Future<void> trySignInGoogle() async {
    try {
      final googleUser = await _googleSignIn.attemptLightweightAuthentication(); 

      if (googleUser == null) {
        debugPrint("Nenhum usuário encontrado durante login silencioso.");
        throw Exception("Nenhum usuário logado anteriormente");
      } 
        
      debugPrint("Usuário encontrado durante login silencioso: ${googleUser.email}");
      return await _signIn(googleUser);
      
    } catch (e) {
      debugPrint('Error initializing GoogleSignIn: $e');
      throw Exception("Erro ao tentar fazer login silenciosamente: $e");
    }
  }

  Future<void> logoutGoogle() async {
    await _googleSignIn.signOut();
    await FirebaseAuth.instance.signOut();
  }

  Future<void> signInMicrosoft() async {
    final microsoftProvider = OAuthProvider("microsoft.com");
    try {
      final UserCredential userCredential =
          await FirebaseAuth.instance.signInWithProvider(microsoftProvider);
      final user = userCredential.user;

      if (user != null) {
        // Contas Microsoft podem vir sem nome ou foto
        return await _userRepository.createUserDoc(
          user.email ?? '',
          user.displayName ?? '',
          user.uid,
          user.photoURL ?? '',
        );
      }
    } on FriendlyException {
      rethrow;
    } on FirebaseAuthException catch (e) {
      debugPrint("Erro no login com Microsoft: ${e.message}");
    } catch (err) {
      debugPrint(err.toString());
    }
    throw Exception("Erro ao fazer login com Microsoft");
  }

  Future<void> trySignInMicrosoft() async {
    final User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      try {
        debugPrint("Usuário já estava logado: ${user.email}");
        return await _userRepository.createUserDoc(
          user.email ?? '',
          user.displayName ?? '',
          user.uid,
          user.photoURL ?? '',
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
