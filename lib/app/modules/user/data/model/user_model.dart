import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hive/hive.dart';
part 'user_model.g.dart';

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

  @HiveField(8)
  String status;

  @HiveField(9)
  DateTime? statusUpdatedAt;

  @HiveField(10)
  String? statusUpdatedBy;

  @HiveField(11)
  String? statusObservation;

  @HiveField(12)
  DateTime? lastUpdated;


  UserModel({
    required this.id,
    this.name,
    required this.email,
    this.urlImage,
    required this.role,
    required this.createdAt,
    this.roleUpdatedAt,
    this.roleUpdatedBy,
    required this.status,
    this.statusUpdatedAt,
    this.statusUpdatedBy,
    this.statusObservation,
    this.lastUpdated,
  });

  // Factory para criar um usuário vazio com campos required
  factory UserModel.empty() {
    return UserModel(
      id: '',
      email: '',
      role: 'user',
      createdAt: DateTime.now(),
      status: 'anonymous',
    );
  }

  // fromMap (do Firestore)
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'],
      name: map['name'],
      email: map['email'],
      urlImage: map['urlImage'],
      role: map['role'] ?? 'user',
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      roleUpdatedAt: map['roleUpdatedAt'] != null
          ? (map['roleUpdatedAt'] as Timestamp).toDate()
          : null,
      roleUpdatedBy: map['roleUpdatedBy'],
      status: map['status'] ?? 'active',
      statusUpdatedAt: map['statusUpdatedAt'] != null
          ? (map['statusUpdatedAt'] as Timestamp).toDate()
          : null,
      statusUpdatedBy: map['statusUpdatedBy'],
      statusObservation: map['statusObservation'],
      lastUpdated: map['lastUpdated'] != null
          ? (map['lastUpdated'] as Timestamp).toDate()
          : null,
    );
  }


  factory UserModel.fromMapWithData(
      Map<String, dynamic> map, String id, String name, String urlImage, DateTime lastUpdated) {
    return UserModel(
      id: id,
      name: name,
      email: map['email'],
      urlImage: urlImage,
      role: map['role'] ?? 'user',
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      roleUpdatedAt: map['roleUpdatedAt'] != null
          ? (map['roleUpdatedAt'] as Timestamp).toDate()
          : null,
      roleUpdatedBy: map['roleUpdatedBy'],
      status: map['status'] ?? 'active',
      statusUpdatedAt: map['statusUpdatedAt'] != null
          ? (map['statusUpdatedAt'] as Timestamp).toDate()
          : null,
      statusObservation: map['statusObservation'],
      lastUpdated: lastUpdated,
    );
  }

  // toJson
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'urlImage': urlImage,
      'role': role,
      'createdAt':  Timestamp.fromDate(createdAt),
      'roleUpdatedAt':
          roleUpdatedAt != null ? Timestamp.fromDate(roleUpdatedAt!) : null,
      'roleUpdatedBy': roleUpdatedBy,
      'status': status,
      'statusUpdatedAt':
          statusUpdatedAt != null ? Timestamp.fromDate(statusUpdatedAt!) : null,
      'statusUpdatedBy': statusUpdatedBy,
      'statusObservation': statusObservation,
      'lastUpdated': lastUpdated != null ? Timestamp.fromDate(lastUpdated!) : null,
    };
  }

  // fromJson
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? '',
      name: json['name'],
      email: json['email'] ?? '',
      urlImage: json['urlImage'],
      role: json['role'] ?? 'user',
      createdAt:
          json['createdAt'] = DateTime.parse(json['createdAt']),
      roleUpdatedAt: json['roleUpdatedAt'] != null
          ? DateTime.parse(json['roleUpdatedAt'])
          : null,
      roleUpdatedBy: json['roleUpdatedBy'],
      status: json['status'] ?? 'active',
      statusUpdatedAt: json['statusUpdatedAt'] != null
          ? DateTime.parse(json['statusUpdatedAt'])
          : null,
      statusUpdatedBy: json['statusUpdatedBy'],
      statusObservation: json['statusObservation'],
      lastUpdated: json['lastUpdated'] != null
          ? DateTime.parse(json['lastUpdated'])
          : null,
     );
  }
}