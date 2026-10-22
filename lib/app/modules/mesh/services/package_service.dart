import 'dart:convert';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/cupertino.dart';
import 'package:redescomunicacionais/app/config/secrets.dart';
import 'package:redescomunicacionais/app/modules/mesh/model/public_key_package.dart';
import 'package:redescomunicacionais/app/modules/news/data/model/news_package_model.dart';
import 'package:redescomunicacionais/app/modules/news/data/repository/news_repository.dart';
import 'package:redescomunicacionais/app/modules/user/data/repository/user_repository.dart';
import 'package:pointycastle/asymmetric/api.dart';
import 'package:redescomunicacionais/app/modules/news/data/model/news_model.dart';
import 'package:redescomunicacionais/app/modules/mesh/services/keys_service.dart';
import 'package:redescomunicacionais/app/modules/mesh/utils/date_utils.dart';

class OfflinePackageService {
  late final NewsRepository newsRepository = NewsRepository();
  final UserRepository _userRepository = UserRepository();
  final FirebaseFunctions _functions = FirebaseFunctions
      .instanceFor(region: 'southamerica-east1');

  static const String apiSender = 'INTERNAL_API';

  // cria o pacote a ser enviado
  Future<void> createNewsPackage(NewsModel news, String email) async {
    try {
      // Recupera a chave privada do armazenamento seguro
      final privateKeyStr = await _userRepository.getPrivateKeyInStorage();
      if (privateKeyStr == null) {
        throw Exception("Private key not found on device");
      }

      // Transforma a chave privada salva em string em RSAPrivateKey
      final RSAPrivateKey privateKey =
          KeysServices.importPrivateKey(privateKeyStr);

      final DateTime lastUpdated = DateTime.now();

      final Map<String, dynamic> mapToSign = {
        'id': news.id,
        'news': news.toJson(),
        'email': email,
        'lastUpdated': toJsIso(lastUpdated),
      };

      // Converte o mapa em uma string para ser assinada
      final String payload = jsonEncode(_sortMapKeys(mapToSign));

      // Assina a string com a chave privada
      final String signature = KeysServices.toSign(payload, privateKey);

      final package = NewsPackageModel(
        news: news,
        signature: signature,
        email: email,
        lastUpdated: lastUpdated,
        isUploaded: false,
        id: news.id,
      );

      // Salva o pacote no Hive local
      await newsRepository.saveNewsPackageInHive(package);

    } catch (e) {
      throw Exception("Error creating news package: $e");
    }
  }

  // assina novamente um pacote existente e salva no Hive
  Future<NewsPackageModel?> resignNewsPackage(NewsPackageModel package) async {
    try {
      final news = package.news;
      if (news == null) {
        throw Exception("News package has no news to sign");
      }

      // Recupera a chave privada do armazenamento seguro
      final privateKeyStr = await _userRepository.getPrivateKeyInStorage();
      if (privateKeyStr == null) {
        throw Exception("Private key not found on device");
      }

      final RSAPrivateKey privateKey =
          KeysServices.importPrivateKey(privateKeyStr);

      // Quem assina agora passa a ser o dono da assinatura do pacote
      final currentUser = await _userRepository.getCurrentUserFromHive();

      // Gera a nova assinatura a partir do estado atual da notícia
      final DateTime lastUpdated = DateTime.now();
      final String id = package.id ?? news.id;

      final Map<String, dynamic> mapToSign = {
        'id': id,
        'news': news.toJson(),
        'email': currentUser.email,
        'lastUpdated': toJsIso(lastUpdated),
      };

      final String payload = jsonEncode(_sortMapKeys(mapToSign));
      final String signature = KeysServices.toSign(payload, privateKey);

      final resignedPackage = NewsPackageModel(
        news: news,
        signature: signature,
        email: currentUser.email,
        lastUpdated: lastUpdated,
        isUploaded: false,
        id: id,
      );

      // Salva o pacote atualizado no Hive local
      await newsRepository.saveNewsPackageInHive(resignedPackage);

      return resignedPackage;
    } catch (e) {
      debugPrint("Error re-signing news package: $e");
      return null;
    }
  }

  // valida um pacote recebido
  bool verifyNewsPackage(NewsPackageModel package, String publicKeyStr) {
    try {
      final RSAPublicKey publicKey = KeysServices.importPublicKey(publicKeyStr);

      final Map<String, dynamic> mapToCheck = {
        'id': package.id,
        'news': package.news?.toJson(),
        'email': package.email,
        'lastUpdated': package.lastUpdated != null
            ? toJsIso(package.lastUpdated!)
            : null,
      };

      // Transforma o pacote recebido na mesma string de quando foi assinado
      final String payload = jsonEncode(_sortMapKeys(mapToCheck));

      // Verifica a assinatura
      return KeysServices.toCheck(
          payload, package.signature ?? "", publicKey);
    } catch (e) {
      debugPrint("Error verifying news package: $e");
      return false;
    }
  }

  // busca o pacote de chaves públicas na API (getPublicKeysPackage) e
  // valida a assinatura com a chave da API. Retorna null se for inválido
  Future<PublicKeyPackage?> fetchPublicKeysPackageFromApi() async {
    try {
      final result = await _functions.httpsCallable('getPublicKeysPackage').call();
      final Map<String, dynamic> data =
          jsonDecode(jsonEncode(result.data)) as Map<String, dynamic>;

      final package = PublicKeyPackage.fromJson(data);

      if (package.sender != apiSender) {
        debugPrint("Public keys package has unexpected sender: ${package.sender}");
        return null;
      }

      if (!verifyKeysPackage(package)) {
        debugPrint("Public keys package signature is invalid");
        return null;
      }

      return package;
    } on FirebaseFunctionsException catch (e) {
      debugPrint("API error while fetching public keys package: ${e.code}");
      return null;
    } catch (e) {
      debugPrint("Error fetching public keys package: $e");
      return null;
    }
  }

  // verifica se o pacote de chaves recebido (da API ou de vizinhos) é autêntico
  bool verifyKeysPackage(PublicKeyPackage package) {
    try {
      // Importa a Chave Pública da API fixada no código do app
      final RSAPublicKey apiPublicKey = KeysServices.importPublicKey(Secrets.apiPublicKey);

      // Reconstrói o mapa que foi assinado pela API no servidor
      // Emails em ordem alfabética e timestamp em UTC, para o JSON ficar
      // idêntico ao que a API assinou (JS toISOString() é sempre UTC)
      final Map<String, dynamic> mapToCheck = {
        'publicKeys': package.publicKeys,
        'sender': package.sender,
        'timestamp': toJsIso(package.timestamp),
      };

      final String payload = jsonEncode(_sortMapKeys(mapToCheck));
      // Verifica a assinatura usando a chave mestre da API
      return KeysServices.toCheck(payload, package.signature, apiPublicKey);
    } catch (e) {
      debugPrint("Error verifying public keys package: $e");
      return false;
    }
  }

  // ordena alfabeticamente as chaves do map para a assinatura
  static dynamic _sortMapKeys(dynamic value) {
    if (value is Map) {
      final sortedKeys = value.keys.
      map((k) => k.toString()).toList()..sort();
      return {
        for (final k in sortedKeys)
          if (value[k] != null) k:
          _sortMapKeys(value[k]),
      };
    }
    if (value is List) {
      return value.map(_sortMapKeys).
      toList();
    }
    return value;
  }
}
