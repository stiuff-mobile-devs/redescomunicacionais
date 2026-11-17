import 'package:redescomunicacionais/app/modules/news/data/model/news_model.dart';

// Conteúdo preenchido no formulário de matéria (criar e editar).
// Não é salvo em lugar nenhum: o NewsController aplica estes campos num NewsModel.
class NewsFormData {
  final String title;
  final String subtitle;
  final String body;
  final List<String> cities;
  final List<String> categories;
  final String type;
  final List<String> urlImages;
  final String videoUrl;
  final List<String> collaborators;

  const NewsFormData({
    required this.title,
    required this.subtitle,
    required this.body,
    required this.cities,
    required this.categories,
    required this.type,
    required this.urlImages,
    required this.videoUrl,
    required this.collaborators,
  });

  // Copia o conteúdo do formulário para a matéria (status e datas ficam com o controller)
  void applyTo(NewsModel news) {
    news
      ..title = title
      ..subtitle = subtitle
      ..body = body
      ..cities = List<String>.from(cities)
      ..categories = List<String>.from(categories)
      ..type = type
      ..urlImages = List<String>.from(urlImages)
      ..videoUrl = videoUrl
      ..collaborators = List<String>.from(collaborators);
  }
}
