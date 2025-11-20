import 'package:get/get.dart';

class CentralDeComunicacaoController extends GetxController {
  CentralDeComunicacaoController();

  RxBool isBusy = false.obs;

  final List<Map<String, String>> chats = const [
    {
      'name': 'Avisos RCL SSA',
      'url': 'https://chat.google.com/room/AAQA29ehRvg',
      'image': 'assets/icons/new-icon-green.png'
    },
    {
      'name': 'Bate-papo Usuários RCL SSA',
      'url': 'https://chat.google.com/room/AAQAlCP4PCI',
      'image': 'assets/icons/new-icon-red.png'
    },
    {
      'name': 'Feedback e Sugestões RCL SSA',
      'url': 'https://chat.google.com/room/AAQAkabSUuw',
      'image': 'assets/icons/new-icon-yellow.png'
    },
  ];
}
