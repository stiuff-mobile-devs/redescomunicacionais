import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hive/hive.dart';

part 'public_key_model.g.dart';

@HiveType(typeId: 4)
class PublicKeyModel extends HiveObject {
  @HiveField(0)
  String? id;

  @HiveField(1)
  String? email;

  @HiveField(2)
  String? publicKey;

  @HiveField(3)
  List<String>? oldPublicKeys;

  @HiveField(4)
  List<String>? cities;

  @HiveField(5)
  DateTime? createdAt;

  @HiveField(6)
  DateTime? lastUpdated;

  @HiveField(7)
  RevocationInfo? revocationInfo;

  PublicKeyModel({
    this.id,
    this.email,
    this.publicKey,
    this.oldPublicKeys,
    this.cities,
    this.createdAt,
    this.lastUpdated,
    this.revocationInfo,
  });

  factory PublicKeyModel.fromJson(Map<String, dynamic> json) {
    return PublicKeyModel(
      id: json['id'] as String?,
      email: json['email'] as String?,
      publicKey: json['publicKey'] as String?,
      oldPublicKeys: (json['oldPublicKeys'] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList(),
      cities:
          (json['cities'] as List<dynamic>?)?.map((e) => e.toString()).toList(),
      createdAt: _parseTimestamp(json['createdAt']),
      lastUpdated: _parseTimestamp(json['lastUpdated']),
      revocationInfo: json['revocationInfo'] != null 
          ? RevocationInfo.fromJson(json['revocationInfo'] as Map<String, dynamic>) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'publicKey': publicKey,
      'oldPublicKeys': oldPublicKeys,
      'cities': cities,
      'createdAt': createdAt,
      'lastUpdated': lastUpdated,
      'revocationInfo': revocationInfo?.toJson(),
    };
  }

  PublicKeyModel copyWith({
    String? id,
    String? email,
    String? publicKey,
    List<String>? oldPublicKeys,
    List<String>? cities,
    DateTime? createdAt,
    DateTime? lastUpdated,
    RevocationInfo? revocationInfo,
  }) {
    return PublicKeyModel(
      id: id ?? this.id,
      email: email ?? this.email,
      publicKey: publicKey ?? this.publicKey,
      oldPublicKeys: oldPublicKeys ?? this.oldPublicKeys,
      cities: cities ?? this.cities,
      createdAt: createdAt ?? this.createdAt,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      revocationInfo: revocationInfo ?? this.revocationInfo,
    );
  }

  static DateTime? _parseTimestamp(dynamic value) {
    if (value == null) return null;
    if (value is Timestamp) return value.toDate();
    if (value is String) return DateTime.tryParse(value);
    return null;
  }
}

@HiveType(typeId: 12)
class RevocationInfo extends HiveObject {
  @HiveField(0)
  bool? isRevoked;

  @HiveField(1)
  DateTime? revokedAt;

  @HiveField(2)
  String? revokedBy;

  @HiveField(3)
  String? revocationReason;

  RevocationInfo({
    this.isRevoked,
    this.revokedAt,
    this.revokedBy,
    this.revocationReason,
  });

  factory RevocationInfo.fromJson(Map<String, dynamic> json) {
    return RevocationInfo(
      isRevoked: json['isRevoked'] ?? false,
      revokedAt: _parseTimestamp(json['revokedAt']),
      revokedBy: json['revokedBy'] as String?,
      revocationReason: json['revocationReason'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'isRevoked': isRevoked,
      'revokedAt': revokedAt,
      'revokedBy': revokedBy,
      'revocationReason': revocationReason,
    };
  }

  RevocationInfo copyWith({
    bool? isRevoked,
    DateTime? revokedAt,
    String? revokedBy,
    String? revocationReason,
  }) {
    return RevocationInfo(
      isRevoked: isRevoked ?? this.isRevoked,
      revokedAt: revokedAt ?? this.revokedAt,
      revokedBy: revokedBy ?? this.revokedBy,
      revocationReason: revocationReason ?? this.revocationReason,
    );
  }

  static DateTime? _parseTimestamp(dynamic value) {
    if (value == null) return null;
    if (value is Timestamp) return value.toDate();
    if (value is String) return DateTime.tryParse(value);
    return null;
  }
}