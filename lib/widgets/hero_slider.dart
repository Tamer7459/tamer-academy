import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';

import '../core/app_localizations.dart';
import '../core/app_theme.dart';
import 'animated_widgets.dart';

class HeroSlider extends StatefulWidget {
  final String userName;
  const HeroSlider({super.key, required this.userName});

  @override
  State<HeroSlider> createState() => _HeroSliderState();
}

class _HeroSliderState extends State<HeroSlider> {
  int _current = 0;
  Timer? _timer;
  static const _interval = Duration(seconds: 5);

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(_interval, (_) {
      if (mounted) {
        setState(() => _current = (_current + 1) % 3);
      }
    });
  }

  void _next() {
    setState(() => _current = (_current + 1) % 3);
    _startTimer();
  }

  void _prev() {
    setState(() => _current = (_current - 1 + 3) % 3);
    _startTimer();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = Localizations.of<AppLocalizations>(context, AppLocalizations)!;
    final t = l10n.t;
    final w = MediaQuery.of(context).size.width;
    final isMobile = w < 600;

    final slides = [
      _SlideData(
        image: 'assets/workspace.png',
        gradientColors: [const Color(0xFF0D5C52), const Color(0xFF1A8A7A)],
        overlayColors: [Colors.black.withValues(alpha: 0.55), Colors.black.withValues(alpha: 0.2)],
        icon: Icons.school_rounded,
        eyebrow: t('appName'),
        title: l10n.isRtl
            ? '${t('welcomeBack').replaceAll('!', '').trim()} \u2068${widget.userName}\u2069!'
            : '${t('welcomeBack')} ${widget.userName}',
        subtitle: t('homeSubtitle'),
        cta: t('home'),
      ),
      _SlideData(
        image: 'assets/fullstack.png',
        gradientColors: [const Color(0xFF0D3B66), const Color(0xFF1A5276)],
        overlayColors: [Colors.black.withValues(alpha: 0.5), Colors.black.withValues(alpha: 0.15)],
        icon: Icons.language_rounded,
        eyebrow: t('webDevelopment'),
        title: t('webDevHeroTitle'),
        subtitle: t('webDevHeroSubtitle'),
        cta: t('home'),
      ),
      _SlideData(
        image: 'assets/flutter.png',
        gradientColors: [const Color(0xFF1A0D5C), const Color(0xFF2E1A7A)],
        overlayColors: [Colors.black.withValues(alpha: 0.5), Colors.black.withValues(alpha: 0.15)],
        icon: Icons.smartphone_rounded,
        eyebrow: t('mobileDevelopment'),
        title: t('mobileDevHeroTitle'),
        subtitle: t('mobileDevHeroSubtitle'),
        cta: t('home'),
      ),
    ];

    final currentSlide = slides[_current];

    return Column(
      children: [
        HoverCard(
          borderRadius: BorderRadius.circular(24),
          hoverScale: 1.008,
          child: Container(
            width: double.infinity,
            height: isMobile ? 300 : 400,
            margin: const EdgeInsets.fromLTRB(20, 20, 20, 0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(color: Colors.black.withValues(alpha: 0.15), blurRadius: 24, offset: const Offset(0, 8)),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // Background — صورة واضحة وخلفية غير داكنة
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 600),
                    switchInCurve: Curves.easeOutCubic,
                    switchOutCurve: Curves.easeInCubic,
                    child: Container(
                      key: ValueKey(_current),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                          colors: currentSlide.gradientColors,
                        ),
                      ),
                      child: Image.asset(
                        currentSlide.image,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: double.infinity,
                        errorBuilder: (_, __, ___) => const SizedBox(),
                      ),
                    ),
                  ),

                  // Gradient overlay — خفيف حتى تظهر الخلفية بوضوح
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                        colors: [
                          Colors.black.withValues(alpha: 0.35),
                          Colors.black.withValues(alpha: 0.08),
                        ],
                      ),
                    ),
                  ),

                  // Text content — في الجانب وخلفية غير داكنة
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 500),
                    switchInCurve: Curves.easeOutCubic,
                    transitionBuilder: (child, anim) => FadeTransition(
                      opacity: anim,
                      child: SlideTransition(
                        position: Tween<Offset>(begin: const Offset(0.05, 0), end: Offset.zero).animate(anim),
                        child: child,
                      ),
                    ),
                    child: Padding(
                      key: ValueKey('text$_current'),
                      padding: EdgeInsets.all(isMobile ? 20 : 32),
                      child: Align(
                        alignment: AlignmentDirectional.centerStart,
                        child: Container(
                          constraints: const BoxConstraints(maxWidth: 520),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Badge
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.18),
                                  borderRadius: BorderRadius.circular(100),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(currentSlide.icon, size: 14, color: Colors.white),
                                    const SizedBox(width: 6),
                                    Text(currentSlide.eyebrow, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.white)),
                                  ],
                                ),
                              ),
                              SizedBox(height: isMobile ? 14 : 20),
                                  Text(
                                    currentSlide.title,
                                    softWrap: true,
                                    overflow: TextOverflow.visible,
                                    textDirection: l10n.isRtl ? TextDirection.rtl : TextDirection.ltr,
                                    textAlign: TextAlign.start,
                                    style: TextStyle(
                                      fontSize: isMobile ? 26 : 36,
                                      fontWeight: FontWeight.w900,
                                      color: Colors.white,
                                      height: 1.25,
                                      shadows: [Shadow(color: Colors.black.withValues(alpha: 0.55), blurRadius: 10, offset: const Offset(0, 2))],
                                    ),
                                  ),
                                  SizedBox(height: isMobile ? 8 : 12),
                                  Text(
                                    currentSlide.subtitle,
                                    softWrap: true,
                                    overflow: TextOverflow.visible,
                                    textDirection: l10n.isRtl ? TextDirection.rtl : TextDirection.ltr,
                                    textAlign: TextAlign.start,
                                    style: TextStyle(
                                      fontSize: isMobile ? 13 : 15,
                                      color: Colors.white.withValues(alpha: 0.92),
                                      height: 1.5,
                                      shadows: [Shadow(color: Colors.black.withValues(alpha: 0.5), blurRadius: 8)],
                                    ),
                                  ),
                          SizedBox(height: isMobile ? 16 : 24),
                          HoverButton(
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(100),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(currentSlide.cta, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: currentSlide.gradientColors[1])),
                                  const SizedBox(width: 6),
                                  Icon(Icons.arrow_forward_rounded, size: 18, color: currentSlide.gradientColors[1]),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
              ),
            ),
          ),

                // ═══ Prev arrow (always left) ═══
                Positioned(
                  left: 12,
                  top: 0,
                  bottom: 0,
                  child: Center(
                    child: GestureDetector(
                      onTap: _prev,
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.chevron_left_rounded,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                    ),
                  ),
                ),

                // ═══ Next arrow (always right) ═══
                Positioned(
                  right: 12,
                  top: 0,
                  bottom: 0,
                  child: Center(
                    child: GestureDetector(
                      onTap: _next,
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.chevron_right_rounded,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                    ),
                  ),
                ),

                // ═══ Dots ═══
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 16,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(3, (i) {
                      final isActive = i == _current;
                      return GestureDetector(
                        onTap: () {
                          setState(() => _current = i);
                          _startTimer();
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          width: isActive ? 28 : 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: isActive ? Colors.white : Colors.white.withValues(alpha: 0.35),
                            borderRadius: BorderRadius.circular(100),
                          ),
                        ),
                      );
                    }),
                  ),
                ),
              ],
            ),
          ),
          ),
        ),

        // ═══ Trust strip ═══
        if (!isMobile)
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('${t('trustedBy')}  ', style: const TextStyle(fontSize: 12, color: AppColors.grayMedium)),
                _TrustBadge(label: t('webDevelopment')),
                const SizedBox(width: 8),
                _TrustBadge(label: t('mobileDevelopment')),
                const SizedBox(width: 8),
                _TrustBadge(label: t('free')),
              ],
            ),
          ),
      ],
    );
  }
}

class _SlideData {
  final String image;
  final List<Color> gradientColors;
  final List<Color> overlayColors;
  final IconData icon;
  final String eyebrow;
  final String title;
  final String subtitle;
  final String cta;

  const _SlideData({
    required this.image,
    required this.gradientColors,
    required this.overlayColors,
    required this.icon,
    required this.eyebrow,
    required this.title,
    required this.subtitle,
    required this.cta,
  });
}

class _TrustBadge extends StatelessWidget {
  final String label;
  const _TrustBadge({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.tealPrimary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(100),
      ),
      child: Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.tealPrimary)),
    );
  }
}