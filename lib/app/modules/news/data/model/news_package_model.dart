import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hive/hive.dart';
import 'package:redescomunicacionais/app/modules/news/data/model/news_model.dart';

part 'news_package_model.g.dart';

@HiveType(typeId: 2)
class NewsPackageModel {
  @HiveField(0)
  final NewsModel? news;

  @HiveField(1)
  final String? signature;

  @HiveField(2)
  final String? email;

  @HiveField(3)
  final DateTime? lastUpdated;

  @HiveField(4)
  final bool? isUploaded;

  @HiveField(5)
  final String? id;

  NewsPackageModel({
    required this.news,
    required this.signature,
    required this.email,
    required this.lastUpdated,
    required this.isUploaded,
    required this.id,
  });

  factory NewsPackageModel.fromJson(Map<String, dynamic> json) {
    return NewsPackageModel(
      news: json['news'] != null 
          ? NewsModel.fromMap(Map<String, dynamic>.from(json['news'])) 
          : null,
      signature: json['signature'] as String? ?? '',
      email: json['email'] as String? ?? '',
      lastUpdated: _parseDate(json['lastUpdated']),
      isUploaded: json['isUploaded'] as bool? ?? false,
      id: json['id'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'news': news?.toJson(), 
      'signature': signature,
      'email': email,
      'lastUpdated': lastUpdated?.toIso8601String(), 
      'isUploaded': isUploaded,
      'id': id,
    };

    data.removeWhere((key, value) => value == null);

    return data;
  }

  Map<String, dynamic> toFirebase() {
    final Map<String, dynamic> data = {
      'news': news?.toFirebase(), 
      'signature': signature,
      'email': email,
      'lastUpdated': lastUpdated, 
      'isUploaded': isUploaded,
      'id': id,
    };

    data.removeWhere((key, value) => value == null);

    return data;
  }

  // Interpretador Híbrido: Firestore, Dart e JSON/Mesh
  static DateTime? _parseDate(dynamic value) {
    if (value == null) return null;
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value); 
    return null;
  }
}