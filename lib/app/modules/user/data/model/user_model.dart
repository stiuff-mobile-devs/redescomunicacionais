import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:redescomunicacionais/app/modules/utils/user/userRoles.dart';
import 'package:redescomunicacionais/app/modules/utils/components/date_parser.dart';
part 'user_model.g.dart';

// ÍNDICES OBSOLETOS - NÃO REUTILIZAR:
// 8: status
// 9: statusUpdatedAt
// 10: statusUpdatedBy
// 11: statusObservation

@HiveType(typeId: 0)
class UserModel extends HiveObject {
  @HiveField(0)
  String? id;

  @HiveField(1)
  String? name;

  @HiveField(2)
  String? email;

  @HiveField(3)
  String? urlImage;

  @HiveField(4)
  String? role;

  @HiveField(5)
  DateTime? createdAt;

  @HiveField(6)
  DateTime? roleUpdatedAt;

  @HiveField(7)
  String? roleUpdatedBy;

  @HiveField(12)
  DateTime? lastUpdated;

  @HiveField(13)
  Map<String, String>? operationsCities;

  @HiveField(14)
  String? selectedAppCity; 

  UserModel({
    this.id,
    this.name,
    this.email,
    this.urlImage,
    this.role,
    this.createdAt,
    this.roleUpdatedAt,
    this.roleUpdatedBy,
    this.lastUpdated,
    this.operationsCities,
    this.selectedAppCity,
  });

  factory UserModel.empty() {
    return UserModel(
      name: 'Convidado',
      email: 'Convidado',
      role: UserRoles.guest,
    );
  }

  // Leitura tolerante: campo com tipo errado vira null (ou o padrão) em vez de
  // lançar erro, para um documento ruim não derrubar o login nem a listagem.
  // Campos a mais são ignorados. `selectedAppCity` é só local (não vem da nuvem).
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: _readString(json, 'id'),
      email: _readString(json, 'email'),
      role: _readRole(json),
      name: _readString(json, 'name'),
      urlImage: _readString(json, 'urlImage'),
      roleUpdatedBy: _readString(json, 'roleUpdatedBy'),
      createdAt: DateParser.parse(json['createdAt']),
      roleUpdatedAt: DateParser.parse(json['roleUpdatedAt']),
      lastUpdated: DateParser.parse(json['lastUpdated']),
      operationsCities: _readCities(json),
    );
  }

  static String? _readString(Map<String, dynamic> json, String key) {
    final value = json[key];
    if (value == null || value is String) return value as String?;
    debugPrint('UserModel: campo "$key" ignorado (tipo ${value.runtimeType})');
    return null;
  }

  // Só aceita os papéis conhecidos; ausente ou inválido vira 'user'
  static String _readRole(Map<String, dynamic> json) {
    const validRoles = [UserRoles.admin, UserRoles.editor, UserRoles.user];
    final value = json['role'];
    if (value is String && validRoles.contains(value)) return value;
    if (value != null) {
      debugPrint('UserModel: papel inválido "$value", usando "${UserRoles.user}"');
    }
    return UserRoles.user;
  }

  // Mantém só os pares texto -> texto; qualquer outro formato é descartado
  static Map<String, String>? _readCities(Map<String, dynamic> json) {
    final value = json['operationsCities'];
    if (value == null) return null;
    if (value is! Map) {
      debugPrint('UserModel: operationsCities ignorado (tipo ${value.runtimeType})');
      return null;
    }
    final cities = <String, String>{};
    value.forEach((key, city) {
      if (key is String && city is String) cities[key] = city;
    });
    if (cities.length != value.length) {
      debugPrint('UserModel: ${value.length - cities.length} cidade(s) inválida(s) ignorada(s)');
    }
    return cities;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'id': id,
      'name': name,
      'email': email,
      'urlImage': urlImage,
      'role': role,
      'createdAt': createdAt?.toIso8601String(), // Converte para texto
      'roleUpdatedAt': roleUpdatedAt?.toIso8601String(), // Converte para texto
      'roleUpdatedBy': roleUpdatedBy,
      'lastUpdated': lastUpdated?.toIso8601String(), // Converte para texto
      'operationsCities': operationsCities,
    };

    // Remove os campos nulos para economizar banda na malha ad-hoc
    data.removeWhere((key, value) => value == null);

    return data;
  }

  Map<String, dynamic> toFirebase() {
    final Map<String, dynamic> data = {
      'id': id,
      'name': name,
      'email': email,
      'urlImage': urlImage,
      'role': role,
      'createdAt': createdAt, // Envia o DateTime nativo (Firestore aceita)
      'roleUpdatedAt': roleUpdatedAt,
      'roleUpdatedBy': roleUpdatedBy,
      'lastUpdated': lastUpdated,
      'operationsCities': operationsCities,
    };

    // Remove os campos nulos
    data.removeWhere((key, value) => value == null);

    return data;
  }

  // Campos que o próprio usuário pode alterar (para update(), nunca set()):
  // enviar campos do admin, mesmo nulos, faz a regra do Firestore negar.
  Map<String, dynamic> toFirebaseProfile() {
    final Map<String, dynamic> data = {
      'name': name,
      'urlImage': urlImage,
    };
    data.removeWhere((key, value) => value == null);
    return data;
  }
}