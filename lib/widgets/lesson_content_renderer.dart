// ignore_for_file: unused_import
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show Clipboard, ClipboardData;
import 'package:flutter_highlight/flutter_highlight.dart';
import 'package:highlight/languages/xml.dart';
import 'package:highlight/languages/dart.dart';
import 'package:highlight/languages/javascript.dart';
import 'package:highlight/languages/css.dart';
import 'package:highlight/languages/json.dart';
import 'package:highlight/languages/shell.dart';
import 'package:highlight/languages/python.dart';
import 'package:highlight/languages/java.dart';
import 'package:highlight/languages/kotlin.dart';
import 'package:highlight/languages/swift.dart';

class CodeBlock {
  final String language;
  final String code;
  const CodeBlock(this.language, this.code);
}

class LessonContentRenderer extends StatelessWidget {
  static final RegExp _markdownImageRegex = RegExp(
    r'!\[((?:\\.|[^\]])*)\]\(\s*([^\s)]+)(?:\s+["\x27](.*?)["\x27])?\s*\)',
  );
  static final RegExp _splitOpenAiImageRegex = RegExp(
    r'https://images\.openai\.com/static-rsc-4/([A-Za-z0-9_-]+)-!?\[((?:\\.|[^\]])*)\]\(\s*([A-Za-z0-9_-]+(?:\?[^)\s]*)?)\s*\)',
    caseSensitive: false,
  );

  @visibleForTesting
  static String normalizeOpenAiImageMarkup(String content) {
    return content.replaceAllMapped(_splitOpenAiImageRegex, (match) {
      final alt = match.group(2) ?? '';
      final imageIdSuffix = match.group(3) ?? '';
      final imageUrl = 'https://images.openai.com/static-rsc-4/${match.group(1)}-$imageIdSuffix';
      return '![$alt]($imageUrl)';
    });
  }

  final String content;
  final String lang;
  final double fontSize;

  const LessonContentRenderer({
    super.key,
    required this.content,
    required this.lang,
    this.fontSize = 16,
  });

  static Map<String, String> _codeLanguages() {
    return {
      'html': 'html',
      'xml': 'xml',
      'dart': 'dart',
      'flutter': 'dart',
      'js': 'javascript',
      'javascript': 'javascript',
      'ts': 'typescript',
      'css': 'css',
      'json': 'json',
      'bash': 'shell',
      'shell': 'shell',
      'python': 'python',
      'java': 'java',
      'kotlin': 'kotlin',
      'swift': 'swift',
    };
  }

  static List<CodeBlock> extractCodeBlocks(String content) {
    final blocks = <CodeBlock>[];
    final regex = RegExp(r'```([\w+#-]*)\n([\s\S]*?)```');
    for (final m in regex.allMatches(content)) {
      final lang = m.group(1)?.trim().isEmpty ?? true ? 'text' : m.group(1)!.trim();
      blocks.add(CodeBlock(lang, m.group(2) ?? ''));
    }
    return blocks;
  }

  static bool _isDirectImageUrl(String raw) {
    final s = raw.trim().replaceAll('\u200B', '');
    if (!s.startsWith('http://') && !s.startsWith('https://') && !s.startsWith('data:image/')) {
      return false;
    }
    if (s.contains(' ') || s.contains('\n') || s.contains('\t')) {
      return false;
    }
    if (s.startsWith('data:image/')) return true;

    final lower = s.toLowerCase();
    final uri = Uri.tryParse(s);
    final path = (uri != null && uri.path.isNotEmpty) ? uri.path.toLowerCase() : lower;

    const imageExtensions = ['.png', '.jpg', '.jpeg', '.gif', '.webp', '.svg', '.bmp', '.ico', '.avif'];
    for (final ext in imageExtensions) {
      if (path.endsWith(ext) || lower.contains('$ext?') || lower.contains('$ext#')) {
        return true;
      }
    }

    if (lower.contains('cloudinary.com') ||
        // OpenAI-hosted lesson illustrations use signed URLs without a file extension.
        lower.contains('images.openai.com') ||
        lower.contains('images.unsplash.com') ||
        lower.contains('imgur.com') ||
        lower.contains('postimg.cc') ||
        lower.contains('postimages.org') ||
        lower.contains('gyazo.com') ||
        lower.contains('prnt.sc') ||
        lower.contains('/image/upload/') ||
        lower.contains('/images/') ||
        lower.contains('/img/') ||
        lower.contains('/photos/')) {
      return true;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final normalizedContent = normalizeOpenAiImageMarkup(content);
    // Break very long words (no spaces) to prevent overflow — but DO NOT break URLs or image tags!
    final brokenContent = normalizedContent.replaceAllMapped(RegExp(r'\S{30,}'), (m) {
      final word = m.group(0)!;
      if (word.startsWith('http://') ||
          word.startsWith('https://') ||
          word.startsWith('data:') ||
          word.contains('://') ||
          word.contains('http') ||
          word.startsWith('![') ||
          word.startsWith('<img')) {
        return word;
      }
      final buffer = StringBuffer();
      for (int i = 0; i < word.length; i++) {
        buffer.write(word[i]);
        if ((i + 1) % 30 == 0 && i != word.length - 1) buffer.write('\u200B');
      }
      return buffer.toString();
    });

    final lines = brokenContent.split('\n');
    final children = <Widget>[];
    var i = 0;
    var inList = false;
    var listItems = <String>[];
    var inNumberedList = false;
    var numberedItems = <String>[];

    void flushLists() {
      if (inList) {
        children.add(_buildList(context, listItems, numbered: false));
        listItems = [];
        inList = false;
      }
      if (inNumberedList) {
        children.add(_buildList(context, numberedItems, numbered: true));
        numberedItems = [];
        inNumberedList = false;
      }
    }

    while (i < lines.length) {
      final line = lines[i];
      final trimmed = line.trim();
      final cleanLine = trimmed.replaceAll('\u200B', '');

      // ── Code Block: ```lang ... ``` ──
      final codeMatch = RegExp(r'^```').hasMatch(trimmed);
      if (codeMatch) {
        flushLists();
        final langMatch = RegExp(r'^```([\w+#-]*)').firstMatch(trimmed);
        final lang = (langMatch?.group(1) ?? '').trim().isEmpty ? 'text' : langMatch!.group(1)!.trim();
        final codeLines = <String>[];
        i++;
        while (i < lines.length && !RegExp(r'^```').hasMatch(lines[i].trim())) {
          codeLines.add(lines[i]);
          i++;
        }
        i++;
        children.add(_buildCodeBlock(context, lang, codeLines.join('\n')));
        continue;
      }

      // ── Markdown Table: | a | b | + |---|---| ──
      String clean(String s) => s.replaceAll('\u200B', '');
      if (clean(line).trim().startsWith('|') && i + 1 < lines.length && RegExp(r'^\s*\|?(\s*:?-+:?\s*\|)+\s*$').hasMatch(clean(lines[i + 1]))) {
        flushLists();
        final tableLines = <String>[];
        while (i < lines.length && clean(lines[i]).trim().startsWith('|')) {
          tableLines.add(lines[i]);
          i++;
          if (i < lines.length && clean(lines[i]).trim().isEmpty) break;
        }
        final rows = <List<String>>[];
        for (var t = 0; t < tableLines.length; t++) {
          final l = clean(tableLines[t]);
          if (RegExp(r'^\s*\|?(\s*:?-+:?\s*\|)+\s*$').hasMatch(l)) continue; // separator
          final cells = l.split('|').map((c) => c.trim()).where((c) => c.isNotEmpty).toList();
          if (cells.isNotEmpty) rows.add(cells);
        }
        if (rows.isNotEmpty) {
          children.add(_buildTable(context, rows));
        }
        continue;
      }

      // ── Direct Image URL on its own line ──
      if (_isDirectImageUrl(cleanLine)) {
        flushLists();
        children.add(_buildImage(context, cleanLine));
        i++;
        continue;
      }

      // ── Standalone HTML <img> tag ──
      final htmlImgMatch = RegExp(r'^\s*<img\s+([^>]+)>\s*$', caseSensitive: false).firstMatch(cleanLine);
      if (htmlImgMatch != null) {
        flushLists();
        final attrs = htmlImgMatch.group(1)!;
        final srcMatch = RegExp(r'src=["\x27]([^"\x27]+)["\x27]', caseSensitive: false).firstMatch(attrs);
        final altMatch = RegExp(r'alt=["\x27]([^"\x27]*)["\x27]', caseSensitive: false).firstMatch(attrs);
        if (srcMatch != null) {
          children.add(_buildImage(context, srcMatch.group(1)!, alt: altMatch?.group(1)));
          i++;
          continue;
        }
      }

      // ── Standalone Markdown Image: ![alt](url "title") ──
      final mdImgStandaloneMatch = RegExp(r'^\s*!\[((?:\\.|[^\]])*)\]\(\s*([^\s)]+)(?:\s+["\x27](.*?)["\x27])?\s*\)\s*$').firstMatch(cleanLine);
      if (mdImgStandaloneMatch != null) {
        flushLists();
        final alt = _unescapeMarkdownAlt(mdImgStandaloneMatch.group(1));
        final url = mdImgStandaloneMatch.group(2)!;
        children.add(_buildImage(context, url, alt: alt));
        i++;
        continue;
      }

      // ── Inline Markdown Image(s) mixed with text ──
      if (_markdownImageRegex.hasMatch(line)) {
        flushLists();
        children.addAll(_buildMixedLineWithImages(context, line));
        i++;
        continue;
      }

      // ── Headings: #, ##, ###, ... ──
      if (RegExp(r'^#{1,6}\s').hasMatch(line)) {
        flushLists();
        final level = RegExp(r'^#+').firstMatch(line)!.group(0)!.length;
        final text = line.replaceFirst(RegExp(r'^#+\s*'), '');
        children.add(Padding(
          padding: const EdgeInsets.only(top: 16, bottom: 8),
          child: _RichText(
            text: text,
            style: theme.textTheme.titleLarge!.copyWith(
              fontWeight: FontWeight.w800,
              fontSize: level <= 2 ? 22 : 18,
              color: theme.colorScheme.primary,
            ),
          ),
        ));
        i++;
        continue;
      }

      // ── Blockquote: > text ──
      if (RegExp(r'^>\s').hasMatch(line)) {
        flushLists();
        final text = line.replaceFirst(RegExp(r'^>\s*'), '');
        children.add(Container(
          width: double.infinity,
          margin: const EdgeInsets.symmetric(vertical: 8),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: theme.colorScheme.primary.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(12),
            border: Border(
              left: BorderSide(color: theme.colorScheme.primary, width: 4),
            ),
          ),
          child: _RichText(
            text: text,
            style: TextStyle(fontSize: fontSize, height: 1.7),
          ),
        ));
        i++;
        continue;
      }

      // ── Bullet List: - item, * item, + item ──
      if (RegExp(r'^[-*+]\s').hasMatch(line)) {
        if (inNumberedList) flushLists();
        inList = true;
        listItems.add(line.replaceFirst(RegExp(r'^[-*+]\s*'), ''));
        i++;
        continue;
      }

      // ── Numbered List: 1. item, 1) item ──
      if (RegExp(r'^\d+[.)]\s').hasMatch(line)) {
        if (inList) flushLists();
        inNumberedList = true;
        numberedItems.add(line.replaceFirst(RegExp(r'^\d+[.)]\s*'), ''));
        i++;
        continue;
      }

      // ── Empty Line ──
      if (line.trim().isEmpty) {
        flushLists();
        children.add(const SizedBox(height: 8));
        i++;
        continue;
      }

      // ── Standard Paragraph ──
      flushLists();
      children.add(Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: _RichText(text: line, style: TextStyle(fontSize: fontSize, height: 1.8)),
      ));
      i++;
    }
    flushLists();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: children,
    );
  }

  List<Widget> _buildMixedLineWithImages(BuildContext context, String line) {
    final widgets = <Widget>[];
    final matches = _markdownImageRegex.allMatches(line).toList();
    var lastEnd = 0;

    for (final m in matches) {
      if (m.start > lastEnd) {
        final text = line.substring(lastEnd, m.start).trim();
        if (text.isNotEmpty) {
          widgets.add(Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: _RichText(text: text, style: TextStyle(fontSize: fontSize, height: 1.8)),
          ));
        }
      }
      final alt = _unescapeMarkdownAlt(m.group(1));
      final url = m.group(2)!;
      widgets.add(_buildImage(context, url, alt: alt));
      lastEnd = m.end;
    }

    if (lastEnd < line.length) {
      final text = line.substring(lastEnd).trim();
      if (text.isNotEmpty) {
        widgets.add(Padding(
          padding: const EdgeInsets.only(top: 6, bottom: 6),
          child: _RichText(text: text, style: TextStyle(fontSize: fontSize, height: 1.8)),
        ));
      }
    }
    return widgets;
  }

  String? _unescapeMarkdownAlt(String? alt) {
    return alt?.replaceAll(r'\[', '[').replaceAll(r'\]', ']');
  }

  Widget _buildList(BuildContext context, List<String> items, {required bool numbered}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: List.generate(items.length, (idx) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 3),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 28,
                  child: Text(
                    numbered ? '${idx + 1}.' : '•',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),
                Expanded(child: _buildListItemContent(context, items[idx])),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildListItemContent(BuildContext context, String rawText) {
    final trimmed = rawText.trim();
    final clean = trimmed.replaceAll('\u200B', '');
    if (_isDirectImageUrl(clean)) {
      return _buildImage(context, clean);
    }
    if (_markdownImageRegex.hasMatch(rawText)) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: _buildMixedLineWithImages(context, rawText),
      );
    }
    return _RichText(text: rawText, style: TextStyle(fontSize: fontSize, height: 1.7));
  }

  Widget _buildImage(BuildContext context, String rawUrl, {String? alt}) {
    final cleanUrl = rawUrl.replaceAll('\u200B', '').trim();
    if (cleanUrl.isEmpty) return const SizedBox.shrink();

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final cleanAlt = (alt != null && alt.trim().isNotEmpty) ? alt.trim() : null;

    Widget imageWidget;
    if (cleanUrl.startsWith('data:image/')) {
      try {
        final commaIdx = cleanUrl.indexOf(',');
        final base64Str = commaIdx != -1 ? cleanUrl.substring(commaIdx + 1) : cleanUrl;
        final bytes = base64Decode(base64Str);
        imageWidget = Image.memory(
          bytes,
          fit: BoxFit.contain,
          errorBuilder: (ctx, err, stack) => _buildImageError(context, cleanUrl, cleanAlt),
        );
      } catch (_) {
        imageWidget = _buildImageError(context, cleanUrl, cleanAlt);
      }
    } else {
      imageWidget = Image.network(
        cleanUrl,
        fit: BoxFit.contain,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          final total = loadingProgress.expectedTotalBytes;
          final loaded = loadingProgress.cumulativeBytesLoaded;
          final progress = (total != null && total > 0) ? loaded / total : null;
          return Container(
            height: 180,
            alignment: Alignment.center,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 28,
                  height: 28,
                  child: CircularProgressIndicator(
                    value: progress,
                    strokeWidth: 2.5,
                    color: theme.colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'جاري تحميل الصورة...',
                  style: TextStyle(
                    fontSize: 12,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) {
          return _buildImageError(context, cleanUrl, cleanAlt);
        },
      );
    }

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.4),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          MouseRegion(
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              onTap: () => _showFullScreenImage(context, cleanUrl, cleanAlt),
              child: Stack(
                alignment: Alignment.topRight,
                children: [
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxHeight: 520),
                    child: Center(child: imageWidget),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.65),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.zoom_in_rounded, size: 14, color: Colors.white),
                          SizedBox(width: 4),
                          Text(
                            'تكبير',
                            style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (cleanAlt != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E293B) : const Color(0xFFEEF2F6),
                border: Border(
                  top: BorderSide(
                    color: theme.colorScheme.outlineVariant.withValues(alpha: 0.3),
                  ),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.image_outlined,
                    size: 14,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      cleanAlt,
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
                      ),
                      textAlign: TextAlign.start,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildImageError(BuildContext context, String url, String? alt) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      alignment: Alignment.center,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.broken_image_rounded, size: 40, color: theme.colorScheme.error.withValues(alpha: 0.7)),
          const SizedBox(height: 8),
          Text(
            'تعذر تحميل الصورة',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: theme.colorScheme.error),
          ),
          if (alt != null && alt.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              alt,
              style: TextStyle(fontSize: 12, color: theme.colorScheme.onSurface.withValues(alpha: 0.6)),
              textAlign: TextAlign.center,
            ),
          ],
          const SizedBox(height: 8),
          InkWell(
            onTap: () => _copy(context, url),
            borderRadius: BorderRadius.circular(6),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.copy_rounded, size: 14, color: theme.colorScheme.primary),
                  const SizedBox(width: 6),
                  Text(
                    'نسخ رابط الصورة',
                    style: TextStyle(fontSize: 11, color: theme.colorScheme.primary, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showFullScreenImage(BuildContext context, String url, String? alt) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.9),
      builder: (dialogCtx) {
        Widget imgWidget;
        if (url.startsWith('data:image/')) {
          final commaIdx = url.indexOf(',');
          final base64Str = commaIdx != -1 ? url.substring(commaIdx + 1) : url;
          imgWidget = Image.memory(base64Decode(base64Str), fit: BoxFit.contain);
        } else {
          imgWidget = Image.network(url, fit: BoxFit.contain);
        }

        return Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            backgroundColor: Colors.black.withValues(alpha: 0.6),
            foregroundColor: Colors.white,
            elevation: 0,
            title: Text(alt ?? 'عرض الصورة', style: const TextStyle(fontSize: 16, color: Colors.white)),
            leading: IconButton(
              icon: const Icon(Icons.close_rounded, color: Colors.white),
              onPressed: () => Navigator.of(dialogCtx).pop(),
            ),
          ),
          body: Center(
            child: InteractiveViewer(
              minScale: 0.5,
              maxScale: 5.0,
              child: imgWidget,
            ),
          ),
        );
      },
    );
  }

  Widget _buildTable(BuildContext context, List<List<String>> rows) {
    if (rows.isEmpty) return const SizedBox.shrink();
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final header = rows.first;
    final dataRows = rows.skip(1).toList();
    final colCount = rows.map((r) => r.length).reduce((a, b) => a > b ? a : b);
    for (final r in rows) {
      while (r.length < colCount) {
        r.add('');
      }
    }
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5)),
      ),
      clipBehavior: Clip.antiAlias,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Directionality(
          textDirection: lang == 'ar' ? TextDirection.rtl : TextDirection.ltr,
          child: Table(
            border: TableBorder(
              horizontalInside: BorderSide(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.3)),
              verticalInside: BorderSide(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.3)),
            ),
            defaultColumnWidth: const IntrinsicColumnWidth(),
            children: [
              TableRow(
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF2D2D2D) : const Color(0xFF1E293B),
                ),
                children: header.map((cell) => Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: _RichText(
                    text: cell,
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: Colors.white, height: 1.6),
                  ),
                )).toList(),
              ),
              ...dataRows.map((row) => TableRow(
                decoration: BoxDecoration(color: theme.colorScheme.surface),
                children: row.map((cell) => Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  child: _RichText(
                    text: cell,
                    style: TextStyle(fontSize: fontSize, height: 1.7, color: theme.colorScheme.onSurface),
                  ),
                )).toList(),
              )),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCodeBlock(BuildContext context, String language, String code) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final langMap = _codeLanguages();
    final highlightLang = langMap[language.toLowerCase()] ?? language.toLowerCase();
    final langTheme = isDark ? 'atom-one-dark' : 'atom-one-light';

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0D1424) : const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.4)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            color: theme.colorScheme.primary.withValues(alpha: 0.12),
            child: Row(
              children: [
                Icon(Icons.code, size: 16, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  language.isEmpty ? 'code' : language,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: theme.colorScheme.primary,
                    fontFamily: 'monospace',
                  ),
                ),
                const Spacer(),
                InkWell(
                  onTap: () => _copy(context, code),
                  borderRadius: BorderRadius.circular(6),
                  child: const Padding(
                    padding: EdgeInsets.all(4),
                    child: Icon(Icons.copy_rounded, size: 16),
                  ),
                ),
              ],
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.all(14),
            child: HighlightView(
                code,
                language: highlightLang,
                theme: _highlightTheme(langTheme),
                padding: EdgeInsets.zero,
                textStyle: const TextStyle(fontFamily: 'monospace', fontSize: 14, height: 1.6),
              ),
          ),
        ],
      ),
    );
  }

  static Map<String, TextStyle> _highlightTheme(String name) {
    final base = HighlightViewThemeMap.themes[name];
    return base ?? HighlightViewThemeMap.themes['atom-one-dark']!;
  }

  void _copy(BuildContext context, String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Copied'),
        duration: Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

class _RichText extends StatelessWidget {
  final String text;
  final TextStyle style;
  const _RichText({required this.text, required this.style});

  @override
  Widget build(BuildContext context) {
    final spans = <TextSpan>[];

    var remaining = text;
    final combined = RegExp(r'(`[^`]+`|\*\*[^*]+\*\*|(?<!\*)\*[^*]+\*(?!\*))');
    final matches = combined.allMatches(remaining).toList();
    var lastEnd = 0;

    for (final m in matches) {
      if (m.start > lastEnd) {
        spans.add(TextSpan(text: remaining.substring(lastEnd, m.start)));
      }
      final token = m.group(0)!;
      if (token.startsWith('`')) {
        final code = token.substring(1, token.length - 1);
        spans.add(TextSpan(
          text: code,
          style: TextStyle(
            fontFamily: 'monospace',
            backgroundColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
            color: Theme.of(context).colorScheme.primary,
            fontWeight: FontWeight.w600,
            fontSize: style.fontSize! - 2,
          ),
        ));
      } else if (token.startsWith('**')) {
        spans.add(TextSpan(text: token.substring(2, token.length - 2), style: const TextStyle(fontWeight: FontWeight.w800)));
      } else {
        spans.add(TextSpan(text: token.substring(1, token.length - 1), style: const TextStyle(fontStyle: FontStyle.italic)));
      }
      lastEnd = m.end;
    }
    if (lastEnd < remaining.length) {
      spans.add(TextSpan(text: remaining.substring(lastEnd)));
    }

    return Text.rich(
      TextSpan(style: style, children: spans),
    );
  }
}

class HighlightViewThemeMap {
  static final themes = <String, Map<String, TextStyle>>{
    'atom-one-dark': {
      'root': const TextStyle(color: Color(0xFFABB2BF), backgroundColor: Color(0xFF0D1424)),
      'keyword': const TextStyle(color: Color(0xFFC678DD), fontWeight: FontWeight.bold),
      'built_in': const TextStyle(color: Color(0xFFE5C07B)),
      'type': const TextStyle(color: Color(0xFFE5C07B)),
      'literal': const TextStyle(color: Color(0xFF56B6C2)),
      'number': const TextStyle(color: Color(0xFFD19A66)),
      'regexp': const TextStyle(color: Color(0xFF56B6C2)),
      'string': const TextStyle(color: Color(0xFF98C379)),
      'subst': const TextStyle(color: Color(0xFFABB2BF)),
      'symbol': const TextStyle(color: Color(0xFF61AFEF)),
      'class': const TextStyle(color: Color(0xFFE5C07B)),
      'function': const TextStyle(color: Color(0xFF61AFEF)),
      'title': const TextStyle(color: Color(0xFF61AFEF)),
      'params': const TextStyle(color: Color(0xFFABB2BF)),
      'comment': const TextStyle(color: Color(0xFF5C6370), fontStyle: FontStyle.italic),
      'meta': const TextStyle(color: Color(0xFF7F848E)),
      'section': const TextStyle(color: Color(0xFFE06C75)),
      'variable': const TextStyle(color: Color(0xFFE06C75)),
      'name': const TextStyle(color: Color(0xFFE06C75)),
      'attr': const TextStyle(color: Color(0xFFD19A66)),
      'attribute': const TextStyle(color: Color(0xFFE06C75)),
      'tag': const TextStyle(color: Color(0xFFE06C75)),
      'selector-tag': const TextStyle(color: Color(0xFFE06C75)),
      'selector-id': const TextStyle(color: Color(0xFF61AFEF)),
      'selector-class': const TextStyle(color: Color(0xFFE5C07B)),
      'selector-attr': const TextStyle(color: Color(0xFFE06C75)),
      'selector-pseudo': const TextStyle(color: Color(0xFFE06C75)),
      'addition': const TextStyle(color: Color(0xFF98C379)),
      'deletion': const TextStyle(color: Color(0xFFE06C75)),
      'emphasis': const TextStyle(fontStyle: FontStyle.italic),
      'strong': const TextStyle(fontWeight: FontWeight.bold),
    },
    'atom-one-light': {
      'root': const TextStyle(color: Color(0xFF383A42), backgroundColor: Color(0xFFF1F5F9)),
      'keyword': const TextStyle(color: Color(0xFFA626A4), fontWeight: FontWeight.bold),
      'built_in': const TextStyle(color: Color(0xFFC18401)),
      'type': const TextStyle(color: Color(0xFFC18401)),
      'literal': const TextStyle(color: Color(0xFF0184BC)),
      'number': const TextStyle(color: Color(0xFF986801)),
      'regexp': const TextStyle(color: Color(0xFF0184BC)),
      'string': const TextStyle(color: Color(0xFF50A14F)),
      'subst': const TextStyle(color: Color(0xFF383A42)),
      'symbol': const TextStyle(color: Color(0xFF4078F2)),
      'class': const TextStyle(color: Color(0xFFC18401)),
      'function': const TextStyle(color: Color(0xFF4078F2)),
      'title': const TextStyle(color: Color(0xFF4078F2)),
      'params': const TextStyle(color: Color(0xFF383A42)),
      'comment': const TextStyle(color: Color(0xFFA0A1A7), fontStyle: FontStyle.italic),
      'meta': const TextStyle(color: Color(0xFF7F848E)),
      'section': const TextStyle(color: Color(0xFFE45649)),
      'variable': const TextStyle(color: Color(0xFFE45649)),
      'name': const TextStyle(color: Color(0xFFE45649)),
      'attr': const TextStyle(color: Color(0xFF986801)),
      'attribute': const TextStyle(color: Color(0xFFE45649)),
      'tag': const TextStyle(color: Color(0xFFE45649)),
      'selector-tag': const TextStyle(color: Color(0xFFE45649)),
      'selector-id': const TextStyle(color: Color(0xFF4078F2)),
      'selector-class': const TextStyle(color: Color(0xFFC18401)),
      'selector-attr': const TextStyle(color: Color(0xFFE45649)),
      'selector-pseudo': const TextStyle(color: Color(0xFFE45649)),
      'addition': const TextStyle(color: Color(0xFF50A14F)),
      'deletion': const TextStyle(color: Color(0xFFE45649)),
      'emphasis': const TextStyle(fontStyle: FontStyle.italic),
      'strong': const TextStyle(fontWeight: FontWeight.bold),
    },
  };
}
