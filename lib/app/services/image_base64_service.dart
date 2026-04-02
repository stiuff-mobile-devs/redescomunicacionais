import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as img;
import 'package:image_cropper/image_cropper.dart';

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
      _message.value = 'no_image_selected'.tr;
      return;
    }

    _base64String.value = null;
    _message.value = 'processing_image_message'.tr;

    // MUDANÇA: Verificar tipo MIME em vez da extensão do arquivo
    String? mimeType = imageFile.mimeType;
    if (mimeType != null) {
      // Verificar pelo tipo MIME
      if (mimeType != 'image/jpeg' && mimeType != 'image/jpg') {
        _message.value = 'image_format_invalid'.tr;
        return;
      }
    } else {
      // Fallback: verificar extensão (para compatibilidade)
      String fileName = imageFile.name.toLowerCase();
      if (!fileName.endsWith('.jpg') && !fileName.endsWith('.jpeg')) {
        _message.value = 'image_format_invalid'.tr;
        return;
      }
    }

    final CroppedFile? croppedFile = await ImageCropper().cropImage(
      sourcePath: imageFile.path,
      compressFormat: ImageCompressFormat.jpg,
      compressQuality: 85,
      maxWidth: 1280,
      maxHeight: 1280,
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: 'crop_image_title'.tr,
          toolbarColor: Colors.black,
          toolbarWidgetColor: Colors.white,
          initAspectRatio: CropAspectRatioPreset.original,
          lockAspectRatio: false,
          hideBottomControls: false,
        ),
        IOSUiSettings(
          title: 'crop_image_title'.tr,
          aspectRatioLockEnabled: false,
          resetAspectRatioEnabled: true,
        ),
      ],
    );

    if (croppedFile == null) {
      _message.value = 'no_image_selected'.tr;
      return;
    }

    Uint8List imageBytes = await croppedFile.readAsBytes();
    if (imageBytes.lengthInBytes <= maxSizeBytes) {
      _base64String.value = base64Encode(imageBytes);
      _message.value = 'image_selected_success'.tr;
      return;
    }

    img.Image? image = img.decodeImage(imageBytes);
    if (image == null) {
      _message.value = 'error_processing_image'.tr;
      return;
    }

    Uint8List compressedImage =
        Uint8List.fromList(img.encodeJpg(image, quality: 10));

    if (compressedImage.lengthInBytes > maxSizeBytes) {
      _message.value = 'image_too_large'.tr;
    } else {
      _base64String.value = base64Encode(compressedImage);
      _message.value = 'image_compressed'.tr;
    }
  }
}
