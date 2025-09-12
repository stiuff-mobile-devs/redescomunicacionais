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
  });
}
