// ignore_for_file: unused_import
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // Break very long words (no spaces) to prevent overflow — e.g. "dddd..." test content
    final brokenContent = content.replaceAllMapped(RegExp(r'\S{30,}'), (m) {
      final word = m.group(0)!;
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

      final codeMatch = RegExp(r'^```').hasMatch(line.trim());
      if (codeMatch) {
        flushLists();
        final langMatch = RegExp(r'^```([\w+#-]*)').firstMatch(line.trim());
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

      // ── Markdown Table: | a | b | + |---|---|
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

      if (RegExp(r'^[-*+]\s').hasMatch(line)) {
        flushLists();
        inList = true;
        listItems.add(line.replaceFirst(RegExp(r'^[-*+]\s*'), ''));
        i++;
        continue;
      }

      if (RegExp(r'^\d+[.)]\s').hasMatch(line)) {
        flushLists();
        inNumberedList = true;
        numberedItems.add(line.replaceFirst(RegExp(r'^\d+[.)]\s*'), ''));
        i++;
        continue;
      }

      if (line.trim().isEmpty) {
        flushLists();
        children.add(const SizedBox(height: 8));
        i++;
        continue;
      }

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
                Expanded(child: _RichText(text: items[idx], style: TextStyle(fontSize: fontSize, height: 1.7))),
              ],
            ),
          );
        }),
      ),
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
          textDirection: TextDirection.rtl,
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
          SelectionArea(
            child: SingleChildScrollView(
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
      SnackBar(
        content: const Text('Copied'),
        duration: const Duration(seconds: 1),
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