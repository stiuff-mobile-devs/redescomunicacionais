import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:redescomunicacionais/app/modules/connections/data/repository/connections_repository.dart';

class ConnectionsController extends GetxController {
  ConnectionsController();
  ConnectionsRepository connectionsRepository = ConnectionsRepository();

  final RxBool isLoading = false.obs;

  final RxBool isInternetConnected = false.obs;

  StreamSubscription<InternetStatus>? _connectionSubscription;

  Timer? _timer;
  int secondsRefresh = 15;

  @override
  void onInit() {
    super.onInit();
    _startInternetMonitoring();
    //Não é necessário iniciar o timer para atualizar as conexões, pois a atualização ocorre em tempo real via stream. 
    //_startTimer(secondsRefresh);
  }

  void _startInternetMonitoring() {
    // Escuta as mudanças de status da internet
    _connectionSubscription = InternetConnection().onStatusChange.listen((
      InternetStatus status,
    ) {
      switch (status) {
        case InternetStatus.connected:
          isInternetConnected.value = true;
          break;
        case InternetStatus.disconnected:
          isInternetConnected.value = false;
          break;
      }
    });
  }

  void _startTimer(int secondsRefresh) {
    _timer = Timer.periodic(Duration(seconds: secondsRefresh), (timer) {
      debugPrint('Atualizando conexões...');
    });
  }



  @override
  void onClose() {
    _connectionSubscription?.cancel();
    _timer?.cancel();
    super.onClose();
  }
}
