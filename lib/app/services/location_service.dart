import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:redescomunicacionais/app/modules/user/controller/user_controller.dart';
import 'package:redescomunicacionais/app/modules/user/data/model/user_model.dart';

class LocationService extends GetxService {
  UserController userController = Get.find<UserController>();

  RxString city = "Obtendo localização...".obs;

  Future<LocationService> init() async {
    return this;
  }

  void _closeDialogIfOpen() {
    final overlayContext = Get.overlayContext;
    if (overlayContext == null) return;

    final navigator = Navigator.of(overlayContext, rootNavigator: true);
    if (navigator.canPop()) {
      navigator.pop();
    }
  }

  Future<void> requestLocation(UserModel user) async {
    bool needsLocationUpdate = user.lastLocation == null ||
        user.lastLocationUpdatedAt == null ||
        DateTime.now().difference(user.lastLocationUpdatedAt!).inDays >= 7;

    if (!needsLocationUpdate) {
      await _getUserLocation(user);
      return;
    }

    final completer = Completer<void>();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (Platform.isAndroid) {
        await Get.dialog(
          AlertDialog(
            title: const Text("Solicitação de Localização"),
            content: const Text(
                "O aplicativo gostaria de acessar sua localização para fornecer melhor informações sobre sua área. Se concorda, selecione 'Confirmar'. Caso contrário, selecione 'Continuar sem localização'."),
            actions: [
              TextButton(
                onPressed: () {
                  city.value = "Localização não fornecida";
                  if (Get.isDialogOpen ?? false) {
                    _closeDialogIfOpen();
                  }
                },
                child: const Text("Continuar sem localização"),
              ),
              TextButton(
                onPressed: () async {
                  if (Get.isDialogOpen ?? false) {
                    _closeDialogIfOpen();
                  }
                  _showLocationLoadingDialog();
                  await _getUserLocation(user);
                  if (Get.isDialogOpen ?? false) {
                    _closeDialogIfOpen();
                  }
                },
                child: const Text("Confirmar"),
              ),
            ],
          ),
        );
      } else {
        await Get.dialog(
          AlertDialog(
            title: const Text("Permitir localização"),
            content: const Text(
              "Usamos sua localização para mostrar notícias mais próximas de você.",
            ),
            actions: [
              TextButton(
                onPressed: () async {
                  if (Get.isDialogOpen ?? false) {
                    _closeDialogIfOpen();
                  }
                  _showLocationLoadingDialog();
                  await _getUserLocation(user);
                  if (Get.isDialogOpen ?? false) {
                    _closeDialogIfOpen();
                  }
                },
                child: const Text("Continuar"),
              ),
            ],
          ),
          barrierDismissible: false,
        );
      }

      completer.complete();
    });

    await completer.future;
  }

  Future<void> _getUserLocation(UserModel user) async {
    try {
      LocationPermission permission = await Geolocator.requestPermission();

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        city.value = "Localização não fornecida";
        return;
      }
      // Obtém a posição atual com timeout
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      ).timeout(const Duration(seconds: 10));

      // Converte coordenadas em cidade
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        city.value =
            placemarks.first.subAdministrativeArea ?? "Cidade não encontrada";
        user.lastLocation = placemarks.first.subAdministrativeArea;
        user.lastLocationUpdatedAt = DateTime.now();

        debugPrint(
            "Atualizando localização: ${user.lastLocation} - ${user.lastLocationUpdatedAt}");

        try {
          await userController.updateUserInFirebase(user);
          debugPrint("Firebase atualizado com sucesso");
        } catch (e) {
          debugPrint("Erro ao atualizar Firebase: $e");
        }

        try {
          await userController.updateUserInHive(user);
          debugPrint("Hive atualizado com sucesso");
        } catch (e) {
          debugPrint("Erro ao atualizar Hive: $e");
        }
      }
    } on TimeoutException {
      city.value = "Erro ao atualizar localização";
    } catch (e) {
      city.value = "Erro ao atualizar localização";
    }
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
