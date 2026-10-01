import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:redescomunicacionais/app/modules/dashboard/controller/home_controller.dart';
import 'package:redescomunicacionais/app/modules/mesh/services/nearby_service.dart';
import 'package:redescomunicacionais/app/utils/theme/theme_controller.dart';
import 'package:redescomunicacionais/app/utils/theme/color_pallete.dart';

class ConsolePage extends GetView<HomeController> {
  const ConsolePage({super.key});

  // === VARIÁVEIS ESTÁTICAS PARA MANTER OS LOGS MESMO SAINDO DA TELA ===
  static final RxList<String> _consoleLogs = <String>[].obs;
  static bool _isLogIntercepted = false;

  void _setupInterceptor() {
    // Intercepta o debugPrint global apenas uma vez
    if (!_isLogIntercepted) {
      _isLogIntercepted = true;
      final originalDebugPrint = debugPrint;
      debugPrint = (String? message, {int? wrapWidth}) {
        final time = DateTime.now().toLocal().toString().split(' ')[1].substring(0, 8);
        _consoleLogs.insert(0, "[$time] $message");
        
        // Mantém apenas os últimos 150 logs para não pesar a memória
        if (_consoleLogs.length > 150) _consoleLogs.removeLast();
        
        originalDebugPrint(message, wrapWidth: wrapWidth);
      };
      debugPrint("Console Visual Iniciado. Aguardando eventos da Rede Mesh...");
    }
  }

  @override
  Widget build(BuildContext context) {
    _setupInterceptor();
    final isLight = Get.find<ThemeController>().isLight;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Console Mesh (Nearby)', style: TextStyle(fontWeight: FontWeight.bold)),
        foregroundColor: Colors.white,
      ),
      backgroundColor: isLight ? Colors.grey.shade100 : Colors.black,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Botões de Interação do Teste
              Wrap(
                spacing: 12,
                runSpacing: 12,
                alignment: WrapAlignment.center,
                children: [
                  ElevatedButton.icon(
                    onPressed: () async {
                      try {
                        final nearbyService = Get.find<NearbyService>();
                        await nearbyService.startEpidemicMesh('Celular_Teste_${DateTime.now().second}');
                      } catch (e) {
                        debugPrint("Erro ao buscar NearbyService: $e");
                      }
                    },
                    icon: const Icon(Icons.radar, color: Colors.white),
                    label: const Text('Iniciar Rádio', style: TextStyle(color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: () async {
                      try {
                        final nearbyService = Get.find<NearbyService>();
                        await nearbyService.stopAll();
                        debugPrint("Malha Epidêmica Parada Manualmente.");
                      } catch (e) {
                        debugPrint("Erro: $e");
                      }
                    },
                    icon: const Icon(Icons.stop, color: Colors.white),
                    label: const Text('Parar Rádio', style: TextStyle(color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    ),
                  ),
                  TextButton.icon(
                    onPressed: () => _consoleLogs.clear(),
                    icon: const Icon(Icons.delete_outline),
                    label: const Text('Limpar Logs'),
                  )
                ],
              ),
              const SizedBox(height: 16),
              
              // Área Preta do Terminal
              Expanded(
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.black87,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade800, width: 2),
                  ),
                  child: Obx(() {
                    if (_consoleLogs.isEmpty) {
                      return const Center(
                        child: Text(
                          "Nenhum log no momento...", 
                          style: TextStyle(color: Colors.white54, fontStyle: FontStyle.italic)
                        ),
                      );
                    }
                    return ListView.builder(
                      itemCount: _consoleLogs.length,
                      itemBuilder: (context, index) {
                        final log = _consoleLogs[index];
                        
                        // Sistema de cores para facilitar a leitura
                        Color logColor = Colors.white;
                        if (log.contains("Erro") || log.contains("ALERTA") || log.contains("falhou")) {
                          logColor = Colors.redAccent;
                        } else if (log.contains("SUCESSO")) {
                          logColor = Colors.greenAccent;
                        } else if (log.contains("Validando") || log.contains("Handshake") || log.contains("Preparando")) {
                          logColor = Colors.orangeAccent;
                        }

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 6.0),
                          child: Text(
                            log,
                            style: TextStyle(
                              fontFamily: 'monospace',
                              fontSize: 13,
                              color: logColor,
                            ),
                          ),
                        );
                      },
                    );
                  }),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}