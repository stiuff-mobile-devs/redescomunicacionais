import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:redescomunicacionais/app/modules/mesh/model/public_key_model.dart';

class PublicKeyPackage {
  final List<PublicKeyModel> publicKeys;
  final String senderEmail;
  final DateTime timestamp;
  final String signature;

  PublicKeyPackage({
    required this.publicKeys,
    required this.senderEmail,
    required this.timestamp,
    required this.signature,
  });

  factory PublicKeyPackage.fromJson(Map<String, dynamic> json) {
    return PublicKeyPackage(
      publicKeys: (json['publicKeys'] as List<dynamic>?)
              ?.map((e) => PublicKeyModel.fromJson(Map<String, dynamic>.from(e)))
              .toList() ??
          [],
      senderEmail: json['senderEmail'] ?? '',
      timestamp: _parseDate(json['timestamp']) ?? DateTime.now(),
      signature: json['signature'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'publicKeys': publicKeys.map((e) => e.toJson()).toList(),
      'senderEmail': senderEmail,
      'timestamp': timestamp.toIso8601String(),
      'signature': signature,
    };
  }

  static DateTime? _parseDate(dynamic value) {
    if (value is Timestamp) {
      return value.toDate();
    }
    if (value is String) {
      return DateTime.tryParse(value);
    }
    if (value is DateTime) {
      return value;
    }
    return null;
  }
}