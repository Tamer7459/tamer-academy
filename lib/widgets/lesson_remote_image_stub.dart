import 'package:flutter/material.dart';

Widget buildLessonRemoteImage(
  String url, {
  required String? alt,
  required Widget Function() errorBuilder,
}) {
  return Image.network(
    url,
    fit: BoxFit.contain,
    semanticLabel: alt,
    errorBuilder: (context, error, stackTrace) => errorBuilder(),
  );
}
