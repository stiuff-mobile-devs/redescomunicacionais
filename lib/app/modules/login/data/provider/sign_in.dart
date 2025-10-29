import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:redescomunicacionais/app/modules/user/data/model/user_model.dart';
import 'package:redescomunicacionais/app/modules/user/data/repository/user_repository.dart';

class SignInService {
  final GoogleSignIn _googleSignIn = GoogleSignIn(scopes: ['email']);
  final UserRepository _userRepository = UserRepository();

  SignInService();

  Future<UserModel?> signInGoogle() async {
    var account = await _googleSignIn.signIn();
    var b = await account!.authentication;
    final authCredential = GoogleAuthProvider.credential(
        accessToken: b.accessToken, idToken: b.idToken);
    try {
      var userCredential =
          await FirebaseAuth.instance.signInWithCredential(authCredential);

      return await _userRepository.createUserDoc(
        userCredential.user!.email!,
        userCredential.user!.displayName!,
        userCredential.user!.uid,
        userCredential.user!.photoURL!,
      );
    } catch (err) {
      debugPrint(err.toString());
    }
    return null;
  }

  Future<UserModel?> trySignInGoogle() async {
    final User? firebaseUser = FirebaseAuth.instance.currentUser;
    if (firebaseUser != null) {
      return UserModel(
        id: firebaseUser.uid,
        name: firebaseUser.displayName,
        email: firebaseUser.email ?? '',
        urlImage: firebaseUser.photoURL,
        role: 'user',
        createdAt: firebaseUser.metadata.creationTime,
        roleUpdatedAt: null,
        roleUpdatedBy: null,
        status: 'active',
        statusUpdatedAt: null,
        statusUpdatedBy: null,
        statusObservation: null,
      );
      ;
    }
    var account = await _googleSignIn.signInSilently();
    if (account == null) {
      return null;
    }
    var b = await account.authentication;
    final authCredential = GoogleAuthProvider.credential(
        accessToken: b.accessToken, idToken: b.idToken);
    try {
      var userCredential =
          await FirebaseAuth.instance.signInWithCredential(authCredential);
      return await _userRepository.createUserDoc(
        userCredential.user!.email!,
        userCredential.user!.displayName!,
        userCredential.user!.uid,
        userCredential.user!.photoURL!,
      );
    } catch (err) {
      debugPrint(err.toString());
    }
    return null;
  }

  logoutGoogle() async {
    await _googleSignIn.signOut();
    await FirebaseAuth.instance.signOut();
  }

  Future<UserModel?> signInMicrosoft() async {
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
    return null;
  }

  Future<UserModel?> trySignInMicrosoft() async {
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
        return null;
      }
    }

    debugPrint("Nenhum usuário logado.");
    return null;
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
