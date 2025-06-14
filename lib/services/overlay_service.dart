import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';

class OverlayService {
  final ImagePicker _picker = ImagePicker();

  final ValueNotifier<Uint8List?> overlayImage = ValueNotifier(null);

  Future<void> loadOverlayImage() async {
    if (overlayImage.value != null) {
      overlayImage.value = null;
    } else {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
      );

      if (pickedFile != null) {
        final bytes = await File(pickedFile.path).readAsBytes();
        overlayImage.value = bytes;
      }
    }
  }

  void dispose() {
    overlayImage.dispose();
  }
}