import 'package:flutter/material.dart';
import '../widgets/code_result_viewer.dart';

class TestViewerScreen extends StatelessWidget {
  const TestViewerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Test Viewer')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text('HTML Test', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          CodeResultViewer(type: CodeResultType.html, codeHtml: '<h1>Tamer Portfolio</h1><p>Hello World</p><nav><a href="#">Home</a></nav>'),
          const SizedBox(height: 24),
          const Text('Dart Test', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          CodeResultViewer(type: CodeResultType.dart, codeDart: 'void main(){print("hello");}'),
        ],
      ),
    );
  }
}
