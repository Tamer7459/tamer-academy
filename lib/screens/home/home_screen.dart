import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/app_localizations.dart';
import '../../core/app_theme.dart';
import '../../models/app_user.dart';
import '../../models/course.dart';
import '../../services/database_service.dart';
import '../../widgets/animated_widgets.dart';
import '../../widgets/impressive_widgets.dart';
import '../courses/course_detail_screen.dart';
import '../../widgets/hero_slider.dart';

class HomeScreen extends StatefulWidget {
  final AppUser user;
  final bool myCoursesOnly;

  const HomeScreen({super.key, required this.user, this.myCoursesOnly = false});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _searchCtrl = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _searchCtrl.addListener(() => setState(() => _searchQuery = _searchCtrl.text));
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = Localizations.of<AppLocalizations>(context, AppLocalizations)!;
    final t = l10n.t;
    final db = context.watch<DatabaseService>();

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // ═══ Hero Slider — يظهر فقط في الرئيسية، لا في دوراتي ═══
            if (!widget.myCoursesOnly)
              SliverToBoxAdapter(
                child: HeroSlider(userName: widget.user.name),
              ),

            // ═══ Search ═══
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.search_rounded, color: AppColors.grayLight, size: 22),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextField(
                          controller: _searchCtrl,
                          decoration: InputDecoration(
                            hintText: '${t('search')}...',
                            border: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(vertical: 12),
                            hintStyle: TextStyle(color: AppColors.grayLight),
                          ),
                          style: const TextStyle(fontSize: 15),
                        ),
                      ),
                      if (_searchQuery.isNotEmpty)
                        IconButton(
                          icon: const Icon(Icons.clear_rounded, size: 18),
                          onPressed: () => _searchCtrl.clear(),
                          color: AppColors.grayLight,
                          tooltip: 'clear',
                        ),
                    ],
                  ),
                ),
              ),
            ),

            // ═══ Stats Row — responsive + conditional ═══
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                child: StreamBuilder<List<Course>>(
                  stream: db.publishedCoursesStream(),
                  builder: (context, courseSnap) {
                    final publishedCount = courseSnap.data?.length ?? 0;
                    final myCoursesCount = widget.user.isAdmin ? publishedCount : widget.user.accessCourses.length;
                    return StreamBuilder<Map<String, dynamic>>(
                      stream: db.progressStream(widget.user.uid),
                      builder: (context, snap) {
                        final data = snap.data ?? {};
                        final courses = Map<String, dynamic>.from(data['courses'] as Map? ?? {});
                        var totalCompleted = 0;
                        var totalAnswered = 0;
                        courses.forEach((_, v) {
                          final m = Map<String, dynamic>.from(v as Map? ?? {});
                          totalCompleted += ((m['completed'] as List?)?.length ?? 0);
                          totalAnswered += ((m['answered'] as List?)?.length ?? 0);
                        });
                        // Responsive: on very small screens, stack vertically
                        final isNarrow = MediaQuery.of(context).size.width < 360;
                        if (widget.myCoursesOnly) {
                          // دوراتي: show my courses count instead of مكتمل
                          final row = Row(
                            children: [
                              Expanded(child: FadeSlideIn(delay: const Duration(milliseconds: 100), child: TiltGlowCard(borderRadius: BorderRadius.circular(16), glowColor: AppColors.tealPrimary, child: _StatCard(value: '$myCoursesCount', label: t('myCourses'), color: AppColors.tealPrimary, icon: Icons.menu_book_rounded)))),
                              const SizedBox(width: 12),
                              Expanded(child: FadeSlideIn(delay: const Duration(milliseconds: 180), child: TiltGlowCard(borderRadius: BorderRadius.circular(16), glowColor: AppColors.peachStart, child: _StatCard(value: '$totalAnswered', label: t('exercisesSolved'), color: AppColors.peachStart, icon: Icons.quiz_rounded)))),
                            ],
                          );
                          if (isNarrow) {
                            return Column(children: [row.children[0], const SizedBox(height: 12), row.children[2]]);
                          }
                          return row;
                        } else {
                          // الرئيسية: show مكتمل + الدورات المتاحة (instead of تمارين محلولة)
                          final row = Row(
                            children: [
                              Expanded(child: FadeSlideIn(delay: const Duration(milliseconds: 100), child: TiltGlowCard(borderRadius: BorderRadius.circular(16), glowColor: AppColors.tealPrimary, child: _StatCard(value: '$totalCompleted', label: t('completed'), color: AppColors.tealPrimary, icon: Icons.check_circle_rounded)))),
                              const SizedBox(width: 12),
                              Expanded(child: FadeSlideIn(delay: const Duration(milliseconds: 180), child: TiltGlowCard(borderRadius: BorderRadius.circular(16), glowColor: AppColors.tealLight, child: _StatCard(value: '$publishedCount', label: t('featuredCourses'), color: AppColors.tealLight, icon: Icons.layers_rounded)))),
                            ],
                          );
                          if (isNarrow) {
                            return Column(children: [row.children[0], const SizedBox(height: 12), row.children[2]]);
                          }
                          return row;
                        }
                      },
                    );
                  },
                ),
              ),
            ),

            // ═══ My Courses / All Courses ═══
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 28, 20, 12),
                child: Row(
                  children: [
                    Builder(builder: (context) {
                      final isDark = Theme.of(context).brightness == Brightness.dark;
                      return Text(
                        widget.myCoursesOnly ? t('myCourses') : t('home'),
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: isDark ? Colors.white : AppColors.navyText),
                      );
                    }),
                    const Spacer(),
                    Icon(Icons.arrow_forward_ios_rounded, size: 16, color: AppColors.grayLight),
                  ],
                ),
              ),
            ),

            // ═══ Course List ═══
            StreamBuilder<List<Course>>(
              stream: db.publishedCoursesStream(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return SliverFillRemaining(child: _ErrorState(t: t, error: snapshot.error));
                }
                if (!snapshot.hasData) {
                  return const SliverFillRemaining(child: Center(child: CircularProgressIndicator()));
                }
                var courses = snapshot.data!;
                if (widget.myCoursesOnly) {
                  courses = courses.where((c) => widget.user.hasAccess(c.id)).toList();
                }
                final _q = _searchQuery.trim().toLowerCase();
                if (_q.isNotEmpty) {
                  final lang = Localizations.of<AppLocalizations>(context, AppLocalizations)!.languageCode;
                  courses = courses.where((c) {
                    final title = c.title.getWithFallback(lang).toLowerCase();
                    final desc = c.description.getWithFallback(lang).toLowerCase();
                    final titleAll = '${c.title.ar} ${c.title.en} ${c.title.fr}'.toLowerCase();
                    final descAll = '${c.description.ar} ${c.description.en} ${c.description.fr}'.toLowerCase();
                    return title.contains(_q) || desc.contains(_q) || titleAll.contains(_q) || descAll.contains(_q);
                  }).toList();
                }
                if (courses.isEmpty) {
                  return SliverFillRemaining(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.menu_book_rounded, size: 56, color: AppColors.grayLight),
                          const SizedBox(height: 12),
                          Text(t('noCourses'), style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.grayMedium)),
                        ],
                      ),
                    ),
                  );
                }

                return StreamBuilder<Map<String, dynamic>>(
                  stream: db.progressStream(widget.user.uid),
                  builder: (context, progressSnap) {
                    final progressData = progressSnap.data ?? {};
                    final courseProgress = Map<String, dynamic>.from(progressData['courses'] as Map? ?? {});
                    return SliverPadding(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                      sliver: SliverGrid(
                        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                          maxCrossAxisExtent: 400,
                          mainAxisSpacing: 14,
                          crossAxisSpacing: 14,
                          mainAxisExtent: 375,
                        ),
                        delegate: SliverChildBuilderDelegate(
                          (context, i) {
                            final course = courses[i];
                            final courseData = Map<String, dynamic>.from(courseProgress[course.id] as Map? ?? {});
                            final completedCount = ((courseData['completed'] as List?)?.length ?? 0);
                            return FadeSlideIn(
                              delay: Duration(milliseconds: 80 * i),
                              child: TiltGlowCard(
                                borderRadius: BorderRadius.circular(20),
                                glowColor: AppTheme.track(context, course.track),
                                maxTilt: 5,
                                child: _CourseCard(
                                  course: course,
                                  completedCount: completedCount,
                                  onTap: () => Navigator.of(context).push(
                                    MaterialPageRoute(builder: (_) => CourseDetailScreen(user: widget.user, course: course)),
                                  ),
                                ),
                              ),
                            );
                          },
                          childCount: courses.length,
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════
// STAT CARD
// ══════════════════════════════════════════════
class _StatCard extends StatelessWidget {
  final String value;
  final String label;
  final Color color;
  final IconData icon;

  const _StatCard({required this.value, required this.label, required this.color, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(value, style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: color)),
              Text(label, style: const TextStyle(fontSize: 12, color: AppColors.grayMedium)),
            ],
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════
// COURSE CARD
// ══════════════════════════════════════════════
class _CourseCard extends StatelessWidget {
  final Course course;
  final int completedCount;
  final VoidCallback onTap;

  const _CourseCard({
    required this.course,
    required this.completedCount,
    required this.onTap,
  });

  static const _palette = [0xFF1A8A7A, 0xFF3BBFAE, 0xFFF5A623, 0xFF3B82F6, 0xFF8B5CF6, 0xFFEF4444];
  @override
  Widget build(BuildContext context) {
    final l10n = Localizations.of<AppLocalizations>(context, AppLocalizations)!;
    final t = l10n.t;
    final lang = l10n.languageCode;
    final baseTrackColor = AppTheme.track(context, course.track);
    final trackColor = (course.colorSeed >= 0 && course.colorSeed < _palette.length) ? Color(_palette[course.colorSeed]) : baseTrackColor;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Course image (if any)
            if (course.imageUrl.isNotEmpty)
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                child: SizedBox(
                  width: double.infinity,
                  height: course.imageHeight > 0 ? course.imageHeight : 160,
                  child: course.imageUrl.startsWith('data:')
                      ? Builder(builder: (_) {
                          try {
                            final b64 = course.imageUrl.split(',').last;
                            return Image.memory(base64Decode(b64), fit: course.boxFit, width: double.infinity, height: course.imageHeight > 0 ? course.imageHeight : 160);
                          } catch (_) {
                            return Image.network(course.imageUrl, fit: course.boxFit, errorBuilder: (_, __, ___) => Container(color: trackColor.withValues(alpha: 0.1), child: Icon(Icons.broken_image_rounded, color: trackColor)));
                          }
                        })
                      : Image.network(course.imageUrl, fit: course.boxFit, errorBuilder: (_, __, ___) => Container(color: trackColor.withValues(alpha: 0.1), child: Icon(Icons.broken_image_rounded, color: trackColor))),
                ),
              ),
            // Header with track color
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [trackColor.withValues(alpha: 0.15), trackColor.withValues(alpha: 0.05)],
                ),
                borderRadius: course.imageUrl.isNotEmpty ? BorderRadius.zero : const BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: trackColor.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      course.track == 'web' ? Icons.language_rounded : Icons.smartphone_rounded,
                      color: trackColor,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          course.title.getWithFallback(lang),
                          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 17),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          course.track == 'web' ? t('webDevelopment') : t('mobileDevelopment'),
                          style: const TextStyle(fontSize: 13, color: AppColors.grayMedium),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: (course.isFree ? AppColors.success : AppColors.warning).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(100),
                    ),
                    child: Text(
                      course.isFree ? t('free') : '${course.price}\$',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 13,
                        color: course.isFree ? AppColors.success : AppColors.warning,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Body
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    course.description.getWithFallback(lang),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: AppColors.grayMedium, height: 1.6, fontSize: 14),
                  ),
                  if (completedCount > 0) ...[
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Icon(Icons.check_circle_rounded, size: 16, color: AppColors.success),
                        const SizedBox(width: 6),
                        Text(
                          '$completedCount ${t('completed')}',
                          style: TextStyle(fontSize: 13, color: AppColors.success, fontWeight: FontWeight.w700),
                        ),
                        const Spacer(),
                        Icon(Icons.chevron_left_rounded, color: AppColors.grayLight),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════
// ERROR STATE
// ══════════════════════════════════════════════
class _ErrorState extends StatelessWidget {
  final String Function(String) t;
  final Object? error;
  const _ErrorState({required this.t, this.error});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 56, color: AppColors.danger),
            const SizedBox(height: 12),
            Text(t('error'), style: const TextStyle(fontWeight: FontWeight.w700)),
            if (error != null) ...[
              const SizedBox(height: 8),
              Text(error.toString(), textAlign: TextAlign.center, style: const TextStyle(fontSize: 12, color: AppColors.grayMedium)),
            ],
          ],
        ),
      ),
    );
  }
}