import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:redescomunicacionais/app/modules/user/data/model/user_model.dart';

enum UserRole { user, admin, editor }

class UserProvider {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Armazena sempre na mesma chave para garantir apenas uma entrada
  final String hiveUserKey = 'current_user';

  Future<UserModel> createUserDoc(
      String email, String name, String uid, String urlImage) async {
    UserModel user = UserModel(
      id: uid,
      name: name,
      email: email,
      urlImage: urlImage,
      role: 'user',
      createdAt: DateTime.now(),
      status: 'active',
    );

    try {
      user = await _createUserDocInFirebase(user, uid, name, urlImage);
    } catch (e) {
      debugPrint("Erro ao criar usuário no Firebase: $e");
    }

    try {
      user = await _createUserDocInHive(user);
    } catch (e) {
      debugPrint("Erro ao criar usuário no Hive: $e");
    }

    return user;
  }

  Future<UserModel> _createUserDocInFirebase(
      UserModel user, String uid, String name, String urlImage) async {
    try {
      DocumentSnapshot doc =
          await _firestore.collection('users').doc(user.id).get();

      if (doc.exists) {
        return UserModel.fromMapWithData(
            doc.data() as Map<String, dynamic>, uid, name, urlImage);
      }

      // Se o documento não existe, cria um novo
      await _firestore.collection('users').doc(user.id).set({
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
        'lastLocation': user.lastLocation,
        'lastLocationUpdatedAt': user.lastLocationUpdatedAt,
      });

      return user;
    } catch (e) {
      throw Exception("Erro ao criar usuário no Firebase: $e");
    }
  }

  Future<UserModel> _createUserDocInHive(UserModel user) async {
    try {
      var box = await Hive.openBox<UserModel>('users');

      // Verifica se a chave já existe
      if (!box.containsKey(hiveUserKey)) {
        await box.put(hiveUserKey, user);
        return user;
      } else {
        return getCurrentUserFromHive();
      }
    } catch (e) {
      throw Exception("Erro ao criar usuário no Hive: $e");
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
      debugPrint("  - lastLocation: ${user.lastLocation}");
      debugPrint("  - lastLocationUpdatedAt: ${user.lastLocationUpdatedAt}");

      return user;
    } catch (e) {
      // Se houver erro ao ler (adapter desatualizado), limpa o Hive
      debugPrint("Erro ao recuperar usuário do Hive: $e");
      debugPrint("Limpando Hive para recriar com adapter atualizado...");
      try {
        await Hive.deleteBoxFromDisk('users');
      } catch (deleteError) {
        debugPrint("Erro ao deletar box: $deleteError");
      }
      throw Exception("Erro ao recuperar usuário do Hive: $e");
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
        case 'admin':
          return UserRole.admin;
        case 'editor':
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

      debugPrint(
          "Usuário atualizado no Hive: ${user.lastLocation} - ${user.lastLocationUpdatedAt}");

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
        'lastLocation': user.lastLocation,
        'lastLocationUpdatedAt': user.lastLocationUpdatedAt,
      });
    } catch (e) {
      debugPrint("Erro ao atualizar usuário no Firebase: $e");
      throw Exception("Erro ao atualizar usuário no Firebase: $e");
    }
  }

  Future<UserModel> updateUserBasicInfo({
    required String userId,
    String? name,
    String? email,
    String? urlImage,
  }) async {
    try {
      // Busca o usuário atual
      DocumentSnapshot doc =
          await _firestore.collection('users').doc(userId).get();

      if (!doc.exists) {
        throw Exception("Usuário não encontrado");
      }

      UserModel currentUser =
          UserModel.fromMap(doc.data() as Map<String, dynamic>);

      // Atualiza apenas os campos fornecidos
      Map<String, dynamic> updates = {};
      if (name != null) updates['name'] = name;
      if (email != null) updates['email'] = email;
      if (urlImage != null) updates['urlImage'] = urlImage;

      // Atualiza no Firebase
      await _firestore.collection('users').doc(userId).update(updates);

      // Cria o usuário atualizado
      UserModel updatedUser = UserModel(
        id: currentUser.id,
        name: name ?? currentUser.name,
        email: email ?? currentUser.email,
        urlImage: urlImage ?? currentUser.urlImage,
        role: currentUser.role,
        createdAt: currentUser.createdAt,
        status: currentUser.status,
        roleUpdatedAt: currentUser.roleUpdatedAt,
        roleUpdatedBy: currentUser.roleUpdatedBy,
        statusUpdatedAt: currentUser.statusUpdatedAt,
        statusUpdatedBy: currentUser.statusUpdatedBy,
        statusObservation: currentUser.statusObservation,
        lastLocation: currentUser.lastLocation,
        lastLocationUpdatedAt: currentUser.lastLocationUpdatedAt,
      );

      // Atualiza no Hive se for o usuário atual
      await updateUserInHive(updatedUser);

      debugPrint("Informações básicas do usuário atualizadas com sucesso");
      return updatedUser;
    } catch (e) {
      debugPrint("Erro ao atualizar informações do usuário: $e");
      throw Exception("Erro ao atualizar informações do usuário: $e");
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
        lastLocation: currentUser.lastLocation,
        lastLocationUpdatedAt: currentUser.lastLocationUpdatedAt,
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
