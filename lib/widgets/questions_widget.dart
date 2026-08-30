import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/app_localizations.dart';
import '../core/app_theme.dart';
import '../models/lesson.dart';
import 'lesson_content_renderer.dart';
import 'random_question_picker.dart';

class QuestionsWidget extends StatefulWidget {
  final Lesson lesson;
  final String userId;
  const QuestionsWidget({super.key, required this.lesson, required this.userId});

  @override
  State<QuestionsWidget> createState() => _QuestionsWidgetState();
}

class _QuestionsWidgetState extends State<QuestionsWidget> {
  final Set<int> _expanded = {};

  @override
  Widget build(BuildContext context) {
    final l10n = Localizations.of<AppLocalizations>(context, AppLocalizations)!;
    final t = l10n.t;
    final lang = l10n.languageCode;
    final theme = Theme.of(context);
    final qs = widget.lesson.questions.where((q) => q.hasContent).toList();

    if (qs.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Center(
            child: Column(
              children: [
                Icon(Icons.quiz_outlined, size: 48, color: AppColors.grayLight),
                const SizedBox(height: 12),
                Text(t('noContent'), style: TextStyle(color: AppColors.grayMedium, fontWeight: FontWeight.w700)),
              ],
            ),
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHeader(icon: Icons.quiz_rounded, title: '${t('oralQuestions')} — ${qs.length}'),
        const SizedBox(height: 12),
        RandomQuestionPicker(lesson: widget.lesson, userId: widget.userId),
        const SizedBox(height: 24),
        _SectionHeader(icon: Icons.list_alt_rounded, title: t('allQuestions')),
        const SizedBox(height: 12),
        ...List.generate(qs.length, (i) {
          final q = qs[i];
          final isExpanded = _expanded.contains(i);
          return Card(
            margin: const EdgeInsets.only(bottom: 10),
            child: Column(
              children: [
                InkWell(
                  onTap: () => setState(() {
                    if (isExpanded) _expanded.remove(i);
                    else _expanded.add(i);
                  }),
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 16,
                          backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.12),
                          child: Text('${i + 1}', style: TextStyle(fontWeight: FontWeight.w900, color: theme.colorScheme.primary, fontSize: 13)),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            q.question.getWithFallback(lang).split('\n').first,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14, height: 1.4),
                          ),
                        ),
                        Icon(isExpanded ? Icons.expand_less_rounded : Icons.expand_more_rounded, color: AppColors.grayMedium),
                      ],
                    ),
                  ),
                ),
                if (isExpanded)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Divider(height: 1),
                        const SizedBox(height: 12),
                        LessonContentRenderer(content: q.question.getWithFallback(lang), lang: lang),
                        const SizedBox(height: 12),
                        _SolutionView(solution: q.solution.getWithFallback(lang), lang: lang),
                      ],
                    ),
                  ),
              ],
            ),
          );
        }),
      ],
    );
  }
}

class _SolutionView extends StatefulWidget {
  final String solution;
  final String lang;
  const _SolutionView({required this.solution, required this.lang});
  @override
  State<_SolutionView> createState() => _SolutionViewState();
}

class _SolutionViewState extends State<_SolutionView> {
  bool _show = false;
  @override
  Widget build(BuildContext context) {
    final l10n = Localizations.of<AppLocalizations>(context, AppLocalizations)!;
    final t = l10n.t;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () => setState(() => _show = !_show),
            icon: Icon(_show ? Icons.visibility_off_rounded : Icons.visibility_rounded, size: 18),
            label: Text(_show ? t('hideSolution') : t('showSolution')),
          ),
        ),
        if (_show) ...[
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.warning.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.warning.withValues(alpha: 0.15)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [Icon(Icons.lightbulb_rounded, size: 16, color: AppColors.warning), const SizedBox(width: 6), Text(l10n.t('solution'), style: TextStyle(fontWeight: FontWeight.w800, color: AppColors.warning))]),
                const SizedBox(height: 8),
                LessonContentRenderer(content: widget.solution, lang: widget.lang),
              ],
            ),
          ),
        ],
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
