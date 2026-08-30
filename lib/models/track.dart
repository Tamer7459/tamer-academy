import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'course.dart';

class Track {
  final String id;
  final LocalizedText name;
  final LocalizedText description;
  final LocalizedText tags; // comma-separated per language
  final String icon; // icon name
  final String imageUrl;
  final double imageWidth;
  final double imageHeight;
  final String imageFit; // cover | contain | fill | fitWidth
  final int color; // hex color value
  final int order;
  final bool published;

  const Track({
    required this.id,
    required this.name,
    required this.description,
    required this.tags,
    this.icon = 'language_rounded',
    this.imageUrl = '',
    this.imageWidth = 0,
    this.imageHeight = 0,
    this.imageFit = 'cover',
    this.color = 0xFF1A8A7A,
    this.order = 0,
    this.published = true,
  });

  List<String> tagList(String lang) {
    final raw = tags.get(lang);
    return raw.split(',').map((s) => s.trim()).where((s) => s.isNotEmpty).toList();
  }

  factory Track.fromMap(String id, Map<String, dynamic> map) {
    return Track(
      id: id,
      name: LocalizedText.fromMap(map['name'] as Map<String, dynamic>?),
      description: LocalizedText.fromMap(map['description'] as Map<String, dynamic>?),
      tags: LocalizedText.fromMap(map['tags'] as Map<String, dynamic>?),
      icon: map['icon'] as String? ?? 'language_rounded',
      imageUrl: map['imageUrl'] as String? ?? '',
      imageWidth: (map['imageWidth'] as num?)?.toDouble() ?? 0,
      imageHeight: (map['imageHeight'] as num?)?.toDouble() ?? 0,
      imageFit: map['imageFit'] as String? ?? 'cover',
      color: (map['color'] as num?)?.toInt() ?? 0xFF1A8A7A,
      order: (map['order'] as num?)?.toInt() ?? 0,
      published: map['published'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name.toMap(),
      'description': description.toMap(),
      'tags': tags.toMap(),
      'icon': icon,
      'imageUrl': imageUrl,
      'imageWidth': imageWidth,
      'imageHeight': imageHeight,
      'imageFit': imageFit,
      'color': color,
      'order': order,
      'published': published,
    };
  }

  Track copyWith({
    LocalizedText? name,
    LocalizedText? description,
    LocalizedText? tags,
    String? icon,
    String? imageUrl,
    double? imageWidth,
    double? imageHeight,
    String? imageFit,
    int? color,
    int? order,
    bool? published,
  }) {
    return Track(
      id: id,
      name: name ?? this.name,
      description: description ?? this.description,
      tags: tags ?? this.tags,
      icon: icon ?? this.icon,
      imageUrl: imageUrl ?? this.imageUrl,
      imageWidth: imageWidth ?? this.imageWidth,
      imageHeight: imageHeight ?? this.imageHeight,
      imageFit: imageFit ?? this.imageFit,
      color: color ?? this.color,
      order: order ?? this.order,
      published: published ?? this.published,
    );
  }

  BoxFit get boxFit {
    switch (imageFit) {
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
}