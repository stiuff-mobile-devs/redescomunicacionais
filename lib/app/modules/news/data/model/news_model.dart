import 'package:hive/hive.dart';
part 'news_model.g.dart';

@HiveType(typeId: 1)
class NewsModel {
  @HiveField(0)
  String id;

  @HiveField(1)
  String title;

  @HiveField(2)
  String? subtitle;

  @HiveField(3)
  List<String> cities;

  @HiveField(4)
  List<String> categories;

  @HiveField(5)
  String body;

  @HiveField(6)
  List<String> urlImages;

  @HiveField(7)
  String author;

  @HiveField(8)
  String createdBy;

  @HiveField(9)
  DateTime createdAt;

  @HiveField(10)
  String type;

  @HiveField(11)
  String status;

  @HiveField(12)
  String? validatedBy;

  @HiveField(13)
  DateTime? validatedAt;

  @HiveField(14)
  String? editedBy;

  @HiveField(15)
  DateTime? editedAt;

  @HiveField(16)
  String? excluedBy;

  @HiveField(17)
  DateTime? excluedAt;

  @HiveField(18)
  String? editedObservation;

  @HiveField(19)
  String? validatedObservation;

  @HiveField(20)
  String? excludedObservation;

  @HiveField(21)
  String? videoUrl;

  NewsModel({
    required this.id,
    required this.title,
    this.subtitle,
    required this.cities,
    required this.categories,
    required this.body,
    required this.urlImages,
    required this.author,
    required this.createdBy,
    required this.createdAt,
    required this.type,
    required this.status,
    this.validatedBy,
    this.validatedAt,
    this.editedBy,
    this.editedAt,
    this.excluedBy,
    this.excluedAt,
    this.editedObservation,
    this.validatedObservation,
    this.excludedObservation,
    this.videoUrl,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'subtitle': subtitle,
      'cities': cities,
      'categories': categories,
      'body': body,
      'urlImages': urlImages,
      'autor': author,
      'createdBy': createdBy,
      'createdAt': createdAt.toIso8601String(),
      'type': type,
      'status': status,
      'validatedBy': validatedBy,
      'validatedAt': validatedAt?.toIso8601String(),
      'editedBy': editedBy,
      'editedAt': editedAt?.toIso8601String(),
      'excluedBy': excluedBy,
      'excluedAt': excluedAt?.toIso8601String(),
      'editedObservation': editedObservation,
      'validatedObservation': validatedObservation,
      'excludedObservation': excludedObservation,
      'videoUrl': videoUrl,
    };
  }

  // Criar um objeto NewsModel a partir de um documento do Firestore
  factory NewsModel.fromMap(String id, Map<String, dynamic> data) {
    return NewsModel(
      id: id,
      title: data['title'] ?? '',
      subtitle: data['subtitle'],
      cities: List<String>.from(data['cities'] ?? []),
      categories: List<String>.from(data['categories'] ?? []),
      body: data['body'] ?? '',
      urlImages: List<String>.from(data['urlImages'] ?? []),
      author: data['autor'] ?? '',
      createdBy: data['createdBy'] ?? '',
      createdAt: data['createdAt'] != null
          ? DateTime.parse(data['createdAt'])
          : DateTime.now(),
      type: data['type'] ?? '',
      status: data['status'] ?? '',
      validatedBy: data['validatedBy'],
      validatedAt: data['validatedAt'] != null
          ? DateTime.parse(data['validatedAt'])
          : null,
      editedBy: data['editedBy'],
      editedAt:
          data['editedAt'] != null ? DateTime.parse(data['editedAt']) : null,
      excluedBy: data['excluedBy'],
      excluedAt:
          data['excluedAt'] != null ? DateTime.parse(data['excluedAt']) : null,
      editedObservation: data['editedObservation'],
      validatedObservation: data['validatedObservation'],
      excludedObservation: data['excludedObservation'],
      videoUrl: data['videoUrl'],
    );
  }
}
