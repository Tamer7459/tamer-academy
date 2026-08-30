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
import '../../models/course.dart';
import '../../models/track.dart';
import '../../services/database_service.dart';

class TrackEditScreen extends StatefulWidget {
  final Track? track;
  const TrackEditScreen({super.key, this.track});

  @override
  State<TrackEditScreen> createState() => _TrackEditScreenState();
}

class _TrackEditScreenState extends State<TrackEditScreen> {
  final _formKey = GlobalKey<FormState>();

  late final _nameAr = TextEditingController(text: widget.track?.name.ar ?? '');
  late final _nameEn = TextEditingController(text: widget.track?.name.en ?? '');
  late final _nameFr = TextEditingController(text: widget.track?.name.fr ?? '');
  late final _descAr = TextEditingController(text: widget.track?.description.ar ?? '');
  late final _descEn = TextEditingController(text: widget.track?.description.en ?? '');
  late final _descFr = TextEditingController(text: widget.track?.description.fr ?? '');
  late final _tagsAr = TextEditingController(text: widget.track?.tags.ar ?? '');
  late final _tagsEn = TextEditingController(text: widget.track?.tags.en ?? '');
  late final _tagsFr = TextEditingController(text: widget.track?.tags.fr ?? '');
  late final _order = TextEditingController(text: widget.track?.order.toString() ?? '0');
  late final _imageUrlCtrl = TextEditingController(text: widget.track?.imageUrl ?? '');
  late final _imageWidthCtrl = TextEditingController(text: widget.track?.imageWidth != null && widget.track!.imageWidth > 0 ? widget.track!.imageWidth.toStringAsFixed(0) : '');
  late final _imageHeightCtrl = TextEditingController(text: widget.track?.imageHeight != null && widget.track!.imageHeight > 0 ? widget.track!.imageHeight.toStringAsFixed(0) : '');

  late String _icon;
  late int _color;
  late bool _published;
  late String _imageUrl;
  late String _imageFit;
  double _previewW = 0; // 0 = auto (full width)
  double _previewH = 180;
  Uint8List? _imageBytes;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _icon = widget.track?.icon ?? 'language_rounded';
    _color = widget.track?.color ?? AppColors.tealPrimary.toARGB32();
    _published = widget.track?.published ?? true;
    _imageUrl = widget.track?.imageUrl ?? '';
    _imageFit = widget.track?.imageFit ?? 'cover';
    _previewW = widget.track?.imageWidth ?? 0;
    _previewH = widget.track?.imageHeight != null && widget.track!.imageHeight > 0 ? widget.track!.imageHeight : 180;
  }

  @override
  void dispose() {
    _nameAr.dispose();
    _nameEn.dispose();
    _nameFr.dispose();
    _descAr.dispose();
    _descEn.dispose();
    _descFr.dispose();
    _tagsAr.dispose();
    _tagsEn.dispose();
    _tagsFr.dispose();
    _order.dispose();
    _imageUrlCtrl.dispose();
    _imageWidthCtrl.dispose();
    _imageHeightCtrl.dispose();
    super.dispose();
  }

  static const _iconOptions = <String, IconData>{
    'language_rounded': Icons.language_rounded,
    'smartphone_rounded': Icons.smartphone_rounded,
    'code_rounded': Icons.code_rounded,
    'design_services_rounded': Icons.design_services_rounded,
    'cloud_rounded': Icons.cloud_rounded,
    'storage_rounded': Icons.storage_rounded,
    'memory_rounded': Icons.memory_rounded,
    'devices_rounded': Icons.devices_rounded,
    'precision_manufacturing_rounded': Icons.precision_manufacturing_rounded,
    'psychology_rounded': Icons.psychology_rounded,
    'hub_rounded': Icons.hub_rounded,
    'architecture_rounded': Icons.architecture_rounded,
    'data_object_rounded': Icons.data_object_rounded,
    'developer_board_rounded': Icons.developer_board_rounded,
    'terminal_rounded': Icons.terminal_rounded,
    'web_rounded': Icons.web_rounded,
    'app_settings_alt_rounded': Icons.app_settings_alt_rounded,
  };

  static const _colorOptions = [
    0xFF1A8A7A, 0xFF3BBFAE, 0xFFF5A623, 0xFFE8604C,
    0xFF3B82F6, 0xFF8B5CF6, 0xFFEC4899, 0xFF10B981,
    0xFFF97316, 0xFF06B6D4, 0xFF6366F1, 0xFFEF4444,
  ];

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
          // Dimensions badge
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

  Future<String?> _uploadImage(String trackId) async {
    if (_imageBytes == null) {
      return _imageUrlCtrl.text.trim();
    }
    // 0) Try Supabase Storage first (لتخفيف ضغط Firebase)
    try {
      final supa = Supabase.instance.client;
      final path = 'tracks/$trackId.jpg';
      await supa.storage.from('tracks').uploadBinary(path, _imageBytes!, fileOptions: const FileOptions(upsert: true, contentType: 'image/jpeg')).timeout(const Duration(seconds: 5));
      final url = supa.storage.from('tracks').getPublicUrl(path);
      if (url.isNotEmpty) return url;
    } catch (e) {
      debugPrint('supabase storage failed, fallback to firebase: $e');
    }
    // 1) Try Firebase Storage (if enabled / Blaze) — short timeout
    try {
      final ref = FirebaseStorage.instance.ref().child('tracks/$trackId.jpg');
      await ref.putData(_imageBytes!, SettableMetadata(contentType: 'image/jpeg')).timeout(
        const Duration(seconds: 5),
        onTimeout: () => throw TimeoutException('storage timeout'),
      );
      final url = await ref.getDownloadURL().timeout(const Duration(seconds: 5));
      return url;
    } catch (e) {
      debugPrint('storage upload failed, fallback to base64: $e');
      // 2) Fallback FREE: store as base64 data URL in Firestore (no Storage / no Blaze needed)
      // Firestore limit ~1 MB per doc → keep image < ~700 KB raw (≈ 1 MB base64)
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
      final id = widget.track?.id ?? DateTime.now().microsecondsSinceEpoch.toString();
      String? imageUrl;
      try {
        imageUrl = await _uploadImage(id).timeout(const Duration(seconds: 18));
      } catch (e) {
        debugPrint('track save: image upload failed $e');
        if (mounted) {
          final msg = e.toString().contains('permission') || e.toString().contains('unauthorized')
              ? t('storagePermissionError')
              : '${t('imageUploadFailed')}: $e';
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(msg), behavior: SnackBarBehavior.floating, duration: const Duration(seconds: 5)),
          );
        }
        // fallback: if we have a URL typed, use it; otherwise keep existing url or empty
        imageUrl = _imageUrlCtrl.text.trim().isNotEmpty ? _imageUrlCtrl.text.trim() : widget.track?.imageUrl ?? '';
        // if user picked a file but upload failed, don't block save — let admin decide to try again with URL
        // we continue to save track with fallback url
      }
      final w = double.tryParse(_imageWidthCtrl.text.trim()) ?? _previewW;
      final h = double.tryParse(_imageHeightCtrl.text.trim()) ?? _previewH;
      final track = Track(
        id: id,
        name: LocalizedText(ar: _nameAr.text.trim(), en: _nameEn.text.trim(), fr: _nameFr.text.trim()),
        description: LocalizedText(ar: _descAr.text.trim(), en: _descEn.text.trim(), fr: _descFr.text.trim()),
        tags: LocalizedText(ar: _tagsAr.text.trim(), en: _tagsEn.text.trim(), fr: _tagsFr.text.trim()),
        icon: _icon,
        imageUrl: imageUrl ?? '',
        imageWidth: w,
        imageHeight: h,
        imageFit: _imageFit,
        color: _color,
        order: int.tryParse(_order.text) ?? 0,
        published: _published,
      );
      await db.saveTrack(track).timeout(const Duration(seconds: 15));
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      debugPrint('track save error: $e');
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
        title: Text(widget.track == null ? t('addTrack') : t('editTrack')),
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

            // Image preview — TAPPABLE to pick, size controlled by sliders below
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
            // Resize hint
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.open_with_rounded, size: 14, color: AppColors.grayLight),
                const SizedBox(width: 4),
                Text(t('dragToResize'), style: TextStyle(fontSize: 11, color: AppColors.grayLight)),
              ],
            ),
            const SizedBox(height: 10),

            // URL field
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
            // Browse button
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

            // ═══ Dimensions controls ═══
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
                  // Width slider
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
                  // Height slider
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
                  // Fit dropdown
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

            // ═══ Name tabs ═══
            _LangFieldSet(
              label: t('name'),
              controllers: [_nameAr, _nameEn, _nameFr],
              t: t,
              required: true,
            ),
            const SizedBox(height: 16),

            // ═══ Description tabs ═══
            _LangFieldSet(
              label: t('description'),
              controllers: [_descAr, _descEn, _descFr],
              t: t,
              maxLines: 3,
            ),
            const SizedBox(height: 16),

            // ═══ Tags tabs ═══
            _LangFieldSet(
              label: t('tags'),
              controllers: [_tagsAr, _tagsEn, _tagsFr],
              t: t,
              hint: 'HTML, CSS, JavaScript',
            ),
            const SizedBox(height: 20),

            // ═══ Icon picker ═══
            Text(t('icon'), style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _iconOptions.entries.map((entry) {
                final selected = _icon == entry.key;
                return GestureDetector(
                  onTap: () => setState(() => _icon = entry.key),
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: selected ? AppColors.tealPrimary.withValues(alpha: 0.15) : theme.colorScheme.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: selected ? AppColors.tealPrimary : theme.colorScheme.outlineVariant,
                        width: selected ? 2 : 1,
                      ),
                    ),
                    child: Icon(
                      entry.value,
                      size: 22,
                      color: selected ? AppColors.tealPrimary : AppColors.grayMedium,
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),

            // ═══ Color picker ═══
            Text(t('color'), style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _colorOptions.map((c) {
                final selected = _color == c;
                return GestureDetector(
                  onTap: () => setState(() => _color = c),
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Color(c),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: selected ? Colors.white : Colors.transparent,
                        width: 3,
                      ),
                      boxShadow: [
                        if (selected)
                          BoxShadow(color: Color(c).withValues(alpha: 0.4), blurRadius: 8),
                      ],
                    ),
                    child: selected ? const Icon(Icons.check_rounded, color: Colors.white, size: 20) : null,
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),

            // ═══ Order ═══
            TextFormField(
              controller: _order,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: t('order'),
                prefixIcon: const Icon(Icons.sort_rounded),
              ),
              validator: (v) => (int.tryParse(v ?? '') == null) ? t('order') : null,
            ),
            const SizedBox(height: 16),

            // ═══ Published ═══
            SwitchListTile(
              title: Text(t('published')),
              value: _published,
              onChanged: (v) => setState(() => _published = v),
              contentPadding: EdgeInsets.zero,
            ),
            const SizedBox(height: 24),

            // ═══ Save button ═══
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

class _LangFieldSet extends StatefulWidget {
  final String label;
  final List<TextEditingController> controllers;
  final String Function(String) t;
  final int maxLines;
  final bool required;
  final String? hint;

  const _LangFieldSet({
    required this.label,
    required this.controllers,
    required this.t,
    this.maxLines = 1,
    this.required = false,
    this.hint,
  });

  @override
  State<_LangFieldSet> createState() => _LangFieldSetState();
}

class _LangFieldSetState extends State<_LangFieldSet> {
  int _lang = 0;
  static const _langs = ['ar', 'en', 'fr'];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(widget.label, style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(width: 8),
            SegmentedButton<int>(
              segments: [
                ButtonSegment(value: 0, label: Text(widget.t('arabic'))),
                ButtonSegment(value: 1, label: Text(widget.t('english'))),
                ButtonSegment(value: 2, label: Text(widget.t('french'))),
              ],
              selected: {_lang},
              onSelectionChanged: (s) => setState(() => _lang = s.first),
              showSelectedIcon: false,
              style: ButtonStyle(
                visualDensity: VisualDensity.compact,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: widget.controllers[_lang],
          maxLines: widget.maxLines,
          decoration: InputDecoration(
            hintText: widget.hint,
          ),
          validator: widget.required ? (v) => (v == null || v.trim().isEmpty) ? widget.label : null : null,
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