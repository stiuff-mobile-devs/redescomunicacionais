import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class ThemeController extends GetxController {
  final GetStorage _storage = GetStorage();

  static const String _themeKey = 'theme_mode';

  final Rx<ThemeMode> themeMode = ThemeMode.dark.obs;

  bool get isLight => themeMode.value == ThemeMode.light;

  @override
  void onInit() {
    super.onInit();

    final savedTheme = _storage.read<String>(_themeKey);

    if (savedTheme == 'light') {
      themeMode.value = ThemeMode.light;
    } else {
      themeMode.value = ThemeMode.dark;
    }
  }

  void setWhiteTheme() {
    themeMode.value = ThemeMode.light;

    _storage.write(
      _themeKey,
      'light',
    );

    Get.changeThemeMode(ThemeMode.light);
  }

  void setClassicTheme() {
    themeMode.value = ThemeMode.dark;

    _storage.write(
      _themeKey,
      'dark',
    );

    Get.changeThemeMode(ThemeMode.dark);
  }
}