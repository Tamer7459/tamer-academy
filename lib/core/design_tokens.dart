import 'package:flutter/material.dart';

/// ═════════════════════════════════════════════════════════════════════════════
/// Tamer Academy — Design Tokens
/// "أكاديمية الأخوية" — Assassin's Creed: Brotherhood + Terminal
/// ممنوع أي لون أو رقم سحري داخل الويدجتس.
/// ═════════════════════════════════════════════════════════════════════════════

class DTokens {
  DTokens._();

  // ── Spacing (8pt grid) ──
  static const double spaceXs = 4;
  static const double spaceSm = 8;
  static const double spaceMd = 16;
  static const double spaceLg = 24;
  static const double spaceXl = 32;
  static const double spaceXxl = 48;
  static const double spaceMax = 64;

  // ── Border Radius (small, notched — Animus style) ──
  static const Radius radiusXs = Radius.circular(2);
  static const Radius radiusSm = Radius.circular(4);
  static const Radius radiusMd = Radius.circular(8);
  static const Radius radiusLg = Radius.circular(12);
  static const Radius radiusFull = Radius.circular(9999);

  static const BorderRadius borderRadiusXs = BorderRadius.all(radiusXs);
  static const BorderRadius borderRadiusSm = BorderRadius.all(radiusSm);
  static const BorderRadius borderRadiusMd = BorderRadius.all(radiusMd);
  static const BorderRadius borderRadiusLg = BorderRadius.all(radiusLg);
  static const BorderRadius borderRadiusFull = BorderRadius.all(radiusFull);

  // ── Animation durations ──
  static const Duration durFast = Duration(milliseconds: 150);
  static const Duration durNormal = Duration(milliseconds: 300);
  static const Duration durSlow = Duration(milliseconds: 500);
  static const Duration durCinematic = Duration(milliseconds: 800);

  static const Curve curveStandard = Curves.easeOutCubic;
  static const Curve curveCinematic = Curves.easeOutQuart;

  // ── Layout dimensions ──
  static const double maxContentWidth = 1100;
  static const double sidebarWidth = 248;
  static const double minTouchTarget = 48;
  static const double heroMinHeight = 560;
  static const double headerHeight = 56;
  static const double maxReadingWidth = 720;

  // ── Brand colors (for easy reference) ──
  static const Color crimson = Color(0xFFC1232C);
  static const Color crimsonLight = Color(0xFFE5384A);
  static const Color crimsonText = Color(0xFFFF5C6A);
  static const Color gold = Color(0xFFD4A64A);
  static const Color eagle = Color(0xFF5CC8FF);
  static const Color terracotta = Color(0xFFB5532E);
  static const Color ochre = Color(0xFFC98F3B);
}

/// ═════════════════════════════════════════════════════════════════════════════
/// ألوان الوضع الداكن — "Animus Night"
/// ═════════════════════════════════════════════════════════════════════════════
class DColorsDark {
  DColorsDark._();

  // Backgrounds
  static const Color background = Color(0xFF0B0B0D);
  static const Color backgroundSecondary = Color(0xFF121214);
  static const Color surface = Color(0xFF17171A);
  static const Color surfaceElevated = Color(0xFF1E1E22);
  static const Color surfaceGlass = Color(0xFF1A1A1E);

  // Text
  static const Color onSurface = Color(0xFFEDE6D6);       // عاجي
  static const Color onSurfaceDim = Color(0xFFA8A39A);    // ثانوي
  static const Color onSurfaceMuted = Color(0xFF6B6760);   // muted

  // Brand (Crimson)
  static const Color brand = Color(0xFFC1232C);
  static const Color brandLight = Color(0xFFE5384A);
  static const Color brandText = Color(0xFFFF5C6A);       // نص أحمر صغير

  // Accent (Gold)
  static const Color gold = Color(0xFFD4A64A);
  static const Color goldDim = Color(0xFFB8892F);

  // Eagle Vision (Blue)
  static const Color eagle = Color(0xFF5CC8FF);
  static const Color eagleDim = Color(0xFF3A9FD4);

  // Tertiary (Terracotta / Ochre)
  static const Color terracotta = Color(0xFFB5532E);
  static const Color ochre = Color(0xFFC98F3B);

  // Semantic
  static const Color success = Color(0xFF6FBF8E);
  static const Color warning = Color(0xFFD4A64A);
  static const Color danger = Color(0xFFFF6A3D);          // برتقالي أحمر (مع أيقونة دائماً)
  static const Color info = Color(0xFF5CC8FF);

  // Borders
  static const Color border = Color(0xFF2D2C2E);
  static const Color borderSoft = Color(0xFF252426);
}

/// ═════════════════════════════════════════════════════════════════════════════
/// ألوان الوضع الفاتح — "Animus White Room / Roman Parchment"
/// ═════════════════════════════════════════════════════════════════════════════
class DColorsLight {
  DColorsLight._();

  // Backgrounds
  static const Color background = Color(0xFFF4F1EA);
  static const Color backgroundSecondary = Color(0xFFECE7DB);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceElevated = Color(0xFFF0ECE2);
  static const Color surfaceGlass = Color(0xFFE8E3D6);

  // Text
  static const Color onSurface = Color(0xFF1B1A1C);
  static const Color onSurfaceDim = Color(0xFF5E5A52);
  static const Color onSurfaceMuted = Color(0xFF8A8578);

  // Brand (Crimson — darker for contrast)
  static const Color brand = Color(0xFFB01E28);
  static const Color brandLight = Color(0xFFD4303A);
  static const Color brandText = Color(0xFFB01E28);

  // Accent (Gold)
  static const Color gold = Color(0xFF8A5F10);
  static const Color goldDim = Color(0xFF6B4A0C);

  // Eagle Vision (Blue)
  static const Color eagle = Color(0xFF1F6FB8);
  static const Color eagleDim = Color(0xFF175A96);

  // Tertiary
  static const Color terracotta = Color(0xFF9A4525);
  static const Color ochre = Color(0xFFA07020);

  // Semantic
  static const Color success = Color(0xFF2E7D52);
  static const Color warning = Color(0xFF8A5F10);
  static const Color danger = Color(0xFFD44020);
  static const Color info = Color(0xFF1F6FB8);

  // Borders
  static const Color border = Color(0xFFD9D2C3);
  static const Color borderSoft = Color(0xFFE5DFD2);
}

/// ═════════════════════════════════════════════════════════════════════════════
/// أنماط الظل (Shadows) — دافئة
/// ═════════════════════════════════════════════════════════════════════════════
class DShadows {
  DShadows._();

  static const List<BoxShadow> cardSoft = [
    BoxShadow(color: Color(0x0F1B1A1C), blurRadius: 12, offset: Offset(0, 4)),
  ];

  static const List<BoxShadow> cardElevated = [
    BoxShadow(color: Color(0x1A1B1A1C), blurRadius: 24, offset: Offset(0, 8)),
  ];

  static const List<BoxShadow> crimsonGlow = [
    BoxShadow(color: Color(0x33C1232C), blurRadius: 20, offset: Offset(0, 0)),
  ];

  static const List<BoxShadow> eagleGlow = [
    BoxShadow(color: Color(0x335CC8FF), blurRadius: 16, offset: Offset(0, 0)),
  ];

  static const List<BoxShadow> goldGlow = [
    BoxShadow(color: Color(0x33D4A64A), blurRadius: 16, offset: Offset(0, 0)),
  ];
}

/// ═════════════════════════════════════════════════════════════════════════════
/// تدرجات (Gradients)
/// ═════════════════════════════════════════════════════════════════════════════
class DGradients {
  DGradients._();

  static const LinearGradient heroMeshDark = LinearGradient(
    colors: [Color(0xFF0B0B0D), Color(0xFF121214), Color(0xFF17171A)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient heroMeshLight = LinearGradient(
    colors: [Color(0xFFF4F1EA), Color(0xFFECE7DB), Color(0xFFE5DFD2)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient crimsonGlow = LinearGradient(
    colors: [Color(0xFFC1232C), Color(0xFFE5384A)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient eagleGlow = LinearGradient(
    colors: [Color(0xFF5CC8FF), Color(0xFF3A9FD4)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient goldGlow = LinearGradient(
    colors: [Color(0xFFD4A64A), Color(0xFFB8892F)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

/// ═════════════════════════════════════════════════════════════════════════════
/// أنماط الخطوط
/// ═════════════════════════════════════════════════════════════════════════════
class DTypography {
  DTypography._();

  static const String heading = 'El Messiri';
  static const String headingFallback = 'Cairo';
  static const String body = 'IBM Plex Sans Arabic';
  static const String mono = 'JetBrains Mono';
  static const String monoFallback = 'monospace';
}
