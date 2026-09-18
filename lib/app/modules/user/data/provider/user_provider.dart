import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:redescomunicacionais/app/modules/user/data/model/user_model.dart';
import 'package:redescomunicacionais/app/modules/user/utils/userRoles.dart';
import 'package:redescomunicacionais/app/modules/mesh/services/key_storage_service.dart';
import 'package:redescomunicacionais/app/modules/mesh/model/public_key_model.dart';

class UserProvider {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseFunctions _functions = FirebaseFunctions.instanceFor(region: 'southamerica-east1');
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final KeyStorageService _keyStorageService = KeyStorageService();

  // Armazena sempre na mesma chave para garantir apenas uma entrada
  final String hiveUserKey = 'current_user';
  final String userCollection = 'users';

  Future<void> createUserDoc(
      String email, String name, String uid, String urlImage) async {
    UserModel userFirebase = UserModel.empty();

    UserModel newUser = UserModel(
      id: uid,
      name: name,
      email: email,
      urlImage: urlImage,
      role: UserRoles.user,
      createdAt: DateTime.now(),
      lastUpdated: DateTime.now(),
    );

    try {
      userFirebase = await _getCurrentUserFromFirebase(uid);
    } catch (e) {
      debugPrint("Usuário não encontrado no Firebase");
    }

    if (userFirebase.role == UserRoles.guest) {
      try {
        await _createUserDocInFirebase(newUser);
        await createUserDocInHive(newUser);
      } catch (e) {
        throw Exception("Erro ao criar documento no Firebase: $e");
      }
    } else {
      try {
        await createUserDocInHive(userFirebase);
      } catch (e) {
        throw Exception("Erro ao criar documento no Hive: $e");
      }
    }
  }

  Future<void> _createUserDocInFirebase(UserModel user) async {
    try {
      await _firestore
          .collection(userCollection)
          .doc(user.id)
          .set(user.toJson());
    } catch (e) {
      throw Exception("Erro ao criar usuário do Firebase: $e");
    }
  }

  Future<void> createUserDocInHive(UserModel user) async {
    try {
       var box = Hive.isBoxOpen(userCollection)
          ? Hive.box<UserModel>(userCollection)
          : await Hive.openBox<UserModel>(userCollection);

      // Verifica se a chave já existe

      await box.put(hiveUserKey, user);
      await box.flush(); // Força a escrita no disco
    } catch (e) {
      throw Exception("Erro ao criar usuário no Hive: $e");
    }
  }

  Future<UserModel> getCurrentUserFromHive() async {
    try {
       var box = Hive.isBoxOpen(userCollection)
          ? Hive.box<UserModel>(userCollection)
          : await Hive.openBox<UserModel>(userCollection);

      if (!box.containsKey(hiveUserKey)) {
        throw Exception("Nenhum usuário encontrado no Hive");
      }

      UserModel user = box.get(hiveUserKey)!;

      debugPrint("Usuário recuperado do Hive:");

      return user;
    } catch (e) {
      return UserModel.empty();
    }
  }

  Future<UserModel> _getCurrentUserFromFirebase(String uid) async {
    try {
      DocumentSnapshot doc =
          await _firestore.collection(userCollection).doc(uid).get();

      if (!doc.exists) {
        throw Exception("Nenhum usuário encontrado no Firebase");
      }

      UserModel user = UserModel.fromJson(doc.data() as Map<String, dynamic>);
      debugPrint("Usuário recuperado do Firebase: ${user.name}");
      return user;
    } catch (e) {
      throw Exception("Erro ao recuperar usuário do Firebase: $e");
    }
  }

  Future<List<UserModel>> getAllUsersFromFirebase() async {
    try {
      QuerySnapshot querySnapshot =
          await _firestore.collection(userCollection).get();

      return querySnapshot.docs.map((doc) {
        Map<String, dynamic> userData = doc.data() as Map<String, dynamic>;

        userData['id'] = doc.id;

        return UserModel.fromJson(userData);
      }).toList();
    } catch (e) {
      throw Exception("Erro ao buscar usuários: $e");
    }
  }

  Future<void> deleteCurrentUserFromHive() async {
    try {
      var box = Hive.isBoxOpen(userCollection)
          ? Hive.box<UserModel>(userCollection)
          : await Hive.openBox<UserModel>(userCollection);

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

  Future<void> deleteCurrentUserAccountFromFirebase() async {
    final currentFirebaseUser = _auth.currentUser;
    final currentUserFromHive = await getCurrentUserFromHive();

    final String uid = currentFirebaseUser?.uid.isNotEmpty == true
        ? currentFirebaseUser!.uid
        : currentUserFromHive.id;

    if (uid.isEmpty) {
      throw Exception('Não foi possível identificar a conta para exclusão.');
    }

    if (currentFirebaseUser == null) {
      throw Exception(
          'Usuário não autenticado no Firebase. Faça login novamente.');
    }

    try {
      await _firestore.collection('roles').doc(uid).delete();
      await _firestore.collection(userCollection).doc(uid).delete();
      await currentFirebaseUser.delete();
      await deleteCurrentUserFromHive();
      await _auth.signOut();
    } on FirebaseAuthException catch (e) {
      if (e.code == 'requires-recent-login') {
        throw Exception(
            'Por segurança, faça login novamente antes de excluir sua conta.');
      }
      throw Exception('Erro ao excluir conta: ${e.message ?? e.code}');
    }
  }

  Future<void> updateUserRole(String userId, String role, String adminEmail,
      Map<String, String> operationsCities) async {
    try {
      final docRef = _firestore.collection(userCollection).doc(userId);

      await docRef.update({
        'operationsCities': operationsCities,
        'role': role,
        'roleUpdatedAt': FieldValue.serverTimestamp(),
        'roleUpdatedBy': adminEmail,
        'lastUpdated': FieldValue.serverTimestamp(),
      });

      DocumentSnapshot updatedDoc = await docRef.get();
      UserModel updatedUser =
          UserModel.fromJson(updatedDoc.data() as Map<String, dynamic>);

      await _updateUserRoleinRoles(
          userId, role, adminEmail, operationsCities, updatedUser.email);

      if (updatedUser.email == adminEmail) {
        await _updateUserInHive(updatedUser);
      }
    } catch (e) {
      throw Exception("Erro ao atualizar e recuperar usuário: $e");
    }
  }

  Future<void> _updateUserRoleinRoles(
      String userId,
      String role,
      String adminEmail,
      Map<String, String> operationsCities,
      String userEmail) async {
    try {
      final docRef = _firestore.collection('roles').doc(userId);

      await docRef.set({
        'userId': userId,
        'role': role,
        'operationsCities': operationsCities,
        'userEmail': userEmail,
        'roleUpdatedAt': FieldValue.serverTimestamp(),
        'roleUpdatedBy': adminEmail,
        'lastUpdated': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception("Erro ao atualizar e recuperar usuário: $e");
    }
  }

  Future<void> _updateUserInHive(UserModel user) async {
    try {
       var box = Hive.isBoxOpen(userCollection)
          ? Hive.box<UserModel>(userCollection)
          : await Hive.openBox<UserModel>(userCollection);

      await box.put(hiveUserKey, user);
      await box.flush(); // Força a escrita no disco

      return;
    } catch (e) {
      debugPrint("Erro ao atualizar usuário no Hive: $e");
      throw Exception("Erro ao atualizar usuário no Hive: $e");
    }
  }

  Future<void> updateUserNameToFirebase(String userId, String name) async {
    try {
      final docRef = _firestore.collection(userCollection).doc(userId);

      await docRef.update({
        'name': name,
        'lastUpdated': FieldValue.serverTimestamp(),
      });

      DocumentSnapshot updatedDoc = await docRef.get();
      UserModel updatedUser =
          UserModel.fromJson(updatedDoc.data() as Map<String, dynamic>);
      await _updateUserInHive(updatedUser);
    } catch (e) {
      throw Exception("Erro ao atualizar e recuperar usuário: $e");
    }
  }

  Future<bool> updatePublicKeyInFirebase(
      String email, String newPublicKey) async {
    try {
      DocumentReference docRef =
          _firestore.collection('public_keys').doc(email);
      DocumentSnapshot doc = await docRef.get();

      if (!doc.exists) {
        return false;
      }

      final data = doc.data() as Map<String, dynamic>?;
      final String? currentPublicKey = data?['publicKey'];

      Map<String, dynamic> updateData = {
        'publicKey': newPublicKey,
        'lastUpdated': DateTime.now(),
      };

      // Se existir uma chave pública atual, move para a lista de antigas
      if (currentPublicKey != null && currentPublicKey.isNotEmpty) {
        updateData['oldPublicKeys'] = FieldValue.arrayUnion([currentPublicKey]);
      }

      await docRef.update(updateData);

      return true;
    } catch (e) {
      throw Exception(
          "Erro ao verificar e atualizar chaves do usuário no Firebase: $e");
    }
  }

  Future<String?> getPrivateKeyInStorage() async {
    return await _keyStorageService.getPrivateKey();
  }

  Future<void> savePublicKey(PublicKeyModel publicKeyModel) async {
    try {
      final callable = _functions.httpsCallable('savePublicKey');
      final payload = publicKeyModel.toJsonStringData();

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

  Future<void> createPublicKeyInFirebase(PublicKeyModel publicKeyModel) async {
    try {
      await _firestore.collection('public_keys').doc(publicKeyModel.email).set(
        publicKeyModel.toJson(),
        SetOptions(merge: true),
      );
    } catch (e) {
      throw Exception("Erro ao criar public Key");
    }
  }

  Future<void> saveLocalSelectedCity(String cityName) async {
    try {
      var box = Hive.isBoxOpen(userCollection)
          ? Hive.box<UserModel>(userCollection)
          : await Hive.openBox<UserModel>(userCollection);

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
      var box = Hive.isBoxOpen(userCollection)
          ? Hive.box<UserModel>(userCollection)
          : await Hive.openBox<UserModel>(userCollection);

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
