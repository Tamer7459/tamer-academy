import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

import 'code_result_stub.dart' if (dart.library.html) 'code_result_web.dart' as webHelper;

import '../../core/app_localizations.dart';
import '../../core/app_theme.dart';

enum CodeResultType { html, dart }

class CodeResultViewer extends StatefulWidget {
  final CodeResultType type;
  final String codeHtml;
  final String codeDart;
  final String? videoUrl;

  const CodeResultViewer({
    super.key,
    required this.type,
    this.codeHtml = '',
    this.codeDart = '',
    this.videoUrl,
  });

  @override
  State<CodeResultViewer> createState() => _CodeResultViewerState();
}

class _CodeResultViewerState extends State<CodeResultViewer> {
  WebViewController? _controller;
  bool _failed = false;
  bool _loaded = false;
  bool _isDark = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    if (_controller == null || _isDark != isDark) {
      _isDark = isDark;
      _load(isDark);
    }
  }

  String _videoEmbedUrl(String url) {
    final videoId = extractVideoId(url);
    if (videoId == null) return url;
    final isYoutube = url.contains('youtube') || url.contains('youtu.be');
    if (isYoutube) {
      return 'https://www.youtube-nocookie.com/embed/$videoId?rel=0';
    }
    return 'https://drive.google.com/file/d/$videoId/preview';
  }

  void _load(bool isDark) {
    // Empty check — show placeholder instead of grey box
    final hasHtml = widget.type == CodeResultType.html && widget.codeHtml.trim().isNotEmpty;
    final hasDart = widget.type == CodeResultType.dart && widget.codeDart.trim().isNotEmpty;
    final hasVideo = widget.videoUrl != null && widget.videoUrl!.trim().isNotEmpty;
    if (!hasHtml && !hasDart && !hasVideo) {
      _controller = null;
      _loaded = true;
      return;
    }

    // On web everything is rendered with HtmlElementView iframes in build()
    // (webview_flutter_web does not implement setJavaScriptMode etc.)
    if (kIsWeb) {
      _controller = null;
      _loaded = true;
      _failed = false;
      return;
    }

    final controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(isDark ? const Color(0xFF0f1526) : Colors.white)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (_) {
            if (mounted) setState(() => _loaded = true);
          },
          onWebResourceError: (_) {
            if (mounted) setState(() => _failed = true);
          },
        ),
      );

    if (hasHtml) {
      final css = '''
      <style>
        * { box-sizing: border-box; }
        html, body { height: auto; min-height: 100%; overflow: auto; -webkit-overflow-scrolling: touch; }
        body {
          margin: 0;
          padding: 16px;
          font-family: system-ui, -apple-system, 'Segoe UI', sans-serif;
          background: ${isDark ? '#0f1526' : '#ffffff'};
          color: ${isDark ? '#e2e8f0' : '#0f172a'};
          line-height: 1.6;
        }
        h1,h2,h3 { color: ${isDark ? '#f8fafc' : '#0f172a'}; }
        a { color: #0ea5e9; }
        pre { background: ${isDark ? '#0b1120' : '#f1f5f9'}; padding: 12px; border-radius: 8px; overflow: auto; }
        code { font-family: 'Fira Code', monospace; }
        img { max-width: 100%; height: auto; border-radius: 8px; }
        table { border-collapse: collapse; width: 100%; }
        th, td { border: 1px solid ${isDark ? '#334155' : '#e2e8f0'}; padding: 8px; }
      </style>
      ''';
      final htmlDoc = '<!DOCTYPE html><html><head><meta charset="utf-8"><meta name="viewport" content="width=device-width, initial-scale=1">$css</head><body>${widget.codeHtml}</body></html>';
      controller.loadHtmlString(htmlDoc);
      // Fallback timeout: if WebView doesn't load in 4s on web, mark as loaded to hide spinner
      Future.delayed(const Duration(seconds: 4), () {
        if (mounted && !_loaded && !_failed) setState(() => _loaded = true);
      });
    } else if (widget.type == CodeResultType.html && hasVideo) {
      controller.loadRequest(Uri.parse(_videoEmbedUrl(widget.videoUrl!)));
    } else if (hasDart) {
      final encoded = Uri.encodeComponent(widget.codeDart);
      final theme = isDark ? 'dark' : 'light';
      controller.loadRequest(
        Uri.parse(
          'https://dartpad.dev/embed-inline.html?code=$encoded&split=50&theme=$theme&run=true',
        ),
      );
    }

    _controller = controller;
  }

  @override
  void didUpdateWidget(covariant CodeResultViewer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.codeHtml != widget.codeHtml ||
        oldWidget.codeDart != widget.codeDart ||
        oldWidget.type != widget.type) {
      _failed = false;
      _loaded = false;
      _load(_isDark);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = Localizations.of<AppLocalizations>(context, AppLocalizations)!;
    final t = l10n.t;
    final isMobile = MediaQuery.of(context).size.width < 600;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // On web, use HtmlElementView with iframe srcdoc for reliable rendering
    if (kIsWeb) {
      final hasHtml = widget.type == CodeResultType.html && widget.codeHtml.trim().isNotEmpty;
      final hasDart = widget.type == CodeResultType.dart && widget.codeDart.trim().isNotEmpty;
      final hasVideo = widget.videoUrl != null && widget.videoUrl!.trim().isNotEmpty;
      Widget? child;
      if (hasHtml) {
        child = webHelper.buildHtmlWebView(widget.codeHtml, isDark);
      } else if (hasDart) {
        child = webHelper.buildDartPadWebView(widget.codeDart, isDark);
      } else if (hasVideo) {
        child = webHelper.buildVideoWebView(_videoEmbedUrl(widget.videoUrl!));
      }
      if (child != null) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: Container(
            height: isMobile ? 420 : 500,
            decoration: BoxDecoration(
              border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
              borderRadius: BorderRadius.circular(14),
            ),
            child: child,
          ),
        );
      }
    }

    if (_failed && _controller == null) {
      return _FallbackError(t: t, url: _videoEmbedUrl(widget.videoUrl ?? ''));
    }

    // Empty — no code and no video: show placeholder instead of grey 400 box
    if (_controller == null) {
      return Container(
        height: 120,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.code_off_rounded, size: 28, color: AppColors.grayLight),
              const SizedBox(height: 8),
              Text(t('noPreview'), style: TextStyle(color: AppColors.grayMedium, fontSize: 13)),
            ],
          ),
        ),
      );
    }

    // Failed but controller exists — show raw code as fallback instead of endless grey
    if (_failed) {
      final raw = widget.codeHtml.isNotEmpty ? widget.codeHtml : widget.codeDart;
      return Container(
        height: 220,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
          borderRadius: BorderRadius.circular(14),
        ),
        padding: const EdgeInsets.all(12),
        child: SingleChildScrollView(
          child: Text(raw.isNotEmpty ? raw : t('noPreview'), style: TextStyle(fontFamily: 'monospace', fontSize: 13)),
        ),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: Container(
        height: isMobile ? 420 : 500,
        decoration: BoxDecoration(
          border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Stack(
          children: [
            WebViewWidget(
              controller: _controller!,
              gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>{
                Factory<OneSequenceGestureRecognizer>(
                  () => EagerGestureRecognizer(),
                ),
              },
            ),
            if (!_loaded)
              const Center(child: CircularProgressIndicator()),
          ],
        ),
      ),
    );
  }
}

class _FallbackError extends StatelessWidget {
  final String Function(String) t;
  final String url;

  const _FallbackError({required this.t, required this.url});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.error.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.link_rounded, size: 40, color: Theme.of(context).colorScheme.error),
            const SizedBox(height: 8),
            Text(t('error'), style: const TextStyle(fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            if (url.isNotEmpty)
              FilledButton.icon(
                onPressed: () => _openUrl(url),
                icon: const Icon(Icons.open_in_new),
                label: Text(t('openInNewTab')),
              ),
          ],
        ),
      ),
    );
  }

  void _openUrl(String url) {
    // ignore: avoid_print
    print('open $url');
  }
}

String? extractVideoId(String url) {
  final trimmed = url.trim();
  // youtube
  final ytRegexps = [
    RegExp(r'youtube\.com/watch\?v=([\w-]+)'),
    RegExp(r'youtu\.be/([\w-]+)'),
    RegExp(r'youtube\.com/embed/([\w-]+)'),
    RegExp(r'youtube\.com/shorts/([\w-]+)'),
    RegExp(r'youtube\.com/live/([\w-]+)'),
  ];
  for (final r in ytRegexps) {
    final m = r.firstMatch(trimmed);
    if (m != null) return m.group(1);
  }
  // google drive
  final driveRegexps = [
    RegExp(r'drive\.google\.com/file/d/([\w-]+)'),
    RegExp(r'drive\.google\.com/open\?id=([\w-]+)'),
  ];
  for (final r in driveRegexps) {
    final m = r.firstMatch(trimmed);
    if (m != null) return m.group(1);
  }
  return null;
}

String? ytThumbnailUrl(String url) {
  final id = extractVideoId(url);
  if (id == null) return null;
  return 'https://img.youtube.com/vi/$id/mqdefault.jpg';
}

// Video preview with thumbnail + play
class VideoPreview extends StatelessWidget {
  final String videoUrl;

  const VideoPreview({super.key, required this.videoUrl});

  @override
  Widget build(BuildContext context) {
    final l10n = Localizations.of<AppLocalizations>(context, AppLocalizations)!;
    final t = l10n.t;
    final thumb = ytThumbnailUrl(videoUrl);
    final isYoutube = videoUrl.contains('youtube') || videoUrl.contains('youtu.be');

    return Container(
      height: 220,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (thumb != null)
            Image.network(thumb, fit: BoxFit.cover)
          else
            Container(
              color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
              child: Center(
                child: Icon(Icons.play_circle_outline_rounded,
                    size: 60, color: Theme.of(context).colorScheme.primary),
              ),
            ),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.transparent, Colors.black.withValues(alpha: 0.6)],
              ),
            ),
          ),
          Center(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.5),
                    blurRadius: 20,
                  ),
                ],
              ),
              child: const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 40),
            ),
          ),
          Positioned(
            bottom: 12,
            left: 12,
            right: 12,
            child: Row(
              children: [
                Icon(
                  isYoutube ? Icons.ondemand_video_rounded : Icons.cloud_rounded,
color: Colors.white,
                  size: 18,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    t('video'),
                    style: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.w800),
                  ),
                ),
                const Icon(Icons.play_arrow_rounded, color: Colors.white),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// dartpad iframe for mobile lessons (web only alternative)
class DartPadWebView extends StatelessWidget {
  final String code;
  const DartPadWebView({super.key, required this.code});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final encoded = Uri.encodeComponent(code);
    final url = 'https://dartpad.dev/embed-inline.html?code=$encoded&split=50&theme=${isDark ? 'dark' : 'light'}&run=true';

    return SizedBox(
      height: 420,
      child: HtmlEmbed(url: url),
    );
  }
}

class HtmlEmbed extends StatefulWidget {
  final String url;
  const HtmlEmbed({super.key, required this.url});

  @override
  State<HtmlEmbed> createState() => _HtmlEmbedState();
}

class _HtmlEmbedState extends State<HtmlEmbed> {
  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadRequest(Uri.parse(widget.url));
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
          borderRadius: BorderRadius.circular(14),
        ),
        child: WebViewWidget(
          controller: _controller,
          gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>{
            Factory<OneSequenceGestureRecognizer>(
              () => EagerGestureRecognizer(),
            ),
          },
        ),
      ),
    );
  }
}