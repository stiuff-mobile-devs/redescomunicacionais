import 'package:hive/hive.dart';
import 'package:redescomunicacionais/app/modules/user/utils/userRoles.dart';
import 'package:redescomunicacionais/app/utils/components/date_parser.dart';
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

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String?, 
      email: json['email'] as String? ,
      role: json['role'] as String? ?? UserRoles.user, 
      name: json['name'] as String?,
      urlImage: json['urlImage'] as String?,
      roleUpdatedBy: json['roleUpdatedBy'] as String?,
      createdAt: DateParser.parse(json['createdAt']),
      roleUpdatedAt: DateParser.parse(json['roleUpdatedAt']),
      lastUpdated: DateParser.parse(json['lastUpdated']),
      operationsCities: json['operationsCities'] != null
          ? (json['operationsCities'] as Map<dynamic, dynamic>).map(
              (key, value) => MapEntry(key.toString(), value.toString()),
            )
          : null,
    );
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
}