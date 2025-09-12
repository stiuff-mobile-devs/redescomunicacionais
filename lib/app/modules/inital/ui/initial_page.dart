import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:redescomunicacionais/app/modules/login/controller/login_controller.dart';

class InitialPage extends StatefulWidget {
  const InitialPage({super.key});

  @override
  State<InitialPage> createState() => _InitialPageState();
}

class _InitialPageState extends State<InitialPage> {
  final LoginController _loginController = Get.put(LoginController());

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: Future.delayed(const Duration(seconds: 3), () async {
          return await _loginController.tryLogin();
        }),
        builder: (context, snapshot) {
          return Stack(
            children: [
              Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topRight,
                    end: Alignment.bottomLeft,
                    colors: [
                      Colors.blue,
                      Colors.black,
                    ],
                  ),
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
          );
        });
  }
}
