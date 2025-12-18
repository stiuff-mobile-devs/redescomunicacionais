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
  DateTime? createdAt;

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
  String? lastLocation;

  @HiveField(13)
  DateTime? lastLocationUpdatedAt;

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
    this.lastLocation,
    this.lastLocationUpdatedAt,
  });

  // fromMap (para Firestore)
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] ?? '',
      name: map['name'],
      email: map['email'] ?? '',
      urlImage: map['urlImage'],
      role: map['role'] ?? 'user',
      createdAt: map['createdAt'] != null
          ? (map['createdAt'] as Timestamp).toDate()
          : null,
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
      lastLocation: map['lastLocation'],
      lastLocationUpdatedAt: map['lastLocationUpdatedAt'] != null
          ? (map['lastLocationUpdatedAt'] as Timestamp).toDate()
          : null,
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
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : null,
      'roleUpdatedAt':
          roleUpdatedAt != null ? Timestamp.fromDate(roleUpdatedAt!) : null,
      'roleUpdatedBy': roleUpdatedBy,
      'status': status,
      'statusUpdatedAt':
          statusUpdatedAt != null ? Timestamp.fromDate(statusUpdatedAt!) : null,
      'statusUpdatedBy': statusUpdatedBy,
      'statusObservation': statusObservation,
      'lastLocation': lastLocation,
      'lastLocationUpdatedAt': lastLocationUpdatedAt != null
          ? Timestamp.fromDate(lastLocationUpdatedAt!)
          : null,
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
          json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
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
      lastLocation: json['lastLocation'],
      lastLocationUpdatedAt: json['lastLocationUpdatedAt'] != null
          ? DateTime.parse(json['lastLocationUpdatedAt'])
          : null,
    );
  }
}
