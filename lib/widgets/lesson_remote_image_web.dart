import 'dart:html' as html;

import 'package:flutter/material.dart';

Widget buildLessonRemoteImage(
  String url, {
  required String? alt,
  required Widget Function() errorBuilder,
}) {
  return _BrowserImage(url: url, alt: alt, errorBuilder: errorBuilder);
}

class _BrowserImage extends StatefulWidget {
  final String url;
  final String? alt;
  final Widget Function() errorBuilder;

  const _BrowserImage({
    required this.url,
    required this.alt,
    required this.errorBuilder,
  });

  @override
  State<_BrowserImage> createState() => _BrowserImageState();
}

class _BrowserImageState extends State<_BrowserImage> {
  bool _loaded = false;
  bool _failed = false;

  @override
  Widget build(BuildContext context) {
    if (_failed) return widget.errorBuilder();

    return AspectRatio(
      aspectRatio: 16 / 9,
      child: Stack(
        fit: StackFit.expand,
        children: [
          HtmlElementView.fromTagName(
            tagName: 'img',
            onElementCreated: (element) {
              final image = element as html.ImageElement;
              image.alt = widget.alt ?? '';
              image.style
                ..width = '100%'
                ..height = '100%'
                ..objectFit = 'contain'
                ..display = 'block';
              image.onLoad.listen((_) {
                if (mounted) setState(() => _loaded = true);
              });
              image.onError.listen((_) {
                if (mounted) setState(() => _failed = true);
              });
              image.src = widget.url;
            },
          ),
          if (!_loaded)
            const Center(
              child: SizedBox(
                width: 28,
                height: 28,
                child: CircularProgressIndicator(strokeWidth: 2.5),
              ),
            ),
        ],
      ),
    );
  }
}
