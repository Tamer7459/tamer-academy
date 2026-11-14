import 'dart:ui' show lerpDouble;

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

import '../core/design_tokens.dart';

/// ═════════════════════════════════════════════════════════════════════════════════
/// Cinematic Effects — مكونات مساعدة للتجربة السينمائية
/// ═════════════════════════════════════════════════════════════════════════════════

// ═════════════════════════════════════════════════════════════════════════════════
// 1. Gradient Orb — كرة توهج تتحرك ببطء في الخلفية لتعطي عمقاً بصرياً (Mesh Gradient)
// ═════════════════════════════════════════════════════════════════════════════════

class GradientOrb extends StatefulWidget {
  final Color color;
  final double size;
  final Offset start;
  final Offset end;
  final Duration duration;
  final bool blur;

  const GradientOrb({
    super.key,
    required this.color,
    this.size = 400,
    this.start = const Offset(-0.2, -0.2),
    this.end = const Offset(1.2, 1.2),
    this.duration = const Duration(seconds: 12),
    this.blur = true,
  });

  @override
  State<GradientOrb> createState() => _GradientOrbState();
}

class _GradientOrbState extends State<GradientOrb> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration)
      ..repeat(reverse: true);
    _animation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: DTokens.curveCinematic),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, _) {
        final dx = lerpDouble(widget.start.dx, widget.end.dx, _animation.value)!;
        final dy = lerpDouble(widget.start.dy, widget.end.dy, _animation.value)!;
        return Positioned.fill(
          child: Align(
            alignment: Alignment(dx, dy),
            child: Container(
              width: widget.size,
              height: widget.size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    widget.color.withValues(alpha: widget.blur ? 0.25 : 0.15),
                    widget.color.withValues(alpha: 0),
                  ],
                  stops: const [0.0, 0.7],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════════
// 2. Shimmer Loader — شريط تحميل متوهج لحالات الهيكلية (skeleton)
// ═════════════════════════════════════════════════════════════════════════════════

class ShimmerLoader extends StatefulWidget {
  final double width;
  final double height;
  final BorderRadius borderRadius;
  final Color baseColor;
  final Color highlightColor;

  const ShimmerLoader({
    super.key,
    this.width = double.infinity,
    this.height = 16,
    this.borderRadius = DTokens.borderRadiusSm,
    this.baseColor = const Color(0xFF1F2A3C),
    this.highlightColor = const Color(0xFF2A374C),
  });

  @override
  State<ShimmerLoader> createState() => _ShimmerLoaderState();
}

class _ShimmerLoaderState extends State<ShimmerLoader> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final base = isDark ? widget.baseColor : const Color(0xFFE2E8F0);
    final highlight = isDark ? widget.highlightColor : const Color(0xFFF1F5F9);

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final shift = _controller.value;
        return ClipRRect(
          borderRadius: widget.borderRadius,
          child: Stack(
            children: [
              Container(
                width: widget.width,
                height: widget.height,
                color: base,
              ),
              Positioned(
                left: -widget.width + (widget.width * 2 * shift),
                top: 0,
                bottom: 0,
                width: widget.width,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [highlight.withValues(alpha: 0), highlight, highlight.withValues(alpha: 0)],
                      stops: const [0.35, 0.5, 0.65],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════════
// 3. Cinematic Page Route — انتقال صفحة بتلاشي وتكبير خفيف (Fade-through)
// ═════════════════════════════════════════════════════════════════════════════════

class CinematicPageRoute<T> extends PageRouteBuilder<T> {
  final WidgetBuilder builder;
  final Duration duration;

  CinematicPageRoute({
    required this.builder,
    this.duration = DTokens.durCinematic,
  }) : super(
          pageBuilder: (context, animation, secondaryAnimation) => builder(context),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: animation,
              child: ScaleTransition(
                scale: Tween<double>(begin: 0.96, end: 1.0).animate(
                  CurvedAnimation(parent: animation, curve: DTokens.curveStandard),
                ),
                child: child,
              ),
            );
          },
          transitionDuration: duration,
          reverseTransitionDuration: DTokens.durNormal,
        );
}

// ══════════════════════════════════════════════════════════════════════════════════
// 4. Mouse Follower Glow — توهج يتبع المؤشر على الويب (يُعطل على الموبايل)
// ═════════════════════════════════════════════════════════════════════════════════

class MouseFollowerGlow extends StatefulWidget {
  final Widget child;
  final Color color;
  final double size;

  const MouseFollowerGlow({
    super.key,
    required this.child,
    this.color = const Color(0xFF0EA5E9),
    this.size = 120,
  });

  @override
  State<MouseFollowerGlow> createState() => _MouseFollowerGlowState();
}

class _MouseFollowerGlowState extends State<MouseFollowerGlow> {
  Offset _position = Offset.zero;
  bool _visible = false;

  @override
  Widget build(BuildContext context) {
    if (!kIsWeb) return widget.child;

    return MouseRegion(
      onHover: (event) {
        setState(() {
          _position = event.localPosition;
          _visible = true;
        });
      },
      onExit: (_) => setState(() => _visible = false),
      child: Stack(
        children: [
          widget.child,
          if (_visible)
            Positioned(
              left: _position.dx - widget.size / 2,
              top: _position.dy - widget.size / 2,
              child: AnimatedContainer(
                duration: DTokens.durFast,
                curve: DTokens.curveStandard,
                width: widget.size,
                height: widget.size,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      widget.color.withValues(alpha: 0.18),
                      widget.color.withValues(alpha: 0),
                    ],
                    stops: const [0.0, 0.6],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
