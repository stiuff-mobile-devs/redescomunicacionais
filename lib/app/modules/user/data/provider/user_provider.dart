import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:redescomunicacionais/app/modules/user/data/model/user_model.dart';
import 'package:redescomunicacionais/app/modules/user/utils/userRoles.dart';

enum UserRole { user, admin, editor }

class UserProvider {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Armazena sempre na mesma chave para garantir apenas uma entrada
  final String hiveUserKey = 'current_user';

  Future<UserModel> createUserDoc(
      String email, String name, String uid, String urlImage) async {
    UserModel userHive = UserModel.empty();
    UserModel userFirebase = UserModel.empty();

    UserModel newUser = UserModel(
      id: uid,
      name: name,
      email: email,
      urlImage: urlImage,
      role: 'user',
      createdAt: DateTime.now(),
      status: 'active',
    );

    try {
      userFirebase = await getCurrentUserFromFirebase(uid);
    } catch (e) {
      debugPrint("Usuário não encontrado no Firebase");
    }

    try {
      userHive = await getCurrentUserFromHive();
    } catch (e) {
      debugPrint("Usuário não encontrado no Hive");
    }

    UserModel selectedUser =
        await _selectUpdatedUser(userFirebase, userHive, newUser);

    try {
      await _createUserDocInFirebase(selectedUser, name, urlImage);
    } catch (e) {
      throw Exception("Erro ao criar documento no Firebase: $e");
    }

    try {
      await createUserDocInHive(selectedUser);
    } catch (e) {
      debugPrint("Erro ao criar documento no Hive: $e");
    }
    try {
      await _updateBasicInformations(selectedUser, name, urlImage);
    } catch (e) {
      throw Exception("Erro ao atualizar informações básicas do usuário: $e");
    }

    return selectedUser;
  }

  Future<String> _createUserDocInFirebase(
      UserModel user, String name, String urlImage) async {
    try {
      DocumentSnapshot doc =
          await _firestore.collection('users').doc(user.id).get();

      final newUser = UserModel(
        id: user.id,
        urlImage: user.urlImage,
        name: user.name,
        email: user.email,
        role: user.role,
        createdAt: user.createdAt,
        roleUpdatedAt: user.roleUpdatedAt,
        roleUpdatedBy: user.roleUpdatedBy,
        status: user.status,
        statusUpdatedAt: user.statusUpdatedAt,
        statusUpdatedBy: user.statusUpdatedBy,
        statusObservation: user.statusObservation,
        lastUpdated: DateTime.now(),
      );
      try {
        await _firestore.collection('users').doc(user.id).set(newUser.toJson());
        return 'success';
      } catch (e) {
        throw Exception("Erro ao criar usuário do Firebase: $e");
      }
    } catch (e) {
      throw Exception("Erro ao criar usuário do Firebase: $e");
    }
  }

  Future<String> createUserDocInHive(UserModel user) async {
    try {
      var box = await Hive.openBox<UserModel>('users');

      // Verifica se a chave já existe
      
        await box.put(hiveUserKey, user);
        await box.flush(); // Força a escrita no disco
        return 'success';
      
    } catch (e) {
      throw Exception("Erro ao criar usuário no Hive: $e");
    }
  }

  Future<UserModel> _selectUpdatedUser(
      UserModel userFirebase, UserModel userHive, UserModel newUser) async {
    if (userFirebase.status == 'anonymous' && userHive.status == 'anonymous') {
      return newUser;
    } else if (userFirebase.status != 'anonymous' &&
        userHive.status == 'anonymous') {
      return userFirebase;
    } else if (userFirebase.status == 'anonymous' &&
        userHive.status != 'anonymous') {
      return userHive;
    } else {
      if (userFirebase.lastUpdated != null) {
        return userFirebase;
      } else {
        UserModel userWithTimestamp = UserModel(
          id: userHive.id,
          name: userHive.name,
          email: userHive.email,
          urlImage: userHive.urlImage,
          role: userHive.role,
          createdAt: userHive.createdAt,
          roleUpdatedAt: userHive.roleUpdatedAt,
          roleUpdatedBy: userHive.roleUpdatedBy,
          status: userHive.status,
          statusUpdatedAt: userHive.statusUpdatedAt,
          statusUpdatedBy: userHive.statusUpdatedBy,
          statusObservation: userHive.statusObservation,
          lastUpdated: DateTime.now(),
        );
        return userWithTimestamp;
      }
    }
  }

  Future<UserModel> getCurrentUserFromHive() async {
    try {
      var box = await Hive.openBox<UserModel>('users');

      if (!box.containsKey(hiveUserKey)) {
        throw Exception("Nenhum usuário encontrado no Hive");
      }

      UserModel user = box.get(hiveUserKey)!;

      debugPrint("Usuário recuperado do Hive:");

      return user;
    } catch (e) {
      throw Exception("Erro ao recuperar usuário do Hive: $e");
    }
  }

  Future<UserModel> getCurrentUserFromFirebase(String uid) async {
    try {
      DocumentSnapshot doc =
          await _firestore.collection('users').doc(uid).get();

      if (!doc.exists) {
        return UserModel.empty();
      }

      UserModel user = UserModel.fromMap(doc.data() as Map<String, dynamic>);
      debugPrint("Usuário recuperado do Firebase: ${user.name}");
      return user;
    } catch (e) {
      throw Exception("Erro ao recuperar usuário do Firebase: $e");
    }
  }

  Future<void> _updateBasicInformations(
      UserModel selectedUser, String name, String urlImage) async {
    if (selectedUser.status == 'anonymous') {
      return;
    } else if (selectedUser.name != name || selectedUser.urlImage != urlImage) {
      UserModel updatedUser = UserModel(
        id: selectedUser.id,
        name: name,
        email: selectedUser.email,
        urlImage: urlImage,
        role: selectedUser.role,
        createdAt: selectedUser.createdAt,
        roleUpdatedAt: selectedUser.roleUpdatedAt,
        roleUpdatedBy: selectedUser.roleUpdatedBy,
        status: selectedUser.status,
        statusUpdatedAt: selectedUser.statusUpdatedAt,
        statusUpdatedBy: selectedUser.statusUpdatedBy,
        statusObservation: selectedUser.statusObservation,
        lastUpdated: DateTime.now(),
      );

      await updateUserInFirebase(updatedUser);

      await updateUserInHive(updatedUser);

      return;
    }
  }

  Future<void> addProfile(
      String email, String profile, String adminEmail) async {
    try {
      // Busca na coleção 'users' pelo campo 'email'
      QuerySnapshot querySnapshot = await _firestore
          .collection('users')
          .where('email', isEqualTo: email)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        // Pega o primeiro documento encontrado
        DocumentSnapshot userDoc = querySnapshot.docs.first;
        String userId = userDoc.id;

        // Atualiza apenas o campo 'role' do usuário existente
        await _firestore.collection('users').doc(userId).update({
          'role': profile,
          'roleUpdatedAt': DateTime.now(),
          'roleUpdatedBy': adminEmail,
          'lastUpdated': DateTime.now(),
        });
      } else {
        throw Exception("Usuário não encontrado");
      }
    } catch (e) {
      throw Exception("Erro ao atualizar role do usuário: $e");
    }
  }

  Future<void> updateRoleDocument(
      String userId, String role, String updatedBy) async {
    try {
      await _firestore.collection('roles').doc(userId).set({
        'userId': userId,
        'role': role,
        'updatedAt': DateTime.now(),
        'updatedBy': updatedBy,
        'lastUpdated': DateTime.now(),
      }, SetOptions(merge: true));
      debugPrint(
          "Documento de role atualizado: userId=$userId, role=$role, updatedBy=$updatedBy");
    } catch (e) {
      throw Exception("Erro ao atualizar documento de role: $e");
    }
  }

  Future<UserRole> getUserRole(String uid) async {
    try {
      DocumentSnapshot userDoc =
          await _firestore.collection('users').doc(uid).get();

      if (!userDoc.exists) {
        return UserRole.user;
      }

      Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;

      String role = userData['role'] ?? 'user';

      switch (role.toLowerCase()) {
        case UserRoles.admin:
          return UserRole.admin;
        case UserRoles.editor:
          return UserRole.editor;
        default:
          return UserRole.user;
      }
    } catch (e) {
      debugPrint("Erro ao buscar role do usuário: $e");
      return UserRole.user; // Retorna user como padrão em caso de erro
    }
  }

  Future<List<Map<String, dynamic>>> getAllUsers() async {
    try {
      QuerySnapshot querySnapshot = await _firestore.collection('users').get();

      return querySnapshot.docs.map((doc) {
        Map<String, dynamic> userData = doc.data() as Map<String, dynamic>;
        userData['id'] = doc.id; // Adiciona o ID do documento
        return userData;
      }).toList();
    } catch (e) {
      throw Exception("Erro ao buscar usuários: $e");
    }
  }

  Future<void> updateUserInHive(UserModel user) async {
    try {
      var box = await Hive.openBox<UserModel>('users');

      // Deleta o usuário antigo e insere o novo para garantir persistência
      await box.delete(hiveUserKey);
      await box.put(hiveUserKey, user);
      await box.flush(); // Força a escrita no disco

      return;
    } catch (e) {
      debugPrint("Erro ao atualizar usuário no Hive: $e");
      throw Exception("Erro ao atualizar usuário no Hive: $e");
    }
  }

  Future<void> updateUserInFirebase(UserModel user) async {
    try {
      await _firestore.collection('users').doc(user.id).update({
        'id': user.id,
        'urlImage': user.urlImage,
        'name': user.name,
        'email': user.email,
        'role': user.role,
        'createdAt': user.createdAt,
        'roleUpdatedAt': user.roleUpdatedAt,
        'roleUpdatedBy': user.roleUpdatedBy,
        'status': user.status,
        'statusUpdatedAt': user.statusUpdatedAt,
        'statusUpdatedBy': user.statusUpdatedBy,
        'statusObservation': user.statusObservation,
        'lastUpdated': DateTime.now(),
      });
    } catch (e) {
      debugPrint("Erro ao atualizar usuário no Firebase: $e");
      throw Exception("Erro ao atualizar usuário no Firebase: $e");
    }
  }

  Future<void> deleteCurrentUserFromHive() async {
    try {
      final box = await Hive.openBox<UserModel>('users');

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

  Future<UserModel> updateCurrentUserName(String name) async {
    try {
      final currentUser = await getCurrentUserFromHive();

      final updatedUser = UserModel(
        id: currentUser.id,
        name: name,
        email: currentUser.email,
        urlImage: currentUser.urlImage,
        role: currentUser.role,
        createdAt: currentUser.createdAt,
        roleUpdatedAt: currentUser.roleUpdatedAt,
        roleUpdatedBy: currentUser.roleUpdatedBy,
        status: currentUser.status,
        statusUpdatedAt: currentUser.statusUpdatedAt,
        statusUpdatedBy: currentUser.statusUpdatedBy,
        statusObservation: currentUser.statusObservation,
        lastUpdated: DateTime.now(),
      );

      await updateUserInFirebase(updatedUser);
      await updateUserInHive(updatedUser);

      return updatedUser;
    } catch (e) {
      throw Exception("Erro ao atualizar nome do usuário: $e");
    }
  }

  Future<void> deleteCurrentUserAccount() async {
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
      await _firestore.collection('users').doc(uid).delete();
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
}
