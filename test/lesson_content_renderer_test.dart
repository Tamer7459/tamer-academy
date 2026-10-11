import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tamer_academy/widgets/lesson_content_renderer.dart';

Widget _wrap(String content) {
  return MaterialApp(
    home: Scaffold(
      body: LessonContentRenderer(content: content, lang: 'ar'),
    ),
  );
}

void main() {
  test('isImageUrl detects bare image links', () {
    expect(LessonContentRenderer.isImageUrl('https://res.cloudinary.com/dme6jhgkm/image/upload/v1788128792/1788128278cfd6_q0jno5.png'), isTrue);
    expect(LessonContentRenderer.isImageUrl('https://example.com/photo.JPG'), isTrue);
    expect(LessonContentRenderer.isImageUrl('https://example.com/page'), isFalse);
    expect(LessonContentRenderer.isImageUrl('just some text'), isFalse);
  });

  testWidgets('markdown image syntax renders an Image widget', (tester) async {
    await tester.pumpWidget(_wrap('before\n\n![alt text](https://example.com/a.png)\n\nafter'));
    await tester.pump();
    expect(find.byType(Image), findsOneWidget);
    expect(find.text('before', findRichText: true), findsOneWidget);
    expect(find.text('after', findRichText: true), findsOneWidget);
  });

  testWidgets('bare image URL on its own line renders an Image widget', (tester) async {
    await tester.pumpWidget(_wrap('https://res.cloudinary.com/dme6jhgkm/image/upload/v1788128792/1788128278cfd6_q0jno5.png'));
    await tester.pump();
    expect(find.byType(Image), findsOneWidget);
  });

  testWidgets('markdown link renders tappable text, not raw syntax', (tester) async {
    await tester.pumpWidget(_wrap('افتح [Firebase Console](https://console.firebase.google.com/).'));
    await tester.pump();
    expect(find.textContaining('Firebase Console', findRichText: true), findsOneWidget);
    expect(find.textContaining('[Firebase Console]', findRichText: true), findsNothing);
  });
}
