import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../core/app_theme.dart';

// ══════════════════════════════════════════════
// TILT + GLOW + SCALE CARD — wow hover
// ══════════════════════════════════════════════
class TiltGlowCard extends StatefulWidget {
  final Widget child;
  final Color glowColor;
  final double maxTilt; // degrees
  final double hoverScale;
  final BorderRadius borderRadius;
  final bool enableGlow;
  final bool enableTilt;

  const TiltGlowCard({
    super.key,
    required this.child,
    this.glowColor = AppColors.tealPrimary,
    this.maxTilt = 6,
    this.hoverScale = 1.03,
    this.borderRadius = const BorderRadius.all(Radius.circular(20)),
    this.enableGlow = true,
    this.enableTilt = true,
  });

  @override
  State<TiltGlowCard> createState() => _TiltGlowCardState();
}

class _TiltGlowCardState extends State<TiltGlowCard> with SingleTickerProviderStateMixin {
  bool _hovered = false;
  Offset _mousePos = Offset.zero;
  final _key = GlobalKey();
  late final AnimationController _pulseCtrl;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 2200))..repeat(reverse: true);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final w = MediaQuery.maybeOf(context)?.size.width ?? 800;
      if (w < 700) {
        Future.doWhile(() async {
          if (!mounted) return false;
          await Future.delayed(Duration(milliseconds: 2500 + (hashCode % 1500)));
          if (!mounted) return false;
          setState(() {
            _hovered = true;
            _mousePos = Offset((math.Random().nextDouble() - 0.5) * 0.6, (math.Random().nextDouble() - 0.5) * 0.6);
          });
          await Future.delayed(const Duration(milliseconds: 700));
          if (!mounted) return false;
          setState(() {
            _hovered = false;
            _mousePos = Offset.zero;
          });
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

  void _onHover(PointerEvent e) {
    if (!widget.enableTilt) return;
    final box = _key.currentContext?.findRenderObject() as RenderBox?;
    if (box == null) return;
    final pos = box.globalToLocal(e.position);
    final size = box.size;
    final dx = (pos.dx / size.width - 0.5) * 2; // -1 to 1
    final dy = (pos.dy / size.height - 0.5) * 2;
    setState(() => _mousePos = Offset(dx, dy));
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.maybeOf(context)?.size.width != null && MediaQuery.of(context).size.width < 700;
    final pulse = isMobile ? _pulseCtrl.value : 0.0;
    final effectiveHovered = _hovered || (isMobile && pulse > 0.6);
    final tiltX = effectiveHovered ? -_mousePos.dy * widget.maxTilt * math.pi / 180 : 0.0;
    final tiltY = effectiveHovered ? _mousePos.dx * widget.maxTilt * math.pi / 180 : 0.0;
    final scale = effectiveHovered ? widget.hoverScale : 1.0 + (isMobile ? pulse * 0.008 : 0);
    return MouseRegion(
      key: _key,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() {
        _hovered = false;
        _mousePos = Offset.zero;
      }),
      onHover: _onHover,
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTapDown: (_) => setState(() => _hovered = true),
        onTapUp: (_) async {
          await Future.delayed(const Duration(milliseconds: 500));
          if (mounted) setState(() => _hovered = false);
        },
        onTapCancel: () => setState(() => _hovered = false),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeOutCubic,
          transform: Matrix4.identity()
            ..setEntry(3, 2, 0.001)
            ..rotateX(tiltX)
            ..rotateY(tiltY)
            ..scale(scale),
          transformAlignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: widget.borderRadius,
            boxShadow: [
              BoxShadow(
                color: effectiveHovered ? widget.glowColor.withValues(alpha: 0.18) : Colors.black.withValues(alpha: 0.04 + pulse * 0.02),
                blurRadius: effectiveHovered ? 28 : 12 + pulse * 6,
                offset: Offset(0, effectiveHovered ? 14 : 4 + pulse * 2),
                spreadRadius: effectiveHovered ? 2 : 0,
              ),
              if (effectiveHovered && widget.enableGlow)
                BoxShadow(
                color: widget.glowColor.withValues(alpha: 0.12),
                blurRadius: 40,
                spreadRadius: -4,
              ),
          ],
        ),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 350),
          decoration: BoxDecoration(
            borderRadius: widget.borderRadius,
            border: _hovered && widget.enableGlow
                ? Border.all(color: widget.glowColor.withValues(alpha: 0.35), width: 1.2)
                : null,
          ),
          child: widget.child,
        ),
      ),
      ),
    );
  }
}

// ══════════════════════════════════════════════
// MAGNETIC BUTTON — follows cursor
// ══════════════════════════════════════════════
class MagneticButton extends StatefulWidget {
  final Widget child;
  final double strength;
  const MagneticButton({super.key, required this.child, this.strength = 0.18});
  @override
  State<MagneticButton> createState() => _MagneticButtonState();
}

class _MagneticButtonState extends State<MagneticButton> with SingleTickerProviderStateMixin {
  Offset _offset = Offset.zero;
  bool _hovered = false;
  final _key = GlobalKey();
  late final AnimationController _pulseCtrl;
  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1800))..repeat(reverse: true);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final w = MediaQuery.maybeOf(context)?.size.width ?? 800;
      if (w < 700) {
        Future.doWhile(() async {
          if (!mounted) return false;
          await Future.delayed(Duration(milliseconds: 2800 + (hashCode % 1200)));
          if (!mounted) return false;
          setState(() => _hovered = true);
          await Future.delayed(const Duration(milliseconds: 600));
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

  void _onHover(PointerEvent e) {
    final box = _key.currentContext?.findRenderObject() as RenderBox?;
    if (box == null) return;
    final center = box.size.center(Offset.zero);
    final pos = box.globalToLocal(e.position);
    final delta = pos - center;
    setState(() => _offset = delta * widget.strength);
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.maybeOf(context)?.size.width != null && MediaQuery.of(context).size.width < 700;
    return MouseRegion(
      key: _key,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() {
        _hovered = false;
        _offset = Offset.zero;
      }),
      onHover: _onHover,
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTapDown: (_) => setState(() => _hovered = true),
        onTapUp: (_) async {
          await Future.delayed(const Duration(milliseconds: 400));
          if (mounted) setState(() => _hovered = false);
        },
        onTapCancel: () => setState(() => _hovered = false),
        child: AnimatedContainer(
          duration: Duration(milliseconds: _hovered ? 100 : 350),
          curve: _hovered ? Curves.linear : Curves.elasticOut,
          transform: Matrix4.translationValues(_offset.dx, _offset.dy, 0),
          child: AnimatedScale(
            scale: _hovered ? 1.05 : 1.0 + (isMobile ? _pulseCtrl.value * 0.015 : 0),
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOutCubic,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                boxShadow: _hovered
                    ? [BoxShadow(color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3), blurRadius: 20, offset: const Offset(0, 8))]
                    : isMobile
                        ? [BoxShadow(color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.10 + 0.06 * _pulseCtrl.value), blurRadius: 12)]
                        : [],
              ),
              child: widget.child,
            ),
          ),
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════
// FLOATING — gentle up/down
// ══════════════════════════════════════════════
class Floating extends StatefulWidget {
  final Widget child;
  final double amplitude;
  final Duration duration;
  final double delay;
  const Floating({super.key, required this.child, this.amplitude = 8, this.duration = const Duration(milliseconds: 2800), this.delay = 0});
  @override
  State<Floating> createState() => _FloatingState();
}

class _FloatingState extends State<Floating> with SingleTickerProviderStateMixin {
  late final AnimationController _c;
  late final Animation<double> _anim;
  @override
  void initState() {
    super.initState();
    _c = AnimationController(vsync: this, duration: widget.duration)..repeat(reverse: true);
    _anim = Tween<double>(begin: -widget.amplitude, end: widget.amplitude).animate(CurvedAnimation(parent: _c, curve: Curves.easeInOutSine));
    if (widget.delay > 0) {
      Future.delayed(Duration(milliseconds: (widget.delay * 1000).toInt()), () {
        if (mounted) _c.forward();
      });
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, child) => Transform.translate(offset: Offset(0, _anim.value), child: child),
      child: widget.child,
    );
  }
}

// ══════════════════════════════════════════════
// SHIMMER GRADIENT BORDER — animated
// ══════════════════════════════════════════════
class AnimatedGradientBorder extends StatefulWidget {
  final Widget child;
  final BorderRadius borderRadius;
  final double strokeWidth;
  const AnimatedGradientBorder({super.key, required this.child, this.borderRadius = const BorderRadius.all(Radius.circular(20)), this.strokeWidth = 1.5});
  @override
  State<AnimatedGradientBorder> createState() => _AnimatedGradientBorderState();
}

class _AnimatedGradientBorderState extends State<AnimatedGradientBorder> with SingleTickerProviderStateMixin {
  late final AnimationController _c;
  @override
  void initState() {
    super.initState();
    _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 2800))..repeat();
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
      builder: (_, child) => Container(
        decoration: BoxDecoration(
          borderRadius: widget.borderRadius,
          gradient: SweepGradient(
            colors: const [AppColors.tealPrimary, AppColors.peachStart, AppColors.tealLight, AppColors.tealPrimary],
            stops: const [0.0, 0.33, 0.66, 1.0],
            transform: GradientRotation(_c.value * 2 * math.pi),
          ),
        ),
        padding: EdgeInsets.all(widget.strokeWidth),
        child: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: widget.borderRadius - BorderRadius.circular(widget.strokeWidth),
          ),
          child: child,
        ),
      ),
      child: widget.child,
    );
  }
}

// ══════════════════════════════════════════════
// ICON HOVER — rotates + scales
// ══════════════════════════════════════════════
class HoverIcon extends StatefulWidget {
  final IconData icon;
  final Color color;
  final double size;
  final Color bgColor;
  const HoverIcon({super.key, required this.icon, required this.color, this.size = 28, required this.bgColor});
  @override
  State<HoverIcon> createState() => _HoverIconState();
}

class _HoverIconState extends State<HoverIcon> with SingleTickerProviderStateMixin {
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
          await Future.delayed(Duration(milliseconds: 3000 + (hashCode % 1500)));
          if (!mounted) return false;
          setState(() => _hovered = true);
          await Future.delayed(const Duration(milliseconds: 600));
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
    final pulse = isMobile ? _pulseCtrl.value : 0.0;
    final effectiveHovered = _hovered || (isMobile && pulse > 0.7);
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
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutBack,
          padding: EdgeInsets.all(effectiveHovered ? 16 : 14),
          decoration: BoxDecoration(
            color: effectiveHovered ? widget.color.withValues(alpha: 0.18) : widget.bgColor.withValues(alpha: 0.12 + pulse * 0.04),
            borderRadius: BorderRadius.circular(14),
            boxShadow: effectiveHovered ? [BoxShadow(color: widget.color.withValues(alpha: 0.25), blurRadius: 16)] : isMobile ? [BoxShadow(color: widget.color.withValues(alpha: 0.08 + pulse * 0.08), blurRadius: 8 + pulse * 6)] : [],
          ),
          child: AnimatedRotation(
            turns: effectiveHovered ? 0.06 : 0,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOutBack,
            child: AnimatedScale(
              scale: effectiveHovered ? 1.15 : 1.0 + pulse * 0.04,
              duration: const Duration(milliseconds: 300),
              child: Icon(widget.icon, color: widget.color, size: widget.size),
            ),
          ),
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════
// GRADIENT ORBS — background
// ══════════════════════════════════════════════
class GradientOrbs extends StatelessWidget {
  const GradientOrbs({super.key});
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          top: -60,
          right: -40,
          child: _Orb(color: AppColors.tealPrimary.withValues(alpha: 0.12), size: 260),
        ),
        Positioned(
          bottom: -40,
          left: -30,
          child: _Orb(color: AppColors.peachStart.withValues(alpha: 0.10), size: 200),
        ),
      ],
    );
  }
}

class _Orb extends StatefulWidget {
  final Color color;
  final double size;
  const _Orb({required this.color, required this.size});
  @override
  State<_Orb> createState() => _OrbState();
}

class _OrbState extends State<_Orb> with SingleTickerProviderStateMixin {
  late final AnimationController _c;
  @override
  void initState() {
    super.initState();
    _c = AnimationController(vsync: this, duration: Duration(milliseconds: 3500 + (widget.size.toInt() % 1000)))..repeat(reverse: true);
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
      builder: (_, __) => Transform.scale(
        scale: 1 + 0.08 * math.sin(_c.value * 2 * math.pi),
        child: Container(
          width: widget.size,
          height: widget.size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(colors: [widget.color, Colors.transparent]),
          ),
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════
// NEON GLOW BUTTON
// ══════════════════════════════════════════════
class NeonButton extends StatefulWidget {
  final String label;
  final IconData icon;
  final VoidCallback? onPressed;
  final Color color;
  const NeonButton({super.key, required this.label, required this.icon, this.onPressed, this.color = AppColors.tealPrimary});
  @override
  State<NeonButton> createState() => _NeonButtonState();
}

class _NeonButtonState extends State<NeonButton> {
  bool _hovered = false;
  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(100),
          boxShadow: _hovered
              ? [
                  BoxShadow(color: widget.color.withValues(alpha: 0.4), blurRadius: 24, spreadRadius: 2),
                  BoxShadow(color: widget.color.withValues(alpha: 0.15), blurRadius: 40, spreadRadius: -4),
                ]
              : [BoxShadow(color: widget.color.withValues(alpha: 0.2), blurRadius: 12)],
        ),
        child: FilledButton.icon(
          onPressed: widget.onPressed,
          icon: AnimatedRotation(turns: _hovered ? 0.05 : 0, duration: const Duration(milliseconds: 250), child: Icon(widget.icon, size: 20)),
          label: Text(widget.label, style: const TextStyle(fontWeight: FontWeight.w800)),
          style: FilledButton.styleFrom(
            padding: EdgeInsets.symmetric(horizontal: _hovered ? 34 : 28, vertical: 16),
            backgroundColor: widget.color,
          ),
        ),
      ),
    );
  }
}
