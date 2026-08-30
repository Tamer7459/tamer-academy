import 'dart:async';
import 'dart:convert';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../utils/pick_image.dart';

import '../../core/app_localizations.dart';
import '../../core/app_theme.dart';
import '../../data/lesson_templates.dart';
import '../../models/course.dart';
import '../../models/track.dart';
import '../../services/database_service.dart';

class CourseEditScreen extends StatefulWidget {
  final Course? course;

  const CourseEditScreen({super.key, this.course});

  @override
  State<CourseEditScreen> createState() => _CourseEditScreenState();
}

class _CourseEditScreenState extends State<CourseEditScreen> {
  final _formKey = GlobalKey<FormState>();

  late final _titleAr = TextEditingController(text: widget.course?.title.ar ?? '');
  late final _titleEn = TextEditingController(text: widget.course?.title.en ?? '');
  late final _titleFr = TextEditingController(text: widget.course?.title.fr ?? '');
  late final _descAr = TextEditingController(text: widget.course?.description.ar ?? '');
  late final _descEn = TextEditingController(text: widget.course?.description.en ?? '');
  late final _descFr = TextEditingController(text: widget.course?.description.fr ?? '');
  late final _price = TextEditingController(text: widget.course?.price.toString() ?? '0');
  late final _order = TextEditingController(text: widget.course?.order.toString() ?? '0');
  late final _imageUrlCtrl = TextEditingController(text: widget.course?.imageUrl ?? '');
  late final _imageWidthCtrl = TextEditingController(text: widget.course?.imageWidth != null && widget.course!.imageWidth > 0 ? widget.course!.imageWidth.toStringAsFixed(0) : '');
  late final _imageHeightCtrl = TextEditingController(text: widget.course?.imageHeight != null && widget.course!.imageHeight > 0 ? widget.course!.imageHeight.toStringAsFixed(0) : '');

  late String _track = widget.course?.track ?? 'web';
  late String _level = widget.course?.level ?? 'beginner';
  late bool _published = widget.course?.published ?? true;
  late int _colorSeed = widget.course?.colorSeed ?? 0;
  late String _imageUrl;
  late String _imageFit;
  double _previewW = 0;
  double _previewH = 180;
  Uint8List? _imageBytes;
  bool _saving = false;

  static const _courseColorOptions = [
    0xFF1A8A7A,
    0xFF3BBFAE,
    0xFFF5A623,
    0xFF3B82F6,
    0xFF8B5CF6,
    0xFFEF4444,
  ];

  @override
  void initState() {
    super.initState();
    _imageUrl = widget.course?.imageUrl ?? '';
    _imageFit = widget.course?.imageFit ?? 'cover';
    _previewW = widget.course?.imageWidth ?? 0;
    _previewH = widget.course?.imageHeight != null && widget.course!.imageHeight > 0 ? widget.course!.imageHeight : 180;
  }

  @override
  void dispose() {
    _titleAr.dispose();
    _titleEn.dispose();
    _titleFr.dispose();
    _descAr.dispose();
    _descEn.dispose();
    _descFr.dispose();
    _price.dispose();
    _order.dispose();
    _imageUrlCtrl.dispose();
    _imageWidthCtrl.dispose();
    _imageHeightCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final bytes = await pickImageBytes();
      if (bytes != null && bytes.isNotEmpty) {
        setState(() {
          _imageBytes = bytes;
          _imageUrlCtrl.clear();
          _imageUrl = '';
        });
      }
    } catch (e) {
      if (mounted) {
        final l10n = Localizations.of<AppLocalizations>(context, AppLocalizations)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${l10n.t('imagePickError')}: $e'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  BoxFit get _fit {
    switch (_imageFit) {
      case 'contain':
        return BoxFit.contain;
      case 'fill':
        return BoxFit.fill;
      case 'fitWidth':
        return BoxFit.fitWidth;
      default:
        return BoxFit.cover;
    }
  }

  Widget _buildImagePreview(ThemeData theme, String Function(String) t) {
    Widget imageWidget;
    bool hasImage = false;
    if (_imageBytes != null) {
      hasImage = true;
      imageWidget = Image.memory(_imageBytes!, fit: _fit);
    } else if (_imageUrl.isNotEmpty) {
      hasImage = true;
      if (_imageUrl.startsWith('data:')) {
        try {
          final b64 = _imageUrl.split(',').last;
          final bytes = base64Decode(b64);
          imageWidget = Image.memory(bytes, fit: _fit);
        } catch (_) {
          imageWidget = Image.network(
            _imageUrl,
            fit: _fit,
            errorBuilder: (_, __, ___) => Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.broken_image_rounded, size: 40, color: AppColors.danger),
                const SizedBox(height: 8),
                Text(t('invalidImageUrl'), style: TextStyle(color: AppColors.danger, fontSize: 12)),
              ],
            ),
          );
        }
      } else {
        imageWidget = Image.network(
          _imageUrl,
          fit: _fit,
          errorBuilder: (_, __, ___) => Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.broken_image_rounded, size: 40, color: AppColors.danger),
              const SizedBox(height: 8),
              Text(t('invalidImageUrl'), style: TextStyle(color: AppColors.danger, fontSize: 12)),
            ],
          ),
        );
      }
    } else {
      imageWidget = Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.add_a_photo_rounded, size: 40, color: AppColors.grayLight),
          const SizedBox(height: 8),
          Text(t('pickImageOrUrl'), style: TextStyle(color: AppColors.grayMedium)),
        ],
      );
    }

    if (!hasImage) return imageWidget;

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Container(color: theme.colorScheme.surface, child: imageWidget),
          Positioned(
            top: 8,
            right: 8,
            child: _RemoveImageBtn(onTap: () {
              setState(() {
                _imageBytes = null;
                _imageUrlCtrl.clear();
                _imageUrl = '';
              });
            }),
          ),
          Positioned(
            bottom: 8,
            left: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                _previewW > 0 && _previewH > 0
                    ? '${_previewW.toStringAsFixed(0)} × ${_previewH.toStringAsFixed(0)}'
                    : _previewH > 0
                        ? 'H: ${_previewH.toStringAsFixed(0)}'
                        : 'auto',
                style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<String?> _uploadImage(String courseId) async {
    if (_imageBytes == null) {
      return _imageUrlCtrl.text.trim();
    }
    // Try Supabase Storage first (لتخفيف ضغط Firebase)
    try {
      final supa = Supabase.instance.client;
      final path = 'courses/$courseId.jpg';
      await supa.storage.from('courses').uploadBinary(path, _imageBytes!, fileOptions: const FileOptions(upsert: true, contentType: 'image/jpeg')).timeout(const Duration(seconds: 5));
      final url = supa.storage.from('courses').getPublicUrl(path);
      if (url.isNotEmpty) return url;
    } catch (e) {
      debugPrint('supabase storage failed, fallback to firebase: $e');
    }
    try {
      final ref = FirebaseStorage.instance.ref().child('courses/$courseId.jpg');
      await ref.putData(_imageBytes!, SettableMetadata(contentType: 'image/jpeg')).timeout(
            const Duration(seconds: 5),
            onTimeout: () => throw TimeoutException('storage timeout'),
          );
      final url = await ref.getDownloadURL().timeout(const Duration(seconds: 5));
      return url;
    } catch (e) {
      debugPrint('course storage upload failed, fallback to base64: $e');
      if (_imageBytes!.lengthInBytes > 750 * 1024) {
        throw Exception('الصورة كبيرة جداً (${(_imageBytes!.lengthInBytes / 1024).toStringAsFixed(0)} KB). قلل الحجم أو استخدم رابط خارجي.');
      }
      return 'data:image/jpeg;base64,${base64Encode(_imageBytes!)}';
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    final l10n = Localizations.of<AppLocalizations>(context, AppLocalizations)!;
    final t = l10n.t;
    try {
      final db = context.read<DatabaseService>();
      final id = widget.course?.id ?? DateTime.now().microsecondsSinceEpoch.toString();
      String? imageUrl;
      try {
        imageUrl = await _uploadImage(id).timeout(const Duration(seconds: 18));
      } catch (e) {
        debugPrint('course save: image upload failed $e');
        if (mounted) {
          final msg = e.toString().contains('permission') || e.toString().contains('unauthorized')
              ? t('storagePermissionError')
              : '${t('imageUploadFailed')}: $e';
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(msg), behavior: SnackBarBehavior.floating, duration: const Duration(seconds: 5)),
          );
        }
        imageUrl = _imageUrlCtrl.text.trim().isNotEmpty ? _imageUrlCtrl.text.trim() : widget.course?.imageUrl ?? '';
      }
      final w = double.tryParse(_imageWidthCtrl.text.trim()) ?? _previewW;
      final h = double.tryParse(_imageHeightCtrl.text.trim()) ?? _previewH;
      final course = Course(
        id: id,
        title: LocalizedText(ar: _titleAr.text.trim(), en: _titleEn.text.trim(), fr: _titleFr.text.trim()),
        description: LocalizedText(ar: _descAr.text.trim(), en: _descEn.text.trim(), fr: _descFr.text.trim()),
        track: _track,
        level: _level,
        price: double.tryParse(_price.text) ?? 0,
        order: int.tryParse(_order.text) ?? 0,
        published: _published,
        colorSeed: _colorSeed,
        imageUrl: imageUrl ?? '',
        imageWidth: w,
        imageHeight: h,
        imageFit: _imageFit,
      );
      await db.saveCourse(course).timeout(const Duration(seconds: 15));
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      debugPrint('course save error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${t('unknownError')}: $e'), behavior: SnackBarBehavior.floating, duration: const Duration(seconds: 5)),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = Localizations.of<AppLocalizations>(context, AppLocalizations)!;
    final t = l10n.t;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.course == null ? t('addCourse') : t('editCourse')),
        actions: [
          IconButton(
            onPressed: _saving ? null : _save,
            icon: const Icon(Icons.save_rounded),
            tooltip: t('save'),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // ═══ Image Section ═══
            Text(t('image'), style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 10),
            Center(
              child: GestureDetector(
                onTap: _pickImage,
                child: MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: Container(
                    height: _previewH,
                    width: _previewW > 0 ? _previewW : double.infinity,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: theme.colorScheme.outlineVariant),
                    ),
                    child: _buildImagePreview(theme, t),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.open_with_rounded, size: 14, color: AppColors.grayLight),
                const SizedBox(width: 4),
                Text(t('dragToResize'), style: TextStyle(fontSize: 11, color: AppColors.grayLight)),
              ],
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: _imageUrlCtrl,
              decoration: InputDecoration(
                hintText: t('imageUrlHint'),
                prefixIcon: const Icon(Icons.link_rounded, size: 20),
                suffixIcon: _imageUrlCtrl.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear_rounded, size: 18),
                        onPressed: () {
                          setState(() {
                            _imageUrlCtrl.clear();
                            _imageUrl = '';
                            _imageBytes = null;
                          });
                        },
                      )
                    : null,
              ),
              onChanged: (v) {
                setState(() => _imageUrl = v.trim());
              },
            ),
            const SizedBox(height: 6),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _pickImage,
                icon: const Icon(Icons.folder_open_rounded, size: 20),
                label: Text(t('browseFiles')),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: theme.colorScheme.outlineVariant),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.aspect_ratio_rounded, size: 18, color: AppColors.tealPrimary),
                      const SizedBox(width: 6),
                      Text(t('imageDimensions'), style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: isDark ? Colors.white : AppColors.navyText)),
                      const Spacer(),
                      TextButton(
                        onPressed: () {
                          setState(() {
                            _previewW = 0;
                            _previewH = 180;
                            _imageWidthCtrl.clear();
                            _imageHeightCtrl.text = '180';
                            _imageFit = 'cover';
                          });
                        },
                        child: Text(t('reset'), style: const TextStyle(fontSize: 12)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _imageWidthCtrl,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: t('width'),
                            hintText: t('auto'),
                            prefixIcon: const Icon(Icons.swap_horiz_rounded, size: 18),
                            suffixText: 'px',
                          ),
                          onChanged: (v) {
                            final w = double.tryParse(v) ?? 0;
                            setState(() => _previewW = w);
                          },
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextFormField(
                          controller: _imageHeightCtrl,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: t('height'),
                            hintText: '180',
                            prefixIcon: const Icon(Icons.swap_vert_rounded, size: 18),
                            suffixText: 'px',
                          ),
                          onChanged: (v) {
                            final h = double.tryParse(v) ?? 180;
                            setState(() => _previewH = h.clamp(80, 600));
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Text(t('width'), style: TextStyle(fontSize: 12, color: AppColors.grayMedium, fontWeight: FontWeight.w600)),
                      const Spacer(),
                      Text(_previewW > 0 ? '${_previewW.toStringAsFixed(0)} px' : t('auto'), style: TextStyle(fontSize: 12, color: AppColors.tealPrimary, fontWeight: FontWeight.w700)),
                    ],
                  ),
                  Slider(
                    value: _previewW.clamp(0, 600),
                    min: 0,
                    max: 600,
                    divisions: 24,
                    label: _previewW > 0 ? _previewW.toStringAsFixed(0) : t('auto'),
                    onChanged: (v) {
                      setState(() {
                        _previewW = v;
                        if (v == 0) {
                          _imageWidthCtrl.clear();
                        } else {
                          _imageWidthCtrl.text = v.toStringAsFixed(0);
                        }
                      });
                    },
                  ),
                  Row(
                    children: [
                      Text(t('height'), style: TextStyle(fontSize: 12, color: AppColors.grayMedium, fontWeight: FontWeight.w600)),
                      const Spacer(),
                      Text('${_previewH.toStringAsFixed(0)} px', style: TextStyle(fontSize: 12, color: AppColors.tealPrimary, fontWeight: FontWeight.w700)),
                    ],
                  ),
                  Slider(
                    value: _previewH.clamp(80, 500),
                    min: 80,
                    max: 500,
                    divisions: 21,
                    label: _previewH.toStringAsFixed(0),
                    onChanged: (v) {
                      setState(() {
                        _previewH = v;
                        _imageHeightCtrl.text = v.toStringAsFixed(0);
                      });
                    },
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: _imageFit,
                    decoration: InputDecoration(
                      labelText: t('imageFit'),
                      prefixIcon: const Icon(Icons.crop_rounded, size: 18),
                    ),
                    items: [
                      DropdownMenuItem(value: 'cover', child: Text(t('fitCover'))),
                      DropdownMenuItem(value: 'contain', child: Text(t('fitContain'))),
                      DropdownMenuItem(value: 'fill', child: Text(t('fitFill'))),
                      DropdownMenuItem(value: 'fitWidth', child: Text(t('fitWidth'))),
                    ],
                    onChanged: (v) => setState(() => _imageFit = v ?? 'cover'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            // ── Course Template ──
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: theme.colorScheme.primary.withValues(alpha: 0.06), borderRadius: BorderRadius.circular(12), border: Border.all(color: theme.colorScheme.primary.withValues(alpha: 0.15))),
              child: Row(
                children: [
                  Icon(Icons.auto_awesome_rounded, size: 18, color: theme.colorScheme.primary),
                  const SizedBox(width: 8),
                  Expanded(child: Text('قالب وصف الدورة', style: TextStyle(fontWeight: FontWeight.w800, color: theme.colorScheme.primary))),
                  FilledButton.icon(
                    onPressed: () {
                      setState(() {
                        if (_descAr.text.trim().isEmpty) _descAr.text = ContentTemplates.courseDescAr;
                        if (_descEn.text.trim().isEmpty) _descEn.text = ContentTemplates.courseDescEn;
                        if (_descFr.text.trim().isEmpty) _descFr.text = ContentTemplates.courseDescFr;
                        if (_titleAr.text.trim().isEmpty) _titleAr.text = 'دورة جديدة - عنوان';
                        if (_titleEn.text.trim().isEmpty) _titleEn.text = 'New Course - Title';
                        if (_titleFr.text.trim().isEmpty) _titleFr.text = 'Nouveau cours - Titre';
                      });
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم تطبيق قالب الدورة ✓')));
                    },
                    icon: const Icon(Icons.auto_fix_high_rounded, size: 16),
                    label: const Text('تطبيق القالب'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            _LangTabs(
              controllers: {
                'ar': [_titleAr, _descAr],
                'en': [_titleEn, _descEn],
                'fr': [_titleFr, _descFr],
              },
              titleControllers: [_titleAr, _titleEn, _titleFr],
              descControllers: [_descAr, _descEn, _descFr],
              t: t,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: StreamBuilder<List<Track>>(
                    stream: context.read<DatabaseService>().tracksStream(),
                    builder: (context, snapshot) {
                      final tracks = snapshot.data ?? [];
                      return DropdownButtonFormField<String>(
                        value: _track,
                        decoration: InputDecoration(labelText: t('track')),
                        items: tracks.isEmpty
                            ? [const DropdownMenuItem(value: 'web', child: Text('Web'))]
                            : tracks.map((tr) => DropdownMenuItem(
                              value: tr.id,
                              child: Text(tr.name.get(l10n.languageCode)),
                            )).toList(),
                        onChanged: (v) => setState(() => _track = v ?? 'web'),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    initialValue: _level,
                    decoration: InputDecoration(labelText: t('level')),
                    items: [
                      DropdownMenuItem(value: 'beginner', child: Text(t('beginner'))),
                      DropdownMenuItem(value: 'intermediate', child: Text(t('intermediate'))),
                      DropdownMenuItem(value: 'advanced', child: Text(t('advanced'))),
                    ],
                    onChanged: (v) => setState(() => _level = v ?? 'beginner'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _price,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: t('price'),
                      prefixIcon: const Icon(Icons.attach_money_rounded),
                    ),
                    validator: (v) =>
                        (double.tryParse(v ?? '') == null) ? t('price') : null,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _order,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: t('order'),
                      prefixIcon: const Icon(Icons.sort_rounded),
                    ),
                    validator: (v) =>
                        (int.tryParse(v ?? '') == null) ? t('order') : null,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: Text(t('published')),
              value: _published,
              onChanged: (v) => setState(() => _published = v),
            ),
            const SizedBox(height: 8),
            Text(t('tabs'), style: theme.textTheme.labelLarge),
            const SizedBox(height: 8),
            Wrap(
              spacing: 10,
              runSpacing: 8,
              children: List.generate(_courseColorOptions.length, (i) {
                final c = _courseColorOptions[i];
                final selected = _colorSeed == i;
                return GestureDetector(
                  onTap: () => setState(() => _colorSeed = i),
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: Color(c),
                      shape: BoxShape.circle,
                      border: Border.all(color: selected ? Colors.white : Colors.transparent, width: 3),
                      boxShadow: [if (selected) BoxShadow(color: Color(c).withValues(alpha: 0.4), blurRadius: 8)],
                    ),
                    child: selected ? const Icon(Icons.check_rounded, color: Colors.white, size: 22) : null,
                  ),
                );
              }),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: _saving ? null : _save,
              icon: _saving
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Icon(Icons.save_rounded),
              label: Text(t('save')),
            ),
          ],
        ),
      ),
    );
  }
}

class _LangTabs extends StatefulWidget {
  final List<TextEditingController> titleControllers;
  final List<TextEditingController> descControllers;
  final Map<String, List<TextEditingController>> controllers;
  final String Function(String) t;

  const _LangTabs({
    required this.titleControllers,
    required this.descControllers,
    required this.controllers,
    required this.t,
  });

  @override
  State<_LangTabs> createState() => _LangTabsState();
}

class _LangTabsState extends State<_LangTabs> {
  int _lang = 0;
  static const _langs = ['ar', 'en', 'fr'];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SegmentedButton<int>(
          segments: [
            ButtonSegment(value: 0, label: Text(widget.t('arabic'))),
            ButtonSegment(value: 1, label: Text(widget.t('english'))),
            ButtonSegment(value: 2, label: Text(widget.t('french'))),
          ],
          selected: {_lang},
          onSelectionChanged: (s) => setState(() => _lang = s.first),
          showSelectedIcon: false,
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: widget.titleControllers[_lang],
          decoration: InputDecoration(
            labelText: '${widget.t('title')} (${_langs[_lang]})',
            prefixIcon: const Icon(Icons.title_rounded),
          ),
          validator: (v) => (v == null || v.trim().isEmpty) ? widget.t('title') : null,
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: widget.descControllers[_lang],
          maxLines: 3,
          decoration: InputDecoration(
            labelText: '${widget.t('description')} (${_langs[_lang]})',
            alignLabelWithHint: true,
          ),
        ),
      ],
    );
  }
}

class _RemoveImageBtn extends StatelessWidget {
  final VoidCallback onTap;
  const _RemoveImageBtn({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.6),
          shape: BoxShape.circle,
        ),
        child: const Icon(Icons.close_rounded, color: Colors.white, size: 18),
      ),
    );
  }
}
