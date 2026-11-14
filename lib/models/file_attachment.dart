import 'package:cloud_firestore/cloud_firestore.dart';

/// مرفق ملف (صورة أو PDF أو ملف كود نصي) مرفوع مع حل التمرين/الواجب.
class FileAttachment {
  final String id;          // UUID (اسم الملف على الخادم)
  final String originalName; // الاسم الأصلي (يُخزّن كنص فقط، لا يُستخدم في المسار)
  final String mimeType;
  final int sizeBytes;
  final String storagePath;  // مسار التخزين (submissions/{uid}/{assignmentId}/{uuid})
  final DateTime uploadedAt;

  const FileAttachment({
    required this.id,
    required this.originalName,
    required this.mimeType,
    required this.sizeBytes,
    required this.storagePath,
    required this.uploadedAt,
  });

  factory FileAttachment.fromMap(Map<String, dynamic> map) {
    return FileAttachment(
      id: map['id'] as String? ?? '',
      originalName: map['originalName'] as String? ?? '',
      mimeType: map['mimeType'] as String? ?? '',
      sizeBytes: (map['sizeBytes'] as num?)?.toInt() ?? 0,
      storagePath: map['storagePath'] as String? ?? '',
      uploadedAt: map['uploadedAt'] is Timestamp
          ? (map['uploadedAt'] as Timestamp).toDate()
          : DateTime.tryParse(map['uploadedAt']?.toString() ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'originalName': originalName,
      'mimeType': mimeType,
      'sizeBytes': sizeBytes,
      'storagePath': storagePath,
      'uploadedAt': Timestamp.fromDate(uploadedAt),
    };
  }

  /// أنواع الملفات المسموح بها.
  static const List<String> allowedMimeTypes = [
    'image/png',
    'image/jpeg',
    'image/webp',
    'application/pdf',
    'text/plain',
    'text/x-python',
    'text/x-dart',
    'application/javascript',
  ];

  /// حد أقصى لحجم كل ملف (10 MB).
  static const int maxFileSizeBytes = 10 * 1024 * 1024;

  /// حد أقصى لعدد الملفات لكل تسليم.
  static const int maxFilesPerSubmission = 5;

  /// تنظيف الاسم الأصلي (path traversal، أحرف التحكم، bidi).
  static String sanitizeFileName(String name) {
    // Remove path traversal and control characters
    var cleaned = name.replaceAll(RegExp(r'[\\/:*?"<>|\x00-\x1F\x7F]'), '_');
    // Remove bidi control characters
    cleaned = cleaned.replaceAll(RegExp(r'[\u200E\u200F\u202A-\u202E\u2066-\u2069]'), '');
    // Limit length
    if (cleaned.length > 100) cleaned = cleaned.substring(0, 100);
    return cleaned.isEmpty ? 'file' : cleaned;
  }
}
