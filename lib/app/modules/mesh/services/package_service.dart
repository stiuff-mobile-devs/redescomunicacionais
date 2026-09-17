import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:redescomunicacionais/app/config/secrets.dart';
import 'package:redescomunicacionais/app/modules/mesh/model/public_key_package.dart';
import 'package:redescomunicacionais/app/modules/news/data/repository/news_repository.dart';
import 'package:redescomunicacionais/app/modules/user/data/repository/user_repository.dart';
import '../model/news_package_model.dart';
import 'package:pointycastle/asymmetric/api.dart';
import 'package:redescomunicacionais/app/modules/news/data/model/news_model.dart';
import 'package:redescomunicacionais/app/modules/mesh/services/keys_service.dart';

class OfflinePackageService {
  final NewsRepository newsRepository = NewsRepository();
  final UserRepository _userRepository = UserRepository();

  // cria o pacote a ser enviado
  Future<NewsPackageModel?> createNewsPackage(NewsModel news) async {
    try {
      // Recupera a chave privada do armazenamento seguro
      final privateKeyStr = await _userRepository.getPrivateKeyInStorage();
      if (privateKeyStr == null) {
        throw Exception("Private key not found on device");
      }

      // Transforma a chave privada salva em string em RSAPrivateKey
      final RSAPrivateKey privateKey =
          KeysServices.importPrivateKey(privateKeyStr);

      // Converte a notícia em uma string para ser assinada
      final String newsString = jsonEncode(news.toMap());

      // Assina a string da notícia com a chave privada
      final String signature = KeysServices.toSign(newsString, privateKey);

      final package = NewsPackageModel(
        news: news,
        signature: signature,
        email: news.author,
        lastUpdated: DateTime.now(),
        isUploaded: false,
        id: news.id,
      );

      // Salva o pacote no Hive local
      await newsRepository.saveNewsPackageInHive(package);

      // Cria o pacote
      return package;
    } catch (e) {
      debugPrint("Error creating news package: $e");
      return null;
    }
  }

  // valida um pacote recebido
  bool verifyNewsPackage(NewsPackageModel package, String publicKeyStr) {
    try {
      final RSAPublicKey publicKey = KeysServices.importPublicKey(publicKeyStr);

      // Transforma a noticia recebida na mesma string de quando foi assinada
      final String newsString = jsonEncode(package.news?.toMap());

      // Verifica a assinatura
      return KeysServices.toCheck(
          newsString, package.signature ?? "", publicKey);
    } catch (e) {
      debugPrint("Error verifying news package: $e");
      return false;
    }
  }

  // verifica se o pacote de chaves recebido (da API ou de vizinhos) é autêntico
  bool verifyKeysPackage(PublicKeyPackage package) {
    try {
      // Importa a Chave Pública da API fixada no código do app
      final RSAPublicKey apiPublicKey = KeysServices.importPublicKey(Secrets.apiPublicKey);

      // Reconstrói o mapa que foi assinado pela API no servidor
      final Map<String, dynamic> mapToCheck = {
        'publicKeys': package.publicKeys.map((k) => k.toJson()).toList(),
        'senderEmail': package.senderEmail,
        'timestamp': package.timestamp.toIso8601String(),
      };

      // 3. Verifica a assinatura usando a chave mestre da API[cite: 1]
      return KeysServices.toCheck(jsonEncode(mapToCheck), package.signature, apiPublicKey);
    } catch (e) {
      debugPrint("Error verifying public keys package: $e");
      return false;
    }
  }
}
