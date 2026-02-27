import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PopUps {
  PopUps._();

  static void snackbar({
    required String texto,
    required Color cor,
  }) {
    final currentContext = Get.context;

    if (currentContext != null) {
      final messenger = ScaffoldMessenger.maybeOf(currentContext);
      if (messenger != null) {
        messenger.hideCurrentSnackBar();
        messenger.showSnackBar(
          SnackBar(
            content: Text(texto),
            backgroundColor: cor,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 3),
          ),
        );
        return;
      }
    }

    Get.closeAllSnackbars();
    Get.showSnackbar(
      GetSnackBar(
        messageText: Text(
          texto,
          style: const TextStyle(color: Colors.white),
        ),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: cor,
        margin: const EdgeInsets.all(12),
        borderRadius: 8,
        duration: const Duration(seconds: 3),
      ),
    );
  }
}
