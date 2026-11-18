import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:nearby_connections/nearby_connections.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';
import 'package:redescomunicacionais/app/modules/mesh/security/model/public_key_package.dart';
import 'package:redescomunicacionais/app/modules/mesh/security/package_service.dart';
import 'package:redescomunicacionais/app/modules/news/controller/news_controller.dart';
import 'package:redescomunicacionais/app/modules/news/data/model/news_package_model.dart';
import 'package:redescomunicacionais/app/modules/news/data/repository/news_repository.dart' show NewsRepository;
import 'package:redescomunicacionais/app/modules/utils/components/date_parser.dart';
import 'package:redescomunicacionais/app/modules/utils/news/news_states.dart';

// Transporte da rede oportunista (DTN, roteamento epidêmico): dois aparelhos
// se encontram pelo Nearby Connections, trocam o que falta e se separam.
//
// Protocolo (mesmos tipos e campos das versões antigas do app):
// - HANDSHAKE: ids + lastUpdated (ms UTC) das matérias que circulam e a data
//   do pacote de chaves. Enviado ao conectar e quando algo muda.
// - Quem precisa PEDE (REQUEST_NEWS / REQUEST_KEYS); só se envia o que foi
//   pedido (FULL_NEWS_PACKAGE / FULL_KEYS_PACKAGE, como arquivo temporário).
class NearbyService extends GetxService {
  final Strategy strategy = Strategy.P2P_CLUSTER;
  final String serviceId = "br.uff.redescomunicacionais"; // Bundle ID público

  final Nearby _nearby = Nearby();
  final RxList<String> connectedEndpoints = <String>[].obs;

  // Pedidos de conexão em andamento (evita pedir duas vezes ao mesmo aparelho)
  final Set<String> _connecting = {};

  final NewsRepository newsRepository = NewsRepository();
  final OfflinePackageService offlinePackageService = OfflinePackageService();

  // Guarda arquivos em transferência até que o download termine por completo
  final Map<int, Payload> _incomingFilePayloads = {};

  // Arquivos temporários enviados: apagados quando a transferência termina
  final Map<int, String> _outgoingFiles = {};

  // Agrupa várias mudanças seguidas num único aviso aos conectados
  Timer? _announceTimer;
  static const Duration _announceDelay = Duration(seconds: 2);

  // O Nearby Connections só existe no Android
  bool get isSupported => !kIsWeb && Platform.isAndroid;

  @override
  void onInit() {
    super.onInit();
    debugPrint('NearbyService: Serviço inicializado.');
  }

  @override
  void onClose() {
    _announceTimer?.cancel();
    super.onClose();
  }

  Future<bool> requestPermissions() async {
    Map<Permission, PermissionStatus> statuses = await [
      Permission.bluetooth,
      Permission.bluetoothAdvertise,
      Permission.bluetoothConnect,
      Permission.bluetoothScan,
      Permission.location,
      Permission.nearbyWifiDevices,
    ].request();

    bool allGranted = statuses.values.every((status) => status.isGranted);
    if (!allGranted) debugPrint('NearbyService: Permissões NEGADAS. Rádio desligado.');
    return allGranted;
  }

  Future<void> startEpidemicMesh(String userName) async {
    if (!isSupported) {
      debugPrint('NearbyService: a troca entre aparelhos só funciona no Android.');
      return;
    }
    if (!await requestPermissions()) return;
    try {
      await _startAdvertising(userName);
      await _startDiscovery(userName);
      debugPrint('NearbyService: troca entre aparelhos ligada (rede oportunista).');
    } catch (e) {
      debugPrint('NearbyService: Erro ao ligar a troca: $e');
    }
  }

  Future<void> stopAll() async {
    _announceTimer?.cancel();
    await _nearby.stopAdvertising();
    await _nearby.stopDiscovery();
    await _nearby.stopAllEndpoints();
    connectedEndpoints.clear();
    _connecting.clear();
    _incomingFilePayloads.clear();
    for (final path in _outgoingFiles.values) {
      _deleteQuietly(path);
    }
    _outgoingFiles.clear();
    debugPrint("NearbyService: troca entre aparelhos desligada.");
  }

  Future<void> _startAdvertising(String userName) async {
    await _nearby.startAdvertising(
      userName, strategy, serviceId: serviceId,
      onConnectionInitiated: _onConnectionInitiated,
      onConnectionResult: _onConnectionResult,
      onDisconnected: _onDisconnected,
    );
    debugPrint("Começando a anunciar dispositivo $userName na rede");
  }

  Future<void> _startDiscovery(String userName) async {
    await _nearby.startDiscovery(
      userName, strategy, serviceId: serviceId,
      onEndpointFound: (id, name, serviceId) => _requestConnection(id, userName),
      onEndpointLost: (id) => debugPrint('NearbyService: $id saiu do alcance.'),
    );
    debugPrint("Começando a procurar dispositivos proximos");
  }

  // Pede conexão só a quem ainda não está conectado nem com pedido em andamento
  void _requestConnection(String endpointId, String userName) {
    if (_connecting.contains(endpointId) ||
        connectedEndpoints.contains(endpointId)) {
      return;
    }
    _connecting.add(endpointId);
    _nearby
        .requestConnection(
          userName,
          endpointId,
          onConnectionInitiated: _onConnectionInitiated,
          onConnectionResult: _onConnectionResult,
          onDisconnected: _onDisconnected,
        )
        .catchError((e) {
      _connecting.remove(endpointId);
      debugPrint('NearbyService: pedido de conexão a $endpointId falhou: $e');
      return false;
    });
  }

  void _onConnectionInitiated(String endpointId, ConnectionInfo info) async {
    try {
      await _nearby.acceptConnection(
        endpointId,
        onPayLoadRecieved: _onPayloadReceived,
        onPayloadTransferUpdate: _onPayloadTransferUpdate,
      );
      debugPrint('Conexão com dispositivo $endpointId aceita');
    } catch (e) {
      debugPrint('NearbyService: Erro ao aceitar conexão de $endpointId: $e');
    }
  }

  void _onConnectionResult(String endpointId, Status status) {
    _connecting.remove(endpointId);
    if (status == Status.CONNECTED) {
      if (!connectedEndpoints.contains(endpointId)) {
        connectedEndpoints.add(endpointId);
      }
      _sendHandshake(endpointId);
    } else {
      debugPrint('NearbyService: Conexão falhou. Status: $status');
    }
  }

  void _onDisconnected(String endpointId) {
    connectedEndpoints.remove(endpointId);
    _connecting.remove(endpointId);
    debugPrint("Removendo conexão com dispositivo $endpointId");
  }

  void _onPayloadReceived(String endpointId, Payload payload) async {
    if (payload.type == PayloadType.BYTES) {
      debugPrint('NearbyService: Payload leve (BYTES) recebido de $endpointId.');
      try {
        String jsonString = utf8.decode(payload.bytes!);
        _processIncomingJson(endpointId, jsonString);
      } catch (e) {
        debugPrint('NearbyService: Erro ao decodificar bytes: $e');
      }
    } else if (payload.type == PayloadType.FILE) {
      debugPrint('NearbyService: Transferência de arquivo iniciada de $endpointId (Payload ID: ${payload.id}).');
      // Registra o payload para ser processado assim que a transferência concluir
      _incomingFilePayloads[payload.id] = payload;
    }
  }

  void _onPayloadTransferUpdate(String endpointId, PayloadTransferUpdate update) async {
    final bool finished = update.status == PayloadStatus.SUCCESS ||
        update.status == PayloadStatus.FAILURE ||
        update.status == PayloadStatus.CANCELED;

    // Arquivo que ESTE aparelho enviou: apaga o temporário ao terminar
    if (finished) {
      final String? sentFile = _outgoingFiles.remove(update.id);
      if (sentFile != null) _deleteQuietly(sentFile);
    }

    if (update.status == PayloadStatus.SUCCESS) {
      if (_incomingFilePayloads.containsKey(update.id)) {
        final payload = _incomingFilePayloads.remove(update.id)!;

        try {
          // Obtém a URI fornecida pelo Android moderno (ou filePath como fallback)
          final String? uriString = payload.uri ?? payload.filePath;

          if (uriString != null && uriString.isNotEmpty) {
            final Directory tempDir = await getTemporaryDirectory();
            final String targetPath = '${tempDir.path}/incoming_${update.id}.json';

            final bool copied = await _nearby.copyFileAndDeleteOriginal(uriString, targetPath);

            if (copied) {
              final File receivedFile = File(targetPath);
              if (await receivedFile.exists()) {
                String jsonString = await receivedFile.readAsString();
                _processIncomingJson(endpointId, jsonString);
                await receivedFile.delete(); // Limpa o arquivo processado
                debugPrint('NearbyService: Arquivo pesado copiado, lido e processado com sucesso.');
              }
            } else {
              debugPrint('NearbyService: Falha ao copiar arquivo da URI $uriString para $targetPath.');
            }
          } else {
            debugPrint('NearbyService: URI ou caminho ausente para o payload ${update.id}.');
          }
        } catch (e) {
          debugPrint('NearbyService: Erro ao processar arquivo recebido: $e');
        }
      }
    } else if (update.status == PayloadStatus.FAILURE || update.status == PayloadStatus.CANCELED) {
      _incomingFilePayloads.remove(update.id);
      debugPrint('NearbyService: Transferência do payload ${update.id} falhou ou foi cancelada.');
    }
  }

  // Pacotes que circulam: os verificados (box principal, exceto rascunhos, que
  // ficam só no aparelho) + os de retransmissão (assinatura não verificada).
  // Para o mesmo id, fica o mais recente.
  Future<Map<String, NewsPackageModel>> _meshPackages() async {
    final Map<String, NewsPackageModel> result = {};

    void add(NewsPackageModel p) {
      final id = p.id;
      if (id == null || p.news?.status == NewsStates.rascunho) return;
      final current = result[id];
      if (current == null || _isNewer(p, current)) result[id] = p;
    }

    (await newsRepository.getAllPackageNews()).forEach(add);
    (await newsRepository.getAllRelayPackages()).forEach(add);
    return result;
  }

  // Comparações em milissegundos: é a precisão da data no texto assinado.
  // (Comparar microssegundos fazia o criador parecer sempre "mais novo".)
  static int _ms(DateTime? date) => date?.millisecondsSinceEpoch ?? 0;

  bool _isNewer(NewsPackageModel a, NewsPackageModel b) =>
      _ms(a.lastUpdated) > _ms(b.lastUpdated);

  // Data no formato do texto assinado (UTC, milissegundos). Sem data, manda a
  // época zero: versões antigas do app quebravam com null no handshake.
  static String _wireDate(DateTime? date) =>
      DateParser.toJsIso(date ?? DateTime.fromMillisecondsSinceEpoch(0));

  Future<void> _sendBytes(String endpointId, Map<String, dynamic> data) async {
    await _nearby.sendBytesPayload(
        endpointId, Uint8List.fromList(utf8.encode(jsonEncode(data))));
  }

  // Avisa os aparelhos conectados que algo mudou aqui (mudança local ou
  // matéria recebida de outro vizinho), reenviando o handshake. Espera um pouco
  // para juntar várias mudanças seguidas num único aviso.
  void announceToConnected() {
    if (connectedEndpoints.isEmpty) return;
    _announceTimer?.cancel();
    _announceTimer = Timer(_announceDelay, () {
      for (final endpointId in connectedEndpoints.toList()) {
        _sendHandshake(endpointId);
      }
    });
  }

  void _sendHandshake(String endpointId) async {
    debugPrint('NearbyService: Preparando Handshake para $endpointId.');
    try {
      final localNews = (await _meshPackages()).values;
      final List<Map<String, dynamic>> handshakeItems = localNews
          .map((news) => {'id': news.id, 'lastUpdated': _wireDate(news.lastUpdated)})
          .toList();

      final PublicKeyPackage? localKeyPackage =
          await newsRepository.getPublicKeyPackage();

      await _sendBytes(endpointId, {
        'type': 'HANDSHAKE',
        'items': handshakeItems,
        'keysTimestamp': _wireDate(localKeyPackage?.timestamp),
      });
      debugPrint("Enviou o handshake para o dispositivo $endpointId");
    } catch (e) {
      debugPrint('NearbyService: Erro ao gerar Handshake: $e');
    }
  }

  void _processIncomingJson(String endpointId, String jsonString) async {
    try {
      final dynamic decoded = jsonDecode(jsonString);
      if (decoded is! Map) return;
      final Map<String, dynamic> data = Map<String, dynamic>.from(decoded);

      switch (data['type']) {
        case 'HANDSHAKE':
          await _handleHandshake(endpointId, data);
        case 'REQUEST_NEWS':
          final newsId = data['newsId'];
          if (newsId is String) _sendFullNewsPackage(endpointId, newsId);
        case 'REQUEST_KEYS':
          _sendKeysPackage(endpointId);
        case 'FULL_NEWS_PACKAGE':
          await _handleNewsPackage(data);
        case 'FULL_KEYS_PACKAGE':
          await _handleKeysPackage(data);
      }
    } catch (e) {
      debugPrint('NearbyService: Erro ao processar JSON: $e');
    }
  }

  // Compara a lista do vizinho com a local e PEDE só o que falta ou está mais
  // novo lá. Não envia nada por conta própria: o vizinho faz a mesma conta com
  // o nosso handshake e pede o que precisar (evita a mesma matéria ir duas vezes).
  Future<void> _handleHandshake(String endpointId, Map<String, dynamic> data) async {
    debugPrint("Começou a Conferir as matérias");
    final dynamic rawItems = data['items'];
    final List<dynamic> remoteItems = rawItems is List ? rawItems : const [];
    final localNews = await _meshPackages();

    for (final remoteItem in remoteItems) {
      // Um item ruim não interrompe os outros nem a checagem de chaves
      try {
        if (remoteItem is! Map) continue;
        final dynamic remoteId = remoteItem['id'];
        if (remoteId is! String || remoteId.isEmpty) continue;

        final DateTime? remoteDate = DateParser.parse(remoteItem['lastUpdated']);
        final NewsPackageModel? localMatch = localNews[remoteId];

        if (localMatch == null ||
            (remoteDate != null && _ms(remoteDate) > _ms(localMatch.lastUpdated))) {
          await _requestSpecificNews(endpointId, remoteId);
        }
      } catch (e) {
        debugPrint('NearbyService: item do handshake ignorado: $e');
      }
    }
    debugPrint("Parou de Conferir as matérias");

    try {
      final DateTime? remoteKeysDate = DateParser.parse(data['keysTimestamp']);
      final PublicKeyPackage? localKeyPackage =
          await newsRepository.getPublicKeyPackage();

      if (remoteKeysDate != null &&
          _ms(remoteKeysDate) > _ms(localKeyPackage?.timestamp)) {
        debugPrint('NearbyService: Vizinho tem chaves mais novas. Solicitando...');
        await _sendBytes(endpointId, {'type': 'REQUEST_KEYS'});
      }
    } catch (e) {
      debugPrint('NearbyService: Erro ao conferir o pacote de chaves: $e');
    }
  }

  Future<void> _handleNewsPackage(Map<String, dynamic> data) async {
    final dynamic rawPackage = data['package'];
    if (rawPackage is! Map) return;
    final NewsPackageModel receivedPackage =
        NewsPackageModel.fromJson(Map<String, dynamic>.from(rawPackage));
    final String authorEmail = receivedPackage.email ?? '';
    final String? id = receivedPackage.id;

    // Rascunho não circula (versões antigas do app ainda podem enviar)
    if (id == null ||
        receivedPackage.news == null ||
        receivedPackage.news?.status == NewsStates.rascunho) {
      debugPrint('NearbyService: Pacote sem id/matéria ou rascunho. Ignorado.');
      return;
    }

    debugPrint('NearbyService: Pacote assinado por $authorEmail recebido. Validando...');

    if (await offlinePackageService.isAuthentic(receivedPackage)) {
      // LWW: não troca a versão local por uma mais antiga
      final local = await newsRepository.getPackageNews(id);
      bool changed = false;
      if (local == null || _isNewer(receivedPackage, local)) {
        debugPrint('NearbyService: SUCESSO! Assinatura autêntica. Matéria salva.');
        await newsRepository.saveNewsPackageInHive(receivedPackage);
        changed = true;
      }
      await newsRepository.removeRelayPackage(id);
      if (changed) await _onLocalPackagesChanged();
    } else {
      // Assinatura inválida ou autor sem chave conhecida: não é exibida
      // nem sobrescreve a versão válida, mas segue sendo retransmitida
      debugPrint('NearbyService: Falha na validação. Salvando como nó de retransmissão.');
      final relay = (await newsRepository.getAllRelayPackages())
          .firstWhereOrNull((p) => p.id == id);
      if (relay == null || _isNewer(receivedPackage, relay)) {
        await newsRepository.saveRelayPackage(receivedPackage);
        announceToConnected();
      }
    }
  }

  Future<void> _handleKeysPackage(Map<String, dynamic> data) async {
    debugPrint('NearbyService: Pacote de Chaves recebido. Validando com a API...');
    final dynamic rawPackage = data['package'];
    if (rawPackage is! Map) return;
    final PublicKeyPackage receivedKeys =
        PublicKeyPackage.fromJson(Map<String, dynamic>.from(rawPackage));

    if (!offlinePackageService.verifyKeysPackage(receivedKeys)) {
      debugPrint('NearbyService: ALERTA! Pacote de Chaves falso ou corrompido. Descartado.');
      return;
    }

    // Anti-replay: um pacote autêntico, porém mais antigo que o local, é recusado
    final PublicKeyPackage? localKeys = await newsRepository.getPublicKeyPackage();
    if (localKeys != null && _ms(receivedKeys.timestamp) <= _ms(localKeys.timestamp)) {
      debugPrint('NearbyService: Pacote de Chaves não é mais novo que o local. Recusado.');
      return;
    }

    debugPrint('NearbyService: SUCESSO! Chaves validadas. Atualizando localmente...');
    await newsRepository.savePublicKeyPackage(receivedKeys);

    // Chaves novas podem validar matérias que estavam só na retransmissão
    final int moved = await offlinePackageService.revalidateRelayPackages();
    if (moved > 0) await _onLocalPackagesChanged();
    announceToConnected();
  }

  // Matéria nova chegou aqui: mostra na tela e avisa os outros conectados
  // (é assim que ela segue adiante na rede: repasse epidêmico)
  Future<void> _onLocalPackagesChanged() async {
    if (Get.isRegistered<NewsController>()) {
      await Get.find<NewsController>().refreshFromHive();
    }
    announceToConnected();
  }

  Future<void> _requestSpecificNews(String endpointId, String newsId) async {
    await _sendBytes(endpointId, {'type': 'REQUEST_NEWS', 'newsId': newsId});
    debugPrint("Pediu a matéria: $newsId para o dispositivo: $endpointId");
  }

  // Grava o conteúdo num temporário com nome único e envia como arquivo;
  // o temporário é apagado quando a transferência termina
  Future<void> _sendAsFile(String endpointId, String prefix, Map<String, dynamic> data) async {
    final Directory tempDir = await getTemporaryDirectory();
    final File tempFile = File(
        '${tempDir.path}/out_${prefix}_${DateTime.now().microsecondsSinceEpoch}.json');
    await tempFile.writeAsString(jsonEncode(data));

    try {
      final int payloadId = await _nearby.sendFilePayload(endpointId, tempFile.path);
      _outgoingFiles[payloadId] = tempFile.path;
    } catch (e) {
      _deleteQuietly(tempFile.path);
      rethrow;
    }
  }

  void _sendFullNewsPackage(String endpointId, String newsId) async {
    try {
      // Nunca envia rascunho (só pacotes que circulam)
      final NewsPackageModel? package = (await _meshPackages())[newsId];
      if (package == null) return;
      await _sendAsFile(endpointId, newsId,
          {'type': 'FULL_NEWS_PACKAGE', 'package': package.toJson()});
      debugPrint('Enviando noticia $newsId para o dispositivo: $endpointId');
    } catch (e) {
      debugPrint('NearbyService: Erro ao enviar matéria completa: $e');
    }
  }

  void _sendKeysPackage(String endpointId) async {
    debugPrint('NearbyService: Preparando Pacote de Chaves para $endpointId...');
    try {
      final PublicKeyPackage? localKeyPackage =
          await newsRepository.getPublicKeyPackage();
      if (localKeyPackage == null) return;
      await _sendAsFile(endpointId, 'keys',
          {'type': 'FULL_KEYS_PACKAGE', 'package': localKeyPackage.toJson()});
    } catch (e) {
      debugPrint('NearbyService: Erro ao enviar pacote de chaves: $e');
    }
  }

  void _deleteQuietly(String path) {
    try {
      final file = File(path);
      if (file.existsSync()) file.deleteSync();
    } catch (_) {}
  }
}
