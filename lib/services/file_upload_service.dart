import 'dart:typed_data';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

import '../models/file_attachment.dart';

/// خدمة رفع الملفات إلى Firebase Storage (مسارات خاصة بالمستخدم).
/// ملاحظة: التحقق (magic bytes، حدود الحجم، rate limiting) يجب أن يتم ALSO على الخادم
/// (Firebase Functions) — هذا الكود يُقدم التحقق على العميل كطبقة أولى فقط.
class FileUploadService {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String get _uid {
    final u = _auth.currentUser;
    if (u == null) throw Exception('Not authenticated');
    return u.uid;
  }

  /// رفع ملف إلى المسار: submissions/{uid}/{assignmentId}/{uuid}
  /// يُعيد FileAttachment (بدون تحقق خادم — يُستخدم للعرض فقط).
  Future<FileAttachment> uploadFile({
    required String assignmentId,
    required Uint8List bytes,
    required String originalName,
    required String mimeType,
  }) async {
    // التحقق من الحجم
    if (bytes.length > FileAttachment.maxFileSizeBytes) {
      throw Exception('File too large (max ${FileAttachment.maxFileSizeBytes ~/ (1024 * 1024)} MB)');
    }

    // التحقق من نوع الملف (MIME)
    if (!FileAttachment.allowedMimeTypes.contains(mimeType)) {
      throw Exception('File type not allowed: $mimeType');
    }

    // تنظيف الاسم الأصلي
    final cleanName = FileAttachment.sanitizeFileName(originalName);

    // توليد UUID (اسم الملف على الخادم)
    final uuid = '${DateTime.now().microsecondsSinceEpoch}_${_uid.substring(0, 6)}';
    final storagePath = 'submissions/$_uid/$assignmentId/$uuid';

    // رفع bytes
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

  /// حذف ملف من التخزين.
  Future<void> deleteFile(String storagePath) async {
    await _storage.ref(storagePath).delete();
  }

  /// الحصول على رابط تنزيل موقّت (signed URL).
  /// ملاحظة: Firebase Storage getDownloadURL() يُعيد رابطاً عاماً (public) —
  /// للحصول على روابط قصيرة العمر (signed URLs) استخدم Firebase Functions (signed URLs).
  Future<String> getDownloadUrl(String storagePath) async {
    return _storage.ref(storagePath).getDownloadURL();
  }
}
