import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:redescomunicacionais/app/modules/central_de_comunicacao/controller/cdc_controller.dart';
import 'package:redescomunicacionais/app/utils/theme/color_pallete.dart';
import 'package:url_launcher/url_launcher.dart';

class CentralDeComunicacaoPage extends GetView<CentralDeComunicacaoController> {
  const CentralDeComunicacaoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        elevation: 8,
        foregroundColor: Colors.white,
        title: const Text("Central de Comunicação"),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(10)),
        ),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: AppColors.appBarTopGradient(),
          ),
        ),
      ),
      body: Obx(
        () => controller.isBusy.value
            ? const Center(child: CircularProgressIndicator())
            : Container(
                decoration: BoxDecoration(
                  gradient: AppColors.darkBlueToBlackGradient(),
                ),
                margin: const EdgeInsets.symmetric(horizontal: 0),
                child: Center(
                  child: ElevatedButton(
                    onPressed: () async {
                      const url = 'https://chat.google.com/room/AAQAbsILxpE';
                      if (await canLaunchUrl(Uri.parse(url))) {
                        await launchUrl(Uri.parse(url),
                            mode: LaunchMode.externalApplication);
                      } else {
                        Get.snackbar(
                          'Erro',
                          'Não foi possível abrir o Google Chat.',
                          snackPosition: SnackPosition.BOTTOM,
                        );
                      }
                    },
                    child: const Text('Clique aqui'),
                  ),
                ),
              ),
      ),
    );
  }
}
