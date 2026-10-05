import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:pointycastle/api.dart';
import 'package:pointycastle/asymmetric/api.dart';
import 'package:pointycastle/digests/sha256.dart';
import 'package:pointycastle/key_generators/api.dart';
import 'package:pointycastle/key_generators/rsa_key_generator.dart';
import 'package:pointycastle/random/fortuna_random.dart';
import 'package:pointycastle/signers/rsa_signer.dart';

class KeysServices {
  static const String _pubHeader = "-----BEGIN NEIGHBOR_NEWS PUBLIC KEY-----";
  static const String _pubFooter = "-----END NEIGHBOR_NEWS PUBLIC KEY-----";

  static const String _privHeader = "-----BEGIN NEIGHBOR_NEWS PRIVATE KEY-----";
  static const String _privFooter = "-----END NEIGHBOR_NEWS PRIVATE KEY-----";

  static AsymmetricKeyPair<RSAPublicKey, RSAPrivateKey> generateKeyPair() {
    final secureRandom = FortunaRandom();
    final random = Random.secure();
    final seeds = List<int>.generate(32, (_) => random.nextInt(256));
    secureRandom.seed(KeyParameter(Uint8List.fromList(seeds)));

    final rsaParams = RSAKeyGeneratorParameters(BigInt.from(65537), 2048, 64);
    final params = ParametersWithRandom(rsaParams, secureRandom);

    final keyGenerator = RSAKeyGenerator();
    keyGenerator.init(params);

    final pair = keyGenerator.generateKeyPair();
    return AsymmetricKeyPair<RSAPublicKey, RSAPrivateKey>(
      pair.publicKey,
      pair.privateKey,
    );
  }

  static String exportPublicKey(RSAPublicKey key) {
    final modulus = key.modulus.toString();
    final exponent = key.exponent.toString();
    final rawString = "$modulus|$exponent";

    final base64Key = base64.encode(utf8.encode(rawString));
    debugPrint("Chave Publica em string: $base64Key");
    return "$_pubHeader\n$base64Key\n$_pubFooter";
  }

 static String exportPrivateKey(RSAPrivateKey key) {
    // Extraímos todos os componentes estruturais da chave RSA
    final modulus = key.modulus.toString();
    final privateExponent = key.privateExponent.toString();
    final p = key.p.toString();
    final q = key.q.toString();

    // Juntamos tudo com o separador
    final rawString = '$modulus|$privateExponent|$p|$q';

    // Codificamos em Base64 e adicionamos as assinaturas do projeto
    final base64Content = base64.encode(utf8.encode(rawString));
    
    return '$_privHeader\n$base64Content\n$_privFooter';
  }

  static RSAPublicKey importPublicKey(String pemString) {
    if (!pemString.contains(_pubHeader) || !pemString.contains(_pubFooter)) {
      throw FormatException(
          "Chave inválida! Esta chave não pertence ao projeto Neighbor News.");
    }

    final base64Content = pemString
        .replaceAll(_pubHeader, "")
        .replaceAll(_pubFooter, "")
        .replaceAll("\n", "")
        .trim();

    final rawString = utf8.decode(base64.decode(base64Content));
    final parts = rawString.split('|');

    final modulus = BigInt.parse(parts[0]);
    final exponent = BigInt.parse(parts[1]);

    return RSAPublicKey(modulus, exponent);
  }

  static RSAPrivateKey importPrivateKey(String pemString) {
    if (!pemString.contains(_privHeader) || !pemString.contains(_privFooter)) {
      throw FormatException(
          "Chave inválida! Esta chave não pertence ao projeto Neighbor News.");
    }

    final base64Content = pemString
        .replaceAll(_privHeader, "")
        .replaceAll(_privFooter, "")
        .replaceAll("\n", "")
        .trim();

    final rawString = utf8.decode(base64.decode(base64Content));
    final parts = rawString.split('|');

    // Trava de segurança: verifica se a chave não foi salva corrompida no passado
    if (parts.length < 4) {
       throw FormatException("Chave privada corrompida: Faltam os fatores p e q.");
    }

    final modulus = BigInt.parse(parts[0]);
    final privateExponent = BigInt.parse(parts[1]);
    final p = BigInt.parse(parts[2]);
    final q = BigInt.parse(parts[3]);

    // Agora passamos os 4 parâmetros corretamente
    return RSAPrivateKey(modulus, privateExponent, p, q);
  }

  static String toSign(String newsBody, RSAPrivateKey privateKey) {
    final signer =
        RSASigner(SHA256Digest(), '0609608648016503040201'); // OID para SHA-256
    signer.init(true, PrivateKeyParameter<RSAPrivateKey>(privateKey));

    final bytesToSign = utf8.encode(newsBody);
    final signature = signer.generateSignature(Uint8List.fromList(bytesToSign));
    return base64.encode(signature.bytes);
  }

  static bool toCheck(
      String newsBody, String assinaturaBase64, RSAPublicKey publicKey) {
    try {
      final verifier = RSASigner(SHA256Digest(), '0609608648016503040201');
      verifier.init(false, PublicKeyParameter<RSAPublicKey>(publicKey));

      final bytesToVerify = utf8.encode(newsBody);
      final signatureBytes = base64.decode(assinaturaBase64);
      final signature = RSASignature(Uint8List.fromList(signatureBytes));

      return verifier.verifySignature(
          Uint8List.fromList(bytesToVerify), signature);
    } catch (e) {
      return false;
    }
  }
}
