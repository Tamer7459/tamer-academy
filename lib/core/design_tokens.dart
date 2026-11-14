import 'package:flutter/material.dart';

/// ═════════════════════════════════════════════════════════════════════════════
/// Tamer Academy — Design Tokens (المصدر الوحيد للألوان والمسافات والحركة)
/// ممنوع استخدام ألوان أو أرقام سحرية (hardcoded) داخل الويدجتس مباشرة.
/// ═════════════════════════════════════════════════════════════════════════════

class DTokens {
  DTokens._();

  // ═════════════════════════════════════════════════════════════════════════════
  // الألوان الأساسية (ستُ overrid في الثيم الفاتح والداكن عبر ColorScheme)
  // ═════════════════════════════════════════════════════════════════════════════

  static const Color brandTeal = Color(0xFF14B8A6);      // أساسي مميز (مشتق من الشعار)
  static const Color brandWarm = Color(0xFFF59E0B);      // ثانوي دافئ (ذهبي/كهرماني) للإبراز
  static const Color brandSoft = Color(0xFF06B6D4);      // تركواز ناعم للتدرجات

  // ═════════════════════════════════════════════════════════════════════════════
  // المسافات (Spacing)
  // ═════════════════════════════════════════════════════════════════════════════

  static const double spaceXs = 4;
  static const double spaceSm = 8;
  static const double spaceMd = 16;
  static const double spaceLg = 24;
  static const double spaceXl = 32;
  static const double spaceXxl = 48;
  static const double spaceMax = 64;

  // ═════════════════════════════════════════════════════════════════════════════
  // الزوايا (BorderRadius)
  // ═════════════════════════════════════════════════════════════════════════════

  static const Radius radiusSm = Radius.circular(10);
  static const Radius radiusMd = Radius.circular(16);
  static const Radius radiusLg = Radius.circular(24);
  static const Radius radiusXl = Radius.circular(32);
  static const Radius radiusFull = Radius.circular(9999);

  static const BorderRadius borderRadiusSm = BorderRadius.all(radiusSm);
  static const BorderRadius borderRadiusMd = BorderRadius.all(radiusMd);
  static const BorderRadius borderRadiusLg = BorderRadius.all(radiusLg);
  static const BorderRadius borderRadiusXl = BorderRadius.all(radiusXl);
  static const BorderRadius borderRadiusFull = BorderRadius.all(radiusFull);

  // ═════════════════════════════════════════════════════════════════════════════
  // مدة الحركة (Animation durations)
  // ═════════════════════════════════════════════════════════════════════════════

  static const Duration durFast = Duration(milliseconds: 200);
  static const Duration durNormal = Duration(milliseconds: 350);
  static const Duration durSlow = Duration(milliseconds: 600);
  static const Duration durCinematic = Duration(milliseconds: 900);

  // ═════════════════════════════════════════════════════════════════════════════
  // مدة الحركة (Curves)
  // ═════════════════════════════════════════════════════════════════════════════

  static const Curve curveStandard = Curves.easeOutCubic;
  static const Curve curveCinematic = Curves.easeOutQuart;
  static const Curve curveSpring = Curves.elasticOut;

  // ═════════════════════════════════════════════════════════════════════════════
  // أبعاد التخطيط (Layout)
  // ═════════════════════════════════════════════════════════════════════════════

  static const double maxContentWidth = 1100;   // عرض محتوى أقصى مريح للقراءة على الويب
  static const double sidebarWidth = 280;       // عرض الشريط الجانبي للويب العريض
  static const double minTouchTarget = 48;      // أدنى أهداف لمسة للوصول (48dp)
  static const double heroMinHeight = 560;      // أدنى ارتفاع للهيرو
  static const double headerHeight = 64;        // ارتفاع الهيدر
}

/// ألوان الثيم الداكن (الأساسي — يُعرض افتراضياً)
class DColorsDark {
  DColorsDark();

  static const Color background = Color(0xFF07090F);    // شبه سوداء متدرجة
  static const Color backgroundSecondary = Color(0xFF0E1424);
  static const Color surface = Color(0xFF111928);       // بطاقات / طبقاتurface
  static const Color surfaceElevated = Color(0xFF182338);
  static const Color surfaceGlass = Color(0xFF141D2E);  // طبقات زجاجية

  static const Color onSurface = Color(0xFFF5F7FA);
  static const Color onSurfaceDim = Color(0xFFB9C7DC);
  static const Color onSurfaceMuted = Color(0xFF7A8699);

  static const Color brand = Color(0xFF22D3EE);    // توهج تركواز في الداكن
  static const Color brandDim = Color(0xFF0891B2);
  static const Color brandGlow = Color(0xFF22D3EE);  // للتوهج الخارجي

  static const Color warm = Color(0xFFFBBF24);     // ذهبي دافئ
  static const Color warmDim = Color(0xFFF59E0B);

  static const Color border = Color(0xFF1F2A3C);
  static const Color borderSoft = Color(0xFF2A374C);

  static const Color success = Color(0xFF34D399);
  static const Color warning = Color(0xFFFBBF24);
  static const Color danger = Color(0xFFF87171);
  static const Color info = Color(0xFF60A5FA);
}

/// ألوان الثيم الفاتح (دافئ، فاخر بنفس مستوى الداكن)
class DColorsLight {
  DColorsLight();

  static const Color background = Color(0xFFFAFBFE);    // أبيض دافئ / عاجي
  static const Color backgroundSecondary = Color(0xFFF3F5F9);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceElevated = Color(0xFFF0F2F6);
  static const Color surfaceGlass = Color(0xFFE7EBF2);

  static const Color onSurface = Color(0xFF0F172A);
  static const Color onSurfaceDim = Color(0xFF475569);
  static const Color onSurfaceMuted = Color(0xFF94A3B8);

  static const Color brand = Color(0xFF0EA5E9);
  static const Color brandDim = Color(0xFF0891B2);
  static const Color brandGlow = Color(0xFF0EA5E9);

  static const Color warm = Color(0xFFF59E0B);
  static const Color warmDim = Color(0xFFD97706);

  static const Color border = Color(0xFFE2E8F0);
  static const Color borderSoft = Color(0xFFF1F5F9);

  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color danger = Color(0xFFEF4444);
  static const Color info = Color(0xFF3B82F6);
}

/// أنماط الظل والارتفاع (Shadows & Elevation)
class DShadows {
  DShadows._();

  static const List<BoxShadow> cardSoft = [
    BoxShadow(color: Color(0x0F000000), blurRadius: 16, offset: Offset(0, 8)),
  ];

  static const List<BoxShadow> cardElevated = [
    BoxShadow(color: Color(0x17000000), blurRadius: 24, offset: Offset(0, 12)),
    BoxShadow(color: Color(0x0A000000), blurRadius: 40, offset: Offset(0, 20)),
  ];

  static const List<BoxShadow> brandGlow = [
    BoxShadow(color: Color(0x330EA5E9), blurRadius: 24, offset: Offset(0, 0)),
  ];

  static const List<BoxShadow> warmGlow = [
    BoxShadow(color: Color(0x33F59E0B), blurRadius: 20, offset: Offset(0, 0)),
  ];
}

/// أنماط التدرج (Gradients) محسوبة
class DGradients {
  DGradients._();

  static const LinearGradient heroMesh = LinearGradient(
    colors: [Color(0xFF07090F), Color(0xFF0E1424), Color(0xFF111928)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient heroMeshLight = LinearGradient(
    colors: [Color(0xFFFAFBFE), Color(0xFFF3F5F9), Color(0xFFE7EBF2)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient brandGlow = LinearGradient(
    colors: [Color(0xFF22D3EE), Color(0xFF0EA5E9)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient cardSurfaceDark = LinearGradient(
    colors: [Color(0xFF111928), Color(0xFF0E1424)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

/// خصائص النص (Typography) — خط عربي حديث + إنجليزي/فرنسي
class DTypography {
  DTypography._();

  // عائلات الخطوط (تُستخدم عبر GoogleFonts)
  static const String arabic = 'Tajawal';
  static const String international = 'Inter';
  static const String mono = 'monospace';
}
