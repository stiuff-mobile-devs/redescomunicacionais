import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:redescomunicacionais/app/modules/user/data/model/user_model.dart';

enum UserRole { user, admin, editor }

class UserProvider {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

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
      await createUserDocInFirebase(user);
    } catch (e) {
      debugPrint("Erro ao criar usuário no Firebase: $e");
    }

    try {
      await createUserDocInHive(user);
    } catch (e) {
      debugPrint("Erro ao criar usuário no Hive: $e");
    }

    return user;
  }

  Future<void> createUserDocInFirebase(UserModel user) async {
    try {
      DocumentSnapshot doc =
          await _firestore.collection('users').doc(user.id).get();

      if (doc.exists) return; // Evita sobrescrever se já existir

      await _firestore.collection('users').doc(user.id).set({
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
      });
    } catch (e) {
      throw Exception("Erro ao criar usuário no Firebase: $e");
    }
  }

  Future<void> createUserDocInHive(UserModel user) async {
    try {
      var box = await Hive.openBox<UserModel>('users');

      await box.put(hiveUserKey, user);
    } catch (e) {
      throw Exception("Erro ao criar usuário no Hive: $e");
    }
  }

  Future<UserModel?> getCurrentUserFromHive() async {
    try {
      var box = await Hive.openBox<UserModel>('users');

      if (!box.containsKey(hiveUserKey)) return null;

      return box.get(hiveUserKey);
    } catch (e) {
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

  Future<UserRole> getUserRole(String email) async {
    try {
      // Busca na coleção 'users' pelo campo 'email'
      QuerySnapshot querySnapshot = await _firestore
          .collection('users')
          .where('email', isEqualTo: email)
          .limit(1) // Pega apenas o primeiro resultado
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        // Pega o primeiro documento encontrado
        DocumentSnapshot userDoc = querySnapshot.docs.first;
        Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;

        // Verifica o campo 'role'
        String role = userData['role'] ?? 'user';

        switch (role.toLowerCase()) {
          case 'admin':
            return UserRole.admin;
          case 'editor':
            return UserRole.editor;
          default:
            return UserRole.user;
        }
      }

      // Se não encontrou nenhum usuário com esse email
      return UserRole.user;
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
}
