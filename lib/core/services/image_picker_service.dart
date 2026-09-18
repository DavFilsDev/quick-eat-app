import 'dart:convert';
import 'dart:typed_data';

import 'package:image_picker/image_picker.dart';

class ImageSelection {
  const ImageSelection({required this.bytes, required this.dataUri});

  final Uint8List bytes;
  final String dataUri;

  static String versDataUri(Uint8List bytes, {String mimeType = 'image/jpeg'}) {
    return 'data:$mimeType;base64,${base64Encode(bytes)}';
  }
}

abstract class ImagePickerService {
  Future<ImageSelection?> choisirImage();
}

class DeviceImagePickerService implements ImagePickerService {
  DeviceImagePickerService({ImagePicker? picker})
    : _picker = picker ?? ImagePicker();

  final ImagePicker _picker;

  @override
  Future<ImageSelection?> choisirImage() async {
    final fichier = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 800,
      maxHeight: 800,
      imageQuality: 70,
    );
    if (fichier == null) return null;
    final bytes = await fichier.readAsBytes();
    return ImageSelection(
      bytes: bytes,
      dataUri: ImageSelection.versDataUri(bytes),
    );
  }
}
