import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/app_localizations.dart';
import '../../core/app_theme.dart';
import '../../models/track.dart';
import '../../services/database_service.dart';
import '../../state/app_state.dart';
import '../../widgets/animated_widgets.dart';
import '../../widgets/impressive_widgets.dart';
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
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth > 900;
            return SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: isWide ? 48 : 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FadeSlideIn(delay: const Duration(milliseconds: 80), child: _TopBar(t: t, isWide: isWide, loggedIn: widget.loggedIn, isAdmin: widget.isAdmin, onEnter: widget.onEnter)),
                  const SizedBox(height: 40),
                  FadeSlideIn(delay: const Duration(milliseconds: 160), offset: const Offset(0, 30), child: _HeroSection(t: t, isWide: isWide, loggedIn: widget.loggedIn, isAdmin: widget.isAdmin, onEnter: widget.onEnter)),
                  const SizedBox(height: 72),
                  FadeSlideIn(delay: const Duration(milliseconds: 280), child: _TracksSection(t: t, isWide: isWide)),
                  const SizedBox(height: 72),
                  FadeSlideIn(delay: const Duration(milliseconds: 360), child: _FeatureShowcase(t: t, isWide: isWide)),
                  const SizedBox(height: 72),
                  FadeSlideIn(delay: const Duration(milliseconds: 440), child: _WhyUsSection(t: t, isWide: isWide)),
                  const SizedBox(height: 72),
                  FadeSlideIn(delay: const Duration(milliseconds: 520), child: _JoinBanner(t: t, isWide: isWide, loggedIn: widget.loggedIn, isAdmin: widget.isAdmin, onEnter: widget.onEnter)),
                  const SizedBox(height: 48),
                  FadeSlideIn(delay: const Duration(milliseconds: 600), child: _Footer(t: t)),
                  const SizedBox(height: 24),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════
// TOP BAR
// ══════════════════════════════════════════════
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
    final compact = MediaQuery.sizeOf(context).width < 560;
    return Row(
      children: [
        // Logo
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.tealPrimary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Image.asset('assets/logo.png', width: 32, height: 32, fit: BoxFit.cover),
        ),
        const SizedBox(width: 10),
        if (!compact)
          Text(
            t('appName'),
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w900,
              color: AppColors.tealDeep,
            ),
          ),
        const Spacer(),
        IconButton(
          tooltip: t('theme'),
          onPressed: () => context.read<AppState>().toggleTheme(),
          icon: Icon(state.themeMode == ThemeMode.dark ? Icons.light_mode : Icons.dark_mode),
        ),
        PopupMenuButton<String>(
          tooltip: t('language'),
          icon: const Icon(Icons.language),
          onSelected: (code) => context.read<AppState>().setLanguage(code),
          itemBuilder: (_) => [
            PopupMenuItem(value: 'ar', child: Text(t('arabic'))),
            PopupMenuItem(value: 'en', child: Text(t('english'))),
            PopupMenuItem(value: 'fr', child: Text(t('french'))),
          ],
        ),
        const SizedBox(width: 4),
        if (loggedIn)
          FilledButton.icon(
            onPressed: onEnter,
            icon: Icon(isAdmin ? Icons.dashboard_rounded : Icons.rocket_launch_rounded),
            label: Text(isAdmin ? t('enterDashboard') : t('enterApp')),
          )
        else
          FilledButton.icon(
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const LoginScreen()),
            ),
            icon: const Icon(Icons.login),
            label: Text(t('login')),
          ),
      ],
    );
  }
}

// ══════════════════════════════════════════════
// HERO SECTION
// ══════════════════════════════════════════════
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
    final content = isWide
        ? Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(flex: 5, child: _HeroText(t: t, style: style, loggedIn: loggedIn, isAdmin: isAdmin, onEnter: onEnter)),
              const SizedBox(width: 48),
              Expanded(flex: 5, child: _HeroCard()),
            ],
          )
        : Column(
            children: [
              _HeroText(t: t, style: style, loggedIn: loggedIn, isAdmin: isAdmin, onEnter: onEnter),
              const SizedBox(height: 40),
              _HeroCard(),
            ],
          );
    return Stack(
      clipBehavior: Clip.none,
      children: [
        const Positioned.fill(child: GradientOrbs()),
        content,
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.tealPrimary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(100),
          ),
          child: Text(
            t('tagline'),
            style: TextStyle(color: AppColors.tealPrimary, fontWeight: FontWeight.w700, fontSize: 14),
          ),
        ),
        const SizedBox(height: 24),
        Text(
          t('heroTitle'),
          style: style.headlineLarge?.copyWith(
            fontWeight: FontWeight.w900,
            height: 1.2,
            fontSize: style.headlineLarge?.fontSize != null ? (style.headlineLarge!.fontSize! * 1.1) : 40,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          t('heroSubtitle'),
          style: style.bodyLarge?.copyWith(height: 1.8, color: AppColors.grayMedium, fontSize: 17),
        ),
        const SizedBox(height: 32),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            MagneticButton(
              child: NeonButton(
                label: loggedIn && isAdmin ? t('enterDashboard') : t('getStarted'),
                icon: loggedIn && isAdmin ? Icons.dashboard_rounded : Icons.rocket_launch_rounded,
                onPressed: loggedIn && onEnter != null
                    ? onEnter
                    : () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const LoginScreen())),
              ),
            ),
            TiltGlowCard(
              borderRadius: BorderRadius.circular(16),
              glowColor: AppColors.tealPrimary,
              hoverScale: 1.03,
              maxTilt: 4,
              child: OutlinedButton.icon(
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
            ),
          ],
        ),
      ],
    );
  }
}

class _HeroCard extends StatelessWidget {
  const _HeroCard();

  @override
  Widget build(BuildContext context) {
    return Floating(
      amplitude: 6,
      duration: const Duration(milliseconds: 3200),
      child: TiltGlowCard(
        borderRadius: BorderRadius.circular(24),
        glowColor: AppColors.tealPrimary,
        maxTilt: 7,
        hoverScale: 1.02,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Image.asset(
            'assets/workspace.png',
            fit: BoxFit.contain,
            width: double.infinity,
          ),
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════
// TRACKS SECTION
// ══════════════════════════════════════════════
class _SectionKeys {
  static final tracks = GlobalKey();
  static final why = GlobalKey();
  static final join = GlobalKey();
}

class _TracksSection extends StatelessWidget {
  final String Function(String) t;
  final bool isWide;

  const _TracksSection({required this.t, required this.isWide});

  @override
  Widget build(BuildContext context) {
    final db = context.watch<DatabaseService>();
    final lang = Localizations.of<AppLocalizations>(context, AppLocalizations)!.languageCode;

    return Column(
      key: _SectionKeys.tracks,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          t('tracks'),
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w900, fontSize: 28),
        ),
        const SizedBox(height: 8),
        Text(
          t('heroSubtitle'),
          style: TextStyle(color: AppColors.grayMedium, fontSize: 16),
        ),
        const SizedBox(height: 32),
        StreamBuilder<List<Track>>(
          stream: db.publishedTracksStream(),
          builder: (context, snapshot) {
            final tracks = snapshot.data ?? [];
            if (tracks.isEmpty) {
              return Row(
                children: [
                  Icon(Icons.rocket_launch, size: 18, color: AppColors.grayMedium),
                  const SizedBox(width: 8),
                  Text(t('moreComingSoon'), style: TextStyle(color: AppColors.grayMedium)),
                ],
              );
            }
            return LayoutBuilder(
              builder: (context, constraints) {
                final width = isWide ? (constraints.maxWidth - 24) / 2 : constraints.maxWidth;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      spacing: 24,
                      runSpacing: 24,
                      children: tracks.map((track) {
                        final trackColor = Color(track.color);
                        final tags = track.tagList(lang);
                        return SizedBox(
                          width: width,
                          child: TiltGlowCard(
                            borderRadius: BorderRadius.circular(20),
                            glowColor: trackColor,
                            maxTilt: 6,
                            hoverScale: 1.03,
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
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 24),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        color: AppColors.tealPrimary.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(100),
                        border: Border.all(color: AppColors.tealPrimary.withValues(alpha: 0.15)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.hourglass_top_rounded, size: 18, color: AppColors.tealPrimary),
                          const SizedBox(width: 8),
                          Text(t('comingSoonTracks'), style: TextStyle(color: AppColors.tealPrimary, fontWeight: FontWeight.w800, fontSize: 14)),
                        ],
                      ),
                    ),
                  ],
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
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (imageUrl.isNotEmpty)
            ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: imageUrl.startsWith('data:')
                  ? Image.memory(
                      base64Decode(imageUrl.split(',').last),
                      height: imageHeight > 0 ? imageHeight : 120,
                      width: imageWidth > 0 ? imageWidth : double.infinity,
                      fit: imageFit,
                    )
                  : Image.network(
                      imageUrl,
                      height: imageHeight > 0 ? imageHeight : 120,
                      width: imageWidth > 0 ? imageWidth : double.infinity,
                      fit: imageFit,
                    ),
            )
          else
            HoverIcon(icon: icon, color: color, size: 32, bgColor: color.withValues(alpha: 0.12)),
          const SizedBox(height: 20),
          Text(title, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900, fontSize: 22)),
          const SizedBox(height: 8),
          Text(desc, style: const TextStyle(height: 1.7, color: AppColors.grayMedium, fontSize: 15)),
          const SizedBox(height: 20),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: tags
                .map((tag) => HoverCard(
                      hoverScale: 1.08,
                      borderRadius: BorderRadius.circular(100),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(100),
                        ),
                        child: Text(tag, style: TextStyle(color: color, fontWeight: FontWeight.w700, fontSize: 13)),
                      ),
                    ))
                .toList(),
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════
// FEATURE SHOWCASE
// ══════════════════════════════════════════════
class _FeatureShowcase extends StatelessWidget {
  final String Function(String) t;
  final bool isWide;

  const _FeatureShowcase({required this.t, required this.isWide});

  @override
  Widget build(BuildContext context) {
    return TiltGlowCard(
      borderRadius: BorderRadius.circular(28),
      glowColor: AppColors.peachStart,
      maxTilt: 3,
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFFDEBD3), Color(0xFFF8C291), Color(0xFFF5A623)],
          ),
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: AppColors.peachStart.withValues(alpha: 0.2),
              blurRadius: 32,
              offset: const Offset(0, 12),
            ),
          ],
        ),
      child: isWide
          ? Padding(
              padding: const EdgeInsets.all(40),
              child: Row(
                children: [
                  // Left: Laptop + Phone mockup
                  Expanded(flex: 5, child: Floating(child: _DeviceMockup(t: t))),
                  const SizedBox(width: 40),
                  // Right: Features list
                  Expanded(flex: 5, child: _FeatureList(t: t)),
                ],
              ),
            )
          : Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  _FeatureList(t: t),
                  const SizedBox(height: 32),
                  Floating(child: _DeviceMockup(t: t)),
                ],
              ),
            ),
      ),
    );
  }
}

class _DeviceMockup extends StatelessWidget {
  final String Function(String) t;
  const _DeviceMockup({required this.t});

  @override
  Widget build(BuildContext context) {
    return FittedBox(
      fit: BoxFit.scaleDown,
      alignment: Alignment.center,
      child: SizedBox(
        width: 380,
        height: 340,
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.center,
          children: [
            // ═══ Laptop ═══
            Positioned(
              top: 0,
              left: 0,
              child: Container(
                width: 340,
                height: 220,
                decoration: BoxDecoration(
                  color: const Color(0xFF1C1C1E),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(14),
                    topRight: Radius.circular(14),
                  ),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withValues(alpha: 0.3), blurRadius: 24, offset: const Offset(0, 10)),
                  ],
                ),
                child: Column(
                  children: [
                    Container(
                      height: 14,
                      decoration: const BoxDecoration(
                        color: Color(0xFF2C2C2E),
                        borderRadius: BorderRadius.vertical(top: Radius.circular(14)),
                      ),
                      child: Center(
                        child: Container(
                          width: 40,
                          height: 4,
                          decoration: BoxDecoration(
                            color: const Color(0xFF3A3A3C),
                            borderRadius: BorderRadius.circular(100),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Container(
                        margin: const EdgeInsets.fromLTRB(6, 0, 6, 0),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(4),
                          gradient: const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [Color(0xFF0F1923), Color(0xFF162231)],
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  ...List.generate(3, (i) => Container(
                                    width: 7, height: 7,
                                    margin: const EdgeInsets.only(right: 4),
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: [const Color(0xFFFF5F57), const Color(0xFFFFBD2E), const Color(0xFF28C840)][i],
                                    ),
                                  )),
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withValues(alpha: 0.08),
                                      borderRadius: BorderRadius.circular(3),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(Icons.folder_rounded, size: 7, color: Colors.white.withValues(alpha: 0.5)),
                                        const SizedBox(width: 3),
                                        Text('tamer_academy/lib', style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 7)),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              _DarkCodeLine(num: '1', text: 'import', keyword: 'package:flutter/material.dart', color: const Color(0xFFCF8E6D)),
                              _DarkCodeLine(num: '2', text: '', keyword: ''),
                              _DarkCodeLine(num: '3', text: 'class ', keyword: 'Course {', color: const Color(0xFFE06C75)),
                              _DarkCodeLine(num: '4', text: '  final ', keyword: 'title = "Tamer Academy";', color: const Color(0xFF61AFEF)),
                              _DarkCodeLine(num: '5', text: '  track: ', keyword: 'Track.web,', color: const Color(0xFFC678DD)),
                              _DarkCodeLine(num: '6', text: '  ', keyword: 'interactive: true,', color: const Color(0xFFE5C07B)),
                              _DarkCodeLine(num: '7', text: '  ', keyword: 'liveResult: true,', color: const Color(0xFFE5C07B)),
                              _DarkCodeLine(num: '8', text: '  ', keyword: 'freeAccess: true,', color: const Color(0xFFE5C07B)),
                              _DarkCodeLine(num: '9', text: '}', keyword: '', color: const Color(0xFFE06C75)),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Container(
                      height: 18,
                      decoration: const BoxDecoration(
                        color: Color(0xFF2C2C2E),
                        borderRadius: BorderRadius.vertical(bottom: Radius.circular(6)),
                      ),
                      child: Center(
                        child: Container(
                          width: 50,
                          height: 3,
                          decoration: BoxDecoration(
                            color: const Color(0xFF48484A),
                            borderRadius: BorderRadius.circular(100),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              right: 10,
              top: 30,
              child: Container(
                width: 90,
                height: 170,
                decoration: BoxDecoration(
                  color: const Color(0xFF1C1C1E),
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withValues(alpha: 0.25), blurRadius: 16, offset: const Offset(0, 6)),
                  ],
                ),
                child: Column(
                  children: [
                    Container(
                      height: 14,
                      child: Center(
                        child: Container(
                          width: 30,
                          height: 4,
                          decoration: BoxDecoration(
                            color: const Color(0xFF3A3A3C),
                            borderRadius: BorderRadius.circular(100),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Container(
                        margin: const EdgeInsets.fromLTRB(4, 0, 4, 4),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          gradient: const LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [Color(0xFF1A8A7A), Color(0xFF0D5C52)],
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(8),
                          child: Column(
                            children: [
                              const SizedBox(height: 6),
                              Icon(Icons.phone_android_rounded, color: Colors.white.withValues(alpha: 0.9), size: 18),
                              const SizedBox(height: 6),
                              Text(
                                t('mobileDevelopment'),
                                textAlign: TextAlign.center,
                                style: const TextStyle(color: Colors.white, fontSize: 7, fontWeight: FontWeight.w800, height: 1.3),
                              ),
                              const SizedBox(height: 8),
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Column(
                                  children: [
                                    Container(height: 3, width: 40, decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.4), borderRadius: BorderRadius.circular(100))),
                                    const SizedBox(height: 4),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Container(width: 14, height: 14, decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(4))),
                                        const SizedBox(width: 4),
                                        Container(width: 14, height: 14, decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(4))),
                                        const SizedBox(width: 4),
                                        Container(width: 14, height: 14, decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(4))),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Container(height: 3, width: 30, decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.3), borderRadius: BorderRadius.circular(100))),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 6),
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(vertical: 3),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.9),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  t('getStarted'),
                                  textAlign: TextAlign.center,
                                  style: TextStyle(color: AppColors.tealPrimary, fontSize: 6, fontWeight: FontWeight.w800),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              left: -10,
              top: 80,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 8)],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.check_circle_rounded, size: 10, color: AppColors.success),
                    const SizedBox(width: 4),
                    Text('100%', style: TextStyle(fontSize: 8, fontWeight: FontWeight.w800, color: AppColors.success)),
                  ],
                ),
              ),
            ),
            Positioned(
              right: 0,
              bottom: 30,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 8)],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.star_rounded, size: 10, color: AppColors.warning),
                    const SizedBox(width: 4),
                    Text('Flutter', style: TextStyle(fontSize: 8, fontWeight: FontWeight.w800, color: AppColors.warning)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DarkCodeLine extends StatelessWidget {
  final String num;
  final String text;
  final String keyword;
  final Color? color;

  const _DarkCodeLine({required this.num, required this.text, required this.keyword, this.color});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 0.5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 14,
            child: Text(num, style: TextStyle(color: Colors.white.withValues(alpha: 0.2), fontSize: 7, fontFamily: 'monospace')),
          ),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: TextStyle(color: Colors.white.withValues(alpha: 0.85), fontSize: 7.5, fontFamily: 'monospace', height: 1.5),
                children: [
                  TextSpan(text: text, style: TextStyle(color: color)),
                  TextSpan(text: keyword, style: TextStyle(color: color ?? Colors.white.withValues(alpha: 0.85))),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FeatureList extends StatelessWidget {
  final String Function(String) t;
  const _FeatureList({required this.t});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          t('featureShowcaseTitle'),
          style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: isDark ? Colors.white : AppColors.navyText, height: 1.3),
        ),
        const SizedBox(height: 12),
        Text(
          t('featureShowcaseSubtitle'),
          style: TextStyle(fontSize: 15, color: AppColors.grayMedium, height: 1.6),
        ),
        const SizedBox(height: 24),
        _FeatureItem(icon: Icons.play_circle_rounded, text: t('feature1'), color: AppColors.tealPrimary),
        const SizedBox(height: 12),
        _FeatureItem(icon: Icons.code_rounded, text: t('feature2'), color: AppColors.peachStart),
        const SizedBox(height: 12),
        _FeatureItem(icon: Icons.devices_rounded, text: t('feature3'), color: AppColors.tealLight),
        const SizedBox(height: 12),
        _FeatureItem(icon: Icons.quiz_rounded, text: t('feature4'), color: AppColors.goldPrimary),
        const SizedBox(height: 24),
        // Stats row — 100% removed as requested
        Row(
          children: [
            _CompactStat(value: '24/7', label: t('members')),
            const SizedBox(width: 16),
            _CompactStat(value: '3', label: t('language')),
          ],
        ),
      ],
    );
  }
}

class _FeatureItem extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color color;
  const _FeatureItem({required this.icon, required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(child: Text(text, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600))),
      ],
    );
  }
}

class _CompactStat extends StatelessWidget {
  final String value;
  final String label;
  const _CompactStat({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(value, style: const TextStyle(fontWeight: FontWeight.w900, color: AppColors.tealPrimary, fontSize: 16)),
          const SizedBox(height: 2),
          Text(label, style: const TextStyle(fontSize: 10, color: AppColors.grayMedium)),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════
// WHY US SECTION
// ══════════════════════════════════════════════
class _WhyUsSection extends StatelessWidget {
  final String Function(String) t;
  final bool isWide;

  const _WhyUsSection({required this.t, required this.isWide});

  @override
  Widget build(BuildContext context) {
    final features = [
      (Icons.handyman_rounded, t('whyUs1Title'), t('whyUs1Desc'), AppColors.tealPrimary),
      (Icons.insights_rounded, t('whyUs2Title'), t('whyUs2Desc'), AppColors.peachStart),
      (Icons.translate_rounded, t('whyUs3Title'), t('whyUs3Desc'), AppColors.tealLight),
    ];
    return Column(
      key: _SectionKeys.why,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          t('whyUs'),
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w900, fontSize: 28),
        ),
        const SizedBox(height: 32),
        LayoutBuilder(
          builder: (context, constraints) {
            final itemWidth = isWide ? (constraints.maxWidth - 32) / 3 : constraints.maxWidth;
            return Wrap(
              spacing: 16,
              runSpacing: 16,
              children: features.asMap().entries.map((entry) {
                final i = entry.key;
                final f = entry.value;
                return SizedBox(
                  width: itemWidth,
                  child: FadeSlideIn(
                    delay: Duration(milliseconds: 120 * i),
                    child: TiltGlowCard(
                      borderRadius: BorderRadius.circular(16),
                      glowColor: f.$4,
                      maxTilt: 5,
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surface,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            HoverIcon(icon: f.$1, color: f.$4, size: 24, bgColor: f.$4.withValues(alpha: 0.12)),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(f.$2, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800, fontSize: 16)),
                                  const SizedBox(height: 4),
                                  Text(f.$3, style: const TextStyle(height: 1.6, color: AppColors.grayMedium, fontSize: 14)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            );
          },
        ),
      ],
    );
  }
}

// ══════════════════════════════════════════════
// JOIN BANNER
// ══════════════════════════════════════════════
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
    return TiltGlowCard(
      borderRadius: BorderRadius.circular(24),
      glowColor: AppColors.tealPrimary,
      maxTilt: 2,
      child: Container(
        key: _SectionKeys.join,
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: isWide ? 48 : 28, vertical: 48),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [AppColors.tealDeep, AppColors.tealPrimary, AppColors.tealLight],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.tealPrimary.withValues(alpha: 0.3),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            t('joinToday'),
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              height: 1.3,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: loggedIn && onEnter != null
                ? onEnter
                : () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const LoginScreen())),
            style: FilledButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: AppColors.tealDeep,
              padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 18),
              textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
              elevation: 4,
              shadowColor: Colors.black.withValues(alpha: 0.15),
            ),
            icon: Icon(loggedIn && isAdmin ? Icons.dashboard_rounded : Icons.login),
            label: Text(loggedIn && isAdmin ? t('enterDashboard') : t('getStarted')),
          ),
        ],
      ),
    ),
    );
  }
}

// ══════════════════════════════════════════════
// FOOTER
// ══════════════════════════════════════════════
class _Footer extends StatelessWidget {
  final String Function(String) t;

  const _Footer({required this.t});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Divider(color: Theme.of(context).colorScheme.outlineVariant),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(t('privacy'), style: const TextStyle(color: AppColors.grayMedium, fontSize: 14)),
            const SizedBox(width: 16),
            const Text('•', style: TextStyle(color: AppColors.grayLight)),
            const SizedBox(width: 16),
            Text(t('terms'), style: const TextStyle(color: AppColors.grayMedium, fontSize: 14)),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          '© ${DateTime.now().year} ${t('appName')} — ${t('rights')}',
          style: const TextStyle(fontSize: 13, color: AppColors.grayLight),
        ),
      ],
    );
  }
}