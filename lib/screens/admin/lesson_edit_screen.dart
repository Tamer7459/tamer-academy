import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/app_localizations.dart';
import '../../core/app_theme.dart';
import '../../data/lesson_templates.dart';
import '../../models/course.dart';
import '../../models/lesson.dart';
import '../../services/database_service.dart';

class _QCtrl {
  final qAr = TextEditingController();
  final qEn = TextEditingController();
  final qFr = TextEditingController();
  final sAr = TextEditingController();
  final sEn = TextEditingController();
  final sFr = TextEditingController();
  void dispose() {
    qAr.dispose();
    qEn.dispose();
    qFr.dispose();
    sAr.dispose();
    sEn.dispose();
    sFr.dispose();
  }
}

class LessonEditScreen extends StatefulWidget {
  final Course course;
  final Lesson? lesson;
  final int order;

  const LessonEditScreen({super.key, required this.course, this.lesson, this.order = 0});

  @override
  State<LessonEditScreen> createState() => _LessonEditScreenState();
}

class _LessonEditScreenState extends State<LessonEditScreen> {
  final _formKey = GlobalKey<FormState>();
  static const _langs = ['ar', 'en', 'fr'];

  late final _titleAr = TextEditingController(text: widget.lesson?.title.ar ?? '');
  late final _titleEn = TextEditingController(text: widget.lesson?.title.en ?? '');
  late final _titleFr = TextEditingController(text: widget.lesson?.title.fr ?? '');
  late final _contentAr = TextEditingController(text: widget.lesson?.content.ar ?? '');
  late final _contentEn = TextEditingController(text: widget.lesson?.content.en ?? '');
  late final _contentFr = TextEditingController(text: widget.lesson?.content.fr ?? '');
  late final _videoUrl = TextEditingController(text: widget.lesson?.videoUrl ?? '');
  late final _codeHtml = TextEditingController(text: widget.lesson?.codeHtml ?? '');
  late final _codeDart = TextEditingController(text: widget.lesson?.codeDart ?? '');

  // ── Exercise (2nd category) ──
  late final _exerciseAr = TextEditingController(text: widget.lesson?.exercise?.question.ar ?? '');
  late final _exerciseEn = TextEditingController(text: widget.lesson?.exercise?.question.en ?? '');
  late final _exerciseFr = TextEditingController(text: widget.lesson?.exercise?.question.fr ?? '');
  late final _solutionAr = TextEditingController(text: widget.lesson?.exercise?.solution.ar ?? '');
  late final _solutionEn = TextEditingController(text: widget.lesson?.exercise?.solution.en ?? '');
  late final _solutionFr = TextEditingController(text: widget.lesson?.exercise?.solution.fr ?? '');
  late bool _hasExercise = widget.lesson?.exercise?.hasExercise ?? false;

  late List<_QCtrl> _qCtrls;
  late bool _hasQuestions;
  late bool _hasHomework;
  late final _hwAr = TextEditingController(text: widget.lesson?.homeworkPrompt.ar ?? '');
  late final _hwEn = TextEditingController(text: widget.lesson?.homeworkPrompt.en ?? '');
  late final _hwFr = TextEditingController(text: widget.lesson?.homeworkPrompt.fr ?? '');

  late String _codeType;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _codeType = (widget.lesson?.codeDart.isNotEmpty ?? false) ? 'dart' : 'html';
    _codeHtml.addListener(() => setState(() {}));
    _codeDart.addListener(() => setState(() {}));
    // init questions (3rd category) — independent from exercise
    final existing = widget.lesson?.questions ?? [];
    if (existing.isNotEmpty) {
      _qCtrls = existing.map((q) {
        final c = _QCtrl();
        c.qAr.text = q.question.ar;
        c.qEn.text = q.question.en;
        c.qFr.text = q.question.fr;
        c.sAr.text = q.solution.ar;
        c.sEn.text = q.solution.en;
        c.sFr.text = q.solution.fr;
        return c;
      }).toList();
      _hasQuestions = true;
    } else {
      _qCtrls = [_QCtrl()];
      _hasQuestions = false;
    }
    _hasHomework = widget.lesson?.hasHomework ?? false;
    if (_hasHomework && _hwAr.text.isEmpty && _hwEn.text.isEmpty && _hwFr.text.isEmpty) {
      // keep empty to force fill
    }
  }

  @override
  void dispose() {
    for (final c in [
      _titleAr, _titleEn, _titleFr,
      _contentAr, _contentEn, _contentFr,
      _videoUrl, _codeHtml, _codeDart,
      _exerciseAr, _exerciseEn, _exerciseFr,
      _solutionAr, _solutionEn, _solutionFr,
      _hwAr, _hwEn, _hwFr,
    ]) {
      c.dispose();
    }
    for (final q in _qCtrls) q.dispose();
    super.dispose();
  }

  Exercise? _buildExercise() {
    if (!_hasExercise) return null;
    final hasQ = _exerciseAr.text.trim().isNotEmpty || _exerciseEn.text.trim().isNotEmpty || _exerciseFr.text.trim().isNotEmpty;
    if (!hasQ) return null;
    return Exercise(
      question: LocalizedText(ar: _exerciseAr.text.trim(), en: _exerciseEn.text.trim(), fr: _exerciseFr.text.trim()),
      options: const [],
      answerIndex: 0,
      solution: LocalizedText(ar: _solutionAr.text.trim(), en: _solutionEn.text.trim(), fr: _solutionFr.text.trim()),
    );
  }

  List<LessonQuestion> _buildQuestions() {
    if (!_hasQuestions) return [];
    return _qCtrls.map((c) {
      return LessonQuestion(
        question: LocalizedText(ar: c.qAr.text.trim(), en: c.qEn.text.trim(), fr: c.qFr.text.trim()),
        solution: LocalizedText(ar: c.sAr.text.trim(), en: c.sEn.text.trim(), fr: c.sFr.text.trim()),
      );
    }).where((q) => q.hasContent).toList();
  }

  void _addQuestion() {
    if (_qCtrls.length >= 12) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('الحد الأقصى 12 سؤال')));
      return;
    }
    setState(() => _qCtrls.add(_QCtrl()));
  }

  void _removeQuestion(int idx) {
    setState(() {
      _qCtrls[idx].dispose();
      _qCtrls.removeAt(idx);
      if (_qCtrls.isEmpty) _qCtrls.add(_QCtrl());
    });
  }

  void _shuffleQuestions() {
    final rnd = Random();
    setState(() {
      _qCtrls.shuffle(rnd);
    });
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم خلط الأسئلة ✓')));
  }

  Future<void> _quickPaste() async {
    final qCtrl = TextEditingController();
    final sCtrl = TextEditingController();
    final result = await showDialog<bool>(
      context: context,
      builder: (d) => AlertDialog(
        title: const Text('لصق سريع — كل سؤال في سطر'),
        content: SizedBox(
          width: 500,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: qCtrl, maxLines: 9, decoration: const InputDecoration(labelText: 'الأسئلة (ar) — سطر لكل سؤال', hintText: 'ما هو final؟\nما هو const؟')),
                const SizedBox(height: 12),
                TextField(controller: sCtrl, maxLines: 9, decoration: const InputDecoration(labelText: 'الحلول (ar) — سطر لكل حل', hintText: 'حل 1\nحل 2')),
                const SizedBox(height: 8),
                const Text('سيتم إنشاء أسئلة بعدد الأسطر. EN/FR يمكنك تعبئتها لاحقا. الحل يدعم كود وجدول Markdown.', style: TextStyle(fontSize: 11, color: Colors.grey)),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(d, false), child: const Text('إلغاء')),
          FilledButton(onPressed: () => Navigator.pop(d, true), child: const Text('إضافة')),
        ],
      ),
    );
    if (result != true) return;
    final qs = qCtrl.text.split('\n').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
    final ss = sCtrl.text.split('\n').map((e) => e.trim()).toList();
    if (qs.isEmpty) return;
    // dispose old if was single empty
    if (_qCtrls.length == 1 && _qCtrls.first.qAr.text.trim().isEmpty) {
      _qCtrls.first.dispose();
      _qCtrls.clear();
    }
    setState(() {
      _hasQuestions = true;
      for (int i = 0; i < qs.length; i++) {
        final c = _QCtrl();
        c.qAr.text = qs[i];
        c.sAr.text = i < ss.length ? ss[i] : '';
        // en/fr leave empty to fill later
        _qCtrls.add(c);
      }
      // trim to 12 max
      if (_qCtrls.length > 12) {
        for (int i = 12; i < _qCtrls.length; i++) _qCtrls[i].dispose();
        _qCtrls = _qCtrls.sublist(0, 12);
      }
    });
  }

  void _fill9EmptyIfNeeded() {
    if (!_hasQuestions) return;
    if (_qCtrls.length >= 9) return;
    setState(() {
      while (_qCtrls.length < 9) _qCtrls.add(_QCtrl());
    });
  }

  Future<bool> _confirmOverwrite(String title) async {
    final res = await showDialog<bool>(
      context: context,
      builder: (d) => AlertDialog(
        title: Text(title),
        content: const Text('الحقل يحتوي بيانات. هل تريد الكتابة فوقه؟'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(d, false), child: const Text('إلغاء')),
          FilledButton(onPressed: () => Navigator.pop(d, true), child: const Text('نعم، استبدال')),
        ],
      ),
    );
    return res == true;
  }

  Future<void> _applyContentTemplate() async {
    if (_contentAr.text.trim().isNotEmpty && !await _confirmOverwrite('استبدال المحتوى؟')) return;
    setState(() {
      _contentAr.text = ContentTemplates.lessonContentAr;
      _contentEn.text = ContentTemplates.lessonContentEn;
      _contentFr.text = ContentTemplates.lessonContentFr;
    });
    if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم تطبيق قالب المحتوى ✓')));
  }

  Future<void> _applyExerciseTemplate() async {
    if (_hasExercise && _exerciseAr.text.trim().isNotEmpty && !await _confirmOverwrite('استبدال التمرين؟')) return;
    setState(() {
      _hasExercise = true;
      _exerciseAr.text = ContentTemplates.exerciseQuestionAr;
      _exerciseEn.text = ContentTemplates.exerciseQuestionEn;
      _exerciseFr.text = ContentTemplates.exerciseQuestionFr;
      _solutionAr.text = ContentTemplates.exerciseSolutionAr;
      _solutionEn.text = ContentTemplates.exerciseSolutionEn;
      _solutionFr.text = ContentTemplates.exerciseSolutionFr;
    });
    if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم تطبيق قالب التمرين ✓')));
  }

  Future<void> _applyQuestionsTemplate() async {
    if (_hasQuestions && _qCtrls.any((c) => c.qAr.text.trim().isNotEmpty) && !await _confirmOverwrite('استبدال الأسئلة الشفوية؟')) return;
    for (final c in _qCtrls) c.dispose();
    final list = ContentTemplates.oralQuestionsAr;
    setState(() {
      _hasQuestions = true;
      _qCtrls = list.map((e) {
        final c = _QCtrl();
        c.qAr.text = e['q']!;
        c.sAr.text = e['a']!;
        c.qEn.text = e['q']!;
        c.qFr.text = e['q']!;
        c.sEn.text = e['a']!;
        c.sFr.text = e['a']!;
        return c;
      }).toList();
    });
    if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم تطبيق قالب 9 أسئلة شفوية ✓')));
  }

  Future<void> _applyHomeworkTemplate() async {
    if (_hasHomework && _hwAr.text.trim().isNotEmpty && !await _confirmOverwrite('استبدال الواجب؟')) return;
    setState(() {
      _hasHomework = true;
      _hwAr.text = ContentTemplates.homeworkAr;
      _hwEn.text = ContentTemplates.homeworkEn;
      _hwFr.text = ContentTemplates.homeworkFr;
    });
    if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم تطبيق قالب الواجب ✓')));
  }

  Future<void> _applyAllTemplates() async {
    if ((_contentAr.text.trim().isNotEmpty || _hasExercise || _hasQuestions || _hasHomework) && !await _confirmOverwrite('تطبيق كل القوالب؟ سيتم ملء الأقسام الفارغة وإضافة الباقي.')) return;
    await _applyContentTemplate();
    await Future.delayed(const Duration(milliseconds: 100));
    // exercise, questions, homework will each check overwrite again, so call directly
    setState(() {
      _hasExercise = true;
      _exerciseAr.text = ContentTemplates.exerciseQuestionAr;
      _exerciseEn.text = ContentTemplates.exerciseQuestionEn;
      _exerciseFr.text = ContentTemplates.exerciseQuestionFr;
      _solutionAr.text = ContentTemplates.exerciseSolutionAr;
      _solutionEn.text = ContentTemplates.exerciseSolutionEn;
      _solutionFr.text = ContentTemplates.exerciseSolutionFr;
      _hasHomework = true;
      _hwAr.text = ContentTemplates.homeworkAr;
      _hwEn.text = ContentTemplates.homeworkEn;
      _hwFr.text = ContentTemplates.homeworkFr;
    });
    // questions
    for (final c in _qCtrls) c.dispose();
    final list = ContentTemplates.oralQuestionsAr;
    _qCtrls = list.map((e) {
      final c = _QCtrl();
      c.qAr.text = e['q']!;
      c.sAr.text = e['a']!;
      c.qEn.text = e['q']!;
      c.qFr.text = e['q']!;
      c.sEn.text = e['a']!;
      c.sFr.text = e['a']!;
      return c;
    }).toList();
    _hasQuestions = true;
    setState(() {});
    if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم تطبيق كل القوالب ✓')));
  }

  // ── Table template & helpers ──
  static const _tableTemplate = '| الكلمة | المعنى | تُستخدم |\n|---|---|---|\n| `final` | قيمة تُحدد مرة واحدة فقط | عند التشغيل (Runtime) |\n| `const` | قيمة ثابتة ومعروفة مسبقاً | عند الترجمة (Compile-time) |';

  void _insertTableTemplate() {
    final ctrl = _contentAr;
    final text = ctrl.text;
    final toInsert = '${text.isEmpty ? '' : '\n\n'}$_tableTemplate\n';
    final selection = ctrl.selection;
    final offset = selection.isValid ? selection.baseOffset : text.length;
    final newText = text.substring(0, offset) + toInsert + text.substring(offset);
    ctrl.value = TextEditingValue(text: newText, selection: TextSelection.collapsed(offset: offset + toInsert.length));
    setState(() {});
  }

  void _modifyLastTable(void Function(List<List<String>> rows) transformer) {
    final ctrl = _contentAr;
    final text = ctrl.text;
    final lines = text.split('\n');
    int start = -1, end = -1;
    for (int i = 0; i < lines.length; i++) {
      if (lines[i].trim().startsWith('|') && i + 1 < lines.length && RegExp(r'^\s*\|?(\s*:?-+:?\s*\|)+\s*$').hasMatch(lines[i + 1])) {
        start = i;
        end = i + 1;
        int j = i + 2;
        while (j < lines.length && lines[j].trim().startsWith('|')) {
          end = j;
          j++;
        }
      }
    }
    if (start == -1) {
      _insertTableTemplate();
      return;
    }
    final tableLines = lines.sublist(start, end + 1);
    final rows = <List<String>>[];
    for (final l in tableLines) {
      if (RegExp(r'^\s*\|?(\s*:?-+:?\s*\|)+\s*$').hasMatch(l)) continue;
      final cells = l.split('|').map((c) => c.trim()).where((c) => c.isNotEmpty).toList();
      if (cells.isNotEmpty) rows.add(cells);
    }
    if (rows.isEmpty) return;
    transformer(rows);
    final colCount = rows.first.length;
    final header = rows.first;
    final separator = List.filled(colCount, '---').join(' | ');
    final buffer = StringBuffer();
    buffer.writeln('| ${header.join(' | ')} |');
    buffer.writeln('| $separator |');
    for (int i = 1; i < rows.length; i++) {
      while (rows[i].length < colCount) rows[i].add('');
      while (rows[i].length > colCount) rows[i].removeLast();
      buffer.writeln('| ${rows[i].join(' | ')} |');
    }
    final newTable = buffer.toString().trim();
    final before = lines.sublist(0, start).join('\n');
    final after = lines.sublist(end + 1).join('\n');
    final newText = [before, newTable, after].where((s) => s.trim().isNotEmpty).join('\n\n');
    ctrl.value = TextEditingValue(text: newText, selection: TextSelection.collapsed(offset: newText.length));
    setState(() {});
  }

  void _addRow() => _modifyLastTable((rows) => rows.add(List.filled(rows.first.length, 'قيمة جديدة')));
  void _addColumn() => _modifyLastTable((rows) {
        for (int i = 0; i < rows.length; i++) {
          rows[i].add(i == 0 ? 'العمود ${rows[i].length + 1}' : 'قيمة');
        }
      });
  void _removeRow() => _modifyLastTable((rows) {
        if (rows.length > 2) rows.removeLast();
      });
  void _removeColumn() => _modifyLastTable((rows) {
        if (rows.first.length <= 2) return;
        for (final r in rows) r.removeLast();
      });

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    // Validate questions 3 langs mandatory if hasQuestions
    if (_hasQuestions) {
      final built = _buildQuestions();
      if (built.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(Localizations.of<AppLocalizations>(context, AppLocalizations)!.t('need9Questions'))));
        return;
      }
      // Check 3 langs mandatory
      for (int i = 0; i < _qCtrls.length; i++) {
        final c = _qCtrls[i];
        if (c.qAr.text.trim().isEmpty || c.qEn.text.trim().isEmpty || c.qFr.text.trim().isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('السؤال ${i + 1}: يجب ملء 3 لغات للسؤال')));
          return;
        }
        if (c.sAr.text.trim().isEmpty || c.sEn.text.trim().isEmpty || c.sFr.text.trim().isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('السؤال ${i + 1}: يجب ملء 3 لغات للحل')));
          return;
        }
      }
      if (built.length != 9) {
        final confirm = await showDialog<bool>(
          context: context,
          builder: (d) => AlertDialog(
            title: const Text('تنبيه: ليس 9 أسئلة'),
            content: Text('لديك ${built.length} أسئلة فقط. المطلوب دائما 9. هل تريد الحفظ رغم ذلك؟'),
            actions: [
              TextButton(onPressed: () => Navigator.pop(d, false), child: const Text('إلغاء')),
              FilledButton(onPressed: () => Navigator.pop(d, true), child: const Text('حفظ')),
            ],
          ),
        );
        if (confirm != true) return;
      }
    }
    if (_hasExercise) {
      if (_exerciseAr.text.trim().isEmpty || _exerciseEn.text.trim().isEmpty || _exerciseFr.text.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('التمرين: يجب ملء 3 لغات للسؤال')));
        return;
      }
      if (_solutionAr.text.trim().isEmpty || _solutionEn.text.trim().isEmpty || _solutionFr.text.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('التمرين: يجب ملء 3 لغات للحل')));
        return;
      }
    }
    if (_hasHomework) {
      if (_hwAr.text.trim().isEmpty || _hwEn.text.trim().isEmpty || _hwFr.text.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('الواجب: يجب ملء 3 لغات لنص الواجب')));
        return;
      }
    }
    setState(() => _saving = true);
    final l10n = Localizations.of<AppLocalizations>(context, AppLocalizations)!;
    final t = l10n.t;
    try {
      final db = context.read<DatabaseService>();
      final lesson = Lesson(
        id: widget.lesson?.id ?? DateTime.now().microsecondsSinceEpoch.toString(),
        courseId: widget.course.id,
        title: LocalizedText(ar: _titleAr.text.trim(), en: _titleEn.text.trim(), fr: _titleFr.text.trim()),
        content: LocalizedText(ar: _contentAr.text.trim(), en: _contentEn.text.trim(), fr: _contentFr.text.trim()),
        videoUrl: _videoUrl.text.trim(),
        codeHtml: _codeHtml.text.trim(),
        codeDart: _codeDart.text.trim(),
        exercise: _buildExercise(),
        questions: _buildQuestions(),
        homeworkPrompt: _hasHomework
            ? LocalizedText(ar: _hwAr.text.trim(), en: _hwEn.text.trim(), fr: _hwFr.text.trim())
            : const LocalizedText(ar: '', en: '', fr: ''),
        hasHomework: _hasHomework,
        order: widget.lesson?.order ?? widget.order,
      );
      await db.saveLesson(lesson);
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${t('unknownError')}: $e'), behavior: SnackBarBehavior.floating, duration: const Duration(seconds: 5)),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = Localizations.of<AppLocalizations>(context, AppLocalizations)!;
    final t = l10n.t;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.lesson == null ? t('addLesson') : t('editLesson')),
        actions: [
          IconButton(onPressed: _saving ? null : _save, icon: const Icon(Icons.save_rounded), tooltip: t('save')),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // ── Templates for new lesson/course ──
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [AppColors.tealPrimary.withValues(alpha: 0.12), AppColors.tealLight.withValues(alpha: 0.08)]),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.tealPrimary.withValues(alpha: 0.18)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [Icon(Icons.auto_awesome_rounded, size: 18, color: AppColors.tealPrimary), const SizedBox(width: 8), Text('قوالب جاهزة', style: TextStyle(fontWeight: FontWeight.w900, color: AppColors.tealPrimary)), const Spacer(), Text('للدورة/الدرس الجديد', style: TextStyle(fontSize: 11, color: AppColors.grayMedium))]),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      FilledButton.icon(onPressed: _applyContentTemplate, icon: const Icon(Icons.article_rounded, size: 16), label: const Text('قالب المحتوى')),
                      FilledButton.icon(onPressed: _applyExerciseTemplate, icon: const Icon(Icons.edit_note_rounded, size: 16), label: const Text('قالب التمارين')),
                      FilledButton.icon(onPressed: _applyQuestionsTemplate, icon: const Icon(Icons.record_voice_over_rounded, size: 16), label: const Text('قالب الأسئلة (9)')),
                      FilledButton.icon(onPressed: _applyHomeworkTemplate, icon: const Icon(Icons.assignment_rounded, size: 16), label: const Text('قالب الواجب')),
                      OutlinedButton.icon(onPressed: _applyAllTemplates, icon: const Icon(Icons.auto_fix_high_rounded, size: 16), label: const Text('تطبيق الكل للدرس الجديد')),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text('تُطبق على الأقسام الأربعة: المحتوى، التمارين، الأسئلة الشفوية (9)، الواجب. تُستخدم عند إنشاء دورة/درس جديد.', style: TextStyle(fontSize: 11, color: AppColors.grayMedium, height: 1.5)),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _LangSection(title: '${t('title')} (${_langs[0]})', controller: _titleAr, validator: (v) => (v == null || v.trim().isEmpty) ? t('title') : null),
            _LangSection(title: '${t('title')} (${_langs[1]})', controller: _titleEn),
            _LangSection(title: '${t('title')} (${_langs[2]})', controller: _titleFr),
            const Divider(height: 32),
            Text(t('lessonContent'), style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900)),
            const SizedBox(height: 8),
            _LangSection(title: '${t('content')} (${_langs[0]})', controller: _contentAr, maxLines: 10, hint: '## عنوان\nنص الدرس...\n```html\n<code>\n```\n> ملاحظة'),
            _LangSection(title: '${t('content')} (${_langs[1]})', controller: _contentEn, maxLines: 10),
            _LangSection(title: '${t('content')} (${_langs[2]})', controller: _contentFr, maxLines: 10),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: Theme.of(context).colorScheme.surface, borderRadius: BorderRadius.circular(12), border: Border.all(color: Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.5))),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [Icon(Icons.table_chart_rounded, size: 18, color: Theme.of(context).colorScheme.primary), const SizedBox(width: 8), Text('قالب جدول', style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)), const Spacer(), Text('نفس ستايل الصورة', style: TextStyle(fontSize: 11, color: AppColors.grayMedium))]),
                  const SizedBox(height: 10),
                  Wrap(spacing: 8, runSpacing: 8, children: [
                    FilledButton.icon(onPressed: _insertTableTemplate, icon: const Icon(Icons.add_box_rounded, size: 18), label: const Text('إدراج قالب جدول'), style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10))),
                    OutlinedButton.icon(onPressed: _addRow, icon: const Icon(Icons.table_rows_rounded, size: 18), label: const Text('+ صف')),
                    OutlinedButton.icon(onPressed: _addColumn, icon: const Icon(Icons.view_column_rounded, size: 18), label: const Text('+ عمود')),
                    OutlinedButton.icon(onPressed: _removeRow, icon: const Icon(Icons.remove_rounded, size: 18), label: const Text('- صف')),
                    OutlinedButton.icon(onPressed: _removeColumn, icon: const Icon(Icons.view_column_outlined, size: 18), label: const Text('- عمود')),
                  ]),
                  const SizedBox(height: 8),
                  Text('الصق القالب في حقل المحتوى (عربي) ثم استخدم الأزرار لإضافة/حذف. الجدول يُكتب بـ Markdown: | a | b |', style: TextStyle(fontSize: 11, color: AppColors.grayMedium, height: 1.5)),
                ],
              ),
            ),
            const Divider(height: 32),
            Text(t('video'), style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900)),
            const SizedBox(height: 8),
            TextFormField(controller: _videoUrl, decoration: InputDecoration(labelText: t('videoUrl'), prefixIcon: const Icon(Icons.link_rounded), hintText: 'https://www.youtube.com/watch?v=...  أو  https://drive.google.com/file/d/...')),
            const Divider(height: 32),
            // ── 2) Exercises (تمارين) ──
            SwitchListTile(
              title: Text(t('exercise')),
              subtitle: Text(t('hasExercise')),
              value: _hasExercise,
              onChanged: (v) => setState(() => _hasExercise = v),
            ),
            if (_hasExercise) ...[
              const SizedBox(height: 8),
              Text(t('question'), style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900)),
              const SizedBox(height: 8),
              _LangSection(title: '${t('question')} (ar) *', controller: _exerciseAr, maxLines: 4, hint: 'نص التمرين عربي'),
              _LangSection(title: '${t('question')} (en) *', controller: _exerciseEn, maxLines: 3),
              _LangSection(title: '${t('question')} (fr) *', controller: _exerciseFr, maxLines: 3),
              Text(t('solution'), style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900)),
              const SizedBox(height: 8),
              _LangSection(title: '${t('solution')} (ar) *', controller: _solutionAr, maxLines: 4, hint: 'حل التمرين عربي — يدعم كود وجدول'),
              _LangSection(title: '${t('solution')} (en) *', controller: _solutionEn, maxLines: 3),
              _LangSection(title: '${t('solution')} (fr) *', controller: _solutionFr, maxLines: 3),
            ],
            const Divider(height: 32),
            // ── 3) Oral Questions (شفوية 9) ──
            SwitchListTile(
              title: Text(t('oralQuestions')),
              subtitle: Text('${t('questionsCount')}: ${_qCtrls.length} — ${t('need9Questions')}'),
              value: _hasQuestions,
              onChanged: (v) => setState(() {
                _hasQuestions = v;
                if (v) _fill9EmptyIfNeeded();
              }),
            ),
            if (_hasQuestions) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: theme.colorScheme.primary.withValues(alpha: 0.06), borderRadius: BorderRadius.circular(12), border: Border.all(color: theme.colorScheme.primary.withValues(alpha: 0.15))),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [Icon(Icons.quiz_rounded, size: 18, color: theme.colorScheme.primary), const SizedBox(width: 8), Text(t('questions'), style: TextStyle(fontWeight: FontWeight.w800, color: theme.colorScheme.primary)), const Spacer(), Text('${_qCtrls.length}/9', style: TextStyle(fontWeight: FontWeight.w800, color: _qCtrls.length == 9 ? AppColors.success : AppColors.warning))]),
                  const SizedBox(height: 10),
                  Wrap(spacing: 8, runSpacing: 8, children: [
                    FilledButton.icon(onPressed: _addQuestion, icon: const Icon(Icons.add_rounded, size: 18), label: Text('${t('addLesson')} +')),
                    OutlinedButton.icon(onPressed: _shuffleQuestions, icon: const Icon(Icons.shuffle_rounded, size: 18), label: Text(t('shuffleQuestions'))),
                    OutlinedButton.icon(onPressed: _quickPaste, icon: const Icon(Icons.content_paste_rounded, size: 18), label: Text(t('pasteQuick'))),
                    OutlinedButton.icon(onPressed: () => setState(() { while (_qCtrls.length < 9) _qCtrls.add(_QCtrl()); }), icon: const Icon(Icons.format_list_numbered_rounded, size: 18), label: const Text('إكمال إلى 9')),
                  ]),
                  const SizedBox(height: 8),
                  Text(t('importHint'), style: TextStyle(fontSize: 11, color: AppColors.grayMedium)),
                ]),
              ),
              const SizedBox(height: 12),
              ...List.generate(_qCtrls.length, (i) {
                final c = _qCtrls[i];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Row(children: [
                        CircleAvatar(radius: 14, backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.12), child: Text('${i + 1}', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 12, color: theme.colorScheme.primary))),
                        const SizedBox(width: 8),
                        Text('${t('question')} #${i + 1}', style: const TextStyle(fontWeight: FontWeight.w800)),
                        const Spacer(),
                        IconButton(onPressed: () => _removeQuestion(i), icon: const Icon(Icons.delete_rounded, size: 18, color: Colors.red), tooltip: t('delete')),
                        Icon(Icons.drag_indicator_rounded, size: 18, color: AppColors.grayLight),
                      ]),
                      const SizedBox(height: 8),
                      _LangSection(title: '${t('question')} (ar) *', controller: c.qAr, maxLines: 3, hint: 'نص السؤال عربي — يدعم Markdown وكود'),
                      _LangSection(title: '${t('question')} (en) *', controller: c.qEn, maxLines: 2),
                      _LangSection(title: '${t('question')} (fr) *', controller: c.qFr, maxLines: 2),
                      const Divider(height: 20),
                      _LangSection(title: '${t('solution')} (ar) *', controller: c.sAr, maxLines: 4, hint: 'الحل عربي — يدعم ```dart و جدول | a | b |'),
                      _LangSection(title: '${t('solution')} (en) *', controller: c.sEn, maxLines: 3),
                      _LangSection(title: '${t('solution')} (fr) *', controller: c.sFr, maxLines: 3),
                    ]),
                  ),
                );
              }),
            ],
            const Divider(height: 32),
            SwitchListTile(title: Text(t('homework')), subtitle: Text(t('hasHomework')), value: _hasHomework, onChanged: (v) => setState(() => _hasHomework = v)),
            if (_hasHomework) ...[
              const SizedBox(height: 8),
              Text(t('homeworkPrompt'), style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900)),
              const SizedBox(height: 8),
              _LangSection(title: '${t('homeworkPrompt')} (ar) *', controller: _hwAr, maxLines: 6, hint: 'اكتب مهمة الواجب — سيكتب الطالب الكود أسفلها'),
              _LangSection(title: '${t('homeworkPrompt')} (en) *', controller: _hwEn, maxLines: 6),
              _LangSection(title: '${t('homeworkPrompt')} (fr) *', controller: _hwFr, maxLines: 6),
            ],
            const SizedBox(height: 24),
            FilledButton.icon(onPressed: _saving ? null : _save, icon: const Icon(Icons.save_rounded), label: Text(t('save'))),
          ],
        ),
      ),
    );
  }
}

class _LangSection extends StatelessWidget {
  final String title;
  final TextEditingController controller;
  final int maxLines;
  final String? hint;
  final String? Function(String?)? validator;

  const _LangSection({required this.title, required this.controller, this.maxLines = 1, this.hint, this.validator});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(controller: controller, maxLines: maxLines, validator: validator, decoration: InputDecoration(labelText: title, alignLabelWithHint: maxLines > 1, hintText: hint)),
    );
  }
}
