import 'package:flutter/material.dart';

class LocalizedText {
  final String ar;
  final String en;
  final String fr;

  const LocalizedText({required this.ar, required this.en, required this.fr});

  String get(String lang) {
    switch (lang) {
      case 'ar':
        return ar;
      case 'fr':
        return fr;
      default:
        return en;
    }
  }

  String getWithFallback(String lang) {
    final primary = get(lang);
    if (primary.trim().isNotEmpty) return primary;
    if (en.trim().isNotEmpty) return en;
    if (ar.trim().isNotEmpty) return ar;
    if (fr.trim().isNotEmpty) return fr;
    return primary;
  }

  bool get isEmpty => ar.trim().isEmpty && en.trim().isEmpty && fr.trim().isEmpty;
  bool isEmptyFor(String lang) => get(lang).trim().isEmpty;

  factory LocalizedText.fromMap(Map<String, dynamic>? map) {
    return LocalizedText(
      ar: map?['ar'] as String? ?? '',
      en: map?['en'] as String? ?? '',
      fr: map?['fr'] as String? ?? '',
    );
  }

  Map<String, dynamic> toMap() => {'ar': ar, 'en': en, 'fr': fr};
}

class Course {
  final String id;
  final LocalizedText title;
  final LocalizedText description;
  final String track; // 'web' | 'mobile'
  final String level; // 'beginner' | 'intermediate' | 'advanced'
  final double price;
  final int order;
  final bool published;
  final int colorSeed;
  final String imageUrl;
  final double imageWidth;
  final double imageHeight;
  final String imageFit; // cover | contain | fill | fitWidth

  const Course({
    required this.id,
    required this.title,
    required this.description,
    required this.track,
    required this.level,
    required this.price,
    required this.order,
    this.published = true,
    this.colorSeed = 0,
    this.imageUrl = '',
    this.imageWidth = 0,
    this.imageHeight = 0,
    this.imageFit = 'cover',
  });

  bool get isFree => price <= 0;

  factory Course.fromMap(String id, Map<String, dynamic> map) {
    return Course(
      id: id,
      title: LocalizedText.fromMap(map['title'] as Map<String, dynamic>?),
      description: LocalizedText.fromMap(map['description'] as Map<String, dynamic>?),
      track: map['track'] as String? ?? 'web',
      level: map['level'] as String? ?? 'beginner',
      price: (map['price'] as num?)?.toDouble() ?? 0,
      order: (map['order'] as num?)?.toInt() ?? 0,
      published: map['published'] as bool? ?? true,
      colorSeed: (map['colorSeed'] as num?)?.toInt() ?? 0,
      imageUrl: map['imageUrl'] as String? ?? '',
      imageWidth: (map['imageWidth'] as num?)?.toDouble() ?? 0,
      imageHeight: (map['imageHeight'] as num?)?.toDouble() ?? 0,
      imageFit: map['imageFit'] as String? ?? 'cover',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title.toMap(),
      'description': description.toMap(),
      'track': track,
      'level': level,
      'price': price,
      'order': order,
      'published': published,
      'colorSeed': colorSeed,
      'imageUrl': imageUrl,
      'imageWidth': imageWidth,
      'imageHeight': imageHeight,
      'imageFit': imageFit,
    };
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

  Course copyWith({
    LocalizedText? title,
    LocalizedText? description,
    String? track,
    String? level,
    double? price,
    int? order,
    bool? published,
    int? colorSeed,
    String? imageUrl,
    double? imageWidth,
    double? imageHeight,
    String? imageFit,
  }) {
    return Course(
      id: id,
      title: title ?? this.title,
      description: description ?? this.description,
      track: track ?? this.track,
      level: level ?? this.level,
      price: price ?? this.price,
      order: order ?? this.order,
      published: published ?? this.published,
      colorSeed: colorSeed ?? this.colorSeed,
      imageUrl: imageUrl ?? this.imageUrl,
      imageWidth: imageWidth ?? this.imageWidth,
      imageHeight: imageHeight ?? this.imageHeight,
      imageFit: imageFit ?? this.imageFit,
    );
  }
}