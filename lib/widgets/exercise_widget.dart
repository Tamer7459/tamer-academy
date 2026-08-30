import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/app_localizations.dart';
import '../core/app_theme.dart';
import '../models/app_user.dart';
import '../models/course.dart';
import '../models/exercise_submission.dart';
import '../models/lesson.dart';
import '../services/database_service.dart';
import 'lesson_content_renderer.dart';

class ExerciseWidget extends StatefulWidget {
  final Lesson lesson;
  final Course course;
  final AppUser user;
  final bool isAdmin;
  final bool alreadyAnswered;
  final VoidCallback onAnswered;

  const ExerciseWidget({
    super.key,
    required this.lesson,
    required this.course,
    required this.user,
    required this.isAdmin,
    required this.alreadyAnswered,
    required this.onAnswered,
  });

  @override
  State<ExerciseWidget> createState() => _ExerciseWidgetState();
}

class _ExerciseWidgetState extends State<ExerciseWidget> {
  int? _selected;
  bool _showSolution = false;
  bool _sending = false;
  late final TextEditingController _answerController = TextEditingController();

  @override
  void dispose() {
    _answerController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final l10n = Localizations.of<AppLocalizations>(context, AppLocalizations)!;
    final t = l10n.t;
    final lang = l10n.languageCode;
    final exercise = widget.lesson.exercise!;
    final isMCQ = exercise.options.isNotEmpty;
    final answerText = isMCQ
        ? ( _selected != null ? exercise.options[_selected!].getWithFallback(lang) : '')
        : _answerController.text.trim();

    if (isMCQ && _selected == null) return;
    if (!isMCQ && answerText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(t('homeworkEmptyError'))));
      return;
    }

    setState(() => _sending = true);
    try {
      final db = context.read<DatabaseService>();
      final isCorrect = isMCQ ? _selected == exercise.answerIndex : false;
      final sub = ExerciseSubmission(
        id: '${widget.user.uid}_${widget.lesson.id}_${DateTime.now().microsecondsSinceEpoch}',
        userId: widget.user.uid,
        userName: widget.user.name,
        userEmail: widget.user.email,
        courseId: widget.course.id,
        courseTitle: widget.course.title.getWithFallback(lang),
        lessonId: widget.lesson.id,
        lessonTitle: widget.lesson.title.getWithFallback(lang),
        answerText: answerText,
        selectedOptionIndex: _selected,
        isCorrect: isCorrect,
        status: 'pending',
        createdAt: DateTime.now(),
      );
      await db.submitExercise(sub);
      if (!widget.alreadyAnswered) {
        await db.markLessonAnswered(widget.user.uid, widget.course.id, widget.lesson.id);
        widget.onAnswered();
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(t('homeworkSent')), backgroundColor: AppColors.success));
        setState(() {
          _selected = null;
          _answerController.clear();
        });
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
    final exercise = widget.lesson.exercise!;
    final isMCQ = exercise.options.isNotEmpty;
    final db = context.watch<DatabaseService>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHeader(icon: Icons.edit_note_rounded, title: t('exercise')),
        const SizedBox(height: 12),
        Card(
          margin: EdgeInsets.zero,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                LessonContentRenderer(content: exercise.question.getWithFallback(lang), lang: lang),
                const SizedBox(height: 16),
                if (isMCQ) ...[
                  ...List.generate(exercise.options.length, (i) {
                    final option = exercise.options[i];
                    final isSelected = _selected == i;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: InkWell(
                        onTap: () => setState(() => _selected = i),
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isSelected ? theme.colorScheme.primary : theme.colorScheme.outlineVariant.withValues(alpha: 0.6),
                              width: isSelected ? 2 : 1,
                            ),
                            color: isSelected ? theme.colorScheme.primary.withValues(alpha: 0.08) : theme.colorScheme.surface,
                          ),
                          child: Row(
                            children: [
                              Icon(isSelected ? Icons.radio_button_checked_rounded : Icons.radio_button_unchecked_rounded, color: isSelected ? theme.colorScheme.primary : themeDimmed(context), size: 20),
                              const SizedBox(width: 12),
                              Expanded(child: Text(option.getWithFallback(lang), style: TextStyle(fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500))),
                            ],
                          ),
                        ),
                      ),
                    );
                  }),
                ] else ...[
                  TextField(
                    controller: _answerController,
                    maxLines: 6,
                    minLines: 3,
                    decoration: InputDecoration(
                      hintText: t('writeSolutionHere'),
                      hintStyle: TextStyle(color: AppColors.grayLight),
                      alignLabelWithHint: true,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      filled: true,
                      fillColor: theme.colorScheme.surface,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(t('exerciseHint'), style: TextStyle(fontSize: 12, color: AppColors.grayMedium, fontStyle: FontStyle.italic)),
                ],
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: _sending ? null : (isMCQ ? (_selected == null ? null : _submit) : _submit),
                    icon: _sending ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Icon(Icons.send_rounded),
                    label: Text(t('submitAnswer')),
                  ),
                ),
                const SizedBox(height: 8),
                Text('يمكنك الإرسال أكثر من مرة — سيتم حفظ كل محاولة', style: TextStyle(fontSize: 11, color: AppColors.grayMedium)),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        // Solution toggle
        Card(
          margin: EdgeInsets.zero,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                Row(
                  children: [
                    Icon(Icons.lightbulb_rounded, size: 18, color: AppColors.warning),
                    const SizedBox(width: 8),
                    Text(t('solution'), style: TextStyle(fontWeight: FontWeight.w800, color: AppColors.warning)),
                    const Spacer(),
                    OutlinedButton.icon(
                      onPressed: () => setState(() => _showSolution = !_showSolution),
                      icon: Icon(_showSolution ? Icons.visibility_off_rounded : Icons.visibility_rounded, size: 16),
                      label: Text(_showSolution ? t('hideSolution') : t('showSolution')),
                    ),
                  ],
                ),
                if (_showSolution) ...[
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: AppColors.warning.withValues(alpha: 0.06), borderRadius: BorderRadius.circular(10)),
                    child: LessonContentRenderer(content: exercise.solution.getWithFallback(lang), lang: lang),
                  ),
                ] else if (!widget.isAdmin) ...[
                  const SizedBox(height: 8),
                  Text(t('answerFirst'), style: TextStyle(fontSize: 12, color: AppColors.grayMedium, fontStyle: FontStyle.italic)),
                ],
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),
        _SectionHeader(icon: Icons.history_rounded, title: 'إرسالاتي'),
        const SizedBox(height: 12),
        StreamBuilder<List<ExerciseSubmission>>(
          stream: db.lessonExerciseStream(widget.lesson.id, widget.user.uid),
          builder: (context, snap) {
            if (snap.hasError) return Text('${t('error')}: ${snap.error}');
            if (!snap.hasData) return const Center(child: CircularProgressIndicator());
            final subs = snap.data!;
            if (subs.isEmpty) {
              return Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: AppColors.grayLight.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(12)),
                child: Row(children: [Icon(Icons.inbox_rounded, color: AppColors.grayMedium), const SizedBox(width: 10), Text('لا توجد إرسالات بعد — اكتب حلك وأرسل', style: TextStyle(color: AppColors.grayMedium, fontWeight: FontWeight.w600))]),
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
                        Text('${s.createdAt.day}/${s.createdAt.month} ${s.createdAt.hour}:${s.createdAt.minute.toString().padLeft(2,'0')}', style: TextStyle(fontSize: 11, color: AppColors.grayMedium)),
                      ]),
                      if (isReviewed && s.grade != null) ...[
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(color: _gradeColor(s.grade).withValues(alpha: 0.12), borderRadius: BorderRadius.circular(10)),
                          child: Row(mainAxisSize: MainAxisSize.min, children: [Icon(Icons.star_rounded, size: 16, color: _gradeColor(s.grade)), const SizedBox(width: 4), Text('${t('grade')}: ${_formatGrade(s.grade)}/10', style: TextStyle(fontWeight: FontWeight.w800, color: _gradeColor(s.grade)))]),
                        ),
                      ],
                      const SizedBox(height: 10),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(color: theme.colorScheme.surface, border: Border.all(color: theme.dividerColor.withValues(alpha: 0.15)), borderRadius: BorderRadius.circular(12)),
                        child: SelectableText(s.answerText, style: const TextStyle(fontSize: 13, height: 1.7)),
                      ),
                      if (isReviewed && s.selectedOptionIndex != null) ...[
                        const SizedBox(height: 6),
                        Text('اختيار: ${s.selectedOptionIndex! + 1} • ${s.isCorrect ? "✓ صحيح" : "✗ خاطئ"}', style: TextStyle(fontSize: 12, color: s.isCorrect ? AppColors.success : AppColors.danger, fontWeight: FontWeight.w700)),
                      ],
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

Color themeDimmed(BuildContext context) {
  return Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.65);
}
