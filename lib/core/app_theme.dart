import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'design_tokens.dart';

/// ═════════════════════════════════════════════════════════════════════════════
/// AppColors — backward compatibility (mapped to new palette)
/// ═════════════════════════════════════════════════════════════════════════════
class AppColors {
  AppColors._();

  // Mapped to new Crimson palette
  static const Color tealDeep = Color(0xFFC1232C);
  static const Color tealPrimary = Color(0xFFC1232C);
  static const Color tealLight = Color(0xFFE5384A);
  static const Color tealPale = Color(0xFF2A1518);

  // Mapped to new Gold
  static const Color peachStart = Color(0xFFD4A64A);
  static const Color peachEnd = Color(0xFFB8892F);
  static const Color peachLight = Color(0xFF2A2518);
  static const Color warmOrange = Color(0xFFD4A64A);
  static const Color coral = Color(0xFFFF6A3D);

  // Mapped to new neutrals
  static const Color navyDark = Color(0xFF0B0B0D);
  static const Color navyText = Color(0xFFEDE6D6);
  static const Color grayDark = Color(0xFFA8A39A);
  static const Color grayMedium = Color(0xFF8A8578);
  static const Color grayLight = Color(0xFF6B6760);
  static const Color grayVeryLight = Color(0xFF1E1E22);
  static const Color offWhite = Color(0xFFF4F1EA);
  static const Color white = Color(0xFFFFFFFF);

  // Semantic
  static const Color success = Color(0xFF6FBF8E);
  static const Color danger = Color(0xFFFF6A3D);
  static const Color warning = Color(0xFFD4A64A);
  static const Color star = Color(0xFFD4A64A);
  static const Color info = Color(0xFF5CC8FF);

  // Backward compat aliases
  static const Color primary = tealPrimary;
  static const Color secondary = Color(0xFFD4A64A);
  static const Color accent = Color(0xFF5CC8FF);
  static const Color navyPrimary = tealDeep;
  static const Color goldPrimary = Color(0xFFD4A64A);
  static const Color goldLight = Color(0xFFB8892F);
  static const Color goldDark = Color(0xFF8A5F10);
  static const Color cyanAccent = Color(0xFF5CC8FF);
  static const Color creamWhite = offWhite;
  static const Color navyDeep = navyDark;

  static const Color darkBg = Color(0xFF0B0B0D);
  static const Color darkSurface = Color(0xFF17171A);
  static const Color darkCard = Color(0xFF1E1E22);
  static const Color darkElevated = Color(0xFF252426);
  static const Color darkTextDim = Color(0xFFA8A39A);
}

/// ═════════════════════════════════════════════════════════════════════════════
/// AppTheme — يُعتمد بالكامل على Design Tokens.
/// "أكاديمية الأخوية" — Crimson + Gold + Eagle Vision
/// ═════════════════════════════════════════════════════════════════════════════

class AppTheme {
  AppTheme._();

  static ThemeData light() => _build(Brightness.light, false);
  static ThemeData dark() => _build(Brightness.dark, true);

  // Backward-compat helpers
  static Color accent(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? DColorsDark.brand : DColorsLight.brand;
  }

  static Color track(BuildContext context, String track) {
    if (track == 'web' || track == '1787326651194000') return accent(context);
    if (track == 'ai_automation' || track == 'ai' || track == '1794165775204000') {
      return const Color(0xFF8B5CF6);
    }
    return DColorsDark.brand; // fallback to crimson
  }

  static ScrollBehavior get scrollBehavior => const _AppScrollBehavior();

  static ThemeData _build(Brightness brightness, bool isDark) {
    // Local color variables (avoid dynamic access in minified JS)
    final Color brand = isDark ? DColorsDark.brand : DColorsLight.brand;
    final Color brandLight = isDark ? DColorsDark.brandLight : DColorsLight.brandLight;
    final Color brandText = isDark ? DColorsDark.brandText : DColorsLight.brandText;
    final Color gold = isDark ? DColorsDark.gold : DColorsLight.gold;
    final Color eagle = isDark ? DColorsDark.eagle : DColorsLight.eagle;
    final Color terracotta = isDark ? DColorsDark.terracotta : DColorsLight.terracotta;
    final Color ochre = isDark ? DColorsDark.ochre : DColorsLight.ochre;
    final Color success = isDark ? DColorsDark.success : DColorsLight.success;
    final Color warning = isDark ? DColorsDark.warning : DColorsLight.warning;
    final Color danger = isDark ? DColorsDark.danger : DColorsLight.danger;
    final Color info = isDark ? DColorsDark.info : DColorsLight.info;
    final Color surface = isDark ? DColorsDark.surface : DColorsLight.surface;
    final Color surfaceElevated = isDark ? DColorsDark.surfaceElevated : DColorsLight.surfaceElevated;
    final Color onSurface = isDark ? DColorsDark.onSurface : DColorsLight.onSurface;
    final Color onSurfaceDim = isDark ? DColorsDark.onSurfaceDim : DColorsLight.onSurfaceDim;
    final Color onSurfaceMuted = isDark ? DColorsDark.onSurfaceMuted : DColorsLight.onSurfaceMuted;
    final Color border = isDark ? DColorsDark.border : DColorsLight.border;
    final Color borderSoft = isDark ? DColorsDark.borderSoft : DColorsLight.borderSoft;
    final Color background = isDark ? DColorsDark.background : DColorsLight.background;
    final Color backgroundSecondary = isDark ? DColorsDark.backgroundSecondary : DColorsLight.backgroundSecondary;

    final scheme = ColorScheme.fromSeed(
      seedColor: brand,
      brightness: brightness,
      primary: brand,
      onPrimary: isDark ? DColorsDark.background : DColorsLight.background,
      secondary: gold,
      onSecondary: isDark ? DColorsDark.background : DColorsLight.background,
      tertiary: eagle,
      onTertiary: isDark ? DColorsDark.background : DColorsLight.background,
      error: danger,
      onError: isDark ? DColorsDark.background : DColorsLight.background,
      surface: surface,
      onSurface: onSurface,
      onSurfaceVariant: onSurfaceDim,
      outline: border,
      outlineVariant: borderSoft,
      surfaceContainerHighest: surfaceElevated,
      inverseSurface: onSurface,
      onInverseSurface: surface,
      inversePrimary: brandLight,
    );

    final base = ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: background,
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: ZoomPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.windows: FadeUpwardsPageTransitionsBuilder(),
          TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.linux: FadeUpwardsPageTransitionsBuilder(),
        },
      ),
    );

    // Typography: El Messiri (headings) + IBM Plex Sans Arabic (body) + JetBrains Mono (code)
    final textTheme = GoogleFonts.ibmPlexSansArabicTextTheme(
      GoogleFonts.elMessiriTextTheme(base.textTheme),
    ).apply(
      bodyColor: onSurface,
      displayColor: onSurface,
    );

    return base.copyWith(
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        centerTitle: false,
        backgroundColor: Colors.transparent,
        foregroundColor: onSurface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        shadowColor: Colors.transparent,
        color: surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: DTokens.borderRadiusSm,
          side: BorderSide(color: border),
        ),
        margin: EdgeInsets.zero,
      ),
      chipTheme: base.chipTheme.copyWith(
        shape: RoundedRectangleBorder(borderRadius: DTokens.borderRadiusSm),
        side: BorderSide(color: borderSoft),
        labelStyle: TextStyle(color: onSurface, fontSize: 13),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceElevated,
        hintStyle: TextStyle(color: onSurfaceMuted, fontSize: 14),
        labelStyle: TextStyle(color: onSurfaceDim, fontSize: 14),
        prefixIconColor: onSurfaceMuted,
        suffixIconColor: onSurfaceMuted,
        border: OutlineInputBorder(
          borderRadius: DTokens.borderRadiusSm,
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: DTokens.borderRadiusSm,
          borderSide: BorderSide(color: border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: DTokens.borderRadiusSm,
          borderSide: const BorderSide(color: Color(0xFFC1232C), width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: DTokens.borderRadiusSm,
          borderSide: BorderSide(color: danger),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: brand,
          foregroundColor: isDark ? DColorsDark.background : DColorsLight.background,
          disabledBackgroundColor: borderSoft,
          disabledForegroundColor: onSurfaceMuted,
          elevation: 0,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(borderRadius: DTokens.borderRadiusSm),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: brand,
          side: BorderSide(color: brand.withValues(alpha: 0.5)),
          shape: RoundedRectangleBorder(borderRadius: DTokens.borderRadiusSm),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: surfaceElevated,
          foregroundColor: onSurface,
          elevation: 0,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(borderRadius: DTokens.borderRadiusSm),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: brand,
          shape: RoundedRectangleBorder(borderRadius: DTokens.borderRadiusSm),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: surfaceElevated,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: DTokens.borderRadiusMd),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: surfaceElevated,
        surfaceTintColor: Colors.transparent,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: onSurface,
        contentTextStyle: TextStyle(color: background, fontWeight: FontWeight.w600),
        actionTextColor: brand,
        shape: RoundedRectangleBorder(borderRadius: DTokens.borderRadiusSm),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shadowColor: Colors.transparent,
        indicatorColor: brand.withValues(alpha: 0.15),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return IconThemeData(color: brand);
          }
          return IconThemeData(color: onSurfaceMuted);
        }),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return TextStyle(fontWeight: FontWeight.w800, color: brand);
          }
          return TextStyle(fontWeight: FontWeight.w500, color: onSurfaceMuted);
        }),
      ),
      tabBarTheme: TabBarThemeData(
        indicatorColor: brand,
        labelColor: brand,
        unselectedLabelColor: onSurfaceMuted,
        dividerColor: Colors.transparent,
        labelStyle: const TextStyle(fontWeight: FontWeight.w700),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return background;
          return onSurfaceMuted;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return brand;
          return borderSoft;
        }),
        trackOutlineColor: WidgetStatePropertyAll(Colors.transparent),
      ),
      scrollbarTheme: ScrollbarThemeData(
        thumbVisibility: const WidgetStatePropertyAll(true),
        trackVisibility: const WidgetStatePropertyAll(true),
        thickness: const WidgetStatePropertyAll(8),
        radius: const Radius.circular(4),
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.hovered)) return brand;
          return brand.withValues(alpha: 0.6);
        }),
        trackColor: WidgetStatePropertyAll(border),
        trackBorderColor: const WidgetStatePropertyAll(Colors.transparent),
        interactive: true,
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: brand,
        linearTrackColor: borderSoft,
      ),
      dividerTheme: DividerThemeData(
        color: border,
        thickness: 1,
        space: 0,
      ),
      listTileTheme: ListTileThemeData(iconColor: onSurfaceMuted),
      expansionTileTheme: ExpansionTileThemeData(
        iconColor: onSurfaceMuted,
        collapsedIconColor: onSurfaceMuted,
        shape: const Border(),
        collapsedShape: const Border(),
        backgroundColor: surface,
      ),
      popupMenuTheme: PopupMenuThemeData(
        color: surfaceElevated,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: DTokens.borderRadiusSm),
      ),
      dropdownMenuTheme: DropdownMenuThemeData(
        menuStyle: MenuStyle(
          backgroundColor: WidgetStatePropertyAll(surfaceElevated),
          surfaceTintColor: WidgetStatePropertyAll(Colors.transparent),
          shape: WidgetStatePropertyAll(RoundedRectangleBorder(borderRadius: DTokens.borderRadiusSm)),
        ),
      ),
    );
  }
}

class _AppScrollBehavior extends MaterialScrollBehavior {
  const _AppScrollBehavior();
  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
        PointerDeviceKind.trackpad,
        PointerDeviceKind.stylus,
        PointerDeviceKind.unknown,
      };

  @override
  Widget buildScrollbar(BuildContext context, Widget child, ScrollableDetails details) {
    return Scrollbar(
      controller: details.controller,
      thumbVisibility: true,
      trackVisibility: true,
      interactive: true,
      thickness: 8,
      radius: const Radius.circular(4),
      child: child,
    );
  }
}
