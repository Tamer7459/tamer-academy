import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../core/design_tokens.dart';
import '../models/file_attachment.dart';
import '../services/file_upload_service.dart';

/// widget رفع ملفات (صور, PDF, ملفات كود) مع معاينة وشريط تقدم.
/// يُستخدم في HomeworkWidget و ExerciseWidget.
class FileUploadWidget extends StatefulWidget {
  final String assignmentId;
  final ValueChanged<List<FileAttachment>> onAttachmentsChanged;
  final List<FileAttachment> initialAttachments;

  const FileUploadWidget({
    super.key,
    required this.assignmentId,
    required this.onAttachmentsChanged,
    this.initialAttachments = const [],
  });

  @override
  State<FileUploadWidget> createState() => _FileUploadWidgetState();
}

class _FileUploadWidgetState extends State<FileUploadWidget> {
  final FileUploadService _service = FileUploadService();
  final List<FileAttachment> _attachments = [];
  bool _uploading = false;
  double _progress = 0;
  String? _error;

  @override
  void initState() {
    super.initState();
    _attachments.addAll(widget.initialAttachments);
  }

  Future<void> _pickFiles() async {
    if (_attachments.length >= FileAttachment.maxFilesPerSubmission) {
      _showError('الحد الأقصى ${FileAttachment.maxFilesPerSubmission} ملفات');
      return;
    }

    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['png', 'jpg', 'jpeg', 'webp', 'pdf', 'py', 'dart', 'js', 'txt'],
      allowMultiple: true,
      withData: true,
    );

    if (result == null || result.files.isEmpty) return;

    for (final file in result.files) {
      if (_attachments.length >= FileAttachment.maxFilesPerSubmission) break;
      if (file.bytes == null) continue;

      final mimeType = _mimeTypeFor(file.extension ?? '');
      if (!FileAttachment.allowedMimeTypes.contains(mimeType)) {
        _showError('نوع ملف غير مسموح: ${file.name}');
        continue;
      }

      await _uploadSingle(file, mimeType);
    }
  }

  Future<void> _uploadSingle(PlatformFile file, String mimeType) async {
    setState(() {
      _uploading = true;
      _progress = 0;
      _error = null;
    });

    try {
      final attachment = await _service.uploadFile(
        assignmentId: widget.assignmentId,
        bytes: file.bytes!,
        originalName: file.name,
        mimeType: mimeType,
      );
      setState(() {
        _attachments.add(attachment);
        _progress = 1.0;
      });
      widget.onAttachmentsChanged(List.unmodifiable(_attachments));
    } catch (e) {
      _showError('فشل الرفع: $e');
    } finally {
      if (mounted) {
        setState(() {
          _uploading = false;
          _progress = 0;
        });
      }
    }
  }

  Future<void> _removeAttachment(FileAttachment att) async {
    try {
      await _service.deleteFile(att.storagePath);
    } catch (_) {}
    setState(() {
      _attachments.removeWhere((a) => a.id == att.id);
    });
    widget.onAttachmentsChanged(List.unmodifiable(_attachments));
  }

  void _showError(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), behavior: SnackBarBehavior.floating),
    );
    setState(() => _error = msg);
  }

  String _mimeTypeFor(String ext) {
    switch (ext.toLowerCase()) {
      case 'png':
        return 'image/png';
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'webp':
        return 'image/webp';
      case 'pdf':
        return 'application/pdf';
      case 'py':
        return 'text/x-python';
      case 'dart':
        return 'text/x-dart';
      case 'js':
        return 'application/javascript';
      case 'txt':
      default:
        return 'text/plain';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surface = isDark ? DColorsDark.surfaceElevated : DColorsLight.surfaceElevated;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // منطقة الإفلات / زر الاختيار
        GestureDetector(
          onTap: _uploading ? null : _pickFiles,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(DTokens.spaceLg),
            decoration: BoxDecoration(
              color: surface,
              borderRadius: DTokens.borderRadiusMd,
              border: Border.all(
                color: DTokens.brandTeal.withValues(alpha: 0.4),
                width: 1.5,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.cloud_upload_rounded,
                  size: 40,
                  color: DTokens.brandTeal,
                ),
                const SizedBox(height: DTokens.spaceSm),
                Text(
                  'انقر لاختيار ملفات أو اسحبها هنا',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: isDark ? DColorsDark.onSurface : DColorsLight.onSurface,
                  ),
                ),
                const SizedBox(height: DTokens.spaceXs),
                Text(
                  'PNG, JPG, WEBP, PDF, .py, .dart, .js, .txt — حد أقصى ${FileAttachment.maxFilesPerSubmission} ملفات، 10MB لكل ملف',
                  style: TextStyle(
                    fontSize: 11,
                    color: isDark ? DColorsDark.onSurfaceMuted : DColorsLight.onSurfaceMuted,
                  ),
                  textAlign: TextAlign.center,
                ),
                if (_uploading) ...[
                  const SizedBox(height: DTokens.spaceMd),
                  LinearProgressIndicator(
                    value: _progress > 0 ? _progress : null,
                    color: DTokens.brandTeal,
                    backgroundColor: DTokens.brandTeal.withValues(alpha: 0.2),
                  ),
                ],
              ],
            ),
          ),
        ),
        if (_error != null) ...[
          const SizedBox(height: DTokens.spaceSm),
          Text(
            _error!,
            style: TextStyle(color: DColorsLight.danger, fontSize: 12),
          ),
        ],
        // قائمة المرفقات
        if (_attachments.isNotEmpty) ...[
          const SizedBox(height: DTokens.spaceMd),
          Text(
            'المرفقات (${_attachments.length})',
            style: TextStyle(
              fontWeight: FontWeight.w800,
              color: isDark ? DColorsDark.onSurface : DColorsLight.onSurface,
            ),
          ),
          const SizedBox(height: DTokens.spaceSm),
          Wrap(
            spacing: DTokens.spaceSm,
            runSpacing: DTokens.spaceSm,
            children: _attachments.map((att) => _AttachmentChip(
              attachment: att,
              onRemove: () => _removeAttachment(att),
            )).toList(),
          ),
        ],
      ],
    );
  }
}

class _AttachmentChip extends StatelessWidget {
  final FileAttachment attachment;
  final VoidCallback onRemove;

  const _AttachmentChip({required this.attachment, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    final isImage = attachment.mimeType.startsWith('image/');
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: isDark ? DColorsDark.surface : DColorsLight.surface,
        borderRadius: DTokens.borderRadiusSm,
        border: Border.all(
          color: isDark ? DColorsDark.border : DColorsLight.border,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isImage ? Icons.image_rounded : Icons.insert_drive_file_rounded,
            size: 16,
            color: DTokens.brandTeal,
          ),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              attachment.originalName,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            '${(attachment.sizeBytes / 1024).toStringAsFixed(1)} KB',
            style: TextStyle(
              fontSize: 10,
              color: isDark ? DColorsDark.onSurfaceMuted : DColorsLight.onSurfaceMuted,
            ),
          ),
          const SizedBox(width: 6),
          InkWell(
            onTap: onRemove,
            child: const Icon(Icons.close_rounded, size: 16, color: Colors.redAccent),
          ),
        ],
      ),
    );
  }
}
