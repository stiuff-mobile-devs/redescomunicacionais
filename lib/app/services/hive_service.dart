import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:redescomunicacionais/app/modules/mesh/model/news_package_model.dart';
import 'package:redescomunicacionais/app/modules/mesh/model/public_key_model.dart';
import 'package:redescomunicacionais/app/modules/mesh/model/public_key_package.dart';
import 'package:redescomunicacionais/app/modules/user/data/model/user_model.dart';
import 'package:redescomunicacionais/app/modules/news/data/model/news_model.dart';

class HiveInitializer {
  static Future<void> initialize() async {
    try {
      await Hive.initFlutter(); // Inicializa o Hive

      // Registra os adaptadores
      Hive.registerAdapter(UserModelAdapter());
      Hive.registerAdapter(NewsModelAdapter());
      Hive.registerAdapter(NewsPackageModelAdapter());
      Hive.registerAdapter(PublicKeyModelAdapter());
      Hive.registerAdapter(PublicKeyPackageAdapter());

      // Abre as caixas com proteção contra arquivos corrompidos
      await _openBoxSafe<UserModel>('users');
      await _openBoxSafe<NewsModel>('news');
      await _openBoxSafe<NewsPackageModel>('news_packages');
      await _openBoxSafe<PublicKeyModel>('public_key_model');
      await _openBoxSafe<PublicKeyPackage>('public_key_package');
    } catch (e) {
      rethrow;
    }
  }

  /// Tenta abrir uma box. Se falhar (corrupção), deleta o arquivo e tenta abrir uma nova.
  static Future<Box<T>> _openBoxSafe<T>(String boxName) async {
    try {
      return await Hive.openBox<T>(boxName);
    } catch (error, stackTrace) {
      debugPrint(
          '⚠️ Falha ao abrir a box "$boxName". Possível arquivo corrompido.');
      debugPrint('Erro: $error');

      try {
        await Hive.deleteBoxFromDisk(boxName);

        debugPrint(
            '♻️ Arquivo da box "$boxName" deletado com sucesso. Tentando recriar...');

        return await Hive.openBox<T>(boxName);
      } catch (criticalError) {
        debugPrint(
            '❌ Erro crítico: Não foi possível recuperar a box "$boxName".');
        rethrow;
      }
    }
  }
}
