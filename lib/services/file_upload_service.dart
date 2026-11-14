import 'dart:typed_data';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

import '../models/file_attachment.dart';

class FileUploadService {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String get _uid {
    final u = _auth.currentUser;
    if (u == null) throw Exception('Not authenticated');
    return u.uid;
  }

  Future<FileAttachment> uploadFile({
    required String assignmentId,
    required Uint8List bytes,
    required String originalName,
    required String mimeType,
  }) async {
    if (bytes.length > FileAttachment.maxFileSizeBytes) {
      throw Exception('File too large (max ${FileAttachment.maxFileSizeBytes ~/ (1024 * 1024)} MB)');
    }
    if (!FileAttachment.allowedMimeTypes.contains(mimeType)) {
      throw Exception('File type not allowed: $mimeType');
    }

    final cleanName = FileAttachment.sanitizeFileName(originalName);
    final uuid = '${DateTime.now().microsecondsSinceEpoch}_${_uid.substring(0, 6)}';
    final storagePath = 'submissions/$_uid/$assignmentId/$uuid';

    final ref = _storage.ref(storagePath);
    final metadata = SettableMetadata(
      contentType: mimeType,
      contentDisposition: 'attachment; filename="$cleanName"',
      customMetadata: {
        'originalName': cleanName,
        'uploadedBy': _uid,
        'assignmentId': assignmentId,
      },
    );
    await ref.putData(bytes, metadata);

    return FileAttachment(
      id: uuid,
      originalName: cleanName,
      mimeType: mimeType,
      sizeBytes: bytes.length,
      storagePath: storagePath,
      uploadedAt: DateTime.now(),
    );
  }

  Future<void> deleteFile(String storagePath) async {
    await _storage.ref(storagePath).delete();
  }

  Future<String> getDownloadUrl(String storagePath) async {
    return _storage.ref(storagePath).getDownloadURL();
  }
}
