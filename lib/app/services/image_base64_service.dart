import 'dart:convert';
import 'dart:io';

import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

class ImageBase64Service extends GetxController {
  final ImagePicker _picker = ImagePicker();

  final RxList<String> _base64Images = <String>[].obs;

  List<String> get base64Images => _base64Images;

  final RxString _message = ''.obs;

  String get message => _message.value;

  Future<void> pickImages() async {
    try {
      final List<XFile> pickedFiles = await _picker.pickMultiImage();

      if (pickedFiles.isEmpty) {
        _message.value = 'Nenhuma imagem selecionada';
        return;
      }

      if (pickedFiles.length > 3) {
        _message.value = 'Selecione no máximo 3 imagens';
        return;
      }

      _base64Images.clear();

      for (final file in pickedFiles) {
        final bytes = await File(file.path).readAsBytes();
        final base64String = base64Encode(bytes);

        _base64Images.add(base64String);
      }

      _message.value =
      '${_base64Images.length} imagem(ns) selecionada(s)';
    } catch (e) {
      _message.value = 'Erro ao selecionar imagens';
    }
  }

  void clearImages() {
    _base64Images.clear();
  }
}