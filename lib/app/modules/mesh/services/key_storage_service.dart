import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class KeyStorageService {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  // Chave de identificação no cofre do sistema
  static const String _privateKeyAlias = 'neighbor_news_private_key';

  Future<void> savePrivateKey(String pemKey) async {
    await _storage.write(key: _privateKeyAlias, value: pemKey);
  }

  Future<String?> getPrivateKey() async {
    return await _storage.read(key: _privateKeyAlias);
  }

  Future<void> deleteKeys() async {
    await _storage.delete(key: _privateKeyAlias);
  }
}
