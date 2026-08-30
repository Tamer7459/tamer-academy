import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/app_localizations.dart';
import '../../core/app_theme.dart';
import '../../models/app_user.dart';
import '../../state/app_state.dart';
import '../../models/course.dart';
import '../../models/lesson.dart';
import '../../services/database_service.dart';
import '../../widgets/code_result_viewer.dart';
import '../../widgets/exercise_widget.dart';
import '../../widgets/homework_widget.dart';
import '../../widgets/lesson_content_renderer.dart';
import '../../widgets/questions_widget.dart';
import '../admin/lesson_edit_screen.dart';

class LessonScreen extends StatefulWidget {
  final AppUser user;
  final Course course;
  final Lesson lesson;

  const LessonScreen({
    super.key,
    required this.user,
    required this.course,
    required this.lesson,
  });

  @override
  State<LessonScreen> createState() => _LessonScreenState();
}

class _LessonScreenState extends State<LessonScreen> {
  bool _completed = false;
  bool _answered = false;
  bool _isAdmin = false;
  int _tab = 0;

  @override
  void initState() {
    super.initState();
    _isAdmin = widget.user.isAdmin;
    _loadState();
  }

  Future<void> _loadState() async {
    final db = context.read<DatabaseService>();
    final completed =
        await db.isLessonCompleted(widget.user.uid, widget.course.id, widget.lesson.id);
    final answered =
        await db.isLessonAnswered(widget.user.uid, widget.course.id, widget.lesson.id);
    if (mounted) {
      setState(() {
        _completed = completed;
        _answered = answered;
      });
    }
  }

  Future<void> _markComplete() async {
    final db = context.read<DatabaseService>();
    await db.markLessonCompleted(widget.user.uid, widget.course.id, widget.lesson.id);
    if (mounted) setState(() => _completed = true);
  }

  Future<void> _toggleComplete() async {
    final db = context.read<DatabaseService>();
    final newValue = !_completed;
    await db.toggleLessonCompleted(widget.user.uid, widget.course.id, widget.lesson.id, newValue);
    if (mounted) setState(() => _completed = newValue);
  }

  void _goToLesson(BuildContext context, Lesson lesson) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => LessonScreen(
          user: widget.user,
          course: widget.course,
          lesson: lesson,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = Localizations.of<AppLocalizations>(context, AppLocalizations)!;
    final t = l10n.t;
    final lang = l10n.languageCode;
    final lesson = widget.lesson;
    final db = context.watch<DatabaseService>();

    return StreamBuilder<List<Lesson>>(
      stream: db.lessonsStream(widget.course.id),
      builder: (context, lessonsSnap) {
        final lessons = lessonsSnap.data ?? [];
        final index = lessons.indexWhere((l) => l.id == lesson.id);
        final hasPrev = index > 0;
        final hasNext = index >= 0 && index < lessons.length - 1;

        // Dynamic tabs: only show non-empty categories
        final hasExercise = lesson.exercise?.hasExercise ?? false;
        final hasQuestions = lesson.hasQuestions;
        final hasHomework = lesson.hasHomeworkTask;
        final tabTypes = <String>['content'];
        if (hasExercise) tabTypes.add('exercise');
        if (hasQuestions) tabTypes.add('oral');
        if (hasHomework) tabTypes.add('homework');
        final tabsLength = tabTypes.length;
        // clamp _tab to visible range
        final visibleTab = _tab.clamp(0, tabsLength - 1);

        return DefaultTabController(
          length: tabsLength,
          initialIndex: visibleTab,
          child: Scaffold(
          appBar: AppBar(
            title: Text(
              lesson.title.getWithFallback(lang),
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
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
              if (_isAdmin)
                IconButton(
                  tooltip: t('edit'),
                  icon: const Icon(Icons.edit_rounded),
                  onPressed: () async {
                    await Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => LessonEditScreen(course: widget.course, lesson: lesson)),
                    );
                    if (mounted) setState(() {});
                  },
                ),
              if (_completed)
                const Padding(
                  padding: EdgeInsets.only(right: 16),
                  child: Icon(Icons.check_circle_rounded, color: AppColors.success),
                ),
            ],
          ),
          body: Column(
            children: [
              _buildTabs(t: t, lesson: lesson, tabTypes: tabTypes),
              Expanded(
                child: Builder(
                  builder: (context) {
                    final currentType = tabTypes[visibleTab];
                    return ListView(
                      padding: const EdgeInsets.all(16),
                      children: [
                        if (currentType == 'content') ...[
                          if (lesson.videoUrl.isNotEmpty) ...[
                            _SectionHeader(icon: Icons.ondemand_video_rounded, title: t('video')),
                            const SizedBox(height: 10),
                            CodeResultViewer(
                              type: CodeResultType.html,
                              videoUrl: lesson.videoUrl,
                            ),
                            const SizedBox(height: 24),
                          ],
                          _SectionHeader(icon: Icons.menu_book_rounded, title: t('lessonContent')),
                          const SizedBox(height: 12),
                          Card(
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Builder(
                                builder: (context) {
                                  final displayContent = lesson.content.getWithFallback(lang);
                                  final isFallback = lesson.content.isEmptyFor(lang) && !lesson.content.isEmpty;
                                  if (displayContent.trim().isEmpty) {
                                    return Center(
                                      child: Padding(
                                        padding: const EdgeInsets.all(24),
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(Icons.article_outlined, size: 48, color: AppColors.grayLight),
                                            const SizedBox(height: 12),
                                            Text(t('noContent'), style: TextStyle(color: AppColors.grayMedium, fontStyle: FontStyle.italic)),
                                            if (_isAdmin) ...[
                                              const SizedBox(height: 16),
                                              FilledButton.icon(
                                                onPressed: () async {
                                                  final db = context.read<DatabaseService>();
                                                  final course = widget.course;
                                                  await Navigator.of(context).push(
                                                    MaterialPageRoute(builder: (_) => LessonEditScreen(course: course, lesson: lesson)),
                                                  );
                                                  if (context.mounted) setState(() {});
                                                },
                                                icon: const Icon(Icons.edit_rounded, size: 18),
                                                label: Text(t('edit')),
                                              ),
                                            ],
                                          ],
                                        ),
                                      ),
                                    );
                                  }
                                  return Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      if (isFallback)
                                        Container(
                                          margin: const EdgeInsets.only(bottom: 12),
                                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                          decoration: BoxDecoration(
                                            color: AppColors.warning.withValues(alpha: 0.12),
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(Icons.translate_rounded, size: 14, color: AppColors.warning),
                                              const SizedBox(width: 6),
                                              Text(t('showingFallbackLang'), style: TextStyle(fontSize: 12, color: AppColors.warning, fontWeight: FontWeight.w600)),
                                            ],
                                          ),
                                        ),
                                      LessonContentRenderer(
                                        content: displayContent,
                                        lang: lang,
                                      ),
                                    ],
                                  );
                                },
                              ),
                            ),
                          ),
                        ] else if (currentType == 'exercise') ...[
                          ExerciseWidget(
                            lesson: lesson,
                            course: widget.course,
                            user: widget.user,
                            isAdmin: _isAdmin,
                            alreadyAnswered: _answered,
                            onAnswered: () async {
                              await db.markLessonAnswered(widget.user.uid, widget.course.id, lesson.id);
                              if (mounted) setState(() => _answered = true);
                            },
                          ),
                        ] else if (currentType == 'oral') ...[
                          QuestionsWidget(lesson: lesson, userId: widget.user.uid),
                        ] else if (currentType == 'homework') ...[
                          HomeworkWidget(
                            lesson: lesson,
                            course: widget.course,
                            userId: widget.user.uid,
                            userName: widget.user.name,
                            userEmail: widget.user.email,
                          ),
                        ],
                    const SizedBox(height: 24),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      alignment: WrapAlignment.spaceBetween,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        if (hasPrev)
                          OutlinedButton.icon(
                            onPressed: () => _goToLesson(context, lessons[index - 1]),
                            icon: const Icon(Icons.arrow_back_rounded, size: 18),
                            label: Text(t('previousLesson')),
                          ),
                        FilledButton.icon(
                          onPressed: _toggleComplete,
                          icon: Icon(_completed ? Icons.cancel_rounded : Icons.check_circle_outline_rounded, size: 18),
                          label: Text(_completed ? t('markIncomplete') : t('markComplete')),
                          style: FilledButton.styleFrom(
                            backgroundColor: _completed ? AppColors.grayMedium : AppColors.success,
                          ),
                        ),
                        if (hasNext)
                          FilledButton.icon(
                            onPressed: () => _goToLesson(context, lessons[index + 1]),
                            iconAlignment: IconAlignment.end,
                            icon: const Icon(Icons.arrow_forward_rounded, size: 18),
                            label: Text(t('nextLesson')),
                          ),
                      ],
                    ),
                    const SizedBox(height: 24),
                  ],
                );
                  },
                ),
              ),
            ],
          ),
          ),
        );
      },
    );
  }

  Widget _buildTabs({required String Function(String) t, required Lesson lesson, required List<String> tabTypes}) {
    final tabs = <Widget>[];
    for (final type in tabTypes) {
      if (type == 'content') {
        tabs.add(Tab(child: Row(mainAxisSize: MainAxisSize.min, children: [const Icon(Icons.menu_book_rounded, size: 16), const SizedBox(width: 6), Text(t('lessonContent'))])));
      } else if (type == 'exercise') {
        tabs.add(Tab(child: Row(mainAxisSize: MainAxisSize.min, children: [const Icon(Icons.edit_note_rounded, size: 16), const SizedBox(width: 6), Text(t('exercise'))])));
      } else if (type == 'oral') {
        tabs.add(Tab(child: Row(mainAxisSize: MainAxisSize.min, children: [const Icon(Icons.record_voice_over_rounded, size: 16), const SizedBox(width: 6), Text(t('oralQuestions'))])));
      } else if (type == 'homework') {
        tabs.add(Tab(child: Row(mainAxisSize: MainAxisSize.min, children: [const Icon(Icons.assignment_rounded, size: 16), const SizedBox(width: 6), Text(t('homework'))])));
      }
    }

    // If only one tab, hide TabBar and stretch content
    if (tabs.length <= 1) return const SizedBox.shrink();

    return Material(
      color: Theme.of(context).colorScheme.surface,
      child: TabBar(
        tabs: tabs,
        onTap: (i) => setState(() => _tab = i),
        dividerColor: Theme.of(context).colorScheme.surface,
        // stretch remaining tabs when some are hidden
        isScrollable: false,
        labelPadding: const EdgeInsets.symmetric(horizontal: 12),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final IconData icon;
  final String title;

  const _SectionHeader({required this.icon, required this.title});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Icon(icon, size: 20, color: theme.colorScheme.primary),
        const SizedBox(width: 8),
        Text(
          title,
          style: theme.textTheme.titleMedium,
        ),
      ],
    );
  }
}

Color themeDimmed(BuildContext context) {
  return Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.72);
}