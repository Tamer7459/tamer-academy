import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/app_localizations.dart';
import '../../core/app_theme.dart';
import '../../core/design_tokens.dart';
import '../../models/track.dart';
import '../../services/database_service.dart';
import '../../state/app_state.dart';
import '../../widgets/animus_background.dart';
import '../../widgets/cinematic_effects.dart';
import '../../widgets/terminal_window.dart';
import '../auth/login_screen.dart';

class LandingScreen extends StatefulWidget {
  final bool loggedIn;
  final bool isAdmin;
  final VoidCallback? onEnter;

  const LandingScreen({
    super.key,
    this.loggedIn = false,
    this.isAdmin = false,
    this.onEnter,
  });

  @override
  State<LandingScreen> createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen> {
  @override
  Widget build(BuildContext context) {
    final l10n = Localizations.of<AppLocalizations>(context, AppLocalizations)!;
    final t = l10n.t;
    final isWide = MediaQuery.sizeOf(context).width > 900;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: AnimusBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: isWide ? 48 : 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FadeSlideIn(delay: const Duration(milliseconds: 80), child: _TopBar(t: t, isWide: isWide, loggedIn: widget.loggedIn, isAdmin: widget.isAdmin, onEnter: widget.onEnter)),
                const SizedBox(height: DTokens.spaceXxl),
                FadeSlideIn(delay: const Duration(milliseconds: 160), offset: const Offset(0, 30), child: _HeroSection(t: t, isWide: isWide, loggedIn: widget.loggedIn, isAdmin: widget.isAdmin, onEnter: widget.onEnter)),
                const SizedBox(height: DTokens.spaceXxl),
                FadeSlideIn(delay: const Duration(milliseconds: 280), child: _TracksSection(t: t, isWide: isWide)),
                const SizedBox(height: DTokens.spaceXxl),
                FadeSlideIn(delay: const Duration(milliseconds: 360), child: _FeatureShowcase(t: t, isWide: isWide)),
                const SizedBox(height: DTokens.spaceXxl),
                FadeSlideIn(delay: const Duration(milliseconds: 440), child: _WhyUsSection(t: t, isWide: isWide)),
                const SizedBox(height: DTokens.spaceXxl),
                FadeSlideIn(delay: const Duration(milliseconds: 520), child: _JoinBanner(t: t, isWide: isWide, loggedIn: widget.loggedIn, isAdmin: widget.isAdmin, onEnter: widget.onEnter)),
                const SizedBox(height: DTokens.spaceXl),
                FadeSlideIn(delay: const Duration(milliseconds: 600), child: _Footer(t: t)),
                const SizedBox(height: DTokens.spaceLg),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// TOP BAR
// ══════════════════════════════════════════════════════════════════════════════
class _TopBar extends StatelessWidget {
  final String Function(String) t;
  final bool isWide;
  final bool loggedIn;
  final bool isAdmin;
  final VoidCallback? onEnter;

  const _TopBar({
    required this.t,
    required this.isWide,
    this.loggedIn = false,
    this.isAdmin = false,
    this.onEnter,
  });

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final compact = MediaQuery.sizeOf(context).width < 560;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: DTokens.spaceMd, vertical: DTokens.spaceSm),
      decoration: BoxDecoration(
        color: (isDark ? DColorsDark.surface : DColorsLight.surface).withValues(alpha: 0.6),
        borderRadius: DTokens.borderRadiusSm,
        border: Border.all(
          color: (isDark ? DColorsDark.border : DColorsLight.border).withValues(alpha: 0.5),
        ),
      ),
      child: Row(
        children: [
          // Logo
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              gradient: DGradients.crimsonGlow,
              borderRadius: DTokens.borderRadiusSm,
            ),
            child: Image.asset('assets/logo.png', width: 24, height: 24, fit: BoxFit.cover),
          ),
          const SizedBox(width: DTokens.spaceSm),
          if (!compact) ...[
            Text(
              'تامر أكاديمي',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w900,
                color: isDark ? DColorsDark.onSurface : DColorsLight.onSurface,
                fontFamily: DTypography.heading,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              'Tamer Academy',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: isDark ? DColorsDark.onSurfaceMuted : DColorsLight.onSurfaceMuted,
                fontFamily: DTypography.body,
              ),
            ),
          ],
          const Spacer(),
          IconButton(
            tooltip: t('theme'),
            onPressed: () => context.read<AppState>().toggleTheme(),
            icon: Icon(state.themeMode == ThemeMode.dark ? Icons.light_mode : Icons.dark_mode, size: 20),
            constraints: const BoxConstraints(),
            padding: const EdgeInsets.all(8),
          ),
          PopupMenuButton<String>(
            tooltip: t('language'),
            icon: const Icon(Icons.language, size: 20),
            onSelected: (code) => context.read<AppState>().setLanguage(code),
            itemBuilder: (_) => [
              PopupMenuItem(value: 'ar', child: Text(t('arabic'))),
              PopupMenuItem(value: 'en', child: Text(t('english'))),
              PopupMenuItem(value: 'fr', child: Text(t('french'))),
            ],
          ),
          const SizedBox(width: DTokens.spaceSm),
          if (!loggedIn)
            FilledButton.icon(
              onPressed: () => Navigator.of(context).push(
                CinematicPageRoute(builder: (_) => const LoginScreen()),
              ),
              icon: const Icon(Icons.login, size: 16),
              label: Text(t('login'), style: const TextStyle(fontSize: 13)),
            ),
          if (loggedIn && isAdmin)
            FilledButton.icon(
              onPressed: onEnter,
              icon: const Icon(Icons.dashboard_rounded, size: 16),
              label: Text(t('enterDashboard'), style: const TextStyle(fontSize: 13)),
            ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// HERO SECTION — Terminal + Title
// ══════════════════════════════════════════════════════════════════════════════
class _HeroSection extends StatelessWidget {
  final String Function(String) t;
  final bool isWide;
  final bool loggedIn;
  final bool isAdmin;
  final VoidCallback? onEnter;

  const _HeroSection({
    required this.t,
    required this.isWide,
    this.loggedIn = false,
    this.isAdmin = false,
    this.onEnter,
  });

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).textTheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final heroContent = isWide
        ? Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(flex: 5, child: _HeroText(t: t, style: style, loggedIn: loggedIn, isAdmin: isAdmin, onEnter: onEnter)),
              const SizedBox(width: DTokens.spaceXl),
              Expanded(flex: 5, child: MouseFollowerGlow(
                color: const Color(0xFFC1232C).withValues(alpha: 0.12),
                size: 200,
                child: TerminalWindow(onFinalCommandTap: () {
                  // Navigate to tracks section
                  final ctx = _SectionKeys.tracks.currentContext;
                  if (ctx != null) Scrollable.ensureVisible(ctx, duration: const Duration(milliseconds: 600), curve: Curves.easeOut);
                }),
              )),
            ],
          )
        : Column(
            children: [
              _HeroText(t: t, style: style, loggedIn: loggedIn, isAdmin: isAdmin, onEnter: onEnter),
              const SizedBox(height: DTokens.spaceXl),
              SizedBox(
                height: 320,
                child: TerminalWindow(onFinalCommandTap: () {
                  final ctx = _SectionKeys.tracks.currentContext;
                  if (ctx != null) Scrollable.ensureVisible(ctx, duration: const Duration(milliseconds: 600), curve: Curves.easeOut);
                }),
              ),
            ],
          );

    return Stack(
      clipBehavior: Clip.none,
      children: [
        // Animated glow orbs
        GradientOrb(color: const Color(0xFFC1232C).withValues(alpha: 0.12), size: 500, start: const Offset(-0.3, -0.3), end: const Offset(1.1, 0.6), duration: const Duration(seconds: 14)),
        GradientOrb(color: const Color(0xFFD4A64A).withValues(alpha: 0.08), size: 400, start: const Offset(0.8, 0.8), end: const Offset(-0.2, 1.1), duration: const Duration(seconds: 16)),
        GradientOrb(color: const Color(0xFF5CC8FF).withValues(alpha: 0.06), size: 300, start: const Offset(-0.1, 0.9), end: const Offset(1.1, -0.2), duration: const Duration(seconds: 12)),
        heroContent,
      ],
    );
  }
}

class _HeroText extends StatelessWidget {
  final String Function(String) t;
  final TextTheme style;
  final bool loggedIn;
  final bool isAdmin;
  final VoidCallback? onEnter;

  const _HeroText({
    required this.t,
    required this.style,
    this.loggedIn = false,
    this.isAdmin = false,
    this.onEnter,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Tagline badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFFC1232C).withValues(alpha: 0.1),
            borderRadius: DTokens.borderRadiusSm,
            border: Border.all(color: const Color(0xFFC1232C).withValues(alpha: 0.3)),
          ),
          child: Text(
            t('tagline'),
            style: TextStyle(
              color: const Color(0xFFC1232C),
              fontWeight: FontWeight.w700,
              fontSize: 13,
              fontFamily: DTypography.heading,
            ),
          ),
        ),
        const SizedBox(height: DTokens.spaceLg),
        // Title — huge, bold
        Text(
          t('heroTitle'),
          style: (style.headlineLarge ?? const TextStyle()).copyWith(
            fontWeight: FontWeight.w900,
            height: 1.1,
            fontSize: 48,
            fontFamily: DTypography.heading,
            color: isDark ? DColorsDark.onSurface : DColorsLight.onSurface,
          ),
        ),
        const SizedBox(height: DTokens.spaceMd),
        // Subtitle
        Text(
          t('heroSubtitle'),
          style: (style.bodyLarge ?? const TextStyle()).copyWith(
            height: 1.8,
            color: isDark ? DColorsDark.onSurfaceDim : DColorsLight.onSurfaceDim,
            fontSize: 16,
            fontFamily: DTypography.body,
          ),
        ),
        const SizedBox(height: DTokens.spaceXl),
        // CTA buttons
        Wrap(
          spacing: DTokens.spaceMd,
          runSpacing: DTokens.spaceSm,
          children: [
            MouseFollowerGlow(
              color: const Color(0xFFC1232C),
              size: 180,
              child: FilledButton.icon(
                onPressed: loggedIn && onEnter != null
                    ? onEnter
                    : () => Navigator.of(context).push(
                          CinematicPageRoute(builder: (_) => const LoginScreen()),
                        ),
                icon: Icon(loggedIn && isAdmin ? Icons.dashboard_rounded : Icons.rocket_launch_rounded, size: 20),
                label: Text(
                  loggedIn && isAdmin ? t('enterDashboard') : t('getStarted'),
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                ),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 18),
                  backgroundColor: const Color(0xFFC1232C),
                ),
              ),
            ),
            OutlinedButton.icon(
              onPressed: () {
                final ctx = _SectionKeys.tracks.currentContext;
                if (ctx != null) Scrollable.ensureVisible(ctx, duration: const Duration(milliseconds: 600), curve: Curves.easeOut);
              },
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 18),
                textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              icon: const Icon(Icons.menu_book_rounded),
              label: Text(t('learnMore')),
            ),
          ],
        ),
      ],
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// SECTION KEYS
// ══════════════════════════════════════════════════════════════════════════════
class _SectionKeys {
  static final tracks = GlobalKey();
  static final why = GlobalKey();
  static final join = GlobalKey();
}

// ══════════════════════════════════════════════════════════════════════════════
// TRACKS SECTION
// ══════════════════════════════════════════════════════════════════════════════
class _TracksSection extends StatelessWidget {
  final String Function(String) t;
  final bool isWide;

  const _TracksSection({required this.t, required this.isWide});

  @override
  Widget build(BuildContext context) {
    final db = context.watch<DatabaseService>();
    final lang = Localizations.of<AppLocalizations>(context, AppLocalizations)!.languageCode;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      key: _SectionKeys.tracks,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          t('tracks'),
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.w900,
            fontSize: 28,
            fontFamily: DTypography.heading,
            color: isDark ? DColorsDark.onSurface : DColorsLight.onSurface,
          ),
        ),
        const SizedBox(height: DTokens.spaceSm),
        Text(
          t('heroSubtitle'),
          style: TextStyle(color: isDark ? DColorsDark.onSurfaceDim : DColorsLight.onSurfaceDim, fontSize: 16),
        ),
        const SizedBox(height: DTokens.spaceXl),
        StreamBuilder<List<Track>>(
          stream: db.publishedTracksStream(),
          builder: (context, snapshot) {
            final tracks = snapshot.data ?? [];
            if (tracks.isEmpty) {
              return Row(
                children: [
                  Icon(Icons.rocket_launch, size: 18, color: isDark ? DColorsDark.onSurfaceMuted : DColorsLight.onSurfaceMuted),
                  const SizedBox(width: 8),
                  Text(t('moreComingSoon'), style: TextStyle(color: isDark ? DColorsDark.onSurfaceMuted : DColorsLight.onSurfaceMuted)),
                ],
              );
            }
            return LayoutBuilder(
              builder: (context, constraints) {
                final width = isWide ? (constraints.maxWidth - DTokens.spaceLg) / 2 : constraints.maxWidth;
                return Wrap(
                  spacing: DTokens.spaceLg,
                  runSpacing: DTokens.spaceLg,
                  children: tracks.map((track) {
                    final trackColor = Color(track.color);
                    final tags = track.tagList(lang);
                    return SizedBox(
                      width: width,
                      child: _TrackCard(
                        icon: Icons.category_rounded,
                        title: track.name.getWithFallback(lang),
                        desc: track.description.getWithFallback(lang),
                        tags: tags.isNotEmpty ? tags : ['Flutter', 'Dart'],
                        color: trackColor,
                        imageUrl: track.imageUrl,
                        imageWidth: track.imageWidth,
                        imageHeight: track.imageHeight,
                        imageFit: track.boxFit,
                      ),
                    );
                  }).toList(),
                );
              },
            );
          },
        ),
      ],
    );
  }
}

class _TrackCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String desc;
  final List<String> tags;
  final Color color;
  final String imageUrl;
  final double imageWidth;
  final double imageHeight;
  final BoxFit imageFit;

  const _TrackCard({
    required this.icon,
    required this.title,
    required this.desc,
    required this.tags,
    required this.color,
    this.imageUrl = '',
    this.imageWidth = 0,
    this.imageHeight = 0,
    this.imageFit = BoxFit.cover,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? DColorsDark.surface : DColorsLight.surface,
          borderRadius: DTokens.borderRadiusSm,
          border: Border.all(color: isDark ? DColorsDark.border : DColorsLight.border),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (imageUrl.isNotEmpty)
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                child: SizedBox(
                  width: double.infinity,
                  height: imageHeight > 0 ? imageHeight : 160,
                  child: Image.network(imageUrl, fit: imageFit, errorBuilder: (_, __, ___) => Container(color: color.withValues(alpha: 0.1), child: Icon(icon, color: color, size: 40))),
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(DTokens.spaceMd),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.12),
                          borderRadius: DTokens.borderRadiusSm,
                        ),
                        child: Icon(icon, color: color, size: 20),
                      ),
                      const SizedBox(width: DTokens.spaceSm),
                      Expanded(
                        child: Text(
                          title,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: isDark ? DColorsDark.onSurface : DColorsLight.onSurface,
                            fontFamily: DTypography.heading,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: DTokens.spaceSm),
                  Text(
                    desc,
                    style: TextStyle(
                      fontSize: 13,
                      color: isDark ? DColorsDark.onSurfaceDim : DColorsLight.onSurfaceDim,
                      height: 1.6,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: DTokens.spaceSm),
                  Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    children: tags.map((tag) => Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.08),
                        borderRadius: DTokens.borderRadiusXs,
                        border: Border.all(color: color.withValues(alpha: 0.2)),
                      ),
                      child: Text(
                        tag,
                        style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: color),
                      ),
                    )).toList(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// FEATURE SHOWCASE
// ══════════════════════════════════════════════════════════════════════════════
class _FeatureShowcase extends StatelessWidget {
  final String Function(String) t;
  final bool isWide;

  const _FeatureShowcase({required this.t, required this.isWide});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final features = [
      (Icons.code_rounded, t('featureCode'), const Color(0xFF5CC8FF)),
      (Icons.quiz_rounded, t('featureQuiz'), const Color(0xFFD4A64A)),
      (Icons.assignment_rounded, t('featureHomework'), const Color(0xFFC1232C)),
      (Icons.trending_up_rounded, t('featureProgress'), const Color(0xFF6FBF8E)),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          t('features'),
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.w900,
            fontSize: 24,
            fontFamily: DTypography.heading,
            color: isDark ? DColorsDark.onSurface : DColorsLight.onSurface,
          ),
        ),
        const SizedBox(height: DTokens.spaceLg),
        Wrap(
          spacing: DTokens.spaceMd,
          runSpacing: DTokens.spaceMd,
          children: features.map((f) => SizedBox(
            width: isWide ? 260 : double.infinity,
            child: Container(
              padding: const EdgeInsets.all(DTokens.spaceMd),
              decoration: BoxDecoration(
                color: isDark ? DColorsDark.surface : DColorsLight.surface,
                borderRadius: DTokens.borderRadiusSm,
                border: Border.all(color: isDark ? DColorsDark.border : DColorsLight.border),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: f.$3.withValues(alpha: 0.12),
                      borderRadius: DTokens.borderRadiusSm,
                    ),
                    child: Icon(f.$1, color: f.$3, size: 22),
                  ),
                  const SizedBox(width: DTokens.spaceMd),
                  Expanded(
                    child: Text(
                      f.$2,
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                        color: isDark ? DColorsDark.onSurface : DColorsLight.onSurface,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          )).toList(),
        ),
      ],
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// WHY US SECTION
// ══════════════════════════════════════════════════════════════════════════════
class _WhyUsSection extends StatelessWidget {
  final String Function(String) t;
  final bool isWide;

  const _WhyUsSection({required this.t, required this.isWide});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      key: _SectionKeys.why,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          t('whyUs'),
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.w900,
            fontSize: 24,
            fontFamily: DTypography.heading,
            color: isDark ? DColorsDark.onSurface : DColorsLight.onSurface,
          ),
        ),
        const SizedBox(height: DTokens.spaceLg),
        Container(
          padding: const EdgeInsets.all(DTokens.spaceLg),
          decoration: BoxDecoration(
            color: isDark ? DColorsDark.surface : DColorsLight.surface,
            borderRadius: DTokens.borderRadiusSm,
            border: Border.all(color: isDark ? DColorsDark.border : DColorsLight.border),
          ),
          child: Text(
            t('whyUsText'),
            style: TextStyle(
              fontSize: 15,
              height: 1.8,
              color: isDark ? DColorsDark.onSurfaceDim : DColorsLight.onSurfaceDim,
            ),
          ),
        ),
      ],
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// JOIN BANNER
// ══════════════════════════════════════════════════════════════════════════════
class _JoinBanner extends StatelessWidget {
  final String Function(String) t;
  final bool isWide;
  final bool loggedIn;
  final bool isAdmin;
  final VoidCallback? onEnter;

  const _JoinBanner({
    required this.t,
    required this.isWide,
    this.loggedIn = false,
    this.isAdmin = false,
    this.onEnter,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      key: _SectionKeys.join,
      width: double.infinity,
      padding: const EdgeInsets.all(DTokens.spaceXl),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [const Color(0xFF1A0F10), const Color(0xFF0B0B0D)]
              : [const Color(0xFFF0E8E5), const Color(0xFFF4F1EA)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: DTokens.borderRadiusSm,
        border: Border.all(color: const Color(0xFFC1232C).withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            t('joinTitle'),
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w900,
              fontFamily: DTypography.heading,
              color: isDark ? DColorsDark.onSurface : DColorsLight.onSurface,
            ),
          ),
          const SizedBox(height: DTokens.spaceSm),
          Text(
            t('joinSubtitle'),
            style: TextStyle(
              fontSize: 14,
              color: isDark ? DColorsDark.onSurfaceDim : DColorsLight.onSurfaceDim,
            ),
          ),
          const SizedBox(height: DTokens.spaceLg),
          FilledButton.icon(
            onPressed: loggedIn && onEnter != null
                ? onEnter
                : () => Navigator.of(context).push(
                      CinematicPageRoute(builder: (_) => const LoginScreen()),
                    ),
            icon: const Icon(Icons.rocket_launch_rounded, size: 18),
            label: Text(loggedIn ? t('enterApp') : t('getStarted')),
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFFC1232C),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            ),
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// FOOTER
// ══════════════════════════════════════════════════════════════════════════════
class _Footer extends StatelessWidget {
  final String Function(String) t;

  const _Footer({required this.t});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(DTokens.spaceMd),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: isDark ? DColorsDark.border : DColorsLight.border)),
      ),
      child: Row(
        children: [
          Text(
            '© 2026 Tamer Academy',
            style: TextStyle(fontSize: 12, color: isDark ? DColorsDark.onSurfaceMuted : DColorsLight.onSurfaceMuted),
          ),
          const Spacer(),
          Text(
            'تامر أكاديمي',
            style: TextStyle(fontSize: 12, color: isDark ? DColorsDark.onSurfaceMuted : DColorsLight.onSurfaceMuted, fontFamily: DTypography.heading),
          ),
        ],
      ),
    );
  }
}
