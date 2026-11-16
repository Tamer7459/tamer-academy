import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import '../core/design_tokens.dart';
import '../models/file_attachment.dart';
import '../services/file_upload_service.dart';

class FileUploadWidget extends StatefulWidget {
  final String assignmentId;
  final ValueChanged<List<FileAttachment>> onAttachmentsChanged;
  final ValueChanged<bool> onUploadingChanged;
  final List<FileAttachment> initialAttachments;

  const FileUploadWidget({
    super.key,
    required this.assignmentId,
    required this.onAttachmentsChanged,
    required this.onUploadingChanged,
    this.initialAttachments = const [],
  });

  @override
  State<FileUploadWidget> createState() => _FileUploadWidgetState();
}

class _FileUploadWidgetState extends State<FileUploadWidget> {
  final FileUploadService _service = FileUploadService();
  final List<FileAttachment> _attachments = [];
  final Map<String, Uint8List> _imagePreviews = {};
  bool _uploading = false;
  double _progress = 0;
  String? _error;

  @override
  void initState() {
    super.initState();
    _attachments.addAll(widget.initialAttachments);
  }

  Future<void> _pickFiles() async {
    if (_uploading) return;
    if (_attachments.length >= FileAttachment.maxFilesPerSubmission) {
      _showError('الحد الأقصى ${FileAttachment.maxFilesPerSubmission} ملفات');
      return;
    }

    FilePickerResult? result;
    try {
      result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: [
          'png',
          'jpg',
          'jpeg',
          'webp',
          'pdf',
          'py',
          'dart',
          'js',
          'txt',
        ],
        allowMultiple: true,
        withData: true,
      );
    } catch (e) {
      _showError('تعذر فتح اختيار الملفات: $e');
      return;
    }

    if (!mounted || result == null || result.files.isEmpty) return;

    setState(() {
      _uploading = true;
      _progress = 0;
      _error = null;
    });
    widget.onUploadingChanged(true);

    try {
      final availableSlots =
          FileAttachment.maxFilesPerSubmission - _attachments.length;
      if (result.files.length > availableSlots) {
        _showError('يمكنك إضافة $availableSlots ملفات أخرى كحد أقصى');
      }

      for (final file in result.files.take(availableSlots)) {
        if (file.size > FileAttachment.maxFileSizeBytes) {
          _showError('حجم ${file.name} أكبر من 10MB');
          continue;
        }
        if (file.bytes == null) {
          _showError('تعذرت قراءة الملف: ${file.name}');
          continue;
        }

        final mimeType = _mimeTypeFor(file.extension ?? '');
        if (!FileAttachment.allowedMimeTypes.contains(mimeType)) {
          _showError('نوع ملف غير مسموح: ${file.name}');
          continue;
        }

        await _uploadSingle(file, mimeType);
      }
    } finally {
      if (mounted) {
        setState(() {
          _uploading = false;
          _progress = 0;
        });
        widget.onUploadingChanged(false);
      }
    }
  }

  Future<void> _uploadSingle(PlatformFile file, String mimeType) async {
    if (!mounted) return;
    setState(() => _progress = 0);

    try {
      final attachment = await _service.uploadFile(
        assignmentId: widget.assignmentId,
        bytes: file.bytes!,
        originalName: file.name,
        mimeType: mimeType,
        onProgress: (progress) {
          if (mounted) setState(() => _progress = progress);
        },
      );
      if (!mounted) return;
      setState(() {
        _attachments.add(attachment);
        if (mimeType.startsWith('image/')) {
          _imagePreviews[attachment.id] = file.bytes!;
        }
        _progress = 1.0;
      });
      widget.onAttachmentsChanged(List.unmodifiable(_attachments));
    } catch (e) {
      debugPrint('File upload failed for ${file.name}: $e');
      if (e.toString().contains('TimeoutException')) {
        _showError('انتهت مهلة الرفع. تحقق من اتصال الإنترنت ثم أعد المحاولة.');
      } else if (e is StorageException &&
          (e.message.toLowerCase().contains('network') ||
              e.message.toLowerCase().contains('timeout'))) {
        _showError(
          'تعذر الاتصال بخدمة التخزين. تحقق من الإنترنت ثم أعد المحاولة.',
        );
      } else {
        _showError('فشل رفع ${file.name}: $e');
      }
    }
  }

  Future<void> _removeAttachment(FileAttachment att) async {
    try {
      await _service.deleteFile(att.storagePath);
    } catch (_) {}
    setState(() {
      _attachments.removeWhere((a) => a.id == att.id);
      _imagePreviews.remove(att.id);
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
    final surface = isDark
        ? DColorsDark.surfaceElevated
        : DColorsLight.surfaceElevated;
    // border reserved for future use
    final onSurface = isDark ? DColorsDark.onSurface : DColorsLight.onSurface;
    final muted = isDark
        ? DColorsDark.onSurfaceMuted
        : DColorsLight.onSurfaceMuted;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: _uploading ? null : _pickFiles,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(DTokens.spaceLg),
            decoration: BoxDecoration(
              color: surface,
              borderRadius: DTokens.borderRadiusSm,
              border: Border.all(
                color: const Color(0xFFC1232C).withValues(alpha: 0.4),
                width: 1.5,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.cloud_upload_rounded,
                  size: 40,
                  color: const Color(0xFFC1232C),
                ),
                const SizedBox(height: DTokens.spaceSm),
                Text(
                  'انقر لاختيار صور أو ملفات متعددة',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: onSurface,
                  ),
                ),
                const SizedBox(height: DTokens.spaceXs),
                Text(
                  'يمكنك اختيار عدة صور دفعة واحدة — PNG, JPG, WEBP, PDF, .py, .dart, .js, .txt — حد أقصى ${FileAttachment.maxFilesPerSubmission} ملفات، 10MB لكل ملف',
                  style: TextStyle(fontSize: 11, color: muted),
                  textAlign: TextAlign.center,
                ),
                if (_uploading) ...[
                  const SizedBox(height: DTokens.spaceMd),
                  LinearProgressIndicator(
                    value: _progress,
                    color: const Color(0xFFC1232C),
                    backgroundColor: const Color(
                      0xFFC1232C,
                    ).withValues(alpha: 0.2),
                  ),
                  const SizedBox(height: DTokens.spaceXs),
                  Text(
                    'جارٍ الرفع ${(_progress * 100).round()}٪',
                    style: TextStyle(fontSize: 11, color: muted),
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
        if (_attachments.isNotEmpty) ...[
          const SizedBox(height: DTokens.spaceMd),
          Text(
            'المرفقات (${_attachments.length}/${FileAttachment.maxFilesPerSubmission})',
            style: TextStyle(fontWeight: FontWeight.w800, color: onSurface),
          ),
          const SizedBox(height: DTokens.spaceSm),
          Wrap(
            spacing: DTokens.spaceSm,
            runSpacing: DTokens.spaceSm,
            children: _attachments
                .map(
                  (att) => _AttachmentTile(
                    attachment: att,
                    previewBytes: _imagePreviews[att.id],
                    onRemove: () => _removeAttachment(att),
                  ),
                )
                .toList(),
          ),
        ],
      ],
    );
  }
}

class _AttachmentTile extends StatelessWidget {
  final FileAttachment attachment;
  final Uint8List? previewBytes;
  final VoidCallback onRemove;

  const _AttachmentTile({
    required this.attachment,
    this.previewBytes,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final isImage = attachment.mimeType.startsWith('image/');
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final onSurface = isDark ? DColorsDark.onSurface : DColorsLight.onSurface;
    final surface = isDark ? DColorsDark.surface : DColorsLight.surface;

    return SizedBox(
      width: 132,
      height: isImage && previewBytes != null ? 138 : 58,
      child: Stack(
        children: [
          Container(
            width: double.infinity,
            height: double.infinity,
            padding: EdgeInsets.all(isImage && previewBytes != null ? 6 : 8),
            decoration: BoxDecoration(
              color: surface,
              borderRadius: DTokens.borderRadiusSm,
              border: Border.all(
                color: isDark ? DColorsDark.border : DColorsLight.border,
              ),
            ),
            child: isImage && previewBytes != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.memory(
                      previewBytes!,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: 92,
                    ),
                  )
                : Row(
                    children: [
                      Icon(
                        isImage
                            ? Icons.image_rounded
                            : Icons.insert_drive_file_rounded,
                        size: 16,
                        color: const Color(0xFFC1232C),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          attachment.originalName,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: onSurface,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 2,
                        ),
                      ),
                    ],
                  ),
          ),
          if (isImage && previewBytes != null)
            Positioned(
              left: 8,
              right: 8,
              bottom: 6,
              child: Text(
                attachment.originalName,
                style: TextStyle(fontSize: 10, color: onSurface),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
          Positioned(
            top: 3,
            right: 3,
            child: Material(
              color: Colors.black.withValues(alpha: 0.62),
              shape: const CircleBorder(),
              child: InkWell(
                onTap: onRemove,
                customBorder: const CircleBorder(),
                child: const Padding(
                  padding: EdgeInsets.all(3),
                  child: Icon(
                    Icons.close_rounded,
                    size: 15,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class UploadedFileLinks extends StatelessWidget {
  final List<FileAttachment> attachments;

  const UploadedFileLinks({super.key, required this.attachments});

  Future<void> _open(BuildContext context, FileAttachment attachment) async {
    try {
      final downloadUrl = await FileUploadService().getDownloadUrl(
        attachment.storagePath,
      );
      final opened = await launchUrl(
        Uri.parse(downloadUrl),
        mode: LaunchMode.platformDefault,
      );
      if (!opened && context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('تعذر فتح الملف')));
      }
    } catch (error) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('تعذر تحميل الملف: $error')));
      }
    }
  }

  Future<void> _copyAllLinks(BuildContext context) async {
    try {
      final urls = <String>[];
      for (final attachment in attachments) {
        urls.add(
          await FileUploadService().getDownloadUrl(attachment.storagePath),
        );
      }
      await Clipboard.setData(ClipboardData(text: urls.join('\n')));
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('تم نسخ ${urls.length} رابط بالتسلسل')),
        );
      }
    } catch (error) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('تعذر جمع روابط الملفات: $error')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (attachments.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'الملفات المرفقة',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        if (attachments.length > 1)
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: TextButton.icon(
              onPressed: () => _copyAllLinks(context),
              icon: const Icon(Icons.copy_all_rounded, size: 16),
              label: const Text('نسخ كل الروابط بالتسلسل'),
            ),
          ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: attachments.asMap().entries.map((entry) {
            final index = entry.key + 1;
            final attachment = entry.value;
            return Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: OutlinedButton.icon(
                onPressed: () => _open(context, attachment),
                icon: const Icon(Icons.link_rounded, size: 16),
                label: Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: Text(
                    '$index. ${attachment.originalName}',
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
