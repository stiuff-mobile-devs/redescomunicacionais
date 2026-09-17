import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:redescomunicacionais/app/modules/mesh/model/keys_package_model.dart';
import 'package:redescomunicacionais/app/modules/news/data/repository/news_repository.dart';
import '../model/news_package_model.dart';
import 'package:pointycastle/asymmetric/api.dart';
import 'package:redescomunicacionais/app/modules/news/data/model/news_model.dart';
import 'package:redescomunicacionais/app/modules/mesh/services/key_storage_service.dart';
import 'package:redescomunicacionais/app/modules/mesh/services/keys_service.dart';

class OfflinePackageService {
  final KeyStorageService _keyStorageService = KeyStorageService();

  final NewsRepository newsRepository = NewsRepository();

  // cria o pacote a ser enviado
  Future<NewsPackageModel?> createPackage(NewsModel news) async {
    try {
      // Recupera a chave privada do armazenamento seguro
      final privateKeyStr = await _keyStorageService.getPrivateKey();
      if (privateKeyStr == null) {
        throw Exception("Private key not found on device");
      }

      // Transforma a chave privada salva em string em RSAPrivateKey
      final RSAPrivateKey privateKey = KeysServices.importPrivateKey(privateKeyStr);

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
  bool verifyPackage(NewsPackageModel package, String publicKeyStr) {
    try {
      final RSAPublicKey publicKey = KeysServices.importPublicKey(publicKeyStr);

      // Transforma a noticia recebida na mesma string de quando foi assinada
      final String newsString = jsonEncode(package.news?.toMap());

      // Verifica a assinatura
      return KeysServices.toCheck(newsString, package.signature ?? "", publicKey);
    } catch (e) {
      debugPrint("Error verifying news package: $e");
      return false;
    }
  }

  /// Verifica se o pacote de chaves públicas é autêntico usando a Chave Pública da API.
  bool verifyPublicKeyPackage(PublicKeyPackage package, String apiPublicKeyStr) {
    try {
      // 1. Importa a Chave Pública fixa (hardcoded) da API
      final RSAPublicKey apiPublicKey = KeysServices.importPublicKey(apiPublicKeyStr);

      // 2. Reconstrói o mapa de dados exatamente como ele foi assinado na API
      // Nota: A assinatura nunca inclui o próprio campo 'signature'
      final Map<String, dynamic> dataToVerify = {
        'publicKeys': package.publicKeys.map((e) => e.toJson()).toList(),
        'senderEmail': package.senderEmail,
        'timestamp': package.timestamp.toIso8601String(),
      };

      // Transformando o mapa na mesma String JSON usada no momento da assinatura
      final String packageString = jsonEncode(dataToVerify);

      // 3. Verifica se a matemática da assinatura bate com os dados
      return KeysServices.toCheck(packageString, package.signature, apiPublicKey);
    } catch (e) {
      debugPrint("Erro ao verificar o pacote de chaves da API: $e");
      return false;
    }
  }
}