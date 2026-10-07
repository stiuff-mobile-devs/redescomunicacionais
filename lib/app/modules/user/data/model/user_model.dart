import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hive/hive.dart';
import 'package:redescomunicacionais/app/modules/user/utils/userRoles.dart';
part 'user_model.g.dart';

// ÍNDICES OBSOLETOS - NÃO REUTILIZAR:
// 8: status
// 9: statusUpdatedAt
// 10: statusUpdatedBy
// 11: statusObservation

@HiveType(typeId: 0)
class UserModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String? name;

  @HiveField(2)
  String email;

  @HiveField(3)
  String? urlImage;

  @HiveField(4)
  String role;

  @HiveField(5)
  DateTime createdAt;

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
    required this.id,
    this.name,
    required this.email,
    this.urlImage,
    required this.role,
    required this.createdAt,
    this.roleUpdatedAt,
    this.roleUpdatedBy,
    this.lastUpdated,
    this.operationsCities,
    this.selectedAppCity,
  });

  factory UserModel.empty() {
    return UserModel(
      id: '',
      email: '',
      role: UserRoles.guest,
      createdAt: DateTime.now(),
      lastUpdated: DateTime.now(),
    );
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String? ?? '', 
      email: json['email'] as String? ?? '',
      role: json['role'] as String? ?? 'user', 
      name: json['name'] as String?,
      urlImage: json['urlImage'] as String?,
      roleUpdatedBy: json['roleUpdatedBy'] as String?,
      createdAt: _readDateTime(json['createdAt'], fallback: DateTime.now()),
      roleUpdatedAt: _readNullableDateTime(json['roleUpdatedAt']),
      lastUpdated: _readNullableDateTime(json['lastUpdated']),
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
      'createdAt': createdAt.toIso8601String(), // Converte para texto
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
    return {
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
  }

  static DateTime _readDateTime(dynamic value, {required DateTime fallback}) {
    if (value == null) return fallback;
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value) ?? fallback;
    return fallback;
  }

  static DateTime? _readNullableDateTime(dynamic value) {
    if (value == null) return null;
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value);
    return null;
  }
}