import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tamer_academy/widgets/lesson_content_renderer.dart';

void main() {
  test('normalizes split OpenAI image references into Markdown images', () {
    const raw = 'https://images.openai.com/static-rsc-4/first-token-'
        '[Example image title](second-token?purpose=inline)';

    expect(
      LessonContentRenderer.normalizeOpenAiImageMarkup(raw),
      '![Example image title]('
      'https://images.openai.com/static-rsc-4/first-token-second-token?purpose=inline)',
    );
  });

  test('normalizes parenthesized URL followed by its image caption', () {
    const raw = '(https://images.openai.com/static-rsc-4/image-id?purpose=inline)'
        '[Best + Free React Certificate Online Courses \\[2025\\] 25]';

    expect(
      LessonContentRenderer.normalizeOpenAiImageMarkup(raw),
      '![Best + Free React Certificate Online Courses \\[2025\\] 25]('
      'https://images.openai.com/static-rsc-4/image-id?purpose=inline)',
    );
  });

  testWidgets('keeps consecutive numbered lesson steps in one sequence', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: LessonContentRenderer(
            content: '1. First step\n1. Second step\n1. Third step',
            lang: 'en',
          ),
        ),
      ),
    );

    expect(find.text('1.'), findsOneWidget);
    expect(find.text('2.'), findsOneWidget);
    expect(find.text('3.'), findsOneWidget);
  });
}
