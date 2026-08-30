import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/app_localizations.dart';
import '../core/app_theme.dart';
import '../models/course.dart';
import '../models/homework_submission.dart';
import '../models/lesson.dart';
import '../services/database_service.dart';
import 'lesson_content_renderer.dart';

class HomeworkWidget extends StatefulWidget {
  final Lesson lesson;
  final Course course;
  final String userId;
  final String userName;
  final String userEmail;
  const HomeworkWidget({
    super.key,
    required this.lesson,
    required this.course,
    required this.userId,
    required this.userName,
    required this.userEmail,
  });

  @override
  State<HomeworkWidget> createState() => _HomeworkWidgetState();
}

class _HomeworkWidgetState extends State<HomeworkWidget> {
  final _ctrl = TextEditingController();
  bool _sending = false;

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final l10n = Localizations.of<AppLocalizations>(context, AppLocalizations)!;
    final t = l10n.t;
    final lang = l10n.languageCode;
    final code = _ctrl.text.trim();
    if (code.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(t('homeworkEmptyError'))));
      return;
    }
    setState(() => _sending = true);
    try {
      final db = context.read<DatabaseService>();
      final sub = HomeworkSubmission(
        id: '${widget.userId}_${widget.lesson.id}_${DateTime.now().microsecondsSinceEpoch}',
        userId: widget.userId,
        userName: widget.userName,
        userEmail: widget.userEmail,
        courseId: widget.course.id,
        courseTitle: widget.course.title.getWithFallback(lang),
        lessonId: widget.lesson.id,
        lessonTitle: widget.lesson.title.getWithFallback(lang),
        codeAnswer: code,
        status: 'pending',
        createdAt: DateTime.now(),
      );
      await db.submitHomework(sub);
      if (mounted) {
        _ctrl.clear();
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(t('homeworkSent')), backgroundColor: AppColors.success));
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${t('unknownError')}: $e')));
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  Color _gradeColor(double? g) {
    if (g == null) return AppColors.grayMedium;
    if (g >= 8) return AppColors.success;
    if (g >= 5) return AppColors.warning;
    return AppColors.danger;
  }

  String _formatGrade(double? g) {
    if (g == null) return '';
    final s = g.toStringAsFixed(g.truncateToDouble() == g ? 0 : 2);
    return s.replaceAll('.', ',');
  }

  @override
  Widget build(BuildContext context) {
    final l10n = Localizations.of<AppLocalizations>(context, AppLocalizations)!;
    final t = l10n.t;
    final lang = l10n.languageCode;
    final theme = Theme.of(context);
    final db = context.watch<DatabaseService>();

    if (!widget.lesson.hasHomeworkTask) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Center(
            child: Column(children: [
              Icon(Icons.assignment_outlined, size: 48, color: AppColors.grayLight),
              const SizedBox(height: 12),
              Text(t('noContent'), style: TextStyle(color: AppColors.grayMedium, fontWeight: FontWeight.w700)),
              const SizedBox(height: 6),
              Text(t('hasHomework'), style: TextStyle(fontSize: 12, color: AppColors.grayLight)),
            ]),
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHeader(icon: Icons.assignment_rounded, title: t('homework')),
        const SizedBox(height: 12),
        Card(
          margin: EdgeInsets.zero,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: LessonContentRenderer(content: widget.lesson.homeworkPrompt.getWithFallback(lang), lang: lang),
          ),
        ),
        const SizedBox(height: 16),
        Text(t('homeworkHint'), style: TextStyle(fontSize: 12, color: AppColors.grayMedium, fontStyle: FontStyle.italic)),
        const SizedBox(height: 8),
        TextField(
          controller: _ctrl,
          maxLines: 12,
          minLines: 8,
          style: const TextStyle(fontFamily: 'monospace', fontSize: 13, height: 1.6),
          decoration: InputDecoration(
            hintText: t('writeCodeHere'),
            alignLabelWithHint: true,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            filled: true,
            fillColor: theme.colorScheme.surface,
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            onPressed: _sending ? null : _submit,
            icon: _sending ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Icon(Icons.send_rounded),
            label: Text(t('submitHomework')),
          ),
        ),
        const SizedBox(height: 20),
        _SectionHeader(icon: Icons.history_rounded, title: t('homeworkSubmissions')),
        const SizedBox(height: 12),
        StreamBuilder<List<HomeworkSubmission>>(
          stream: db.lessonHomeworkStream(widget.lesson.id, widget.userId),
          builder: (context, snap) {
            if (snap.hasError) return Text('${t('error')}: ${snap.error}');
            if (!snap.hasData) return const Center(child: CircularProgressIndicator());
            final subs = snap.data!;
            if (subs.isEmpty) {
              return Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: AppColors.grayLight.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(12)),
                child: Row(children: [Icon(Icons.inbox_rounded, color: AppColors.grayMedium), const SizedBox(width: 10), Text(t('noSubmissions'), style: TextStyle(color: AppColors.grayMedium, fontWeight: FontWeight.w600))]),
              );
            }
            return Column(
              children: subs.map((s) {
                final isReviewed = s.isReviewed;
                return Card(
                  margin: const EdgeInsets.only(bottom: 10),
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Row(children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(color: (isReviewed ? AppColors.success : AppColors.warning).withValues(alpha: 0.12), borderRadius: BorderRadius.circular(100)),
                          child: Row(mainAxisSize: MainAxisSize.min, children: [
                            Icon(isReviewed ? Icons.check_circle_rounded : Icons.hourglass_top_rounded, size: 14, color: isReviewed ? AppColors.success : AppColors.warning),
                            const SizedBox(width: 4),
                            Text(isReviewed ? t('homeworkReviewed') : t('homeworkPending'), style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: isReviewed ? AppColors.success : AppColors.warning)),
                          ]),
                        ),
                        const Spacer(),
                        Text('${s.createdAt.day}/${s.createdAt.month} ${s.createdAt.hour}:${s.createdAt.minute.toString().padLeft(2, '0')}', style: TextStyle(fontSize: 11, color: AppColors.grayMedium)),
                      ]),
                      if (isReviewed && s.grade != null) ...[
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(color: _gradeColor(s.grade).withValues(alpha: 0.12), borderRadius: BorderRadius.circular(10)),
                          child: Row(mainAxisSize: MainAxisSize.min, children: [
                            Icon(Icons.star_rounded, size: 16, color: _gradeColor(s.grade)),
                            const SizedBox(width: 4),
                            Text('${t('grade')}: ${_formatGrade(s.grade)}/10', style: TextStyle(fontWeight: FontWeight.w800, color: _gradeColor(s.grade))),
                          ]),
                        ),
                      ],
                      const SizedBox(height: 10),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(color: theme.colorScheme.surface, border: Border.all(color: theme.dividerColor.withValues(alpha: 0.15)), borderRadius: BorderRadius.circular(12)),
                        child: SelectableText(s.codeAnswer, style: const TextStyle(fontFamily: 'monospace', fontSize: 13, height: 1.7)),
                      ),
                      if (isReviewed && s.feedback.isNotEmpty) ...[
                        const SizedBox(height: 10),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(color: AppColors.tealPrimary.withValues(alpha: 0.06), borderRadius: BorderRadius.circular(10)),
                          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Row(children: [Icon(Icons.comment_rounded, size: 14, color: AppColors.tealPrimary), const SizedBox(width: 6), Text(t('feedback'), style: TextStyle(fontWeight: FontWeight.w800, fontSize: 12, color: AppColors.tealPrimary))]),
                            const SizedBox(height: 6),
                            Text(s.feedback, style: const TextStyle(fontSize: 13, height: 1.6)),
                          ]),
                        ),
                      ] else if (isReviewed) ...[
                        const SizedBox(height: 8),
                        Text(t('noFeedback'), style: TextStyle(fontSize: 12, color: AppColors.grayMedium, fontStyle: FontStyle.italic)),
                      ],
                    ]),
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

class _SectionHeader extends StatelessWidget {
  final IconData icon;
  final String title;
  const _SectionHeader({required this.icon, required this.title});
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(children: [Icon(icon, size: 20, color: theme.colorScheme.primary), const SizedBox(width: 8), Text(title, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900))]);
  }
}
