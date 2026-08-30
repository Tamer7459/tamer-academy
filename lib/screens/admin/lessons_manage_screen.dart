import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/app_localizations.dart';
import '../../core/app_theme.dart';
import '../../data/track1_seed.dart';
import '../../data/track2_seed.dart';
import '../../models/app_user.dart';
import '../../models/course.dart';
import '../../models/lesson.dart';
import '../../services/database_service.dart';
import 'lesson_edit_screen.dart';

class LessonsManageScreen extends StatelessWidget {
  final AppUser user;
  final Course course;

  const LessonsManageScreen({super.key, required this.user, required this.course});

  @override
  Widget build(BuildContext context) {
    final l10n = Localizations.of<AppLocalizations>(context, AppLocalizations)!;
    final t = l10n.t;
    final lang = l10n.languageCode;
    final db = context.watch<DatabaseService>();

    return Scaffold(
      appBar: AppBar(
        title: Text('${t('manageLessons')} — ${course.title.getWithFallback(lang)}'),
      ),
      body: StreamBuilder<List<Lesson>>(
        stream: db.lessonsStream(course.id),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Padding(padding: const EdgeInsets.all(16), child: Text('${t('error')}: ${snapshot.error}', textAlign: TextAlign.center)));
          }
          final lessons = snapshot.data ?? [];
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final hasT1 = lessons.any((l) => l.id.contains('_t1_'));
          final hasT2 = lessons.any((l) => l.id.contains('_t2_'));
          final isFlutterCourse = course.title.ar.contains('موبايل') || course.title.en.toLowerCase().contains('mobile') || course.title.en.toLowerCase().contains('flutter') || course.track.toLowerCase().contains('mobile');
          if (lessons.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.playlist_play_rounded,
                        size: 48, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.3)),
                    const SizedBox(height: 12),
                    Text(t('noLessons'), style: const TextStyle(fontWeight: FontWeight.w700)),
                    const SizedBox(height: 20),
                    FilledButton.icon(
                      onPressed: () => _seedTrack1(context),
                      icon: const Icon(Icons.auto_awesome_rounded),
                      label: const Text('تثبيت Track 1: Dart Foundations (7 دروس)'),
                      style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14)),
                    ),
                    const SizedBox(height: 10),
                    FilledButton.icon(
                      onPressed: () => _seedTrack2(context),
                      icon: const Icon(Icons.view_quilt_rounded),
                      label: const Text('تثبيت Track 2: Flutter UI (7 دروس)'),
                      style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14)),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'اختر المسار المطلوب. يمكنك تثبيت كليهما بالتتابع.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6), fontSize: 13, height: 1.6),
                    ),
                  ],
                ),
              ),
            );
          }
          final showTrack2Banner = hasT1 && !hasT2 && isFlutterCourse;
          return Column(
            children: [
              if (showTrack2Banner)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                  child: Card(
                    color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.08),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        children: [
                          Icon(Icons.auto_awesome_rounded, color: Theme.of(context).colorScheme.primary),
                          const SizedBox(width: 10),
                          Expanded(child: Text('Track 1 مثبت. هل تريد إضافة Track 2 (Flutter UI)؟', style: TextStyle(fontWeight: FontWeight.w700))),
                          FilledButton(onPressed: () => _seedTrack2(context), child: const Text('تثبيت Track 2')),
                        ],
                      ),
                    ),
                  ),
                ),
              Expanded(
                child: ReorderableListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: lessons.length,
            onReorderItem: (oldIndex, newIndex) async {
              final reordered = List<Lesson>.from(lessons);
              final item = reordered.removeAt(oldIndex);
              reordered.insert(newIndex, item);
              for (var i = 0; i < reordered.length; i++) {
                final l = reordered[i];
                await db.saveLesson(l.copyWith(order: i));
              }
            },
            itemBuilder: (context, i) {
              final lesson = lessons[i];
              return Card(
                key: ValueKey(lesson.id),
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.12),
                    child: Text('${i + 1}', style: const TextStyle(fontWeight: FontWeight.w800)),
                  ),
                  title: Text(
                    lesson.title.getWithFallback(lang),
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  subtitle: Row(
                    children: [
                      if (lesson.videoUrl.isNotEmpty) const Icon(Icons.ondemand_video_rounded, size: 14),
                      if (lesson.codeHtml.isNotEmpty || lesson.codeDart.isNotEmpty) ...[
                        const SizedBox(width: 6),
                        const Icon(Icons.code_rounded, size: 14),
                      ],
                      if (lesson.exercise?.hasExercise ?? false) ...[
                        const SizedBox(width: 6),
                        const Icon(Icons.edit_note_rounded, size: 14),
                      ],
                      if (lesson.hasQuestions) ...[
                        const SizedBox(width: 6),
                        const Icon(Icons.record_voice_over_rounded, size: 14),
                      ],
                      if (lesson.hasHomeworkTask) ...[
                        const SizedBox(width: 6),
                        const Icon(Icons.assignment_rounded, size: 14),
                      ],
                      if (lesson.hasQuestions)
                        Padding(
                          padding: const EdgeInsets.only(left: 6),
                          child: Text('${lesson.validQuestionsCount}', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
                        ),
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit_rounded),
                        onPressed: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => LessonEditScreen(course: course, lesson: lesson),
                          ),
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.delete_rounded,
                            color: AppColors.danger),
                        onPressed: () => _confirmDelete(context, lesson),
                      ),
                      const Icon(Icons.drag_handle_rounded),
                    ],
                  ),
                ),
              );
            },
          ),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _seedTrack1(BuildContext context) async {
    final l10n = Localizations.of<AppLocalizations>(context, AppLocalizations)!;
    final t = l10n.t;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (d) => AlertDialog(
        title: const Text('تثبيت Track 1؟'),
        content: const Text('سيتم إنشاء 7 دروس: Toolchain, Core Syntax, Variables, Control Flow, OOP, Null Safety, Streams. هل أنت متأكد؟'),
        actions: [
          TextButton(onPressed: () => Navigator.of(d).pop(false), child: Text(t('cancel'))),
          FilledButton(onPressed: () => Navigator.of(d).pop(true), child: Text(t('confirm'))),
        ],
      ),
    );
    if (confirm != true) return;
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('جاري تثبيت الدروس...'), behavior: SnackBarBehavior.floating));
    try {
      final db = context.read<DatabaseService>();
      final lessons = buildTrack1Lessons(course.id);
      for (final l in lessons) {
        // ignore: use_build_context_synchronously
        await db.saveLesson(l);
      }
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تمت إضافة 7 دروس بنجاح ✓'), behavior: SnackBarBehavior.floating));
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${t('unknownError')}: $e'), behavior: SnackBarBehavior.floating));
      }
    }
  }

  Future<void> _seedTrack2(BuildContext context) async {
    final l10n = Localizations.of<AppLocalizations>(context, AppLocalizations)!;
    final t = l10n.t;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (d) => AlertDialog(
        title: const Text('تثبيت Track 2؟'),
        content: const Text('سيتم إنشاء 7 دروس: Project Structure, Layout, UI Elements, Input & Forms, Grids/Lists, Theming, Responsive. هل أنت متأكد؟'),
        actions: [
          TextButton(onPressed: () => Navigator.of(d).pop(false), child: Text(t('cancel'))),
          FilledButton(onPressed: () => Navigator.of(d).pop(true), child: Text(t('confirm'))),
        ],
      ),
    );
    if (confirm != true) return;
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('جاري تثبيت دروس Track 2...'), behavior: SnackBarBehavior.floating));
    try {
      final db = context.read<DatabaseService>();
      final lessons = buildTrack2Lessons(course.id);
      for (final l in lessons) {
        // ignore: use_build_context_synchronously
        await db.saveLesson(l);
      }
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تمت إضافة 7 دروس Track 2 بنجاح ✓'), behavior: SnackBarBehavior.floating));
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${t('unknownError')}: $e'), behavior: SnackBarBehavior.floating));
      }
    }
  }

  void _confirmDelete(BuildContext context, Lesson lesson) {
    final l10n = Localizations.of<AppLocalizations>(context, AppLocalizations)!;
    final t = l10n.t;
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(t('deleteConfirm')),
        content: Text('${t('deleteLessonWarning')}\n\n${lesson.title.en}'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(t('cancel')),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.danger,
            ),
            onPressed: () async {
              await context.read<DatabaseService>().deleteLesson(lesson.id);
              if (dialogContext.mounted) Navigator.of(dialogContext).pop();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(t('deleted')),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
            child: Text(t('delete')),
          ),
        ],
      ),
    );
  }
}