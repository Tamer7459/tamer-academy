import 'package:flutter/material.dart';

// ══════════════════════════════════════════════
// HOVER CARD — scale + shadow + lift
// ══════════════════════════════════════════════
class HoverCard extends StatefulWidget {
  final Widget child;
  final double hoverScale;
  final double hoverElevation;
  final Duration duration;
  final BorderRadius? borderRadius;
  final VoidCallback? onTap;

  const HoverCard({
    super.key,
    required this.child,
    this.hoverScale = 1.025,
    this.hoverElevation = 16,
    this.duration = const Duration(milliseconds: 220),
    this.borderRadius,
    this.onTap,
  });

  @override
  State<HoverCard> createState() => _HoverCardState();
}

class _HoverCardState extends State<HoverCard> with SingleTickerProviderStateMixin {
  bool _hovered = false;
  bool _pressed = false;
  late final AnimationController _pulseCtrl;
  late final Animation<double> _pulse;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 2200));
    _pulse = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOutSine));
    // Auto pulse on mobile so effect is visible without mouse
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final w = MediaQuery.maybeOf(context)?.size.width ?? 800;
      if (w < 700) {
        _pulseCtrl.repeat(reverse: true);
        // periodic hover flash
        Future.doWhile(() async {
          if (!mounted) return false;
          await Future.delayed(const Duration(milliseconds: 2800));
          if (!mounted) return false;
          setState(() => _hovered = true);
          await Future.delayed(const Duration(milliseconds: 650));
          if (!mounted) return false;
          setState(() => _hovered = false);
          return mounted;
        });
      }
    });
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.maybeOf(context)?.size.width != null && MediaQuery.of(context).size.width < 700;
    final pulseVal = isMobile ? _pulse.value : 0.0;
    final effectiveHovered = _hovered || (isMobile && pulseVal > 0.5);
    final scale = _pressed ? 0.98 : (effectiveHovered ? widget.hoverScale : 1.0 + pulseVal * 0.008);
    final shadow = effectiveHovered ? widget.hoverElevation : 4.0 + pulseVal * 4;
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTapDown: (_) => setState(() {
          _pressed = true;
          _hovered = true;
        }),
        onTapUp: (_) async {
          setState(() => _pressed = false);
          await Future.delayed(const Duration(milliseconds: 500));
          if (mounted) setState(() => _hovered = false);
        },
        onTapCancel: () => setState(() {
          _pressed = false;
          _hovered = false;
        }),
        onTap: widget.onTap,
        child: AnimatedScale(
          scale: scale,
          duration: widget.duration,
          curve: Curves.easeOutCubic,
          child: AnimatedContainer(
            duration: widget.duration,
            curve: Curves.easeOutCubic,
            decoration: BoxDecoration(
              borderRadius: widget.borderRadius ?? BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: effectiveHovered
                      ? Colors.black.withValues(alpha: 0.09)
                      : Colors.black.withValues(alpha: 0.04 + pulseVal * 0.02),
                  blurRadius: shadow,
                  offset: Offset(0, effectiveHovered ? 8 : 4 + pulseVal * 2),
                ),
                if (effectiveHovered)
                  BoxShadow(
                    color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.12),
                    blurRadius: 20,
                    spreadRadius: 1,
                  ),
              ],
            ),
            child: widget.child,
          ),
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════
// FADE + SLIDE entrance
// ══════════════════════════════════════════════
class FadeSlideIn extends StatefulWidget {
  final Widget child;
  final Duration delay;
  final Duration duration;
  final Offset offset;
  final double beginOpacity;

  const FadeSlideIn({
    super.key,
    required this.child,
    this.delay = Duration.zero,
    this.duration = const Duration(milliseconds: 600),
    this.offset = const Offset(0, 24),
    this.beginOpacity = 0,
  });

  @override
  State<FadeSlideIn> createState() => _FadeSlideInState();
}

class _FadeSlideInState extends State<FadeSlideIn> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _opacity;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: widget.duration);
    _opacity = Tween<double>(begin: widget.beginOpacity, end: 1).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic),
    );
    _slide = Tween<Offset>(begin: widget.offset, end: Offset.zero).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic),
    );
    Future.delayed(widget.delay, () {
      if (mounted) _ctrl.forward();
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (context, child) => Opacity(
        opacity: _opacity.value,
        child: Transform.translate(
          offset: Offset(_slide.value.dx, _slide.value.dy),
          child: child,
        ),
      ),
      child: widget.child,
    );
  }
}

// ══════════════════════════════════════════════
// STAGGERED LIST — animates children one by one
// ══════════════════════════════════════════════
class StaggeredColumn extends StatelessWidget {
  final List<Widget> children;
  final Duration stagger;
  final Duration duration;
  final Offset offset;

  const StaggeredColumn({
    super.key,
    required this.children,
    this.stagger = const Duration(milliseconds: 90),
    this.duration = const Duration(milliseconds: 500),
    this.offset = const Offset(0, 20),
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (int i = 0; i < children.length; i++)
          FadeSlideIn(
            delay: stagger * i,
            duration: duration,
            offset: offset,
            child: children[i],
          ),
      ],
    );
  }
}

class StaggeredWrap extends StatelessWidget {
  final List<Widget> children;
  final Duration stagger;
  final double spacing;
  final double runSpacing;

  const StaggeredWrap({
    super.key,
    required this.children,
    this.stagger = const Duration(milliseconds: 100),
    this.spacing = 16,
    this.runSpacing = 16,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: spacing,
      runSpacing: runSpacing,
      children: [
        for (int i = 0; i < children.length; i++)
          FadeSlideIn(
            delay: stagger * i,
            offset: const Offset(0, 24),
            child: children[i],
          ),
      ],
    );
  }
}

// ══════════════════════════════════════════════
// HOVER BUTTON — scale + glow
// ══════════════════════════════════════════════
class HoverButton extends StatefulWidget {
  final Widget child;
  final VoidCallback? onPressed;
  final Duration duration;

  const HoverButton({super.key, required this.child, this.onPressed, this.duration = const Duration(milliseconds: 180)});

  @override
  State<HoverButton> createState() => _HoverButtonState();
}

class _HoverButtonState extends State<HoverButton> with SingleTickerProviderStateMixin {
  bool _hovered = false;
  late final AnimationController _pulseCtrl;
  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 2000))..repeat(reverse: true);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final w = MediaQuery.maybeOf(context)?.size.width ?? 800;
      if (w < 700) {
        Future.doWhile(() async {
          if (!mounted) return false;
          await Future.delayed(const Duration(milliseconds: 2600));
          if (!mounted) return false;
          setState(() => _hovered = true);
          await Future.delayed(const Duration(milliseconds: 550));
          if (!mounted) return false;
          setState(() => _hovered = false);
          return mounted;
        });
      }
    });
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.maybeOf(context)?.size.width != null && MediaQuery.of(context).size.width < 700;
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTapDown: (_) => setState(() => _hovered = true),
        onTapUp: (_) async {
          await Future.delayed(const Duration(milliseconds: 400));
          if (mounted) setState(() => _hovered = false);
        },
        onTapCancel: () => setState(() => _hovered = false),
        child: AnimatedScale(
          scale: _hovered ? 1.04 : 1.0,
          duration: widget.duration,
          curve: Curves.easeOutCubic,
          child: AnimatedContainer(
            duration: widget.duration,
            decoration: BoxDecoration(
              boxShadow: _hovered
                  ? [BoxShadow(color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.25), blurRadius: 16, offset: const Offset(0, 6))]
                  : isMobile
                      ? [BoxShadow(color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.08 + 0.04 * _pulseCtrl.value), blurRadius: 10)]
                      : [],
              borderRadius: BorderRadius.circular(16),
            ),
            child: widget.child,
          ),
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════
// PULSE DOT — for live indicators
// ══════════════════════════════════════════════
class PulseDot extends StatefulWidget {
  final Color color;
  final double size;
  const PulseDot({super.key, required this.color, this.size = 10});
  @override
  State<PulseDot> createState() => _PulseDotState();
}

class _PulseDotState extends State<PulseDot> with SingleTickerProviderStateMixin {
  late final AnimationController _c;
  @override
  void initState() {
    super.initState();
    _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200))..repeat();
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _c,
      builder: (_, __) => Container(
        width: widget.size,
        height: widget.size,
        decoration: BoxDecoration(
          color: widget.color,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: widget.color.withValues(alpha: 0.5 * (1 - _c.value)),
              blurRadius: 8 * _c.value,
              spreadRadius: 2 * _c.value,
            ),
          ],
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════
// SHIMMER PLACEHOLDER
// ══════════════════════════════════════════════
class ShimmerBox extends StatefulWidget {
  final double width;
  final double height;
  final BorderRadius borderRadius;
  const ShimmerBox({super.key, required this.width, required this.height, this.borderRadius = const BorderRadius.all(Radius.circular(12))});
  @override
  State<ShimmerBox> createState() => _ShimmerBoxState();
}

class _ShimmerBoxState extends State<ShimmerBox> with SingleTickerProviderStateMixin {
  late final AnimationController _c;
  @override
  void initState() {
    super.initState();
    _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 1400))..repeat();
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return AnimatedBuilder(
      animation: _c,
      builder: (_, __) => Container(
        width: widget.width,
        height: widget.height,
        decoration: BoxDecoration(
          borderRadius: widget.borderRadius,
          gradient: LinearGradient(
            begin: Alignment(-1 + 2 * _c.value, 0),
            end: Alignment(1 + 2 * _c.value, 0),
            colors: isDark
                ? [const Color(0xFF1B3A5C), const Color(0xFF23456B), const Color(0xFF1B3A5C)]
                : [const Color(0xFFF3F4F6), const Color(0xFFE5E7EB), const Color(0xFFF3F4F6)],
          ),
        ),
      ),
    );
  }
}
