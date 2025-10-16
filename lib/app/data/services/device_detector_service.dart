import 'dart:io';
import 'package:flutter/foundation.dart';

/// Enum para definir os tipos de dispositivos suportados
enum DeviceType { android, ios, web, desktop, unknown }

/// Classe responsável por detectar o tipo de dispositivo onde a aplicação está rodando
class DeviceDetectorService {
  static DeviceDetectorService? _instance;

  DeviceDetectorService._internal();

  /// Singleton para garantir uma única instância do serviço
  static DeviceDetectorService get instance {
    _instance ??= DeviceDetectorService._internal();
    return _instance!;
  }

  /// Detecta o tipo de dispositivo atual
  DeviceType get currentDeviceType {
    if (kIsWeb) {
      return DeviceType.web;
    }

    if (Platform.isAndroid) {
      return DeviceType.android;
    }

    if (Platform.isIOS) {
      return DeviceType.ios;
    }

    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      return DeviceType.desktop;
    }

    return DeviceType.unknown;
  }

  /// Verifica se é um dispositivo Android
  bool get isAndroid => currentDeviceType == DeviceType.android;

  /// Verifica se é um dispositivo iOS
  bool get isIOS => currentDeviceType == DeviceType.ios;

  /// Verifica se é Web
  bool get isWeb => currentDeviceType == DeviceType.web;

  /// Verifica se é Desktop (Windows, Linux ou macOS)
  bool get isDesktop => currentDeviceType == DeviceType.desktop;

  /// Verifica se é um dispositivo móvel (Android ou iOS)
  bool get isMobile => isAndroid || isIOS;

  /// Retorna uma string com o nome do dispositivo
  String get deviceName {
    switch (currentDeviceType) {
      case DeviceType.android:
        return 'Android';
      case DeviceType.ios:
        return 'iOS';
      case DeviceType.web:
        return 'Web';
      case DeviceType.desktop:
        return 'Desktop';
      case DeviceType.unknown:
        return 'Unknown';
    }
  }

  /// Retorna informações detalhadas sobre a plataforma
  Map<String, dynamic> get platformInfo {
    return {
      'deviceType': currentDeviceType.toString(),
      'deviceName': deviceName,
      'isWeb': isWeb,
      'isMobile': isMobile,
      'isDesktop': isDesktop,
      'isAndroid': isAndroid,
      'isIOS': isIOS,
    };
  }
}
