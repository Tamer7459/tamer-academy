import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/app_localizations.dart';
import '../../core/app_theme.dart';
import '../../models/course.dart';
import '../../models/exercise_submission.dart';
import '../../services/database_service.dart';

class ExerciseSubmissionsScreen extends StatefulWidget {
  const ExerciseSubmissionsScreen({super.key});

  @override
  State<ExerciseSubmissionsScreen> createState() => _ExerciseSubmissionsScreenState();
}

class _ExerciseSubmissionsScreenState extends State<ExerciseSubmissionsScreen> {
  String? _filterCourseId;
  String _filterStatus = 'all';
  String _search = '';
  final _searchCtrl = TextEditingController();

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

  double _parseGrade(String s) {
    final v = s.replaceAll(',', '.').trim();
    return double.tryParse(v) ?? 0;
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
    final lang = l10n.languageCode;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
          child: Column(
            children: [
              TextField(
                controller: _searchCtrl,
                decoration: InputDecoration(
                  hintText: '${t('search')} (name/email/lesson)',
                  prefixIcon: const Icon(Icons.search_rounded),
                  suffixIcon: _search.isNotEmpty
                      ? IconButton(icon: const Icon(Icons.clear_rounded), onPressed: () => setState(() { _search = ''; _searchCtrl.clear(); }))
                      : null,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                ),
                onChanged: (v) => setState(() => _search = v.trim().toLowerCase()),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: StreamBuilder<List<Course>>(
                      stream: db.coursesStream(),
                      builder: (context, snap) {
                        final courses = snap.data ?? [];
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(color: Theme.of(context).colorScheme.surface, borderRadius: BorderRadius.circular(12), border: Border.all(color: Theme.of(context).colorScheme.outlineVariant)),
                          child: DropdownButton<String?>(
                            value: _filterCourseId,
                            isExpanded: true,
                            underline: const SizedBox(),
                            hint: Text(t('filterByCourse')),
                            items: [
                              DropdownMenuItem(value: null, child: Text(t('allLevels'))),
                              ...courses.map((c) => DropdownMenuItem(value: c.id, child: Text(c.title.getWithFallback(lang), overflow: TextOverflow.ellipsis))),
                            ],
                            onChanged: (v) => setState(() => _filterCourseId = v),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(color: Theme.of(context).colorScheme.surface, borderRadius: BorderRadius.circular(12), border: Border.all(color: Theme.of(context).colorScheme.outlineVariant)),
                    child: DropdownButton<String>(
                      value: _filterStatus,
                      underline: const SizedBox(),
                      items: [
                        DropdownMenuItem(value: 'all', child: Text(t('allStatus'))),
                        DropdownMenuItem(value: 'pending', child: Text(t('pendingHomeworks'))),
                        DropdownMenuItem(value: 'reviewed', child: Text(t('reviewedHomeworks'))),
                      ],
                      onChanged: (v) => setState(() => _filterStatus = v!),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        Expanded(
          child: StreamBuilder<List<ExerciseSubmission>>(
            stream: db.allExerciseSubmissionsStream(),
            builder: (context, snap) {
              if (snap.hasError) return Center(child: Text('${t('error')}: ${snap.error}'));
              if (!snap.hasData) return const Center(child: CircularProgressIndicator());
              var list = snap.data!;
              if (_filterCourseId != null) list = list.where((s) => s.courseId == _filterCourseId).toList();
              if (_filterStatus != 'all') list = list.where((s) => s.status == _filterStatus).toList();
              if (_search.isNotEmpty) {
                list = list.where((s) {
                  final hay = '${s.userName} ${s.userEmail} ${s.lessonTitle} ${s.courseTitle}'.toLowerCase();
                  return hay.contains(_search);
                }).toList();
              }
              if (list.isEmpty) {
                return Center(
                  child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Icon(Icons.edit_note_outlined, size: 48, color: AppColors.grayLight),
                    const SizedBox(height: 12),
                    Text(t('noSubmissions'), style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.grayMedium)),
                  ]),
                );
              }
              return ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: list.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (context, i) {
                  final s = list[i];
                  final isReviewed = s.isReviewed;
                  return Container(
                    decoration: BoxDecoration(color: Theme.of(context).colorScheme.surface, borderRadius: BorderRadius.circular(14), border: Border.all(color: Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.5))),
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Row(children: [
                          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(s.userName.isEmpty ? s.userEmail : s.userName, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14)), Text(s.userEmail, style: TextStyle(fontSize: 11, color: AppColors.grayMedium))])),
                          Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4), decoration: BoxDecoration(color: (isReviewed ? AppColors.success : AppColors.warning).withValues(alpha: 0.12), borderRadius: BorderRadius.circular(100)), child: Text(isReviewed ? t('homeworkReviewed') : t('homeworkPending'), style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: isReviewed ? AppColors.success : AppColors.warning))),
                        ]),
                        const SizedBox(height: 6),
                        Text('${s.courseTitle} • ${s.lessonTitle}', style: TextStyle(fontSize: 12, color: AppColors.grayMedium)),
                        Text('${s.createdAt.day}/${s.createdAt.month}/${s.createdAt.year} ${s.createdAt.hour}:${s.createdAt.minute.toString().padLeft(2,'0')}', style: TextStyle(fontSize: 11, color: AppColors.grayLight)),
                        const SizedBox(height: 10),
                        if (s.selectedOptionIndex != null)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(color: (s.isCorrect ? AppColors.success : AppColors.danger).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                            child: Text('اختيار: ${s.selectedOptionIndex! + 1} • ${s.isCorrect ? "✓ صحيح" : "✗ خاطئ"}', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: s.isCorrect ? AppColors.success : AppColors.danger)),
                          ),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(color: Theme.of(context).colorScheme.surface, border: Border.all(color: Theme.of(context).dividerColor.withValues(alpha: 0.2)), borderRadius: BorderRadius.circular(12)),
                          child: SelectionArea(child: Text(s.answerText, style: const TextStyle(fontSize: 13, height: 1.6))),
                        ),
                        if (isReviewed) ...[
                          const SizedBox(height: 8),
                          if (s.grade != null)
                            Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6), decoration: BoxDecoration(color: _gradeColor(s.grade).withValues(alpha: 0.12), borderRadius: BorderRadius.circular(10)), child: Row(mainAxisSize: MainAxisSize.min, children: [Icon(Icons.star_rounded, size: 16, color: _gradeColor(s.grade)), const SizedBox(width: 4), Text('${t('grade')}: ${_formatGrade(s.grade)}/10', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: _gradeColor(s.grade)))])),
                          if (s.feedback.isNotEmpty) ...[
                            const SizedBox(height: 6),
                            Text('${t('feedback')}: ${s.feedback}', style: const TextStyle(fontSize: 12, height: 1.5)),
                          ],
                        ],
                        const SizedBox(height: 10),
                        Row(children: [
                          FilledButton.icon(onPressed: () => _openReviewDialog(s), icon: Icon(isReviewed ? Icons.edit_rounded : Icons.rate_review_rounded, size: 16), label: Text(t('review')), style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8))),
                          const SizedBox(width: 8),
                          OutlinedButton.icon(onPressed: () => _showFull(s), icon: const Icon(Icons.code_rounded, size: 16), label: Text(t('viewCode'))),
                          const Spacer(),
                          IconButton(onPressed: () => _confirmDelete(s), icon: const Icon(Icons.delete_rounded, color: Colors.red, size: 18)),
                        ]),
                      ]),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  void _showFull(ExerciseSubmission s) {
    showDialog(context: context, builder: (d) => AlertDialog(title: Text(s.lessonTitle, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800)), content: SizedBox(width: 600, child: SingleChildScrollView(child: SelectionArea(child: Text(s.answerText, style: const TextStyle(fontSize: 12, height: 1.6))))), actions: [TextButton(onPressed: () => Navigator.pop(d), child: Text(Localizations.of<AppLocalizations>(context, AppLocalizations)!.t('cancel')))]));
  }

  Future<void> _openReviewDialog(ExerciseSubmission s) async {
    final l10n = Localizations.of<AppLocalizations>(context, AppLocalizations)!;
    final t = l10n.t;
    double grade = s.grade ?? 7;
    final gradeCtrl = TextEditingController(text: _formatGrade(s.grade ?? 7));
    final feedbackCtrl = TextEditingController(text: s.feedback);
    final result = await showDialog<bool>(
      context: context,
      builder: (d) => StatefulBuilder(builder: (context, setState) {
            void syncGrade(String v) {
              final p = _parseGrade(v);
              if (p >= 0 && p <= 10) setState(() => grade = p);
            }
            return AlertDialog(
              title: Text(t('review')),
              content: SizedBox(
                width: 420,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('${s.userName} — ${s.lessonTitle}', style: TextStyle(fontSize: 12, color: AppColors.grayMedium)),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(color: _gradeColor(grade).withValues(alpha: 0.08), borderRadius: BorderRadius.circular(12)),
                        child: Column(
                          children: [
                            Row(children: [Icon(Icons.star_rounded, color: _gradeColor(grade)), const SizedBox(width: 8), Text('${t('grade')}: ${_formatGrade(grade)}/10', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: _gradeColor(grade)))]),
                            const SizedBox(height: 8),
                            Slider(value: grade.clamp(0, 10), min: 0, max: 10, divisions: 20, label: _formatGrade(grade), onChanged: (v) => setState(() { grade = v; gradeCtrl.text = _formatGrade(v); })),
                            const SizedBox(height: 8),
                            TextField(controller: gradeCtrl, keyboardType: const TextInputType.numberWithOptions(decimal: true), decoration: InputDecoration(labelText: '${t('grade')} (0-10, استخدم , أو .)', hintText: '7,5', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)), prefixIcon: const Icon(Icons.edit_rounded)), onChanged: syncGrade),
                            const SizedBox(height: 4),
                            Text('يمكنك كتابة العلامة بالفاصلة مثل 7,5 أو 8,25', style: TextStyle(fontSize: 11, color: AppColors.grayMedium, fontStyle: FontStyle.italic)),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(color: Theme.of(context).colorScheme.surface, border: Border.all(color: Theme.of(context).dividerColor.withValues(alpha: 0.15)), borderRadius: BorderRadius.circular(10)),
                        child: SelectionArea(child: Text(s.answerText, style: const TextStyle(fontSize: 12, height: 1.6))),
                      ),
                      const SizedBox(height: 12),
                      TextField(controller: feedbackCtrl, maxLines: 5, decoration: InputDecoration(labelText: t('feedback'), border: const OutlineInputBorder())),
                    ],
                  ),
                ),
              ),
              actions: [TextButton(onPressed: () => Navigator.pop(d, false), child: Text(t('cancel'))), FilledButton(onPressed: () => Navigator.pop(d, true), child: Text(t('save')))],
            );
          }),
    );
    if (result != true) return;
    final finalGrade = _parseGrade(gradeCtrl.text).clamp(0, 10).toDouble();
    try {
      final db = context.read<DatabaseService>();
      await db.reviewExercise(s.id, grade: finalGrade, feedback: feedbackCtrl.text.trim(), reviewedBy: 'admin');
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(t('homeworkReviewSuccess')), backgroundColor: AppColors.success));
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${t('unknownError')}: $e')));
    }
  }

  void _confirmDelete(ExerciseSubmission s) {
    showDialog(context: context, builder: (d) => AlertDialog(title: const Text('تأكيد الحذف'), content: Text('${s.userEmail} — ${s.lessonTitle}'), actions: [TextButton(onPressed: () => Navigator.pop(d), child: const Text('إلغاء')), FilledButton(style: FilledButton.styleFrom(backgroundColor: AppColors.danger), onPressed: () async { await context.read<DatabaseService>().deleteExerciseSubmission(s.id); if (d.mounted) Navigator.pop(d); }, child: const Text('حذف'))]));
  }
}
