// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;
import 'dart:ui_web' as ui_web;
import 'package:flutter/material.dart';

int _viewCounter = 0;
final Map<String, String> _registeredViews = <String, String>{};

String _registerIframeView(
  String prefix,
  void Function(html.IFrameElement frame) setup,
) {
  final viewType = '$prefix-${_viewCounter++}';
  ui_web.platformViewRegistry.registerViewFactory(viewType, (int viewId) {
    final frame = html.IFrameElement()
      ..style.border = 'none'
      ..style.width = '100%'
      ..style.height = '100%'
      ..style.overflow = 'auto'
      ..setAttribute('allow', 'autoplay; clipboard-write; encrypted-media');
    setup(frame);
    return frame;
  });
  return viewType;
}

Widget buildHtmlWebView(String htmlContent, bool isDark) {
  final css = '''
  <style>
    * { box-sizing: border-box; }
    html, body { margin: 0; padding: 16px; font-family: system-ui, sans-serif; background: ${isDark ? '#0f1526' : '#ffffff'}; color: ${isDark ? '#e2e8f0' : '#0f172a'}; line-height: 1.6; }
    h1,h2,h3 { margin: 0.5em 0; }
    a { color: #0ea5e9; }
    img { max-width: 100%; }
  </style>
  ''';
  final fullHtml =
      '<!DOCTYPE html><html><head><meta charset="utf-8">$css</head><body>$htmlContent</body></html>';
  final cacheKey = 'html|$isDark|$htmlContent';
  final viewType = _registeredViews.putIfAbsent(
    cacheKey,
    () => _registerIframeView('html-preview', (frame) {
          frame.srcdoc = fullHtml;
        }),
  );
  return HtmlElementView(viewType: viewType);
}

Widget buildDartPadWebView(String code, bool isDark) {
  final encoded = Uri.encodeComponent(code);
  final theme = isDark ? 'dark' : 'light';
  final url =
      'https://dartpad.dev/embed-inline.html?code=$encoded&split=50&theme=$theme&run=true';
  final cacheKey = 'dart|$isDark|$code';
  final viewType = _registeredViews.putIfAbsent(
    cacheKey,
    () => _registerIframeView('dartpad-preview', (frame) {
          frame.src = url;
        }),
  );
  return HtmlElementView(viewType: viewType);
}

Widget buildVideoWebView(String embedUrl) {
  final cacheKey = 'video|$embedUrl';
  final viewType = _registeredViews.putIfAbsent(
    cacheKey,
    () => _registerIframeView('video-preview', (frame) {
          frame.src = embedUrl;
        }),
  );
  return HtmlElementView(viewType: viewType);
}
