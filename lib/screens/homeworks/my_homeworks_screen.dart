import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/app_localizations.dart';
import '../../core/app_theme.dart';
import '../../models/app_user.dart';
import '../../models/homework_submission.dart';
import '../../services/database_service.dart';

class MyHomeworksScreen extends StatelessWidget {
  final AppUser user;
  const MyHomeworksScreen({super.key, required this.user});

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
    final db = context.watch<DatabaseService>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(title: Text(t('myHomeworks'))),
      body: StreamBuilder<List<HomeworkSubmission>>(
        stream: db.userHomeworkStream(user.uid),
        builder: (context, snap) {
          if (snap.hasError) return Center(child: Text('${t('error')}: ${snap.error}'));
          if (!snap.hasData) return const Center(child: CircularProgressIndicator());
          final subs = snap.data!;
          if (subs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.assignment_outlined, size: 56, color: AppColors.grayLight),
                  const SizedBox(height: 12),
                  Text(t('noHomeworks'), style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.grayMedium)),
                  const SizedBox(height: 6),
                  Text(t('homeworkHint'), style: TextStyle(fontSize: 12, color: AppColors.grayLight)),
                ],
              ),
            );
          }
          final pending = subs.where((s) => s.isPending).length;
          final reviewed = subs.where((s) => s.isReviewed).length;
          return Column(
            children: [
              Container(
                width: double.infinity,
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(color: AppColors.tealPrimary.withValues(alpha: isDark ? 0.1 : 0.06), borderRadius: BorderRadius.circular(14)),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(children: [
                        Text('$pending', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: AppColors.warning)),
                        Text(t('pendingHomeworks'), style: TextStyle(fontSize: 12, color: AppColors.grayMedium)),
                      ]),
                    ),
                    Container(width: 1, height: 40, color: Theme.of(context).dividerColor.withValues(alpha: 0.2)),
                    Expanded(
                      child: Column(children: [
                        Text('$reviewed', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: AppColors.success)),
                        Text(t('reviewedHomeworks'), style: TextStyle(fontSize: 12, color: AppColors.grayMedium)),
                      ]),
                    ),
                    Expanded(
                      child: Column(children: [
                        Text('${subs.length}', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: AppColors.tealPrimary)),
                        Text(t('homeworkSubmissions'), style: TextStyle(fontSize: 11, color: AppColors.grayMedium)),
                      ]),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  itemCount: subs.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, i) {
                    final s = subs[i];
                    final isReviewed = s.isReviewed;
                    return Container(
                      decoration: BoxDecoration(color: Theme.of(context).colorScheme.surface, borderRadius: BorderRadius.circular(14), border: Border.all(color: Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.5))),
                      child: Padding(
                        padding: const EdgeInsets.all(14),
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Row(children: [
                            Expanded(child: Text(s.lessonTitle, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14), maxLines: 1, overflow: TextOverflow.ellipsis)),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(color: (isReviewed ? AppColors.success : AppColors.warning).withValues(alpha: 0.12), borderRadius: BorderRadius.circular(100)),
                              child: Text(isReviewed ? t('homeworkReviewed') : t('homeworkPending'), style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: isReviewed ? AppColors.success : AppColors.warning)),
                            ),
                          ]),
                          const SizedBox(height: 4),
                          Text(s.courseTitle, style: TextStyle(fontSize: 12, color: AppColors.grayMedium)),
                          const SizedBox(height: 4),
                          Text('${s.createdAt.day}/${s.createdAt.month}/${s.createdAt.year} ${s.createdAt.hour}:${s.createdAt.minute.toString().padLeft(2, '0')}', style: TextStyle(fontSize: 11, color: AppColors.grayLight)),
                          const SizedBox(height: 10),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(color: isDark ? const Color(0xFF0D1424) : const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(10), border: Border.all(color: Theme.of(context).dividerColor.withValues(alpha: 0.15))),
                            child: SelectableText(s.codeAnswer, style: const TextStyle(fontFamily: 'monospace', fontSize: 12, height: 1.6)),
                          ),
                          if (isReviewed) ...[
                            const SizedBox(height: 10),
                            if (s.grade != null)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(color: _gradeColor(s.grade).withValues(alpha: 0.12), borderRadius: BorderRadius.circular(10)),
                                child: Row(mainAxisSize: MainAxisSize.min, children: [Icon(Icons.star_rounded, size: 16, color: _gradeColor(s.grade)), const SizedBox(width: 4), Text('${t('grade')}: ${_formatGrade(s.grade)}/10', style: TextStyle(fontWeight: FontWeight.w800, color: _gradeColor(s.grade)))]),
                              ),
                            if (s.feedback.isNotEmpty) ...[
                              const SizedBox(height: 8),
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
                          ],
                        ]),
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
}
