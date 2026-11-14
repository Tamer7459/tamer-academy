import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'design_tokens.dart';

/// ═════════════════════════════════════════════════════════════════════════════
/// AppTheme — يُعتمد بالكامل على Design Tokens.
/// कोई لون أو مسافة أو زاوية سحرية لا تُكتب داخل الويدجتس بعد الآن.
/// ═════════════════════════════════════════════════════════════════════════════

class AppTheme {
  AppTheme._();

  static ThemeData light() => _build(Brightness.light, DColorsLight());
  static ThemeData dark() => _build(Brightness.dark, DColorsDark());

  // للويب: سكرول دائم + أسهم لوحة المفاتيح
  static ScrollBehavior get scrollBehavior => const _AppScrollBehavior();

  static ThemeData _build(Brightness brightness, dynamic c) {
    final isDark = brightness == Brightness.dark;

    final scheme = ColorScheme(
      brightness: brightness,
      primary: c.brand,
      onPrimary: isDark ? DColorsDark.background : DColorsLight.background,
      primaryContainer: c.brand.withValues(alpha: 0.12),
      onPrimaryContainer: c.brandDim,
      secondary: c.warm,
      onSecondary: isDark ? DColorsDark.background : DColorsLight.background,
      secondaryContainer: c.warm.withValues(alpha: 0.12),
      onSecondaryContainer: c.warmDim,
      tertiary: c.brand,
      onTertiary: isDark ? DColorsDark.background : DColorsLight.background,
      error: c.danger,
      onError: isDark ? DColorsDark.background : DColorsLight.background,
      errorContainer: c.danger.withValues(alpha: 0.12),
      onErrorContainer: c.danger,
      surface: c.surface,
      onSurface: c.onSurface,
      surfaceContainerHighest: c.surfaceElevated,
      onSurfaceVariant: c.onSurfaceDim,
      outline: c.border,
      outlineVariant: c.borderSoft,
      shadow: const Color(0x1A000000),
      surfaceTint: c.brand.withValues(alpha: 0.15),
      inverseSurface: c.onSurface,
      onInverseSurface: c.surface,
      inversePrimary: c.brandDim,
      surfaceContainer: c.surface,
    );

    final base = ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: c.background,
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

    return base.copyWith(
      // Typography: خط عربي حديث + إنجليزي/فرنسي + Monospace للكود
      textTheme: GoogleFonts.interTextTheme(
        GoogleFonts.tajawalTextTheme(base.textTheme),
      ).apply(
        bodyColor: c.onSurface,
        displayColor: c.onSurface,
        fontFamily: DTypography.international,
      ),
      appBarTheme: AppBarTheme(
        centerTitle: false,
        backgroundColor: Colors.transparent,
        foregroundColor: c.onSurface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        shadowColor: Colors.transparent,
        color: c.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: DTokens.borderRadiusLg,
          side: BorderSide(color: c.border),
        ),
        margin: EdgeInsets.zero,
      ),
      chipTheme: base.chipTheme.copyWith(
        shape: RoundedRectangleBorder(borderRadius: DTokens.borderRadiusMd),
        side: BorderSide(color: c.borderSoft),
        labelStyle: TextStyle(color: c.onSurface, fontSize: 13),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: c.surfaceElevated,
        hintStyle: TextStyle(color: c.onSurfaceMuted, fontSize: 14),
        labelStyle: TextStyle(color: c.onSurfaceDim, fontSize: 14),
        prefixIconColor: c.onSurfaceMuted,
        suffixIconColor: c.onSurfaceMuted,
        border: OutlineInputBorder(
          borderRadius: DTokens.borderRadiusMd,
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: DTokens.borderRadiusMd,
          borderSide: BorderSide(color: c.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: DTokens.borderRadiusMd,
          borderSide: const BorderSide(color: DTokens.brandTeal, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: DTokens.borderRadiusMd,
          borderSide: BorderSide(color: c.danger),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: c.brand,
          foregroundColor: c.background,
          disabledBackgroundColor: c.borderSoft,
          disabledForegroundColor: c.onSurfaceMuted,
          elevation: 0,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(borderRadius: DTokens.borderRadiusMd),
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
          textStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: c.brand,
          side: BorderSide(color: c.brand.withValues(alpha: 0.4)),
          shape: RoundedRectangleBorder(borderRadius: DTokens.borderRadiusMd),
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
          textStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: c.surfaceElevated,
          foregroundColor: c.onSurface,
          elevation: 0,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(borderRadius: DTokens.borderRadiusMd),
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
          textStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: c.brand,
          shape: RoundedRectangleBorder(borderRadius: DTokens.borderRadiusMd),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: c.surfaceElevated,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: DTokens.borderRadiusXl),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: c.surfaceElevated,
        surfaceTintColor: Colors.transparent,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: c.onSurface,
        contentTextStyle: const TextStyle(color: DColorsLight.background, fontWeight: FontWeight.w600),
        actionTextColor: c.brand,
        shape: RoundedRectangleBorder(borderRadius: DTokens.borderRadiusMd),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: c.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shadowColor: Colors.transparent,
        indicatorColor: c.brand.withValues(alpha: 0.15),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return IconThemeData(color: c.brand);
          }
          return IconThemeData(color: c.onSurfaceMuted);
        }),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return TextStyle(fontWeight: FontWeight.w800, color: c.brand);
          }
          return TextStyle(fontWeight: FontWeight.w500, color: c.onSurfaceMuted);
        }),
      ),
      tabBarTheme: TabBarThemeData(
        indicatorColor: c.brand,
        labelColor: c.brand,
        unselectedLabelColor: c.onSurfaceMuted,
        dividerColor: Colors.transparent,
        labelStyle: const TextStyle(fontWeight: FontWeight.w800),
      ),
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: ButtonStyle(
          backgroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) return c.brand;
            return Colors.transparent;
          }),
          foregroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) return c.background;
            return c.onSurfaceMuted;
          }),
          side: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return BorderSide(color: c.brand.withValues(alpha: 0.4));
            }
            return BorderSide(color: c.border);
          }),
          shape: WidgetStatePropertyAll(RoundedRectangleBorder(borderRadius: DTokens.borderRadiusMd)),
        ),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return c.background;
          return c.onSurfaceMuted;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return c.brand;
          return c.borderSoft;
        }),
        trackOutlineColor: WidgetStatePropertyAll(Colors.transparent),
      ),
      scrollbarTheme: ScrollbarThemeData(
        thumbVisibility: const WidgetStatePropertyAll(true),
        trackVisibility: const WidgetStatePropertyAll(true),
        thickness: const WidgetStatePropertyAll(8),
        radius: const Radius.circular(10),
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.hovered)) return c.brand;
          return c.brand.withValues(alpha: 0.6);
        }),
        trackColor: WidgetStatePropertyAll(c.border),
        trackBorderColor: const WidgetStatePropertyAll(Colors.transparent),
        interactive: true,
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: c.brand,
        linearTrackColor: c.borderSoft,
      ),
      dividerTheme: DividerThemeData(
        color: c.border,
        thickness: 1,
        space: 0,
      ),
      listTileTheme: ListTileThemeData(iconColor: c.onSurfaceMuted),
      expansionTileTheme: ExpansionTileThemeData(
        iconColor: c.onSurfaceMuted,
        collapsedIconColor: c.onSurfaceMuted,
        shape: const Border(),
        collapsedShape: const Border(),
        backgroundColor: c.surface,
      ),
      popupMenuTheme: PopupMenuThemeData(
        color: c.surfaceElevated,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: DTokens.borderRadiusMd),
      ),
      dropdownMenuTheme: DropdownMenuThemeData(
        menuStyle: MenuStyle(
          backgroundColor: WidgetStatePropertyAll(c.surfaceElevated),
          surfaceTintColor: WidgetStatePropertyAll(Colors.transparent),
          shape: WidgetStatePropertyAll(RoundedRectangleBorder(borderRadius: DTokens.borderRadiusMd)),
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
      radius: const Radius.circular(10),
      child: child,
    );
  }
}
