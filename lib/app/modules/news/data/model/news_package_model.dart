import 'package:hive/hive.dart';
import 'package:redescomunicacionais/app/modules/news/data/model/news_model.dart';
import 'package:redescomunicacionais/app/modules/utils/components/date_parser.dart';

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

  // Leitura tolerante: tipo errado vira o padrão. Uma `news` inválida lança
  // erro (vem do NewsModel.fromMap), e quem chama descarta o pacote.
  factory NewsPackageModel.fromJson(Map<String, dynamic> json) {
    final rawNews = json['news'];
    return NewsPackageModel(
      news: rawNews is Map
          ? NewsModel.fromMap(Map<String, dynamic>.from(rawNews))
          : null,
      signature: json['signature'] is String ? json['signature'] : '',
      email: json['email'] is String ? json['email'] : '',
      lastUpdated: DateParser.parse(json['lastUpdated']),
      isUploaded: json['isUploaded'] is bool ? json['isUploaded'] : false,
      id: json['id'] is String ? json['id'] : null,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'news': news?.toJson(), 
      'signature': signature,
      'email': email,
      'lastUpdated': lastUpdated != null ? DateParser.toJsIso(lastUpdated!) : null,
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
}