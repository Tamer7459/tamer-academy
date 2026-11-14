import 'package:cloud_firestore/cloud_firestore.dart';

class FileAttachment {
  final String id;
  final String originalName;
  final String mimeType;
  final int sizeBytes;
  final String storagePath;
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

  static const List<String> allowedMimeTypes = [
    'image/png', 'image/jpeg', 'image/webp',
    'application/pdf', 'text/plain',
    'text/x-python', 'text/x-dart', 'application/javascript',
  ];

  static const int maxFileSizeBytes = 10 * 1024 * 1024;
  static const int maxFilesPerSubmission = 5;

  static String sanitizeFileName(String name) {
    var cleaned = name.replaceAll(RegExp(r'[\\/:*?"<>|\x00-\x1F\x7F]'), '_');
    cleaned = cleaned.replaceAll(RegExp(r'[\u200E\u200F\u202A-\u202E\u2066-\u2069]'), '');
    if (cleaned.length > 100) cleaned = cleaned.substring(0, 100);
    return cleaned.isEmpty ? 'file' : cleaned;
  }
}
