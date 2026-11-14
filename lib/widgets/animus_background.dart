import 'package:flutter/material.dart';

import '../core/design_tokens.dart';

/// ═════════════════════════════════════════════════════════════════════════════
/// Animus Background — شبكة خطوط رفيعة + vignette + توهج أحمر خفيف
/// ═════════════════════════════════════════════════════════════════════════════

class AnimusBackground extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Stack(
      children: [
        // Base gradient
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              gradient: isDark
                  ? DGradients.heroMeshDark
                  : DGradients.heroMeshLight,
            ),
          ),
        ),
        // Grid lines
        if (showGrid)
          Positioned.fill(
            child: CustomPaint(
              painter: _GridPainter(
                color: isDark
                    ? const Color(0xFF2D2C2E).withValues(alpha: 0.3)
                    : const Color(0xFFD9D2C3).withValues(alpha: 0.4),
                spacing: 40,
              ),
            ),
          ),
        // Red glow (top-right)
        if (showGlow)
          Positioned(
            top: -100,
            right: -100,
            child: Container(
              width: 400,
              height: 400,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFFC1232C).withValues(alpha: isDark ? 0.08 : 0.05),
                    Colors.transparent,
                  ],
                  stops: const [0.0, 0.7],
                ),
              ),
            ),
          ),
        // Vignette
        if (showVignette)
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  colors: [
                    Colors.transparent,
                    (isDark ? const Color(0xFF0B0B0D) : const Color(0xFFF4F1EA))
                        .withValues(alpha: 0.6),
                  ],
                  stops: const [0.5, 1.0],
                ),
              ),
            ),
          ),
        // Content
        child,
      ],
    );
  }
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
