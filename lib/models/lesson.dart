import 'course.dart';

class Exercise {
  final LocalizedText question;
  final List<LocalizedText> options;
  final int answerIndex;
  final LocalizedText solution;

  const Exercise({
    required this.question,
    required this.options,
    required this.answerIndex,
    required this.solution,
  });

  factory Exercise.fromMap(Map<String, dynamic>? map) {
    if (map == null) {
      return Exercise(
        question: const LocalizedText(ar: '', en: '', fr: ''),
        options: const [],
        answerIndex: 0,
        solution: const LocalizedText(ar: '', en: '', fr: ''),
      );
    }
    return Exercise(
      question: LocalizedText.fromMap(map['question'] as Map<String, dynamic>?),
      options: (map['options'] as List?)
              ?.map((e) => LocalizedText.fromMap(e as Map<String, dynamic>))
              .toList() ??
          const [],
      answerIndex: (map['answerIndex'] as num?)?.toInt() ?? 0,
      solution: LocalizedText.fromMap(map['solution'] as Map<String, dynamic>?),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'question': question.toMap(),
      'options': options.map((e) => e.toMap()).toList(),
      'answerIndex': answerIndex,
      'solution': solution.toMap(),
    };
  }

  bool get hasExercise => question.ar.isNotEmpty || question.en.isNotEmpty || question.fr.isNotEmpty;
}

class LessonQuestion {
  final LocalizedText question;
  final LocalizedText solution;

  const LessonQuestion({
    required this.question,
    required this.solution,
  });

  factory LessonQuestion.fromMap(Map<String, dynamic>? map) {
    if (map == null) {
      return const LessonQuestion(
        question: LocalizedText(ar: '', en: '', fr: ''),
        solution: LocalizedText(ar: '', en: '', fr: ''),
      );
    }
    return LessonQuestion(
      question: LocalizedText.fromMap(map['question'] as Map<String, dynamic>?),
      solution: LocalizedText.fromMap(map['solution'] as Map<String, dynamic>?),
    );
  }

  Map<String, dynamic> toMap() => {
        'question': question.toMap(),
        'solution': solution.toMap(),
      };

  bool get hasContent =>
      question.ar.isNotEmpty || question.en.isNotEmpty || question.fr.isNotEmpty;
}

class Lesson {
  final String id;
  final String courseId;
  final LocalizedText title;
  final LocalizedText content;
  final String videoUrl;
  final String codeHtml;
  final String codeDart;
  final Exercise? exercise;
  final List<LessonQuestion> questions;
  final LocalizedText homeworkPrompt;
  final bool hasHomework;
  final int order;

  const Lesson({
    required this.id,
    required this.courseId,
    required this.title,
    required this.content,
    this.videoUrl = '',
    this.codeHtml = '',
    this.codeDart = '',
    this.exercise,
    this.questions = const [],
    this.homeworkPrompt = const LocalizedText(ar: '', en: '', fr: ''),
    this.hasHomework = false,
    required this.order,
  });

  bool get hasQuestions => questions.any((q) => q.hasContent);
  bool get hasHomeworkTask => hasHomework && !homeworkPrompt.isEmpty;
  int get validQuestionsCount => questions.where((q) => q.hasContent).length;

  factory Lesson.fromMap(String id, Map<String, dynamic> map) {
    // Parse questions array
    List<LessonQuestion> parsedQuestions = [];
    final rawQuestions = map['questions'] as List?;
    if (rawQuestions != null) {
      parsedQuestions = rawQuestions
          .map((e) => LessonQuestion.fromMap(e as Map<String, dynamic>?))
          .toList();
    }
    // Backward compat: migrate single exercise -> questions[0] ONLY if questions field absent
    final ex = Exercise.fromMap(map['exercise'] as Map<String, dynamic>?);
    if (rawQuestions == null && ex.hasExercise) {
      parsedQuestions = [
        LessonQuestion(question: ex.question, solution: ex.solution)
      ];
    }

    return Lesson(
      id: id,
      courseId: map['courseId'] as String? ?? '',
      title: LocalizedText.fromMap(map['title'] as Map<String, dynamic>?),
      content: LocalizedText.fromMap(map['content'] as Map<String, dynamic>?),
      videoUrl: map['videoUrl'] as String? ?? '',
      codeHtml: map['codeHtml'] as String? ?? '',
      codeDart: map['codeDart'] as String? ?? '',
      exercise: ex.hasExercise ? ex : null,
      questions: parsedQuestions,
      homeworkPrompt:
          LocalizedText.fromMap(map['homeworkPrompt'] as Map<String, dynamic>?),
      hasHomework: map['hasHomework'] as bool? ??
          (map['homeworkPrompt'] != null &&
              LocalizedText.fromMap(
                      map['homeworkPrompt'] as Map<String, dynamic>?)
                  .ar
                  .trim()
                  .isNotEmpty),
      order: (map['order'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'courseId': courseId,
      'title': title.toMap(),
      'content': content.toMap(),
      'videoUrl': videoUrl,
      'codeHtml': codeHtml,
      'codeDart': codeDart,
      'exercise': exercise?.toMap(),
      'questions': questions.map((e) => e.toMap()).toList(),
      'homeworkPrompt': homeworkPrompt.toMap(),
      'hasHomework': hasHomework,
      'order': order,
    };
  }

  Lesson copyWith({
    String? id,
    String? courseId,
    LocalizedText? title,
    LocalizedText? content,
    String? videoUrl,
    String? codeHtml,
    String? codeDart,
    Exercise? exercise,
    List<LessonQuestion>? questions,
    LocalizedText? homeworkPrompt,
    bool? hasHomework,
    int? order,
  }) {
    return Lesson(
      id: id ?? this.id,
      courseId: courseId ?? this.courseId,
      title: title ?? this.title,
      content: content ?? this.content,
      videoUrl: videoUrl ?? this.videoUrl,
      codeHtml: codeHtml ?? this.codeHtml,
      codeDart: codeDart ?? this.codeDart,
      exercise: exercise ?? this.exercise,
      questions: questions ?? this.questions,
      homeworkPrompt: homeworkPrompt ?? this.homeworkPrompt,
      hasHomework: hasHomework ?? this.hasHomework,
      order: order ?? this.order,
    );
  }
}