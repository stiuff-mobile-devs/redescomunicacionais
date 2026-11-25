import 'package:flutter/foundation.dart';
import 'package:pointycastle/api.dart';
import 'package:pointycastle/asymmetric/api.dart';
import 'package:redescomunicacionais/app/modules/mesh/security/key_storage_service.dart';
import 'package:redescomunicacionais/app/modules/mesh/security/keys_service.dart';
import 'package:redescomunicacionais/app/modules/mesh/security/model/public_key_model.dart';
import 'package:redescomunicacionais/app/modules/news/data/repository/news_repository.dart';
import 'package:redescomunicacionais/app/modules/user/data/repository/user_repository.dart';
import 'package:redescomunicacionais/app/modules/utils/user/userRoles.dart';

// Chave de assinatura da conta logada (uma por conta, no cofre do sistema).
// Regras:
// - a privada só é salva DEPOIS que a pública foi registrada na API;
// - gerar o par exige internet (registro na API); sem internet, tenta de novo
//   quando ela voltar;
// - a chave antiga (uma só por aparelho) só é migrada para a conta se a
//   pública dela for a registrada para aquele e-mail no pacote de chaves.
class SigningKeyService {
  final KeyStorageService _storage = KeyStorageService();
  final UserRepository _userRepository = UserRepository();

  // Evita gerar duas chaves ao mesmo tempo (login + volta da internet)
  static bool _ensuring = false;

  // Expoente público usado na geração (KeysServices.generateKeyPair)
  static final BigInt _publicExponent = BigInt.from(65537);

  // Chave privada (PEM) da conta, ou null se ainda não existe
  Future<String?> privateKeyFor(String? email) async {
    if (email == null || email.trim().isEmpty) return null;
    final String? key = await _storage.getPrivateKey(email);
    if (key != null && key.isNotEmpty) return key;
    return _migrateLegacyKey(email);
  }

  Future<String?> _migrateLegacyKey(String email) async {
    final String? legacy = await _storage.getLegacyPrivateKey();
    if (legacy == null || legacy.isEmpty) return null;

    try {
      final RSAPrivateKey privateKey = KeysServices.importPrivateKey(legacy);
      final String publicKey = KeysServices.exportPublicKey(
          RSAPublicKey(privateKey.modulus!, _publicExponent));

      // Só migra se esta chave é a registrada para este e-mail
      final List<String> known =
          await NewsRepository().getKeysListByEmail(email);
      if (!known.contains(publicKey)) return null;

      await _storage.savePrivateKey(email, legacy);
      await _storage.deleteLegacyPrivateKey();
      debugPrint('SigningKeyService: chave antiga migrada para a conta.');
      return legacy;
    } catch (e) {
      debugPrint('SigningKeyService: chave antiga não migrada: $e');
      return null;
    }
  }

  // Garante a chave da conta logada. Devolve true se ao final ela existe.
  Future<bool> ensureKeyForCurrentUser() async {
    final user = await _userRepository.getCurrentUserFromHive();
    final String? email = user.email;
    if (email == null || email.isEmpty || user.role == UserRoles.guest) {
      return false;
    }

    if (await privateKeyFor(email) != null) return true;
    if (_ensuring) return false;

    _ensuring = true;
    try {
      // RSA 2048 é pesado: gera fora da thread principal para não travar a tela
      final keys = await compute(_generateKeyPair, null);
      final String privateKey = KeysServices.exportPrivateKey(keys.privateKey);
      final String publicKey = KeysServices.exportPublicKey(keys.publicKey);

      final now = DateTime.now();
      // Lança erro se não registrar (sem internet, API recusou...)
      await _userRepository.createPublicKey(PublicKeyModel(
        id: email,
        email: email,
        publicKey: publicKey,
        createdAt: now,
        lastUpdated: now,
      ));

      await _storage.savePrivateKey(email, privateKey);
      debugPrint('SigningKeyService: chave gerada e registrada.');
      return true;
    } catch (e) {
      debugPrint('SigningKeyService: chave não ativada agora (tenta de novo depois): $e');
      return false;
    } finally {
      _ensuring = false;
    }
  }
}

// Função de topo para rodar em outro isolate (compute)
AsymmetricKeyPair<RSAPublicKey, RSAPrivateKey> _generateKeyPair(void _) =>
    KeysServices.generateKeyPair();
