import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/app_localizations.dart';
import '../core/app_theme.dart';
import '../models/lesson.dart';
import '../services/database_service.dart';
import 'lesson_content_renderer.dart';

class RandomQuestionPicker extends StatefulWidget {
  final Lesson lesson;
  final String userId;
  const RandomQuestionPicker({super.key, required this.lesson, required this.userId});

  @override
  State<RandomQuestionPicker> createState() => _RandomQuestionPickerState();
}

class _RandomQuestionPickerState extends State<RandomQuestionPicker> {
  int? _currentIdx;
  bool _showSolution = false;
  bool _allowRepeat = false;
  Set<int> _seen = {};
  bool _loadingSeen = true;

  List<LessonQuestion> get _validQuestions =>
      widget.lesson.questions.where((q) => q.hasContent).toList();

  @override
  void initState() {
    super.initState();
    _loadSeen();
  }

  Future<void> _loadSeen() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = 'random_seen_${widget.lesson.id}';
      final local = prefs.getStringList(key)?.map(int.parse).toSet() ?? <int>{};
      // also try firestore
      List<int> remote = [];
      try {
        final db = context.read<DatabaseService>();
        remote = await db.getRandomSeen(widget.userId, widget.lesson.id);
      } catch (_) {}
      final merged = {...local, ...remote};
      if (mounted) {
        setState(() {
          _seen = merged;
          _loadingSeen = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loadingSeen = false);
    }
  }

  Future<void> _persistSeen() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = 'random_seen_${widget.lesson.id}';
      await prefs.setStringList(key, _seen.map((e) => e.toString()).toList());
    } catch (_) {}
    try {
      final db = context.read<DatabaseService>();
      await db.saveRandomSeen(widget.userId, widget.lesson.id, _seen.toList());
    } catch (_) {}
  }

  void _pickRandom() {
    final list = _validQuestions;
    if (list.isEmpty) return;
    final l10n = Localizations.of<AppLocalizations>(context, AppLocalizations)!;
    final t = l10n.t;
    if (!_allowRepeat && _seen.length >= list.length) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(t('allQuestionsSeen'))));
      return;
    }
    int idx;
    if (_allowRepeat) {
      idx = Random().nextInt(list.length);
    } else {
      final remaining = List<int>.generate(list.length, (i) => i).where((i) => !_seen.contains(i)).toList();
      remaining.shuffle(Random());
      idx = remaining.first;
    }
    setState(() {
      _currentIdx = idx;
      _showSolution = false;
      _seen.add(idx);
    });
    _persistSeen();
  }

  void _resetSeen() async {
    setState(() {
      _seen.clear();
      _currentIdx = null;
      _showSolution = false;
    });
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('random_seen_${widget.lesson.id}');
    } catch (_) {}
    try {
      await context.read<DatabaseService>().saveRandomSeen(widget.userId, widget.lesson.id, []);
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final l10n = Localizations.of<AppLocalizations>(context, AppLocalizations)!;
    final t = l10n.t;
    final lang = l10n.languageCode;
    final theme = Theme.of(context);
    final qs = _validQuestions;

    if (qs.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Center(child: Text(t('noContent'), style: TextStyle(color: AppColors.grayMedium))),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Controls
        Card(
          margin: EdgeInsets.zero,
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: _pickRandom,
                        icon: const Icon(Icons.casino_rounded, size: 20),
                        label: Text(t('pickRandom')),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(color: theme.colorScheme.primary.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(100)),
                      child: Text('${_seen.length}/${qs.length}', style: TextStyle(fontWeight: FontWeight.w800, color: theme.colorScheme.primary, fontSize: 13)),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Icon(_allowRepeat ? Icons.repeat_rounded : Icons.block_rounded, size: 16, color: AppColors.grayMedium),
                    const SizedBox(width: 6),
                    Expanded(child: Text(_allowRepeat ? t('allowRepeat') : t('noRepeat'), style: TextStyle(fontSize: 13, color: AppColors.grayMedium, fontWeight: FontWeight.w600))),
                    Switch(value: _allowRepeat, onChanged: (v) => setState(() => _allowRepeat = v)),
                  ],
                ),
                if (_seen.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: [
                        ..._seen.map((i) => Chip(label: Text('${i + 1}', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700)), visualDensity: VisualDensity.compact, padding: const EdgeInsets.symmetric(horizontal: 6))),
                        ActionChip(label: Text(t('resetSeen'), style: const TextStyle(fontSize: 11)), avatar: const Icon(Icons.refresh_rounded, size: 14), onPressed: _resetSeen),
                      ],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Align(alignment: Alignment.centerRight, child: Text('${t('seenQuestions')}: ${_seen.map((e) => e + 1).join(', ')}', style: TextStyle(fontSize: 11, color: AppColors.grayMedium))),
                ],
              ],
            ),
          ),
        ),
        if (_currentIdx != null) ...[
          const SizedBox(height: 16),
          _SectionHeader(icon: Icons.help_rounded, title: '${t('questionNumber')} ${_currentIdx! + 1}'),
          const SizedBox(height: 10),
          Card(
            margin: EdgeInsets.zero,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(color: theme.colorScheme.primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(100)),
                    child: Row(mainAxisSize: MainAxisSize.min, children: [Icon(Icons.quiz_rounded, size: 14, color: theme.colorScheme.primary), const SizedBox(width: 6), Text('${t('questionNumber')} ${_currentIdx! + 1}/${qs.length}', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 12, color: theme.colorScheme.primary))]),
                  ),
                  const SizedBox(height: 12),
                  LessonContentRenderer(content: qs[_currentIdx!].question.getWithFallback(lang), lang: lang),
                  const SizedBox(height: 14),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () => setState(() => _showSolution = !_showSolution),
                      icon: Icon(_showSolution ? Icons.visibility_off_rounded : Icons.visibility_rounded, size: 18),
                      label: Text(_showSolution ? t('hideSolution') : t('showSolution')),
                    ),
                  ),
                  if (_showSolution) ...[
                    const SizedBox(height: 12),
                    Container(width: double.infinity, height: 1, color: theme.dividerColor.withValues(alpha: 0.2)),
                    const SizedBox(height: 12),
                    Row(children: [Icon(Icons.lightbulb_rounded, size: 16, color: AppColors.warning), const SizedBox(width: 6), Text(t('solution'), style: TextStyle(fontWeight: FontWeight.w800, color: AppColors.warning))]),
                    const SizedBox(height: 8),
                    LessonContentRenderer(content: qs[_currentIdx!].solution.getWithFallback(lang), lang: lang),
                  ],
                ],
              ),
            ),
          ),
        ] else ...[
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(color: theme.colorScheme.primary.withValues(alpha: 0.06), borderRadius: BorderRadius.circular(12), border: Border.all(color: theme.colorScheme.primary.withValues(alpha: 0.12))),
            child: Column(children: [Icon(Icons.casino_rounded, size: 32, color: theme.colorScheme.primary.withValues(alpha: 0.5)), const SizedBox(height: 8), Text(t('pickRandom'), style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.grayMedium)), const SizedBox(height: 4), Text(t('oralQuestions'), style: TextStyle(fontSize: 12, color: AppColors.grayLight))]),
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
