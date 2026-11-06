import 'package:get/get.dart';
import 'package:redescomunicacionais/app/utils/translations/locale_keys.dart';

class UserRoles {
  static const String admin = 'admin';
  static const String editor = 'editor';
  static const String user = 'user';
  static const String guest = 'guest';

  // Nome do papel no idioma atual
  static String label(String? role) {
    switch (role) {
      case admin:
        return LocaleKeys.roleAdmin.tr;
      case editor:
        return LocaleKeys.roleEditor.tr;
      default:
        return LocaleKeys.roleUser.tr;
    }
  }
}
