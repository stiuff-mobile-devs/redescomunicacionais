import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:redescomunicacionais/app/modules/user/data/model/user_model.dart';
import 'package:redescomunicacionais/app/modules/utils/user/userRoles.dart';
import 'package:redescomunicacionais/app/modules/mesh/services/key_storage_service.dart';
import 'package:redescomunicacionais/app/modules/mesh/model/public_key_model.dart';
import 'package:redescomunicacionais/app/modules/utils/components/friendly_exception.dart';
import 'package:redescomunicacionais/app/modules/utils/translations/locale_keys.dart';

class UserProvider {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseFunctions _functions = FirebaseFunctions
      .instanceFor(region: 'southamerica-east1');
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final KeyStorageService _keyStorageService = KeyStorageService();

  // Armazena sempre na mesma chave para garantir apenas uma entrada
  final String hiveUserKey = 'current_user';

  // Box local (precisa ser a mesma aberta no HiveService) e coleção remota.
  // São coisas diferentes: não use uma no lugar da outra.
  static const String _hiveBox = 'users';
  static const String _collection = 'users';

  // Tempo máximo desde o login para o Firebase aceitar excluir a conta
  static const Duration _recentLoginWindow = Duration(minutes: 5);

  Future<Box<UserModel>> _box() async {
    return Hive.isBoxOpen(_hiveBox)
        ? Hive.box<UserModel>(_hiveBox)
        : await Hive.openBox<UserModel>(_hiveBox);
  }

  // Chamado no login: baixa o usuário da nuvem para o Hive (sincronia de cima
  // para baixo) e cria o documento só quando ele realmente não existe.
  Future<void> createUserDoc(
      String email, String name, String uid, String urlImage) async {
    // E-mail é a identidade da chave de assinatura e exigido pelas regras
    if (email.trim().isEmpty) {
      throw const FriendlyException(LocaleKeys.loginEmailRequired,
          details: 'Conta sem e-mail no provedor de login.');
    }

    DocumentSnapshot<Map<String, dynamic>> doc;
    try {
      // Só o servidor responde se o documento existe (o cache pode estar vazio)
      doc = await _firestore
          .collection(_collection)
          .doc(uid)
          .get(const GetOptions(source: Source.server));
    } catch (e) {
      // Sem rede, sem permissão ou outro erro: mantém o usuário local, se for o mesmo
      debugPrint("Erro ao ler o usuário do Firebase: $e");
      final UserModel localUser = await getCurrentUserFromHive();
      if (localUser.id == uid) {
        debugPrint("Mantendo o usuário salvo no Hive.");
        return;
      }
      rethrow;
    }

    if (!doc.exists) {
      final now = DateTime.now();
      final UserModel newUser = UserModel(
        id: uid,
        name: name,
        email: email,
        urlImage: urlImage,
        role: UserRoles.user,
        createdAt: now,
        lastUpdated: now,
      );
      await _createUserDocInFirebase(newUser);
      await _saveFromCloud(newUser);
      return;
    }

    final UserModel cloudUser = UserModel.fromJson(doc.data()!);
    cloudUser.id ??= doc.id;
    await _saveFromCloud(cloudUser);
  }

  // Baixa o usuário logado da nuvem para o Hive (ex.: quando a internet volta).
  // Devolve o usuário atualizado ou null se não foi possível.
  Future<UserModel?> refreshCurrentUserFromCloud() async {
    final String? uid = _auth.currentUser?.uid;
    if (uid == null) return null;

    final UserModel localUser = await getCurrentUserFromHive();
    if (localUser.id != uid) return null;

    try {
      final doc = await _firestore
          .collection(_collection)
          .doc(uid)
          .get(const GetOptions(source: Source.server));
      if (!doc.exists) return null;

      final UserModel cloudUser = UserModel.fromJson(doc.data()!);
      cloudUser.id ??= uid;
      await _saveFromCloud(cloudUser);
      return getCurrentUserFromHive();
    } catch (e) {
      debugPrint("Não foi possível atualizar o usuário da nuvem: $e");
      return null;
    }
  }

  // Grava no Hive o usuário vindo da nuvem, preservando os campos só locais
  Future<void> _saveFromCloud(UserModel cloudUser) async {
    final UserModel localUser = await getCurrentUserFromHive();
    if (localUser.id == cloudUser.id) {
      cloudUser.selectedAppCity = localUser.selectedAppCity;
    }
    await createUserDocInHive(cloudUser);
  }

  //TODO: migrar para uma Cloud Function (o app não deve acessar o Firestore direto)
  Future<void> _createUserDocInFirebase(UserModel user) async {
    try {
      await _firestore
          .collection(_collection)
          .doc(user.id)
          .set(user.toFirebase());
    } catch (e) {
      throw Exception("Erro ao criar usuário do Firebase: $e");
    }
  }

  Future<void> createUserDocInHive(UserModel user) async {
    try {
      final box = await _box();
      await box.put(hiveUserKey, user);
      await box.flush(); // Força a escrita no disco
    } catch (e) {
      throw Exception("Erro ao criar usuário no Hive: $e");
    }
  }

  Future<UserModel> getCurrentUserFromHive() async {
    try {
      final box = await _box();
      final UserModel? user = box.get(hiveUserKey);
      if (user == null) {
        debugPrint("Nenhum usuário encontrado no Hive");
        return UserModel.empty();
      }
      return user;
    } catch (e) {
      debugPrint("Erro ao ler o usuário do Hive: $e");
      return UserModel.empty();
    }
  }

  //TODO: O numero de usuarios tende a crescer, então talvez seja interessante paginar a busca de usuarios no futuro
  //TODO: migrar para uma Cloud Function (o app não deve acessar o Firestore direto)
  Future<List<UserModel>> getAllUsersFromFirebase() async {
    try {
      final querySnapshot = await _firestore.collection(_collection).get();

      final List<UserModel> users = [];
      for (final doc in querySnapshot.docs) {
        // Um documento com problema não pode derrubar a lista inteira
        try {
          final UserModel user = UserModel.fromJson(doc.data());
          user.id = doc.id;
          users.add(user);
        } catch (e) {
          debugPrint("Usuário ${doc.id} ignorado na listagem: $e");
        }
      }
      return users;
    } catch (e) {
      throw Exception("Erro ao buscar usuários: $e");
    }
  }

  Future<void> deleteCurrentUserFromHive() async {
    try {
      final box = await _box();

      if (box.containsKey(hiveUserKey)) {
        await box.delete(hiveUserKey);
        await box.flush();
        debugPrint("Usuário removido do Hive com sucesso");
      } else {
        debugPrint("Nenhum usuário encontrado no Hive para remover");
      }
    } catch (e) {
      debugPrint("Erro ao remover usuário do Hive: $e");
      throw Exception("Erro ao remover usuário do Hive: $e");
    }
  }

  //TODO: migrar para uma Cloud Function (o app não deve acessar o Firestore direto)
  Future<void> deleteCurrentUserDocFromFirebase() async {
    final currentFirebaseUser = _auth.currentUser;

    if (currentFirebaseUser == null) {
      throw const FriendlyException(LocaleKeys.loginAgain,
          details: 'Usuário não autenticado no Firebase.');
    }

    // Confere o login recente ANTES de apagar qualquer coisa, para não
    // apagar o documento e depois o Firebase recusar excluir a conta
    final tokenResult = await currentFirebaseUser.getIdTokenResult();
    final DateTime? authTime = tokenResult.authTime;
    if (authTime == null ||
        DateTime.now().difference(authTime) > _recentLoginWindow) {
      throw FriendlyException(LocaleKeys.loginAgainBeforeDelete,
          details: 'Último login em $authTime.');
    }

    try {
      // Apaga o documento do usuário, a conta no Auth e o Hive
      await _firestore
          .collection(_collection)
          .doc(currentFirebaseUser.uid)
          .delete();
      await currentFirebaseUser.delete();
      await deleteCurrentUserFromHive();
      await _auth.signOut();
    } on FirebaseAuthException catch (e) {
      if (e.code == 'requires-recent-login') {
        throw FriendlyException(LocaleKeys.loginAgainBeforeDelete,
            details: e.code);
      }
      throw Exception('Erro ao excluir conta: ${e.message ?? e.code}');
    }
  }

  Future<void> updateUserRole(String userId, String role, String adminEmail,
      Map<String, String> operationsCities) async {
    try {
      final callable = _functions.httpsCallable('setUserRole');
      await callable.call({
        'targetUid': userId,
        'role': role,
        'operationsCities': operationsCities,
      });

      // Se o alvo é o próprio usuário logado, replica no Hive o que a Function gravou
      if (userId == _auth.currentUser?.uid) {
        await _auth.currentUser?.getIdToken(true);

        UserModel user = await getCurrentUserFromHive();
        if (user.id != userId) return;

        final now = DateTime.now();
        user.role = role;
        user.operationsCities = operationsCities;
        // Quem alterou é identificado pelo uid (contrato das regras do Firestore)
        user.roleUpdatedBy = _auth.currentUser?.uid ?? adminEmail;
        user.roleUpdatedAt = now;
        user.lastUpdated = now;

        await createUserDocInHive(user);
      }
    } on FirebaseFunctionsException catch (e) {
      throw Exception("Erro no Firebase Functions (${e.code}): ${e.message}");
    } catch (e) {
      throw Exception("Erro ao atualizar e recuperar usuário: $e");
    }
  }

  //TODO: migrar para uma Cloud Function (o app não deve acessar o Firestore direto)
  Future<void> updateUserNameToFirebase(String userId, String name) async {
    try {
      final docRef = _firestore.collection(_collection).doc(userId);

      // Só campos de perfil: campos do admin são negados pelas regras
      await docRef.update({
        ...UserModel(name: name).toFirebaseProfile(),
        'lastUpdated': FieldValue.serverTimestamp(),
      });

      final updatedDoc = await docRef.get();
      final UserModel updatedUser = UserModel.fromJson(updatedDoc.data()!);
      updatedUser.id ??= userId;

      await _saveFromCloud(updatedUser);
    } catch (e) {
      throw Exception("Erro ao atualizar e recuperar usuário: $e");
    }
  }

  Future<String?> getPrivateKeyInStorage() async {
    return await _keyStorageService.getPrivateKey();
  }

  Future<void> savePublicKey(PublicKeyModel publicKeyModel) async {
    try {
      final callable = _functions.httpsCallable('savePublicKey');
      final payload = publicKeyModel.toJson();

      await callable.call(payload);
    } on FirebaseFunctionsException catch (e) {
      if (e.code == 'internal') {
        debugPrint("Internal server error: ${e.message}");
      } else if (e.code == 'permission-denied') {
        debugPrint("Permission denied!");
      } else {
        debugPrint("API error while saving public key: ${e.code}");
      }
    }
    catch (e) {
      throw Exception("Error saving public Key");
    }
  }

  Future<void> saveLocalSelectedCity(String cityName) async {
    try {
      final box = await _box();

      if (box.containsKey(hiveUserKey)) {
        UserModel user = box.get(hiveUserKey)!;
        user.selectedAppCity = cityName;

        await user.save();

        debugPrint("Cidade salva no Hive do usuário: $cityName");
      }
    } catch (e) {
      debugPrint("Erro ao salvar cidade localmente: $e");
    }
  }

  Future<void> clearLocalSelectedCity() async {
    try {
      final box = await _box();

      if (box.containsKey(hiveUserKey)) {
        UserModel user = box.get(hiveUserKey)!;
        user.selectedAppCity = null;

        await user.save();

        debugPrint("Cidade removida do Hive do usuário.");
      }
    } catch (e) {
      debugPrint("Erro ao limpar cidade local: $e");
    }
  }
}
