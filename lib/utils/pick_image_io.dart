import 'dart:typed_data';

import 'package:image_picker/image_picker.dart';

Future<Uint8List?> pickImageBytes() async {
  final picker = ImagePicker();
  final picked = await picker.pickImage(
    source: ImageSource.gallery,
    maxWidth: 1200,
    imageQuality: 85,
  );
  if (picked == null) return null;
  return picked.readAsBytes();
}
