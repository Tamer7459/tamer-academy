import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  AppColors._();

  // ══════════════════════════════════════════════
  // PRIMARY (Teal / Green-Blue — like Iqrae Kull)
  // ══════════════════════════════════════════════
  static const Color tealDeep     = Color(0xFF136B5E);
  static const Color tealPrimary  = Color(0xFF1A8A7A);
  static const Color tealLight    = Color(0xFF3BBFAE);
  static const Color tealPale     = Color(0xFFD6F0EC);

  // ══════════════════════════════════════════════
  // WARM ACCENTS (Hero gradients, cards)
  // ══════════════════════════════════════════════
  static const Color peachStart   = Color(0xFFF5A623);
  static const Color peachEnd     = Color(0xFFF8C291);
  static const Color peachLight   = Color(0xFFFDEBD3);
  static const Color warmOrange   = Color(0xFFF09030);
  static const Color coral        = Color(0xFFE8604C);

  // ══════════════════════════════════════════════
  // NEUTRALS
  // ══════════════════════════════════════════════
  static const Color navyDark     = Color(0xFF0D2137);
  static const Color navyText     = Color(0xFF1A2B42);
  static const Color grayDark     = Color(0xFF374151);
  static const Color grayMedium   = Color(0xFF6B7280);
  static const Color grayLight    = Color(0xFF9CA3AF);
  static const Color grayVeryLight= Color(0xFFF3F4F6);
  static const Color offWhite     = Color(0xFFFAFBFC);
  static const Color white        = Color(0xFFFFFFFF);

  // ══════════════════════════════════════════════
  // SEMANTIC
  // ══════════════════════════════════════════════
  static const Color success  = Color(0xFF22C55E);
  static const Color danger   = Color(0xFFEF4444);
  static const Color warning  = Color(0xFFF59E0B);
  static const Color star     = Color(0xFFF59E0B);
  static const Color info     = Color(0xFF3B82F6);

  // ══════════════════════════════════════════════
  // BACKWARD COMPATIBILITY ALIASES
  // ══════════════════════════════════════════════
  static const Color primary    = tealPrimary;
  static const Color secondary  = Color(0xFFF5A623);
  static const Color accent     = Color(0xFF3BBFAE);
  static const Color navyPrimary= tealDeep;
  static const Color goldPrimary= Color(0xFFF5A623);
  static const Color goldLight  = Color(0xFFF8C291);
  static const Color goldDark   = Color(0xFFD4940F);
  static const Color cyanAccent = tealLight;
  static const Color creamWhite = offWhite;
  static const Color navyDeep   = navyDark;

  static const Color darkBg      = Color(0xFF0A1628);
  static const Color darkSurface = Color(0xFF122240);
  static const Color darkCard    = Color(0xFF1B3A5C);
  static const Color darkElevated= Color(0xFF23456B);
  static const Color darkTextDim = Color(0xFFB9C7DC);
}

class AppGradients {
  AppGradients._();

  static const LinearGradient primary = LinearGradient(
    colors: [AppColors.tealDeep, AppColors.tealPrimary],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient hero = LinearGradient(
    colors: [AppColors.peachStart, AppColors.peachEnd, AppColors.peachLight],
    begin: Alignment.topRight,
    end: Alignment.bottomLeft,
  );

  static const LinearGradient tealToPeach = LinearGradient(
    colors: [AppColors.tealPrimary, AppColors.tealLight, AppColors.peachEnd],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient warm = LinearGradient(
    colors: [AppColors.peachLight, AppColors.offWhite],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static final LinearGradient cardShadow = LinearGradient(
    colors: [Colors.transparent, Colors.black.withValues(alpha: 0.03)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
}

class AppTheme {
  AppTheme._();

  static Color accent(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? AppColors.tealLight : AppColors.tealPrimary;
  }

  static Color track(BuildContext context, String track) {
    if (track == 'web') return accent(context);
    return AppColors.tealLight;
  }

  static ThemeData light() => _build(Brightness.light);
  static ThemeData dark() => _build(Brightness.dark);

  // للويب: سكرول دائم + أسهم لوحة المفاتيح
  static ScrollBehavior get scrollBehavior => const _AppScrollBehavior();

  static ThemeData _build(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    final scheme = ColorScheme.fromSeed(
      seedColor: AppColors.tealPrimary,
      brightness: brightness,
      primary: isDark ? AppColors.tealLight : AppColors.tealPrimary,
      onPrimary: isDark ? AppColors.navyDark : AppColors.white,
      secondary: AppColors.peachStart,
      onSecondary: AppColors.white,
      tertiary: AppColors.tealLight,
      surface: isDark ? AppColors.darkSurface : AppColors.white,
      onSurface: isDark ? AppColors.white : AppColors.navyText,
      onSurfaceVariant: isDark ? AppColors.darkTextDim : AppColors.grayMedium,
      outline: isDark ? const Color(0xFF2A4164) : const Color(0xFFE5E7EB),
      outlineVariant: isDark ? const Color(0xFF1E3352) : const Color(0xFFF3F4F6),
      error: isDark ? const Color(0xFFFF6B5E) : AppColors.danger,
    );

    final base = ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: isDark ? AppColors.darkBg : AppColors.offWhite,
      pageTransitionsTheme: PageTransitionsTheme(
        builders: const {
          TargetPlatform.android: ZoomPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.windows: FadeUpwardsPageTransitionsBuilder(),
          TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.linux: FadeUpwardsPageTransitionsBuilder(),
        },
      ),
    );

    return base.copyWith(
      textTheme: GoogleFonts.cairoTextTheme(base.textTheme).apply(
        bodyColor: scheme.onSurface,
        displayColor: scheme.onSurface,
      ),
      appBarTheme: AppBarTheme(
        centerTitle: false,
        backgroundColor: isDark ? AppColors.darkBg : AppColors.white,
        foregroundColor: isDark ? AppColors.white : AppColors.navyText,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      cardTheme: CardThemeData(
        elevation: isDark ? 0 : 2,
        shadowColor: Colors.black.withValues(alpha: 0.06),
        color: isDark ? AppColors.darkCard : AppColors.white,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: isDark
              ? const BorderSide(color: Color(0xFF1E3352))
              : BorderSide.none,
        ),
        margin: EdgeInsets.zero,
      ),
      chipTheme: base.chipTheme.copyWith(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        side: BorderSide(color: scheme.outlineVariant),
        labelStyle: TextStyle(color: scheme.onSurface),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isDark ? AppColors.darkSurface : AppColors.grayVeryLight,
        hintStyle: TextStyle(color: AppColors.grayLight),
        labelStyle: TextStyle(color: AppColors.grayMedium),
        prefixIconColor: AppColors.grayLight,
        suffixIconColor: AppColors.grayLight,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: scheme.outlineVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.tealPrimary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: scheme.error),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: isDark ? AppColors.tealLight : AppColors.tealPrimary,
          foregroundColor: isDark ? AppColors.navyDark : AppColors.white,
          disabledBackgroundColor: AppColors.grayLight.withValues(alpha: 0.3),
          disabledForegroundColor: AppColors.grayLight,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
          textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: isDark ? AppColors.tealLight : AppColors.tealPrimary,
          side: BorderSide(color: isDark ? AppColors.tealLight.withValues(alpha: 0.3) : AppColors.tealPrimary.withValues(alpha: 0.3)),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
          textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: isDark ? AppColors.darkElevated : AppColors.tealPrimary,
          foregroundColor: AppColors.white,
          elevation: 2,
          shadowColor: AppColors.tealPrimary.withValues(alpha: 0.3),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
          textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: isDark ? AppColors.tealLight : AppColors.tealPrimary,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: isDark ? AppColors.darkCard : AppColors.white,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: isDark ? AppColors.darkCard : AppColors.white,
        surfaceTintColor: Colors.transparent,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: isDark ? AppColors.darkElevated : AppColors.navyDark,
        contentTextStyle: const TextStyle(color: AppColors.white, fontWeight: FontWeight.w600),
        actionTextColor: AppColors.tealLight,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: isDark ? AppColors.darkSurface : AppColors.white,
        surfaceTintColor: Colors.transparent,
        elevation: isDark ? 0 : 8,
        shadowColor: Colors.black.withValues(alpha: 0.08),
        indicatorColor: AppColors.tealPrimary.withValues(alpha: 0.12),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return IconThemeData(color: isDark ? AppColors.tealLight : AppColors.tealPrimary);
          }
          return IconThemeData(color: AppColors.grayMedium);
        }),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return TextStyle(fontWeight: FontWeight.w800, color: isDark ? AppColors.tealLight : AppColors.tealPrimary);
          }
          return TextStyle(fontWeight: FontWeight.w500, color: AppColors.grayMedium);
        }),
      ),
      tabBarTheme: TabBarThemeData(
        indicatorColor: AppColors.tealPrimary,
        labelColor: isDark ? AppColors.tealLight : AppColors.tealPrimary,
        unselectedLabelColor: AppColors.grayMedium,
        dividerColor: Colors.transparent,
        labelStyle: const TextStyle(fontWeight: FontWeight.w700),
      ),
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: ButtonStyle(
          backgroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return isDark ? AppColors.tealLight : AppColors.tealPrimary;
            }
            return Colors.transparent;
          }),
          foregroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return isDark ? AppColors.navyDark : AppColors.white;
            }
            return AppColors.grayMedium;
          }),
          side: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return BorderSide(color: AppColors.tealPrimary.withValues(alpha: 0.3));
            }
            return BorderSide(color: AppColors.grayLight);
          }),
          shape: WidgetStatePropertyAll(RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
        ),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return AppColors.white;
          return AppColors.grayLight;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return AppColors.tealPrimary;
          return AppColors.grayVeryLight;
        }),
        trackOutlineColor: WidgetStatePropertyAll(Colors.transparent),
      ),
      scrollbarTheme: ScrollbarThemeData(
        thumbVisibility: const WidgetStatePropertyAll(true),
        trackVisibility: const WidgetStatePropertyAll(true),
        thickness: const WidgetStatePropertyAll(8),
        radius: const Radius.circular(10),
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.hovered)) return AppColors.tealPrimary;
          return AppColors.tealPrimary.withValues(alpha: 0.6);
        }),
        trackColor: WidgetStatePropertyAll(isDark ? const Color(0xFF1E3352) : AppColors.grayVeryLight),
        trackBorderColor: const WidgetStatePropertyAll(Colors.transparent),
        interactive: true,
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: AppColors.tealPrimary,
        linearTrackColor: isDark ? const Color(0xFF1E3352) : AppColors.grayVeryLight,
      ),
      dividerTheme: DividerThemeData(
        color: isDark ? const Color(0xFF1E3352) : AppColors.grayVeryLight,
        thickness: 1,
        space: 0,
      ),
      listTileTheme: ListTileThemeData(iconColor: AppColors.grayMedium),
      expansionTileTheme: ExpansionTileThemeData(
        iconColor: AppColors.grayMedium,
        collapsedIconColor: AppColors.grayMedium,
        shape: const Border(),
        collapsedShape: const Border(),
      ),
      popupMenuTheme: PopupMenuThemeData(
        color: isDark ? AppColors.darkCard : AppColors.white,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
      dropdownMenuTheme: DropdownMenuThemeData(
        menuStyle: MenuStyle(
          backgroundColor: WidgetStatePropertyAll(isDark ? AppColors.darkCard : AppColors.white),
          surfaceTintColor: WidgetStatePropertyAll(Colors.transparent),
          shape: WidgetStatePropertyAll(RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
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
    // سكرول دائم للويب + أسهم لوحة المفاتيح
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