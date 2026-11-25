import 'package:flutter_secure_storage/flutter_secure_storage.dart';

// Cofre do sistema para a chave privada. Uma chave por conta (o e-mail entra
// no nome), para que outra pessoa no mesmo aparelho não assine com a chave
// de quem saiu. A chave privada nunca sai daqui: não logar, não enviar à rede,
// não salvar no Hive/GetStorage.
class KeyStorageService {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  static const String _aliasPrefix = 'neighbor_news_private_key';

  // Nome antigo (uma chave só por aparelho): lido apenas para migração
  static const String _legacyAlias = _aliasPrefix;

  String _aliasFor(String email) => '${_aliasPrefix}_${email.trim().toLowerCase()}';

  Future<void> savePrivateKey(String email, String pemKey) async {
    await _storage.write(key: _aliasFor(email), value: pemKey);
  }

  Future<String?> getPrivateKey(String email) async {
    return await _storage.read(key: _aliasFor(email));
  }

  Future<void> deletePrivateKey(String email) async {
    await _storage.delete(key: _aliasFor(email));
  }

  Future<String?> getLegacyPrivateKey() async {
    return await _storage.read(key: _legacyAlias);
  }

  Future<void> deleteLegacyPrivateKey() async {
    await _storage.delete(key: _legacyAlias);
  }
}
