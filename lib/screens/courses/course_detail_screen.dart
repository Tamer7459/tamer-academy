import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/app_localizations.dart';
import '../../core/app_theme.dart';
import '../../models/access_request.dart';
import '../../models/homework_submission.dart';
import '../../state/app_state.dart';
import '../../models/app_user.dart';
import '../../models/course.dart';
import '../../models/lesson.dart';
import '../../services/database_service.dart';
import '../homeworks/my_homeworks_screen.dart';
import '../lessons/lesson_screen.dart';

class CourseDetailScreen extends StatefulWidget {
  final AppUser user;
  final Course course;

  const CourseDetailScreen({super.key, required this.user, required this.course});

  @override
  State<CourseDetailScreen> createState() => _CourseDetailScreenState();
}

class _CourseDetailScreenState extends State<CourseDetailScreen> {
  @override
  Widget build(BuildContext context) {
    final l10n = Localizations.of<AppLocalizations>(context, AppLocalizations)!;
    final t = l10n.t;
    final lang = l10n.languageCode;
    final db = context.watch<DatabaseService>();
    final hasAccess = widget.user.hasAccess(widget.course.id);

    // If no access and not free, show request banner directly without trying to load lessons (avoids permission-denied)
    if (!hasAccess && !widget.course.isFree) {
      return Scaffold(
        appBar: AppBar(
                title: Text(widget.course.title.getWithFallback(lang)),
                actions: [
                  Consumer<AppState>(
                    builder: (context, state, _) => IconButton(
                      tooltip: t('theme'),
                      icon: Icon(state.themeMode == ThemeMode.dark ? Icons.light_mode : Icons.dark_mode),
                      onPressed: () => context.read<AppState>().toggleTheme(),
                    ),
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
                ],
              ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              _CourseHeader(course: widget.course, lessonsCount: 0, completedCount: 0, hasAccess: hasAccess),
              _RequestAccessBanner(user: widget.user, course: widget.course),
            ],
          ),
        ),
      );
    }

    return StreamBuilder<List<Lesson>>(
      stream: db.lessonsStream(widget.course.id),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          final err = snapshot.error.toString();
          // If permission denied, show request banner instead of error
          if (err.contains('permission-denied') || err.contains('PERMISSION_DENIED')) {
            return Scaffold(
              appBar: AppBar(
                title: Text(widget.course.title.getWithFallback(lang)),
                actions: [
                  Consumer<AppState>(
                    builder: (context, state, _) => IconButton(
                      tooltip: t('theme'),
                      icon: Icon(state.themeMode == ThemeMode.dark ? Icons.light_mode : Icons.dark_mode),
                      onPressed: () => context.read<AppState>().toggleTheme(),
                    ),
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
                ],
              ),
              body: SingleChildScrollView(
                child: Column(
                  children: [
                    _CourseHeader(course: widget.course, lessonsCount: 0, completedCount: 0, hasAccess: hasAccess),
                    _RequestAccessBanner(user: widget.user, course: widget.course),
                  ],
                ),
              ),
            );
          }
          return Scaffold(
            appBar: AppBar(
                title: Text(widget.course.title.getWithFallback(lang)),
                actions: [
                  Consumer<AppState>(
                    builder: (context, state, _) => IconButton(
                      tooltip: t('theme'),
                      icon: Icon(state.themeMode == ThemeMode.dark ? Icons.light_mode : Icons.dark_mode),
                      onPressed: () => context.read<AppState>().toggleTheme(),
                    ),
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
                ],
              ),
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text('${t('error')}: ${snapshot.error}', textAlign: TextAlign.center),
              ),
            ),
          );
        }
        if (!snapshot.hasData) {
          return Scaffold(
            appBar: AppBar(
                title: Text(widget.course.title.getWithFallback(lang)),
                actions: [
                  Consumer<AppState>(
                    builder: (context, state, _) => IconButton(
                      tooltip: t('theme'),
                      icon: Icon(state.themeMode == ThemeMode.dark ? Icons.light_mode : Icons.dark_mode),
                      onPressed: () => context.read<AppState>().toggleTheme(),
                    ),
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
                ],
              ),
            body: const Center(child: CircularProgressIndicator()),
          );
        }
        final lessons = snapshot.data!;

        return StreamBuilder<Map<String, dynamic>>(
          stream: db.progressStream(widget.user.uid),
          builder: (context, progressSnap) {
            final progressData = progressSnap.data ?? {};
            final courseProgress = Map<String, dynamic>.from(progressData['courses'] as Map? ?? {});
            final courseData = Map<String, dynamic>.from(courseProgress[widget.course.id] as Map? ?? {});
            final completed = (courseData['completed'] as List?)?.cast<String>() ?? [];

            Lesson? firstIncomplete;
            for (final l in lessons) {
              if (!completed.contains(l.id)) {
                firstIncomplete = l;
                break;
              }
            }
            final ctaTarget = firstIncomplete ?? (lessons.isEmpty ? null : lessons.first);

            return Scaffold(
              appBar: AppBar(
                title: Text(widget.course.title.getWithFallback(lang)),
                actions: [
                  Consumer<AppState>(
                    builder: (context, state, _) => IconButton(
                      tooltip: t('theme'),
                      icon: Icon(state.themeMode == ThemeMode.dark ? Icons.light_mode : Icons.dark_mode),
                      onPressed: () => context.read<AppState>().toggleTheme(),
                    ),
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
                ],
              ),
              body: CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: _CourseHeader(
                      course: widget.course,
                      lessonsCount: lessons.length,
                      completedCount: completed.length,
                      hasAccess: hasAccess,
                    ),
                  ),
                  if (hasAccess || widget.course.isFree)
                    SliverToBoxAdapter(
                      child: _CourseHomeworkBanner(user: widget.user, course: widget.course),
                    ),
                  if (!hasAccess && !widget.course.isFree)
                    SliverToBoxAdapter(child: _RequestAccessBanner(user: widget.user, course: widget.course))
                  else if (lessons.isEmpty)
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: AppColors.tealPrimary.withValues(alpha: 0.08),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Icon(Icons.menu_book_rounded, size: 48, color: AppColors.tealPrimary.withValues(alpha: 0.4)),
                            ),
                            const SizedBox(height: 16),
                            Text(t('noLessons'), style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.grayMedium)),
                          ],
                        ),
                      ),
                    )
                  else
                    SliverPadding(
                      padding: const EdgeInsets.all(16),
                      sliver: SliverList.separated(
                        itemCount: lessons.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 10),
                        itemBuilder: (context, i) {
                          final lesson = lessons[i];
                          final isDone = completed.contains(lesson.id);
                          return _LessonTile(
                            course: widget.course,
                            lesson: lesson,
                            index: i + 1,
                            isDone: isDone,
                            onTap: () => _openLesson(lesson),
                          );
                        },
                      ),
                    ),
                ],
              ),
              bottomNavigationBar: hasAccess || widget.course.isFree
                  ? SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                        child: SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: FilledButton.icon(
                            onPressed: ctaTarget == null ? null : () => _openLesson(ctaTarget),
                            icon: const Icon(Icons.play_arrow_rounded, size: 24),
                            label: Text(t('startCourse'), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
                          ),
                        ),
                      ),
                    )
                  : null,
            );
          },
        );
      },
    );
  }

  void _openLesson(Lesson lesson) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => LessonScreen(
          user: widget.user,
          course: widget.course,
          lesson: lesson,
        ),
      ),
    );
  }

  void _showContactDialog(String Function(String) t) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        icon: const Icon(Icons.admin_panel_settings_rounded, size: 40),
        title: Text(t('buyRequest')),
        content: Text(t('purchaseMessage')),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(t('cancel')),
          ),
        ],
      ),
    );
  }
}

class _CourseHeader extends StatelessWidget {
  final Course course;
  final int lessonsCount;
  final int completedCount;
  final bool hasAccess;

  const _CourseHeader({
    required this.course,
    required this.lessonsCount,
    required this.completedCount,
    required this.hasAccess,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = Localizations.of<AppLocalizations>(context, AppLocalizations)!;
    final t = l10n.t;
    final lang = l10n.languageCode;
    final theme = Theme.of(context);
    const palette = [0xFF1A8A7A, 0xFF3BBFAE, 0xFFF5A623, 0xFF3B82F6, 0xFF8B5CF6, 0xFFEF4444];
    final baseTrackColor = AppTheme.track(context, course.track);
    final trackColor = (course.colorSeed >= 0 && course.colorSeed < palette.length) ? Color(palette[course.colorSeed]) : baseTrackColor;
    final progress = lessonsCount == 0 ? 0.0 : completedCount / lessonsCount;
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(bottom: BorderSide(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.3))),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (course.imageUrl.isNotEmpty)
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              child: SizedBox(
                width: double.infinity,
                height: course.imageHeight > 0 ? course.imageHeight : 200,
                child: course.imageUrl.startsWith('data:')
                    ? Builder(builder: (_) {
                        try {
                          final b64 = course.imageUrl.split(',').last;
                          return Image.memory(base64Decode(b64), fit: course.boxFit, width: double.infinity);
                        } catch (_) {
                          return Image.network(course.imageUrl, fit: course.boxFit, errorBuilder: (_, __, ___) => Container(color: trackColor.withValues(alpha: 0.1), child: Icon(Icons.broken_image_rounded, color: trackColor, size: 40)));
                        }
                      })
                    : Image.network(course.imageUrl, fit: course.boxFit, errorBuilder: (_, __, ___) => Container(color: trackColor.withValues(alpha: 0.1), child: Icon(Icons.broken_image_rounded, color: trackColor, size: 40))),
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [trackColor, trackColor.withValues(alpha: 0.7)],
                  ),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(color: trackColor.withValues(alpha: 0.25), blurRadius: 12, offset: const Offset(0, 4)),
                  ],
                ),
                child: Icon(
                  course.track == 'web' ? Icons.language_rounded : Icons.smartphone_rounded,
                  color: Colors.white,
                  size: 28,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      course.title.getWithFallback(lang),
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: isDark ? Colors.white : AppColors.navyText),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.layers_rounded, size: 14, color: AppColors.grayMedium),
                        const SizedBox(width: 4),
                        Text(
                          '${t('level')}: ${t(course.level)}',
                          style: TextStyle(color: AppColors.grayMedium, fontSize: 13),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: (course.isFree ? AppColors.success : AppColors.warning).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Text(
                  course.isFree ? t('free') : '${course.price} \$',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 13,
                    color: course.isFree ? AppColors.success : AppColors.warning,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            course.description.getWithFallback(lang),
            style: TextStyle(height: 1.6, color: AppColors.grayMedium, fontSize: 14),
          ),
          const SizedBox(height: 16),
          // Progress section
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.tealPrimary.withValues(alpha: isDark ? 0.1 : 0.06),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${(progress * 100).round()}%',
                            style: TextStyle(fontWeight: FontWeight.w900, color: AppColors.tealPrimary, fontSize: 15),
                          ),
                          Text(
                            '$completedCount/$lessonsCount ${t('lessons')}',
                            style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.grayMedium, fontSize: 13),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(100),
                        child: LinearProgressIndicator(
                          value: progress,
                          minHeight: 6,
                          backgroundColor: isDark ? Colors.white12 : AppColors.grayLight,
                          color: AppColors.tealPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
            ),
          ],
        ),
      );
  }
}

class _RequestAccessBanner extends StatefulWidget {
  final AppUser user;
  final Course course;
  const _RequestAccessBanner({required this.user, required this.course});

  @override
  State<_RequestAccessBanner> createState() => _RequestAccessBannerState();
}

class _RequestAccessBannerState extends State<_RequestAccessBanner> {
  bool _sending = false;

  Future<void> _sendRequest() async {
    if (_sending) return;
    setState(() => _sending = true);
    try {
      final db = context.read<DatabaseService>();
      final l10n = Localizations.of<AppLocalizations>(context, AppLocalizations)!;
      final lang = l10n.languageCode;
      final req = AccessRequest(
        id: '${widget.user.uid}_${widget.course.id}_${DateTime.now().microsecondsSinceEpoch}',
        userId: widget.user.uid,
        userName: widget.user.name,
        userEmail: widget.user.email,
        courseId: widget.course.id,
        courseTitle: widget.course.title.getWithFallback(lang),
        status: 'pending',
        createdAt: DateTime.now(),
      );
      await db.createAccessRequest(req);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.t('requestSent')), behavior: SnackBarBehavior.floating),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${Localizations.of<AppLocalizations>(context, AppLocalizations)!.t('unknownError')}: $e'), behavior: SnackBarBehavior.floating),
        );
      }
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = Localizations.of<AppLocalizations>(context, AppLocalizations)!;
    final t = l10n.t;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final db = context.watch<DatabaseService>();

    return StreamBuilder<List<AccessRequest>>(
      stream: db.userRequestsStream(widget.user.uid),
      builder: (context, snap) {
        final reqs = snap.data ?? [];
        final existing = reqs.where((r) => r.courseId == widget.course.id).toList();
        final hasPending = existing.any((r) => r.status == 'pending');
        final hasDenied = existing.any((r) => r.status == 'denied');

        return Container(
          width: double.infinity,
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isDark
                  ? [AppColors.warning.withValues(alpha: 0.12), AppColors.warning.withValues(alpha: 0.04)]
                  : [AppColors.peachStart.withValues(alpha: 0.1), AppColors.peachStart.withValues(alpha: 0.03)],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.warning.withValues(alpha: 0.2)),
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: hasPending ? AppColors.tealPrimary.withValues(alpha: 0.15) : AppColors.warning.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  hasPending ? Icons.hourglass_top_rounded : Icons.lock_rounded,
                  size: 36,
                  color: hasPending ? AppColors.tealPrimary : AppColors.warning,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                hasPending ? t('requestPending') : hasDenied ? t('requestDenied') : t('noAccess'),
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: isDark ? Colors.white : AppColors.navyText),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 6),
              Text(
                hasPending ? t('requestPendingHint') : hasDenied ? t('requestDeniedHint') : t('noAccessHint'),
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.grayMedium, height: 1.6),
              ),
              const SizedBox(height: 18),
              if (hasPending)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: AppColors.tealPrimary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.tealPrimary)),
                      const SizedBox(width: 10),
                      Text(t('pendingReview'), style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.tealPrimary)),
                    ],
                  ),
                )
              else
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: _sending ? null : _sendRequest,
                    icon: _sending
                        ? SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : const Icon(Icons.send_rounded),
                    label: Text(hasDenied ? t('resendRequest') : t('requestAccess'), style: const TextStyle(fontWeight: FontWeight.w800)),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _CourseHomeworkBanner extends StatelessWidget {
  final AppUser user;
  final Course course;
  const _CourseHomeworkBanner({required this.user, required this.course});

  @override
  Widget build(BuildContext context) {
    final l10n = Localizations.of<AppLocalizations>(context, AppLocalizations)!;
    final t = l10n.t;
    final db = context.watch<DatabaseService>();
    return StreamBuilder<List<HomeworkSubmission>>(
      stream: db.userHomeworkStream(user.uid),
      builder: (context, snap) {
        final all = snap.data ?? [];
        final courseSubs = all.where((s) => s.courseId == course.id).toList();
        final pending = courseSubs.where((s) => s.isPending).length;
        final reviewed = courseSubs.where((s) => s.isReviewed).length;
        return Container(
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.tealPrimary.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.tealPrimary.withValues(alpha: 0.15)),
          ),
          child: Row(
            children: [
              Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: AppColors.tealPrimary.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(10)), child: const Icon(Icons.assignment_rounded, color: AppColors.tealPrimary, size: 20)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(t('myHomeworks'), style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14)),
                  const SizedBox(height: 2),
                  Text('$reviewed/${courseSubs.length} ${t('homeworkReviewed')} • $pending ${t('homeworkPending')}', style: TextStyle(fontSize: 12, color: AppColors.grayMedium)),
                ]),
              ),
              FilledButton(
                onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => MyHomeworksScreen(user: user))),
                child: Text(t('myHomeworks')),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _LessonTile extends StatelessWidget {
  final Course course;
  final Lesson lesson;
  final int index;
  final bool isDone;
  final VoidCallback onTap;

  const _LessonTile({
    required this.course,
    required this.lesson,
    required this.index,
    required this.isDone,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = Localizations.of<AppLocalizations>(context, AppLocalizations)!;
    final lang = l10n.languageCode;
    final theme = Theme.of(context);
    final trackColor = AppTheme.track(context, course.track);
    final isDark = theme.brightness == Brightness.dark;

    final hasVideo = lesson.videoUrl.isNotEmpty;
    final hasCode = lesson.codeHtml.isNotEmpty || lesson.codeDart.isNotEmpty;
    final hasExercise = lesson.exercise?.hasExercise ?? false;
    final hasQuestions = lesson.hasQuestions;
    final hasHomework = lesson.hasHomeworkTask;

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDone
              ? AppColors.success.withValues(alpha: 0.3)
              : theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
        ),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 8, offset: const Offset(0, 2)),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                // Number / check avatar
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    gradient: isDone
                        ? LinearGradient(colors: [AppColors.success, AppColors.success.withValues(alpha: 0.7)])
                        : LinearGradient(colors: [trackColor, trackColor.withValues(alpha: 0.7)]),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: (isDone ? AppColors.success : trackColor).withValues(alpha: 0.25),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Center(
                    child: isDone
                        ? const Icon(Icons.check_rounded, color: Colors.white, size: 22)
                        : Text('$index', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 16)),
                  ),
                ),
                const SizedBox(width: 14),
                // Title + icons
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        lesson.title.getWithFallback(lang),
                        style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: isDark ? Colors.white : AppColors.navyText),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          if (hasVideo) ...[
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColors.peachStart.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.play_circle_outline_rounded, size: 12, color: AppColors.peachStart),
                                  const SizedBox(width: 2),
                                  Text('Video', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.peachStart)),
                                ],
                              ),
                            ),
                          ],
                          if (hasVideo && (hasCode || hasQuestions || hasHomework)) const SizedBox(width: 6),
                          if (hasCode) ...[
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColors.tealPrimary.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.code_rounded, size: 12, color: AppColors.tealPrimary),
                                  const SizedBox(width: 2),
                                  Text('Code', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.tealPrimary)),
                                ],
                              ),
                            ),
                          ],
                          if (hasExercise) ...[
                            if (hasVideo || hasCode) const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColors.goldPrimary.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.edit_note_rounded, size: 12, color: AppColors.goldPrimary),
                                  const SizedBox(width: 2),
                                  Text(l10n.t('exercise'), style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.goldPrimary)),
                                ],
                              ),
                            ),
                          ],
                          if (hasQuestions) ...[
                            if (hasVideo || hasCode || hasExercise) const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: Color(0xFF8B5CF6).withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.record_voice_over_rounded, size: 12, color: Color(0xFF8B5CF6)),
                                  const SizedBox(width: 2),
                                  Text(l10n.t('oralQuestions'), style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Color(0xFF8B5CF6))),
                                ],
                              ),
                            ),
                          ],
                          if (hasHomework) ...[
                            if (hasVideo || hasCode || hasExercise || hasQuestions) const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColors.warning.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.assignment_rounded, size: 12, color: AppColors.warning),
                                  const SizedBox(width: 2),
                                  Text(l10n.t('homework'), style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.warning)),
                                ],
                              ),
                            ),
                          ],
                          if (!hasVideo && !hasCode && !hasExercise && !hasQuestions && !hasHomework) ...[
                            Text(
                              isDone ? l10n.t('completed') : l10n.t('lesson'),
                              style: TextStyle(fontSize: 12, color: AppColors.grayMedium),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
                // Status
                if (isDone)
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: AppColors.success.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.check_circle_rounded, size: 20, color: AppColors.success),
                  )
                else
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: AppColors.tealPrimary.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(Icons.chevron_right_rounded, size: 20, color: AppColors.tealPrimary),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}