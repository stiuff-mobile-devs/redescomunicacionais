import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';

class LocationService extends GetxService {
  RxString city = "Obtendo localização...".obs;
  RxBool dialogShow = true.obs;

  Future<LocationService> init() async {
    return this;
  }

  Future<void> requestLocation() async {
    if (dialogShow.value) {
      final completer = Completer<void>();

      WidgetsBinding.instance.addPostFrameCallback((_) async {
        await Get.dialog(
          AlertDialog(
            title: Text("Solicitação de Localização"),
            content: Text(
                "Este aplicativo precisa acessar sua localização para fornecer informações relevantes à sua área. Para continuar, selecione 'Confirmar'. Caso não deseje prosseguir, selecione 'Sair'."),
            actions: [
              TextButton(
                onPressed: () {
                  SystemNavigator.pop(); // fecha o app
                },
                child: Text("Sair"),
              ),
              TextButton(
                onPressed: () async {
                  _showLocationLoadingDialog();
                  await _getUserLocation();
                  Get.back();
                  Get.back();
                },
                child: Text("Confirmar"),
              ),
            ],
          ),
        );

        completer.complete();
      });

      await completer.future;
    } else {
      await _getUserLocation();
      Get.back();
      Get.back();
    }
  }

  Future<void> _getUserLocation() async {
    try {
      LocationPermission permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        city.value = "Permissão negada";
        return;
      }
      // Obtém a posição atual
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      // Converte coordenadas em cidade
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        city.value =
            placemarks.first.subAdministrativeArea ?? "Cidade não encontrada";
      }
    } catch (e) {
      print("Erro ao obter localização: $e");
      city.value = "Erro ao obter localização";
    }
    dialogShow.value = false;
  }

  void _showLocationLoadingDialog() {
    Timer? timer;
    bool visible = true;

    Get.dialog(
      AlertDialog(
        content: StatefulBuilder(
          builder: (context, setState) {
            timer ??= Timer.periodic(const Duration(milliseconds: 600), (_) {
              setState(() => visible = !visible);
            });
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedOpacity(
                  opacity: visible ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 300),
                  child: SvgPicture.asset(
                    'assets/icons/new-icon-white.svg',
                    width: 80,
                    height: 80,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  "Aguarde enquanto verificamos sua localização",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 20),
                const CircularProgressIndicator(),
              ],
            );
          },
        ),
      ),
      barrierDismissible: false,
    ).then((_) {
      timer?.cancel();
    });
  }
}
