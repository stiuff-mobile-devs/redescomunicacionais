import 'dart:convert';
import 'dart:typed_data';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as img;

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

    Uint8List imageBytes = await imageFile.readAsBytes();
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
