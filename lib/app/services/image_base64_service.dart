import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:redescomunicacionais/app/utils/translations/locale_keys.dart';

class ImageBase64Service extends GetxController {
  final RxnString _base64String = RxnString();
  final RxString _message = "".obs;

  String get message => _message.value;
  String? get base64String => _base64String.value;

  Future<void> pickImage() async {
    const int maxSizeBytes = 500000; // 500KB
    final ImagePicker picker = ImagePicker();
    final XFile? imageFile =
        await picker.pickImage(source: ImageSource.gallery);

    if (imageFile == null) {
      _message.value = LocaleKeys.noImageSelected.tr;
      return;
    }

    _base64String.value = null;
    _message.value = LocaleKeys.processingImage.tr;

    // Redimensionamento da imagem
    final CroppedFile? croppedFile = await ImageCropper().cropImage(
      sourcePath: imageFile.path,
      compressFormat: ImageCompressFormat.jpg,
      compressQuality: 100,
      maxWidth: 1920,
      maxHeight: 1080,
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: LocaleKeys.cropImageTitle.tr,
          toolbarColor: Colors.black,
          toolbarWidgetColor: Colors.white,
          initAspectRatio: CropAspectRatioPreset.original,
          lockAspectRatio: false,
          hideBottomControls: false,
        ),
        IOSUiSettings(
          title: LocaleKeys.cropImageTitle.tr,
          aspectRatioLockEnabled: false,
          resetAspectRatioEnabled: true,
        ),
      ],
    );

    if (croppedFile == null) {
      _message.value = LocaleKeys.noImageSelected.tr;
      return;
    }

    // Compressão para WebP
    Uint8List? webpBytes = await FlutterImageCompress.compressWithFile(
      croppedFile.path,
      format: CompressFormat.webp,
      quality: 100,
    );

    if (webpBytes == null) {
      _message.value = LocaleKeys.errorProcessingImage.tr;
      return;
    }

    int currentQuality = 100;

    // Loop de compressão gradual
    while (webpBytes!.lengthInBytes > maxSizeBytes && currentQuality > 10) {
      currentQuality -= 10; // Diminui 10% a cada tentativa

      webpBytes = await FlutterImageCompress.compressWithList(
        webpBytes,
        format: CompressFormat.webp,
        quality: currentQuality,
      );
    }

// Verificação final após o loop
    if (webpBytes.lengthInBytes > maxSizeBytes) {
      _message.value = LocaleKeys.imageTooLarge.tr;
    } else {
      _base64String.value = base64Encode(webpBytes);
      var tamanho = (_base64String.value!.length) / 1024;
      debugPrint(
          'Tamanho original: ${File(imageFile.path).lengthSync() / 1024} KB');
      debugPrint(
          'Tamanho após crop: ${File(croppedFile.path).lengthSync() / 1024} KB');
      debugPrint('Tamanho em WebP: ${webpBytes.lengthInBytes / 1024} KB');
      debugPrint('Tamanho em base 64: $tamanho KB');
      _message.value = LocaleKeys.imageSelectedSuccess.tr;
    }
  }
}
