import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:redescomunicacionais/app/modules/splash/controller/splash_controller.dart';
import 'package:redescomunicacionais/app/utils/theme/color_pallete.dart';

class SplashPage extends GetView<SplashController> {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: AppColors.darkBlueToBlackGradient(),
            ),
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SvgPicture.asset(
                  'assets/RCLLogo.svg',
                  color: Colors.white,
                  width: 200,
                  height: 200,
                ),
                const SizedBox(height: 100),
                const CircularProgressIndicator(
                    color: Colors.white, strokeWidth: 5),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
