import 'dart:convert';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/foundation.dart';
import 'package:redescomunicacionais/app/config/secrets.dart';
import 'package:redescomunicacionais/app/modules/mesh/security/keys_service.dart';
import 'package:redescomunicacionais/app/modules/mesh/security/model/public_key_package.dart';
import 'package:redescomunicacionais/app/modules/mesh/security/signing_key_service.dart';
import 'package:redescomunicacionais/app/modules/news/data/model/news_model.dart';
import 'package:redescomunicacionais/app/modules/news/data/model/news_package_model.dart';
import 'package:redescomunicacionais/app/modules/news/data/repository/news_repository.dart';
import 'package:redescomunicacionais/app/modules/user/data/repository/user_repository.dart';
import 'package:redescomunicacionais/app/modules/utils/components/date_parser.dart';
import 'package:redescomunicacionais/app/modules/utils/components/friendly_exception.dart';
import 'package:redescomunicacionais/app/modules/utils/news/news_states.dart';
import 'package:redescomunicacionais/app/modules/utils/translations/locale_keys.dart';
import 'package:pointycastle/asymmetric/api.dart';

// Assinatura e verificação de pacotes (matérias e pacote de chaves).
// O texto assinado é o mapa {id, news.toJson(), email, lastUpdated} com as
// chaves em ordem alfabética: não mude esse formato sem planejar a
// compatibilidade com versões antigas do app e com as Functions.
class OfflinePackageService {
  late final NewsRepository newsRepository = NewsRepository();
  final UserRepository _userRepository = UserRepository();
  final SigningKeyService _signingKeys = SigningKeyService();
  final FirebaseFunctions _functions = FirebaseFunctions
      .instanceFor(region: 'southamerica-east1');

  static const String apiSender = 'INTERNAL_API';

  // Chave privada para assinar esta matéria. Sem chave ativa (registro da
  // pública ainda não feito): rascunho segue sem assinatura (nunca sai do
  // aparelho); qualquer outro status lança o aviso para a pessoa.
  Future<RSAPrivateKey?> _privateKeyFor(String? email, NewsModel news) async {
    final String? pem = await _signingKeys.privateKeyFor(email);
    if (pem != null) return KeysServices.importPrivateKey(pem);

    if (news.status == NewsStates.rascunho) return null;
    throw const FriendlyException(LocaleKeys.signatureNotActive,
        details: 'Chave privada ainda não ativada nesta conta.');
  }

  String _sign(String id, NewsModel news, String email, DateTime lastUpdated,
      RSAPrivateKey? privateKey) {
    if (privateKey == null) return '';
    final Map<String, dynamic> mapToSign = {
      'id': id,
      'news': news.toJson(),
      'email': email,
      'lastUpdated': DateParser.toJsIso(lastUpdated),
    };
    return KeysServices.toSign(jsonEncode(_sortMapKeys(mapToSign)), privateKey);
  }

  // cria o pacote a ser enviado
  Future<void> createNewsPackage(NewsModel news, String email) async {
    try {
      final privateKey = await _privateKeyFor(email, news);
      final DateTime lastUpdated = DateTime.now();

      final package = NewsPackageModel(
        news: news,
        signature: _sign(news.id, news, email, lastUpdated, privateKey),
        email: email,
        lastUpdated: lastUpdated,
        isUploaded: false,
        id: news.id,
      );

      // Salva o pacote no Hive local
      await newsRepository.saveNewsPackageInHive(package);
    } on FriendlyException {
      rethrow;
    } catch (e) {
      throw Exception("Error creating news package: $e");
    }
  }

  // assina novamente um pacote existente e salva no Hive. Lança
  // FriendlyException (ex.: assinatura não ativa); outros erros devolvem null.
  Future<NewsPackageModel?> resignNewsPackage(NewsPackageModel package) async {
    try {
      final news = package.news;
      if (news == null) {
        throw Exception("News package has no news to sign");
      }

      // Quem assina agora passa a ser o dono da assinatura do pacote
      final currentUser = await _userRepository.getCurrentUserFromHive();
      final String email = currentUser.email ?? '';
      final privateKey = await _privateKeyFor(email, news);

      final DateTime lastUpdated = DateTime.now();
      final String id = package.id ?? news.id;

      final resignedPackage = NewsPackageModel(
        news: news,
        signature: _sign(id, news, email, lastUpdated, privateKey),
        email: email,
        lastUpdated: lastUpdated,
        isUploaded: false,
        id: id,
      );

      // Salva o pacote atualizado no Hive local
      await newsRepository.saveNewsPackageInHive(resignedPackage);

      return resignedPackage;
    } on FriendlyException {
      rethrow;
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
            ? DateParser.toJsIso(package.lastUpdated!)
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

  // Testa a assinatura com a chave atual e as antigas do autor
  Future<bool> isAuthentic(NewsPackageModel package) async {
    final List<String> keys =
        await newsRepository.getKeysListByEmail(package.email ?? '');
    return keys.any((key) => verifyNewsPackage(package, key));
  }

  // O pacote `a` é mais novo que `b`? (milissegundos, a precisão do texto assinado)
  static bool isNewerPackage(NewsPackageModel a, NewsPackageModel b) =>
      (a.lastUpdated?.millisecondsSinceEpoch ?? 0) >
      (b.lastUpdated?.millisecondsSinceEpoch ?? 0);

  // Depois que o pacote de chaves muda, testa de novo a caixa de retransmissão:
  // matérias de autor que acabou de ganhar chave passam a valer e vão para a
  // box principal (se forem mais novas). Devolve quantas foram movidas.
  Future<int> revalidateRelayPackages() async {
    int moved = 0;
    try {
      for (final package in await newsRepository.getAllRelayPackages()) {
        final String? id = package.id;
        if (id == null || package.news == null) continue;
        if (!await isAuthentic(package)) continue;

        final local = await newsRepository.getPackageNews(id);
        if (local == null || isNewerPackage(package, local)) {
          await newsRepository.saveNewsPackageInHive(package);
        }
        await newsRepository.removeRelayPackage(id);
        moved++;
      }
      if (moved > 0) {
        debugPrint("Retransmissão: $moved matéria(s) agora verificada(s).");
      }
    } catch (e) {
      debugPrint("Erro ao re-verificar a retransmissão: $e");
    }
    return moved;
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
        'timestamp': DateParser.toJsIso(package.timestamp),
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
