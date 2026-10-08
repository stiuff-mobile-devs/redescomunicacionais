import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:nearby_connections/nearby_connections.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';
import 'package:redescomunicacionais/app/modules/mesh/model/public_key_package.dart';
import 'package:redescomunicacionais/app/modules/mesh/model/news_package_model.dart';
import 'package:redescomunicacionais/app/modules/mesh/services/package_service.dart';
import 'package:redescomunicacionais/app/modules/news/data/repository/news_repository.dart' show NewsRepository;

class NearbyService extends GetxService {
  final Strategy strategy = Strategy.P2P_CLUSTER;
  final String serviceId = "br.uff.redescomunicacionais"; // Bundle ID público
  
  final Nearby _nearby = Nearby();
  final RxList<String> connectedEndpoints = <String>[].obs;

  final NewsRepository newsRepository = NewsRepository();
  final OfflinePackageService offlinePackageService = OfflinePackageService();

  // Guarda arquivos em transferência até que o download termine por completo
  final Map<int, Payload> _incomingFilePayloads = {};

  @override
  void onInit() {
    super.onInit();
    debugPrint('NearbyService: Serviço inicializado.');
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
    if (!await requestPermissions()) return;
    try {
      await _startAdvertising(userName);
      await _startDiscovery(userName);
      debugPrint('NearbyService: Celular entrou no modo Malha Epidêmica.');
    } catch (e) {
      debugPrint('NearbyService: Erro ao iniciar malha: $e');
    }
  }

  Future<void> stopAll() async {
    await _nearby.stopAdvertising();
    await _nearby.stopDiscovery();
    await _nearby.stopAllEndpoints();
    connectedEndpoints.clear();
    _incomingFilePayloads.clear();
    debugPrint("Encerrando Malha Epidêmica");
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
      onEndpointFound: (id, name, serviceId) => _nearby.requestConnection(
        userName, id,
        onConnectionInitiated: _onConnectionInitiated,
        onConnectionResult: _onConnectionResult,
        onDisconnected: _onDisconnected,
      ),
      onEndpointLost: (id) => debugPrint('NearbyService: $id saiu do alcance.'),
    );
    debugPrint("Começando a procurar dispositivos proximos");
  }

  void _onConnectionInitiated(String endpointId, ConnectionInfo info) async {
    await _nearby.acceptConnection(
      endpointId,
      onPayLoadRecieved: _onPayloadReceived, 
      onPayloadTransferUpdate: _onPayloadTransferUpdate,
    );
    debugPrint('Conexão com dispositivo $endpointId aceita');
  }

  void _onConnectionResult(String endpointId, Status status) {
    if (status == Status.CONNECTED) {
      connectedEndpoints.add(endpointId);
      _sendHandshake(endpointId);
    } else {
      debugPrint('NearbyService: Conexão falhou. Status: $status');
    }
  }

  void _onDisconnected(String endpointId) {
    connectedEndpoints.remove(endpointId);
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
    } 
    else if (payload.type == PayloadType.FILE) {
      debugPrint('NearbyService: Transferência de arquivo iniciada de $endpointId (Payload ID: ${payload.id}).');
      // Registra o payload para ser processado assim que a transferência concluir
      _incomingFilePayloads[payload.id] = payload;
    }
  }

  void _onPayloadTransferUpdate(String endpointId, PayloadTransferUpdate update) async {
    if (update.status == PayloadStatus.SUCCESS) {
      if (_incomingFilePayloads.containsKey(update.id)) {
        final payload = _incomingFilePayloads.remove(update.id)!;

        try {
          // Obtém a URI fornecida pelo Android moderno (ou filePath como fallback)
          final String? uriString = payload.uri ?? payload.filePath;

          if (uriString != null && uriString.isNotEmpty) {
            final Directory tempDir = await getTemporaryDirectory();
            final String targetPath = '${tempDir.path}/incoming_${update.id}.json';

            // Utiliza o método nativo existente no seu plugin Nearby
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

  void _sendHandshake(String endpointId) async {
    debugPrint('NearbyService: Preparando Handshake para $endpointId.');
    try {
      final localNews = await newsRepository.getAllPackageNews(); 
      List<Map<String, dynamic>> handshakeItems = localNews.map((news) {
        return {'id': news.id, 'lastUpdated': news.lastUpdated?.toIso8601String()};
      }).toList();

      PublicKeyPackage? localKeyPackage = await newsRepository.getPublicKeyPackage();
      DateTime localKeysDate = DateTime(1970); 

      Map<String, dynamic> handshakeData = {
        'type': 'HANDSHAKE',
        'items': handshakeItems,
        'keysTimestamp': localKeyPackage?.timestamp.toIso8601String() ?? localKeysDate.toIso8601String(),
      };
      
      String jsonString = jsonEncode(handshakeData);
      await _nearby.sendBytesPayload(endpointId, Uint8List.fromList(utf8.encode(jsonString)));
      debugPrint("Enviou o handshake para o dispositivo $endpointId");
      
    } catch (e) {
      debugPrint('NearbyService: Erro ao gerar Handshake: $e');
    }
  }

  void _processIncomingJson(String endpointId, String jsonString) async {
    try {
      final Map<String, dynamic> data = jsonDecode(jsonString);
      
      // === CASO 1: HANDSHAKE ===
      if (data['type'] == 'HANDSHAKE') {
        debugPrint("Começou a Conferir as matérias");
        final List<dynamic> remoteItems = data['items'] ?? [];
        final localNews = await newsRepository.getAllPackageNews();

        for (var remoteItem in remoteItems) {
          String remoteId = remoteItem['id'];
          DateTime remoteDate = DateTime.parse(remoteItem['lastUpdated']);
          final localMatch = localNews.firstWhereOrNull((news) => news.id == remoteId);

          if (localMatch == null) {
            _requestSpecificNews(endpointId, remoteId);
          } else {
            final DateTime localDate = localMatch.lastUpdated ?? DateTime(1970);
            if (remoteDate.isAfter(localDate)) {
              _requestSpecificNews(endpointId, remoteId);
            } else if (localDate.isAfter(remoteDate)) {
              _sendFullNewsPackage(endpointId, localMatch.id);
            }
          }
        }

        debugPrint("Parou de Conferir as matérias");
        debugPrint("Começou a conferir o pacote de chaves");

        DateTime remoteKeysDate = DateTime.parse(data['keysTimestamp']);
        PublicKeyPackage? localKeyPackage = await newsRepository.getPublicKeyPackage();
        DateTime localKeysDate = localKeyPackage?.timestamp ?? DateTime(1970);

        if (remoteKeysDate.isAfter(localKeysDate)) {
          debugPrint('NearbyService: Vizinho tem chaves mais novas. Solicitando...');
          Map<String, dynamic> requestData = {'type': 'REQUEST_KEYS'};
          await _nearby.sendBytesPayload(endpointId, Uint8List.fromList(utf8.encode(jsonEncode(requestData))));
        } else if (localKeysDate.isAfter(remoteKeysDate) && localKeyPackage != null) {
          debugPrint('NearbyService: Minhas chaves são mais novas. Enviando pacote...');
          _sendKeysPackage(endpointId);
        }

        debugPrint("Parou de Conferir o pacote de chaves");
      }
      
      // === CASOS 2 e 3: PEDIDOS ESPECÍFICOS ===
      else if (data['type'] == 'REQUEST_NEWS') {
        _sendFullNewsPackage(endpointId, data['newsId']);
      }
      else if (data['type'] == 'REQUEST_KEYS') {
        _sendKeysPackage(endpointId);
      }
      
      // === CASO 4: RECEBIMENTO DA MATÉRIA (SEGURANÇA DO EDITOR) ===
      else if (data['type'] == 'FULL_NEWS_PACKAGE') {
        NewsPackageModel receivedPackage = NewsPackageModel.fromJson(data['package']);
        String authorEmail = receivedPackage.email ?? '';
        
        debugPrint('NearbyService: Pacote assinado por $authorEmail recebido. Validando...');
        
        List<String> keysToTest = await newsRepository.getKeysListByEmail('jfontinele@id.uff.br');

        if (keysToTest.isNotEmpty) {
          bool isAuthentic = false;

          for (String keyStr in keysToTest) {
            isAuthentic = offlinePackageService.verifyNewsPackage(receivedPackage, keyStr);
            if (isAuthentic) break; 
          }

          if (isAuthentic && receivedPackage.news != null) {
            debugPrint('NearbyService: SUCESSO! Assinatura autêntica. Matéria e pacote salvos.');
            await newsRepository.saveNewsToHive(receivedPackage.news!);
            await newsRepository.saveNewsPackageInHive(receivedPackage);
          } else {
            debugPrint('NearbyService: Falha na validação. Salvando como nó de retransmissão.');
            await newsRepository.saveNewsPackageInHive(receivedPackage);
          }
        }
      }

      // === CASO 5: RECEBIMENTO DO PACOTE DE CHAVES (SEGURANÇA DA API) ===
      else if (data['type'] == 'FULL_KEYS_PACKAGE') {
        debugPrint('NearbyService: Pacote de Chaves recebido. Validando com a API...');
        PublicKeyPackage receivedKeys = PublicKeyPackage.fromJson(data['package']);
        
        bool isKeysAuthentic = offlinePackageService.verifyKeysPackage(receivedKeys);

        if (isKeysAuthentic) {
          debugPrint('NearbyService: SUCESSO! Chaves validadas. Atualizando localmente...');
          await newsRepository.savePublicKeyPackage(receivedKeys);
        } else {
          debugPrint('NearbyService: ALERTA! Pacote de Chaves falso ou corrompido. Descartado.');
        }
      }

    } catch (e) {
      debugPrint('NearbyService: Erro ao processar JSON: $e');
    }
  }

  void _requestSpecificNews(String endpointId, String newsId) async {
    Map<String, dynamic> requestData = {'type': 'REQUEST_NEWS', 'newsId': newsId};
    await _nearby.sendBytesPayload(endpointId, Uint8List.fromList(utf8.encode(jsonEncode(requestData))));
    debugPrint("Pediu a matéria: $newsId para o dispositivo: $endpointId");
  }

  void _sendFullNewsPackage(String endpointId, String? newsId) async {
    if (newsId == null) return;
    try {
      NewsPackageModel? package = await newsRepository.getPackageNews(newsId);
      if (package != null) {
        Map<String, dynamic> payloadData = {'type': 'FULL_NEWS_PACKAGE', 'package': package.toJson()};
        String jsonString = jsonEncode(payloadData);
        
        Directory tempDir = await getTemporaryDirectory();
        File tempFile = File('${tempDir.path}/$newsId.json');
        await tempFile.writeAsString(jsonString);

        await _nearby.sendFilePayload(endpointId, tempFile.path);
        debugPrint('Enviando noticia $newsId para o dispositivo: $endpointId');
      }
    } catch (e) {
      debugPrint('NearbyService: Erro ao enviar matéria completa: $e');
    }
  }

  void _sendKeysPackage(String endpointId) async {
    debugPrint('NearbyService: Preparando Pacote de Chaves para $endpointId...');
    try {
      PublicKeyPackage? localKeyPackage = await newsRepository.getPublicKeyPackage();
      if (localKeyPackage != null) {
        Map<String, dynamic> payloadData = {'type': 'FULL_KEYS_PACKAGE', 'package': localKeyPackage.toJson()};
        String jsonString = jsonEncode(payloadData);
        
        Directory tempDir = await getTemporaryDirectory();
        File tempFile = File('${tempDir.path}/keys.json');
        await tempFile.writeAsString(jsonString);
        
        await _nearby.sendFilePayload(endpointId, tempFile.path);
      }
    } catch (e) {
      debugPrint('NearbyService: Erro ao enviar pacote de chaves: $e');
    }
  }
}