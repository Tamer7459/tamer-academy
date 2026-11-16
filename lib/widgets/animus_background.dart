import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';

import '../core/design_tokens.dart';
import 'cinematic_effects.dart';

/// ═════════════════════════════════════════════════════════════════════════════
/// Animus Background — شبكة خطوط رفيعة + vignette + توهج أحمر خفيف
/// ═════════════════════════════════════════════════════════════════════════════

class AnimusBackground extends StatefulWidget {
  final Widget child;
  final bool showGrid;
  final bool showVignette;
  final bool showGlow;

  const AnimusBackground({
    super.key,
    required this.child,
    this.showGrid = true,
    this.showVignette = true,
    this.showGlow = true,
  });

  @override
  State<AnimusBackground> createState() => _AnimusBackgroundState();
}

class _AnimusBackgroundState extends State<AnimusBackground> {
  Offset _pointer = Offset.zero;
  bool _pointerVisible = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final reduceMotion = MediaQuery.disableAnimationsOf(context);

    return MouseRegion(
      onHover: kIsWeb
          ? (event) => setState(() {
              _pointer = event.localPosition;
              _pointerVisible = true;
            })
          : null,
      onExit: kIsWeb ? (_) => setState(() => _pointerVisible = false) : null,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final glowSize = constraints.maxWidth < 600 ? 320.0 : 520.0;
          return Stack(
            fit: StackFit.expand,
            children: [
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: isDark
                        ? const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Color(0xFF0B0B0D),
                              Color(0xFF101014),
                              Color(0xFF0A0A0C),
                            ],
                          )
                        : DGradients.heroMeshLight,
                  ),
                ),
              ),
              if (widget.showGlow && !reduceMotion) ...[
                Positioned.fill(
                  child: GradientOrb(
                    color: const Color(0xFFC1232C).withValues(alpha: 0.24),
                    size: 620,
                    start: const Offset(-0.8, -0.5),
                    end: const Offset(0.6, 0.6),
                    duration: const Duration(seconds: 24),
                  ),
                ),
                Positioned.fill(
                  child: GradientOrb(
                    color: const Color(0xFF5CC8FF).withValues(alpha: 0.18),
                    size: 560,
                    start: const Offset(0.9, 0.4),
                    end: const Offset(-0.5, -0.4),
                    duration: const Duration(seconds: 28),
                  ),
                ),
                Positioned.fill(
                  child: GradientOrb(
                    color: const Color(0xFFD4A64A).withValues(alpha: 0.14),
                    size: 440,
                    start: const Offset(-0.2, 0.8),
                    end: const Offset(0.9, -0.3),
                    duration: const Duration(seconds: 32),
                  ),
                ),
              ],
              if (widget.showGlow)
                AnimatedPositioned(
                  duration: reduceMotion
                      ? Duration.zero
                      : const Duration(milliseconds: 260),
                  curve: Curves.easeOutCubic,
                  left: _pointer.dx - glowSize / 2,
                  top: _pointer.dy - glowSize / 2,
                  child: IgnorePointer(
                    child: AnimatedOpacity(
                      opacity: _pointerVisible && kIsWeb ? 1 : 0,
                      duration: reduceMotion
                          ? Duration.zero
                          : const Duration(milliseconds: 220),
                      child: Container(
                        width: glowSize,
                        height: glowSize,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [
                              (isDark
                                      ? const Color(0xFFC1232C)
                                      : const Color(0xFFB51F2B))
                                  .withValues(alpha: 0.16),
                              const Color(0xFF5CC8FF).withValues(alpha: 0.10),
                              Colors.transparent,
                            ],
                            stops: const [0, 0.42, 1],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              if (widget.showGrid)
                Positioned.fill(
                  child: IgnorePointer(
                    child: CustomPaint(
                      painter: _GridPainter(
                        color: isDark
                            ? const Color(0xFF565258).withValues(alpha: 0.16)
                            : const Color(0xFFD9D2C3).withValues(alpha: 0.4),
                        spacing: 42,
                      ),
                    ),
                  ),
                ),
              if (widget.showVignette && isDark)
                Positioned.fill(
                  child: IgnorePointer(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: RadialGradient(
                          colors: [
                            Colors.transparent,
                            const Color(0xFF050506).withValues(alpha: 0.48),
                          ],
                          stops: const [0.48, 1],
                        ),
                      ),
                    ),
                  ),
                ),
              widget.child,
              if (widget.showGlow && !reduceMotion)
                Positioned.fill(
                  child: IgnorePointer(
                    child: Opacity(
                      opacity: 0.72,
                      child: Stack(
                        children: [
                          GradientOrb(
                            color: const Color(
                              0xFFC1232C,
                            ).withValues(alpha: 0.12),
                            size: 620,
                            start: const Offset(-0.8, 0.6),
                            end: const Offset(0.5, -0.4),
                            duration: const Duration(seconds: 26),
                          ),
                          GradientOrb(
                            color: const Color(
                              0xFF5CC8FF,
                            ).withValues(alpha: 0.08),
                            size: 520,
                            start: const Offset(0.8, -0.3),
                            end: const Offset(-0.3, 0.7),
                            duration: const Duration(seconds: 30),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              if (_pointerVisible && kIsWeb)
                Positioned(
                  left: _pointer.dx - 15,
                  top: _pointer.dy - 15,
                  child: IgnorePointer(
                    child: CustomPaint(
                      size: const Size.square(30),
                      painter: _AssassinCursorPainter(isDark: isDark),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

/// Original hood-and-blade cursor glyph. It is an abstract academy mark,
/// not a Ubisoft/Assassin's Creed asset.
class _AssassinCursorPainter extends CustomPainter {
  final bool isDark;

  const _AssassinCursorPainter({required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    final crimson = const Color(0xFFE5384A);
    final gold = const Color(0xFFD4A64A);
    final outline = Paint()
      ..color = isDark
          ? Colors.white.withValues(alpha: 0.9)
          : const Color(0xFF0B0B0D)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4
      ..strokeJoin = StrokeJoin.round;
    final fill = Paint()..color = crimson.withValues(alpha: 0.92);
    final center = Offset(size.width / 2, size.height / 2);

    final hood = Path()
      ..moveTo(center.dx, 2)
      ..lineTo(size.width - 4, 8)
      ..lineTo(size.width - 8, size.height - 4)
      ..lineTo(center.dx, size.height - 9)
      ..lineTo(8, size.height - 4)
      ..lineTo(4, 8)
      ..close();
    canvas.drawPath(hood, fill);
    canvas.drawPath(hood, outline);

    final blade = Path()
      ..moveTo(center.dx - 1, 8)
      ..lineTo(center.dx + 5, size.height - 7)
      ..lineTo(center.dx, size.height - 4)
      ..lineTo(center.dx - 5, size.height - 7)
      ..close();
    canvas.drawPath(blade, Paint()..color = gold);
    canvas.drawLine(
      Offset(4, size.height - 4),
      Offset(size.width - 4, size.height - 4),
      outline,
    );
  }

  @override
  bool shouldRepaint(covariant _AssassinCursorPainter oldDelegate) =>
      oldDelegate.isDark != isDark;
}

class _GridPainter extends CustomPainter {
  final Color color;
  final double spacing;

  _GridPainter({required this.color, required this.spacing});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 0.5;

    for (double x = 0; x < size.width; x += spacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += spacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant _GridPainter oldDelegate) {
    return oldDelegate.color != color || oldDelegate.spacing != spacing;
  }
}
