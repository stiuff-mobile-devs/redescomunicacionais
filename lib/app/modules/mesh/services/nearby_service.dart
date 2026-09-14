import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:nearby_connections/nearby_connections.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';
import 'package:redescomunicacionais/app/modules/mesh/model/news_package_model.dart';
import 'package:redescomunicacionais/app/modules/mesh/services/package_service.dart';
import 'package:redescomunicacionais/app/modules/news/data/repository/news_repository.dart' show NewsRepository;

class NearbyService extends GetxService {
  final Strategy strategy = Strategy.P2P_CLUSTER;
  final String serviceId = "com.sua_empresa.redescomunicacionais"; // Bundle ID público
  
  final Nearby _nearby = Nearby();
  final RxList<String> connectedEndpoints = <String>[].obs;

  final NewsRepository newsRepository = NewsRepository();
  final OfflinePackageService offlinePackageService = OfflinePackageService();

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
  }

  Future<void> _startAdvertising(String userName) async {
    await _nearby.startAdvertising(
      userName, strategy, serviceId: serviceId,
      onConnectionInitiated: _onConnectionInitiated,
      onConnectionResult: _onConnectionResult,
      onDisconnected: _onDisconnected,
    );
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
  }

  void _onConnectionInitiated(String endpointId, ConnectionInfo info) async {
    // A conexão torna-se simétrica após aceita, removendo a distinção entre anunciante e descobridor.
    await _nearby.acceptConnection(
      endpointId,
      onPayLoadRecieved: _onPayloadReceived, 
      onPayloadTransferUpdate: _onPayloadTransferUpdate,
    );
  }

  void _onConnectionResult(String endpointId, Status status) {
    if (status == Status.CONNECTED) {
      connectedEndpoints.add(endpointId);
      _sendHandshake(endpointId);
    } else {
      debugPrint('NearbyService: Conexão falhou. Status: $status');
    }
  }

  void _onDisconnected(String endpointId) => connectedEndpoints.remove(endpointId);

  void _onPayloadReceived(String endpointId, Payload payload) async {
    if (payload.type == PayloadType.BYTES) {
      String jsonString = String.fromCharCodes(payload.bytes!);
      _processIncomingJson(endpointId, jsonString);
    } 
    else if (payload.type == PayloadType.FILE) {
      debugPrint('NearbyService: Arquivo pesado recebido de $endpointId.');
      try {
        File receivedFile = File(payload.filePath!);
        String jsonString = await receivedFile.readAsString();
        _processIncomingJson(endpointId, jsonString);
        await receivedFile.delete(); 
      } catch (e) {
        debugPrint('NearbyService: Erro ao ler arquivo recebido: $e');
      }
    }
  }

  void _onPayloadTransferUpdate(String endpointId, PayloadTransferUpdate update) {}

  void _sendHandshake(String endpointId) async {
    debugPrint('NearbyService: Preparando Handshake para $endpointId.');
    try {
      // Busca metadados das Notícias
      final localNews = await newsRepository.getAllPackageNews(); 
      List<Map<String, dynamic>> handshakeItems = localNews.map((news) {
        return {'id': news.id, 'lastUpdated': news.lastUpdated?.toIso8601String()};
      }).toList();

      // Busca a data do Pacote de Chaves Públicas local
      // PublicKeyPackage? localKeyPackage = await keyRepository.getLocalPublicKeyPackage();
      DateTime localKeysDate = DateTime(1970); // localKeyPackage?.timestamp ?? DateTime(1970);

      Map<String, dynamic> handshakeData = {
        'type': 'HANDSHAKE',
        'items': handshakeItems,
        'keysTimestamp': localKeysDate.toIso8601String(),
      };
      
      String jsonString = jsonEncode(handshakeData);
      await _nearby.sendBytesPayload(endpointId, Uint8List.fromList(jsonString.codeUnits));
      
    } catch (e) {
      debugPrint('NearbyService: Erro ao gerar Handshake: $e');
    }
  }

  void _requestSpecificNews(String endpointId, String newsId) async {
    Map<String, dynamic> requestData = {'type': 'REQUEST_NEWS', 'newsId': newsId};
    await _nearby.sendBytesPayload(endpointId, Uint8List.fromList(jsonEncode(requestData).codeUnits));
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
      }
    } catch (e) {
      debugPrint('NearbyService: Erro ao enviar matéria completa: $e');
    }
  }

  void _sendKeysPackage(String endpointId) async {
    debugPrint('NearbyService: Preparando Pacote de Chaves para $endpointId...');
    try {
      // PublicKeyPackage? localKeyPackage = await keyRepository.getLocalPublicKeyPackage();
      // if (localKeyPackage != null) {
      //   Map<String, dynamic> payloadData = {'type': 'FULL_KEYS_PACKAGE', 'package': localKeyPackage.toJson()};
      //   String jsonString = jsonEncode(payloadData);
      //   Directory tempDir = await getTemporaryDirectory();
      //   File tempFile = File('${tempDir.path}/keys.json');
      //   await tempFile.writeAsString(jsonString);
      //   await _nearby.sendFilePayload(endpointId, tempFile.path);
      // }
    } catch (e) {
      debugPrint('NearbyService: Erro ao enviar pacote de chaves: $e');
    }
  }

  void _processIncomingJson(String endpointId, String jsonString) async {
    try {
      final Map<String, dynamic> data = jsonDecode(jsonString);
      
      // === CASO 1: HANDSHAKE ===
      if (data['type'] == 'HANDSHAKE') {
        final List<dynamic> remoteItems = data['items'];
        final localNews = await newsRepository.getAllPackageNews();

        // Compara matérias (Last Write Wins)
        for (var remoteItem in remoteItems) {
          String remoteId = remoteItem['id'];
          DateTime remoteDate = DateTime.parse(remoteItem['lastUpdated']);
          final localMatch = localNews.firstWhereOrNull((news) => news.id == remoteId);

          if (localMatch == null) {
            _requestSpecificNews(endpointId, remoteId);
          } else {
            if (remoteDate.isAfter(localMatch.lastUpdated!)) {
              _requestSpecificNews(endpointId, remoteId);
            } else if (localMatch.lastUpdated!.isAfter(remoteDate)) {
              _sendFullNewsPackage(endpointId, localMatch.id);
            }
          }
        }

        // Compara Chaves Públicas para evitar ataques de repetição
        DateTime remoteKeysDate = DateTime.parse(data['keysTimestamp']);
        // PublicKeyPackage? localKeyPackage = await keyRepository.getLocalPublicKeyPackage();
        DateTime localKeysDate = DateTime(1970); // localKeyPackage?.timestamp ?? DateTime(1970);

        if (remoteKeysDate.isAfter(localKeysDate)) {
          debugPrint('NearbyService: Vizinho tem chaves mais novas. Solicitando...');
          Map<String, dynamic> requestData = {'type': 'REQUEST_KEYS'};
          await _nearby.sendBytesPayload(endpointId, Uint8List.fromList(jsonEncode(requestData).codeUnits));
        } else if (localKeysDate.isAfter(remoteKeysDate)) {
          _sendKeysPackage(endpointId);
        }
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
        
        debugPrint('NearbyService: Pacote de $authorEmail recebido. Validando...');
        
        // Pega a Chave Pública do autor salva no Hive
        // String? publicKeyStr = await keyRepository.getPublicKeyStrByEmail(authorEmail);
        String? publicKeyStr = "chave_ficticia";

        if (publicKeyStr != null) {
          bool isAuthentic = offlinePackageService.verifyPackage(receivedPackage, publicKeyStr);
          if (isAuthentic && receivedPackage.news != null) {
            debugPrint('NearbyService: SUCESSO! Assinatura autêntica.');
            await newsRepository.saveNewsToHive(receivedPackage.news!);
          } else {
            debugPrint('NearbyService: ALERTA! Assinatura INVÁLIDA. Pacote descartado.');
          }
        }
      }

      // === CASO 5: RECEBIMENTO DO PACOTE DE CHAVES (SEGURANÇA DA API) ===
      else if (data['type'] == 'FULL_KEYS_PACKAGE') {
        debugPrint('NearbyService: Pacote de Chaves recebido. Validando com a API...');
        // PublicKeyPackage receivedKeys = PublicKeyPackage.fromJson(data['package']);
        
        // A Chave Pública da API é hardcoded e todos confiam nela
        // String apiPublicKey = Constants.apiPublicKey; 
        
        // TODO: Chamar o serviço de criptografia para checar a assinatura (receivedKeys.signature) 
        // usando a apiPublicKey. Se for verdadeiro, salva o pacote no Hive:
        // await keyRepository.saveLocalPublicKeyPackage(receivedKeys);
      }

    } catch (e) {
      debugPrint('NearbyService: Erro ao processar JSON: $e');
    }
  }
}