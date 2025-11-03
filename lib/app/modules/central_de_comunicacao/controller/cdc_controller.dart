import 'package:get/get.dart';

class CentralDeComunicacaoController extends GetxController {
  CentralDeComunicacaoController();

  RxBool isBusy = false.obs;

  final List<Map<String, String>> chats = const [
    {
      'name': 'Chat de Informes',
      'url': 'https://chat.google.com/room/AAQAbsILxpE',
      'image': 'assets/icons/midi.jpg'
    },
    {
      'name': 'Chat 2',
      'url': 'https://chat.google.com/room/AAQAbsILxpE',
      'image': 'assets/icons/midi.jpg'
    },
    {
      'name': 'Chat 3',
      'url': 'https://chat.google.com/room/AAQAbsILxpE',
      'image': 'assets/icons/midi.jpg'
    },
    {
      'name': 'Chat 4',
      'url': 'https://chat.google.com/room/AAQAbsILxpE',
      'image': 'assets/icons/midi.jpg'
    },
  ];
}
