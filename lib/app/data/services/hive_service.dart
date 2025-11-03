import 'package:hive_flutter/hive_flutter.dart';
import 'package:redescomunicacionais/app/modules/user/data/model/user_model.dart';
import 'package:redescomunicacionais/app/modules/news/data/model/news_model.dart';

class HiveInitializer {
  static Future<void> initialize() async {
    await Hive.initFlutter(); // Inicializa o Hive
    print('Hive initialized');

    Hive.registerAdapter(UserModelAdapter());
    Hive.registerAdapter(NewsModelAdapter());

    // Tabelas
    await Hive.openBox<UserModel>('users');
    await Hive.openBox<NewsModel>('news');
  }
}
