// Exceção com uma mensagem própria para mostrar ao usuário.
// `messageKey` é uma chave de LocaleKeys; a tela traduz com messageKey.tr.
// O detalhe técnico fica em `details`, só para logs.
class FriendlyException implements Exception {
  final String messageKey;
  final Object? details;

  const FriendlyException(this.messageKey, {this.details});

  @override
  String toString() => 'FriendlyException($messageKey): $details';
}
