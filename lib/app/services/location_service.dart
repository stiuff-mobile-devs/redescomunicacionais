import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:redescomunicacionais/app/modules/user/controller/user_controller.dart';
import 'package:redescomunicacionais/app/modules/user/data/model/user_model.dart';
import 'package:redescomunicacionais/app/modules/utils/popups/app_popups.dart';
import 'package:redescomunicacionais/app/modules/utils/translations/locale_keys.dart';

class LocationService extends GetxService {
  UserController userController = Get.find<UserController>();

  RxString city = ''.obs;

  Future<LocationService> init() async {
    return this;
  }

  Future<void> requestLocation(UserModel user) async {
    final completer = Completer<void>();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final bool allowed;

      if (Platform.isAndroid) {
        // Fechar a folha conta como "continuar sem localização"
        allowed = await AppPopups.confirm(
          title: LocaleKeys.locationRequestTitle.tr,
          message: LocaleKeys.locationPermissionDescriptionAndroid.tr,
          icon: Icons.location_on_outlined,
          confirmText: LocaleKeys.confirm.tr,
          cancelText: LocaleKeys.continueWithoutLocation.tr,
        );
      } else {
        // No iOS só existe "Continuar": o sistema pergunta a permissão depois
        await AppPopups.alert(
          title: LocaleKeys.allowLocation.tr,
          message: LocaleKeys.locationPermissionDescriptionIos.tr,
          icon: Icons.location_on_outlined,
          confirmText: LocaleKeys.continueLabel.tr,
          dismissible: false,
        );
        allowed = true;
      }

      if (allowed) {
        AppPopups.showLoading(LocaleKeys.checkingLocationMessage.tr);
        await _getUserLocation(user);
        AppPopups.hideLoading();
      } else {
        city.value = LocaleKeys.locationNotProvided.tr;
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
        city.value = LocaleKeys.locationNotProvided.tr;
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
            placemarks.first.subAdministrativeArea ?? LocaleKeys.cityNotFound.tr;
      }
    } on TimeoutException {
      city.value = LocaleKeys.errorUpdatingLocation.tr;
    } catch (e) {
      city.value = LocaleKeys.errorUpdatingLocation.tr;
    }
  }
}
