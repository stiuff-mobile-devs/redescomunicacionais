import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:redescomunicacionais/app/modules/user/controller/user_controller.dart';
import 'package:redescomunicacionais/app/modules/user/data/model/user_model.dart';
import 'package:redescomunicacionais/app/utils/widgets/blinking_loading_icon.dart';

class LocationService extends GetxService {
  UserController userController = Get.find<UserController>();

  RxString city = ''.obs;

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
    

    final completer = Completer<void>();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (Platform.isAndroid) {
        await Get.dialog(
          AlertDialog(
            title: Text('location_request_title'.tr),
            content: Text('location_permission_description_android'.tr),
            actions: [
              TextButton(
                onPressed: () {
                  city.value = 'location_not_provided'.tr;
                  if (Get.isDialogOpen ?? false) {
                    _closeDialogIfOpen();
                  }
                },
                child: Text('continue_without_location'.tr),
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
                child: Text('confirm'.tr),
              ),
            ],
          ),
        );
      } else {
        await Get.dialog(
          AlertDialog(
            title: Text('allow_location'.tr),
            content: Text('location_permission_description_ios'.tr),
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
                child: Text('continue'.tr),
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
        city.value = 'location_not_provided'.tr;
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
        city.value = placemarks.first.subAdministrativeArea ?? 'city_not_found'.tr;

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
      city.value = 'error_updating_location'.tr;
    } catch (e) {
      city.value = 'error_updating_location'.tr;
    }
  }

  void _showLocationLoadingDialog() {
    Get.dialog(
      AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const BlinkingLoadingIcon(
              size: 80,
              color: Colors.black,
            ),
            const SizedBox(height: 20),
            Text(
              'checking_location_message'.tr,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16),
            ),
            SizedBox(height: 20),
            BlinkingLoadingIcon(
              size: 36,
              color: Colors.black,
            ),
          ],
        ),
      ),
      barrierDismissible: false,
    );
  }
}