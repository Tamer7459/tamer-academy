import 'pick_image_stub.dart'
    if (dart.library.html) 'pick_image_web.dart'
    if (dart.library.io) 'pick_image_io.dart' as picker;

import 'dart:typed_data';

Future<Uint8List?> pickImageBytes() => picker.pickImageBytes();
