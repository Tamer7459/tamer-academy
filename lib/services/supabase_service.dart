import 'dart:typed_data';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/course.dart';
import '../models/exercise_submission.dart';
import '../models/homework_submission.dart';
import '../models/lesson.dart';

class SupabaseService {
  SupabaseClient get _db => Supabase.instance.client;

  // ---------- Courses ----------
  Stream<List<Course>> coursesStream() => Stream.value([]);
  Stream<List<Course>> publishedCoursesStream() => Stream.value([]);

  Future<void> saveCourse(Course c) async {
    await _db.from('courses').upsert({
      'id': c.id,
      'title': c.title.toMap(),
      'description': c.description.toMap(),
      'track': c.track,
      'level': c.level,
      'price': c.price,
      'order': c.order,
      'published': c.published,
      'color_seed': c.colorSeed,
      'image_url': c.imageUrl,
      'image_width': c.imageWidth,
      'image_height': c.imageHeight,
      'image_fit': c.imageFit,
    });
  }

  Future<void> deleteCourse(String id) async {
    await _db.from('lessons').delete().eq('course_id', id);
    await _db.from('courses').delete().eq('id', id);
  }

  // ---------- Lessons ----------
  Stream<List<Lesson>> lessonsStream(String courseId) => Stream.value([]);

  Future<void> saveLesson(Lesson l) async {
    await _db.from('lessons').upsert({
      'id': l.id,
      'course_id': l.courseId,
      'title': l.title.toMap(),
      'content': l.content.toMap(),
      'video_url': l.videoUrl,
      'code_html': l.codeHtml,
      'code_dart': l.codeDart,
      'exercise': l.exercise?.toMap(),
      'questions': l.questions.map((q) => q.toMap()).toList(),
      'homework_prompt': l.homeworkPrompt.toMap(),
      'has_homework': l.hasHomework,
      'order': l.order,
    });
  }

  Future<void> deleteLesson(String id) async => await _db.from('lessons').delete().eq('id', id);

  // ---------- Homework ----------
  Future<void> submitHomework(HomeworkSubmission s) async {
    await _db.from('homework_submissions').upsert({
      'id': s.id,
      'user_id': s.userId,
      'user_name': s.userName,
      'user_email': s.userEmail,
      'course_id': s.courseId,
      'course_title': s.courseTitle,
      'lesson_id': s.lessonId,
      'lesson_title': s.lessonTitle,
      'code_answer': s.codeAnswer,
      'status': s.status,
      'grade': s.grade,
      'feedback': s.feedback,
      'created_at': s.createdAt.toIso8601String(),
      'reviewed_at': s.reviewedAt?.toIso8601String(),
      'reviewed_by': s.reviewedBy,
    });
  }

  Stream<List<HomeworkSubmission>> userHomeworkStream(String uid) => Stream.value([]);
  Stream<List<HomeworkSubmission>> homeworkSubmissionsStream({String? courseId, String? lessonId, String? status}) => Stream.value([]);
  Stream<List<HomeworkSubmission>> allHomeworkSubmissionsStream() => Stream.value([]);
  Stream<List<HomeworkSubmission>> lessonHomeworkStream(String lessonId, String userId) => Stream.value([]);

  Future<void> reviewHomework(String id, {required double grade, required String feedback, required String reviewedBy}) async {
    await _db.from('homework_submissions').update({'status': 'reviewed', 'grade': grade, 'feedback': feedback, 'reviewed_at': DateTime.now().toIso8601String(), 'reviewed_by': reviewedBy}).eq('id', id);
  }

  Future<void> deleteHomeworkSubmission(String id) async => await _db.from('homework_submissions').delete().eq('id', id);

  // ---------- Exercise ----------
  Future<void> submitExercise(ExerciseSubmission s) async {
    await _db.from('exercise_submissions').upsert({
      'id': s.id,
      'user_id': s.userId,
      'user_name': s.userName,
      'user_email': s.userEmail,
      'course_id': s.courseId,
      'course_title': s.courseTitle,
      'lesson_id': s.lessonId,
      'lesson_title': s.lessonTitle,
      'answer_text': s.answerText,
      'selected_option_index': s.selectedOptionIndex,
      'is_correct': s.isCorrect,
      'status': s.status,
      'grade': s.grade,
      'feedback': s.feedback,
      'created_at': s.createdAt.toIso8601String(),
      'reviewed_at': s.reviewedAt?.toIso8601String(),
      'reviewed_by': s.reviewedBy,
    });
  }

  Stream<List<ExerciseSubmission>> userExerciseStream(String uid) => Stream.value([]);
  Stream<List<ExerciseSubmission>> lessonExerciseStream(String lessonId, String userId) => Stream.value([]);
  Stream<List<ExerciseSubmission>> allExerciseSubmissionsStream() => Stream.value([]);
  Stream<List<ExerciseSubmission>> exerciseSubmissionsStream({String? courseId, String? lessonId, String? status}) => Stream.value([]);

  Future<void> reviewExercise(String id, {required double grade, required String feedback, required String reviewedBy}) async {
    await _db.from('exercise_submissions').update({'status': 'reviewed', 'grade': grade, 'feedback': feedback, 'reviewed_at': DateTime.now().toIso8601String(), 'reviewed_by': reviewedBy}).eq('id', id);
  }

  Future<void> deleteExerciseSubmission(String id) async => await _db.from('exercise_submissions').delete().eq('id', id);

  // Storage — Supabase
  Future<String> uploadCourseImage(String courseId, List<int> bytes) async {
    final path = 'courses/$courseId.jpg';
    await _db.storage.from('courses').uploadBinary(path, Uint8List.fromList(bytes), fileOptions: const FileOptions(upsert: true, contentType: 'image/jpeg'));
    return _db.storage.from('courses').getPublicUrl(path);
  }
}
