import 'dart:async';

import 'package:flutter/material.dart';

import '../core/design_tokens.dart';

/// ═════════════════════════════════════════════════════════════════════════════
/// Terminal Window — نافذة Terminal حقيقية المظهر للهيرو
/// محاكاة كتابة تلقائية مع تلوين syntax
/// ═════════════════════════════════════════════════════════════════════════════

class TerminalWindow extends StatefulWidget {
  final VoidCallback? onFinalCommandTap;

  const TerminalWindow({super.key, this.onFinalCommandTap});

  @override
  State<TerminalWindow> createState() => _TerminalWindowState();
}

class _TerminalWindowState extends State<TerminalWindow> {
  final List<_TerminalLine> _lines = [];
  int _currentLine = 0;
  int _currentChar = 0;
  Timer? _timer;
  bool _paused = false;
  bool _reduceMotion = false;

  static const List<_TerminalLine> _script = [
    _TerminalLine(command: 'flutter create my_first_app', output: [
      'Creating project my_first_app...',
      '  my_first_app/lib/main.dart (created)',
      '  my_first_app/pubspec.yaml (created)',
      'Running "flutter pub get"...',
      '✓ Project created successfully.',
    ]),
    _TerminalLine(command: 'cd my_first_app && code lib/main.dart', output: [
      '// lib/main.dart',
      'import \'package:flutter/material.dart\';',
      '',
      'void main() => runApp(const MyApp());',
      '',
      'class MyApp extends StatelessWidget {',
      '  const MyApp({super.key});',
      '  @override',
      '  Widget build(BuildContext context) {',
      '    return MaterialApp(',
      '      home: Scaffold(',
      '        body: Center(',
      '          child: Text(\'Hello, Tamer Academy!\'),',
      '        ),',
      '      ),',
      '    );',
      '  }',
      '}',
    ]),
    _TerminalLine(
      command: './start-learning --track flutter',
      output: ['Launching learning path...'],
      isFinal: true,
    ),
  ];

  @override
  void initState() {
    super.initState();
    // Check reduce motion preference
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final mq = MediaQuery.of(context);
      _reduceMotion = mq.accessibleNavigation;
      if (_reduceMotion) {
        // Show full text immediately
        _showAllText();
      } else {
        _startTyping();
      }
    });
  }

  void _showAllText() {
    setState(() {
      for (final line in _script) {
        _lines.add(line);
      }
      _currentLine = _script.length;
    });
  }

  void _startTyping() {
    _timer = Timer.periodic(const Duration(milliseconds: 30), (timer) {
      if (_paused) return;
      if (_currentLine >= _script.length) {
        // Restart after pause
        timer.cancel();
        Future.delayed(const Duration(seconds: 3), () {
          if (mounted) {
            setState(() {
              _lines.clear();
              _currentLine = 0;
              _currentChar = 0;
            });
            _startTyping();
          }
        });
        return;
      }

      final line = _script[_currentLine];
      if (_currentChar == 0 && line.output.isNotEmpty && _lines.length == _currentLine) {
        // Add the command line first
        setState(() {
          _lines.add(_TerminalLine(command: line.command, output: [], isFinal: line.isFinal));
        });
      }

      final cmdLine = _lines.last;
      if (_currentChar < line.command.length) {
        setState(() {
          _lines[_lines.length - 1] = _TerminalLine(
            command: line.command.substring(0, _currentChar + 1),
            output: cmdLine.output,
            isFinal: line.isFinal,
          );
        });
        _currentChar++;
      } else {
        // Command complete, show output
        if (cmdLine.output.isEmpty && line.output.isNotEmpty) {
          setState(() {
            _lines[_lines.length - 1] = _TerminalLine(
              command: line.command,
              output: line.output,
              isFinal: line.isFinal,
            );
          });
        }
        _currentLine++;
        _currentChar = 0;
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF0D0D0F) : const Color(0xFF1A1A1C);
    final textColor = isDark ? const Color(0xFFEDE6D6) : const Color(0xFFEDE6D6);
    final promptColor = const Color(0xFF5CC8FF); // Eagle Vision blue
    final cmdColor = const Color(0xFFEDE6D6);
    final outputColor = const Color(0xFFA8A39A);

    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: DTokens.borderRadiusSm,
        border: Border.all(color: const Color(0xFF2D2C2E)),
        boxShadow: DShadows.crimsonGlow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Title bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: const BoxDecoration(
              color: Color(0xFF1E1E22),
              borderRadius: BorderRadius.vertical(top: Radius.circular(4)),
            ),
            child: Row(
              children: [
                // Window dots
                Container(width: 10, height: 10, decoration: const BoxDecoration(color: Color(0xFFFF5F56), shape: BoxShape.circle)),
                const SizedBox(width: 6),
                Container(width: 10, height: 10, decoration: const BoxDecoration(color: Color(0xFFFFBD2E), shape: BoxShape.circle)),
                const SizedBox(width: 6),
                Container(width: 10, height: 10, decoration: const BoxDecoration(color: Color(0xFF27C93F), shape: BoxShape.circle)),
                const SizedBox(width: 12),
                Text(
                  'tamer@academy:~',
                  style: TextStyle(
                    fontFamily: 'JetBrains Mono',
                    fontSize: 12,
                    color: const Color(0xFFA8A39A),
                  ),
                ),
                const Spacer(),
                // Pause/Skip buttons
                IconButton(
                  icon: Icon(_paused ? Icons.play_arrow : Icons.pause, size: 16),
                  color: const Color(0xFFA8A39A),
                  onPressed: () => setState(() => _paused = !_paused),
                  constraints: const BoxConstraints(),
                  padding: const EdgeInsets.all(4),
                ),
              ],
            ),
          ),
          // Terminal content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (final line in _lines) ...[
                    // Command line
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'tamer@academy:~\$ ',
                          style: TextStyle(
                            fontFamily: 'JetBrains Mono',
                            fontSize: 13,
                            color: promptColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Expanded(
                          child: line.isFinal
                              ? GestureDetector(
                                  onTap: widget.onFinalCommandTap,
                                  child: MouseRegion(
                                    cursor: SystemMouseCursors.click,
                                    child: Text(
                                      line.command,
                                      style: TextStyle(
                                        fontFamily: 'JetBrains Mono',
                                        fontSize: 13,
                                        color: const Color(0xFF5CC8FF),
                                        decoration: TextDecoration.underline,
                                      ),
                                    ),
                                  ),
                                )
                              : Text(
                                  line.command,
                                  style: TextStyle(
                                    fontFamily: 'JetBrains Mono',
                                    fontSize: 13,
                                    color: cmdColor,
                                  ),
                                ),
                        ),
                      ],
                    ),
                    // Output
                    for (final out in line.output)
                      Padding(
                        padding: const EdgeInsets.only(left: 0, top: 2),
                        child: Text(
                          out,
                          style: TextStyle(
                            fontFamily: 'JetBrains Mono',
                            fontSize: 12,
                            color: outputColor,
                            height: 1.6,
                          ),
                        ),
                      ),
                    const SizedBox(height: 8),
                  ],
                  // Blinking cursor
                  if (_currentLine < _script.length)
                    Row(
                      children: [
                        Text(
                          'tamer@academy:~\$ ',
                          style: TextStyle(
                            fontFamily: 'JetBrains Mono',
                            fontSize: 13,
                            color: promptColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        _BlinkingCursor(),
                      ],
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TerminalLine {
  final String command;
  final List<String> output;
  final bool isFinal;

  const _TerminalLine({
    required this.command,
    required this.output,
    this.isFinal = false,
  });
}

class _BlinkingCursor extends StatefulWidget {
  @override
  State<_BlinkingCursor> createState() => _BlinkingCursorState();
}

class _BlinkingCursorState extends State<_BlinkingCursor> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 530),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return Opacity(
          opacity: _controller.value > 0.5 ? 1.0 : 0.0,
          child: Container(
            width: 8,
            height: 16,
            color: const Color(0xFFEDE6D6),
          ),
        );
      },
    );
  }
}
