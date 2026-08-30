// ignore: avoid_web_libraries_in_flutter
import 'dart:async';
import 'dart:html' as html;
import 'dart:typed_data';

Future<Uint8List?> pickImageBytes() {
  final completer = Completer<Uint8List?>();
  final input = html.FileUploadInputElement()..accept = 'image/*';
  // Must be called synchronously from user gesture
  input.click();

  input.onChange.listen((_) {
    final files = input.files;
    if (files == null || files.isEmpty) {
      if (!completer.isCompleted) completer.complete(null);
      return;
    }
    final file = files.first;
    final reader = html.FileReader();
    reader.onLoadEnd.listen((_) {
      if (!completer.isCompleted) {
        final result = reader.result;
        if (result is Uint8List) {
          completer.complete(result);
        } else if (result is ByteBuffer) {
          completer.complete(result.asUint8List());
        } else {
          completer.complete(null);
        }
      }
    });
    reader.onError.listen((_) {
      if (!completer.isCompleted) completer.completeError(reader.error ?? 'read error');
    });
    reader.readAsArrayBuffer(file);
  });

  // If user cancels, onChange may not fire with empty files in some browsers.
  // Fallback: complete with null after a short delay if input is removed?
  // We keep completer pending — the caller will handle null on next interaction.

  return completer.future;
}
