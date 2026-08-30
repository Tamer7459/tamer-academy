import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/access_request.dart';
import '../models/app_notification.dart';
import '../models/app_user.dart';
import '../models/course.dart';
import '../models/exercise_submission.dart';
import '../models/homework_submission.dart';
import '../models/lesson.dart';
import '../models/track.dart';
import 'supabase_service.dart';

class DatabaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final SupabaseService _supa = SupabaseService();
  // تم إيقاف Supabase مؤقتاً لإصلاح البناء — سيعود بعد حل مشكلة Realtime
  static const bool _useSupabase = false;

  CollectionReference<Map<String, dynamic>> get _users => _db.collection('users');
  CollectionReference<Map<String, dynamic>> get _courses => _db.collection('courses');
  CollectionReference<Map<String, dynamic>> get _lessons => _db.collection('lessons');
  CollectionReference<Map<String, dynamic>> get _progress => _db.collection('progress');
  CollectionReference<Map<String, dynamic>> get _tracks => _db.collection('tracks');
  CollectionReference<Map<String, dynamic>> get _requests => _db.collection('accessRequests');
  CollectionReference<Map<String, dynamic>> get _homeworkSubs =>
      _db.collection('homeworkSubmissions');
  CollectionReference<Map<String, dynamic>> get _exerciseSubs =>
      _db.collection('exerciseSubmissions');
  CollectionReference<Map<String, dynamic>> get _notifications =>
      _db.collection('notifications');

  // ---------- Users ----------

  Future<void> createUser(AppUser user) {
    return _users.doc(user.uid).set(user.toMap());
  }

  Stream<AppUser?> userStream(String uid) {
    return _users.doc(uid).snapshots().map(
          (doc) => doc.exists ? AppUser.fromMap(doc.id, doc.data()!) : null,
        );
  }

  Future<AppUser?> getUser(String uid) async {
    final doc = await _users.doc(uid).get();
    return doc.exists ? AppUser.fromMap(doc.id, doc.data()!) : null;
  }

  Stream<List<AppUser>> allUsersStream() {
    return _users.orderBy('createdAt', descending: true).snapshots().map(
          (snap) => snap.docs.map((d) => AppUser.fromMap(d.id, d.data())).toList(),
        );
  }

  Future<void> updateUser(AppUser user) => _users.doc(user.uid).set(user.toMap());

  Future<void> toggleUserCourseAccess(String uid, String courseId, bool has) async {
    final doc = await _users.doc(uid).get();
    if (!doc.exists) return;
    final user = AppUser.fromMap(doc.id, doc.data()!);
    final access = List<String>.from(user.accessCourses);
    if (has && !access.contains(courseId)) {
      access.add(courseId);
    } else if (!has) {
      access.remove(courseId);
    }
    await _users.doc(uid).update({'accessCourses': access});
  }

  Future<void> setUserRole(String uid, String role) => _users.doc(uid).update({'role': role});

  Future<void> updateUserName(String uid, String name) =>
      _users.doc(uid).update({'name': name});

  Future<void> deleteUser(String uid) async {
    try {
      await _progress.doc(uid).delete();
    } catch (_) {}
    await _users.doc(uid).delete();
  }

  // ---------- Courses ----------

  Stream<List<Course>> coursesStream() {
    if (_useSupabase) {
      try {
        return _supa.coursesStream().handleError((e) => _courses.orderBy('order').snapshots().map((snap) => snap.docs.map((d) => Course.fromMap(d.id, d.data())).toList()));
      } catch (_) {}
    }
    return _courses.orderBy('order').snapshots().map((snap) => snap.docs.map((d) => Course.fromMap(d.id, d.data())).toList());
  }

  Stream<List<Course>> publishedCoursesStream() {
    if (_useSupabase) {
      try {
        return _supa.publishedCoursesStream();
      } catch (_) {}
    }
    return _courses.where('published', isEqualTo: true).snapshots().map((snap) {
      final list = snap.docs.map((d) => Course.fromMap(d.id, d.data())).toList()..sort((a, b) => a.order.compareTo(b.order));
      return list;
    });
  }

  Future<Course?> getCourse(String id) async {
    final doc = await _courses.doc(id).get();
    return doc.exists ? Course.fromMap(doc.id, doc.data()!) : null;
  }

  Future<void> saveCourse(Course course) async {
    if (_useSupabase) {
      try {
        await _supa.saveCourse(course);
      } catch (_) {}
    }
    return _courses.doc(course.id).set(course.toMap());
  }

  Future<void> deleteCourse(String id) async {
    if (_useSupabase) {
      try {
        await _supa.deleteCourse(id);
      } catch (_) {}
    }
    final lessons = await _lessons.where('courseId', isEqualTo: id).get();
    for (final l in lessons.docs) {
      await _lessons.doc(l.id).delete();
    }
    await _courses.doc(id).delete();
  }

  // ---------- Lessons ----------

  Stream<List<Lesson>> lessonsStream(String courseId) {
    if (_useSupabase) {
      try {
        return _supa.lessonsStream(courseId);
      } catch (_) {}
    }
    return _lessons.where('courseId', isEqualTo: courseId).snapshots().map((snap) {
      final list = snap.docs.map((d) => Lesson.fromMap(d.id, d.data())).toList()..sort((a, b) => a.order.compareTo(b.order));
      return list;
    });
  }

  Future<Lesson?> getLesson(String id) async {
    final doc = await _lessons.doc(id).get();
    return doc.exists ? Lesson.fromMap(doc.id, doc.data()!) : null;
  }

  Future<int> lessonsCount(String courseId) async {
    final snap = await _lessons.where('courseId', isEqualTo: courseId).get();
    return snap.docs.length;
  }

  Future<void> saveLesson(Lesson lesson) async {
    if (_useSupabase) {
      try {
        await _supa.saveLesson(lesson);
      } catch (_) {}
    }
    return _lessons.doc(lesson.id).set(lesson.toMap());
  }

  Future<void> deleteLesson(String id) async {
    if (_useSupabase) {
      try {
        await _supa.deleteLesson(id);
      } catch (_) {}
    }
    return _lessons.doc(id).delete();
  }

  // ---------- Progress ----------

  Stream<Map<String, dynamic>> progressStream(String uid) {
    return _progress.doc(uid).snapshots().map((doc) => doc.data() ?? {});
  }

  Future<void> markLessonCompleted(String uid, String courseId, String lessonId) async {
    final doc = _progress.doc(uid);
    final data = (await doc.get()).data() ?? {};
    final courses = Map<String, dynamic>.from(data['courses'] as Map? ?? {});
    final course = Map<String, dynamic>.from(courses[courseId] as Map? ?? {});
    final completed = (course['completed'] as List?)?.cast<String>() ?? [];
    if (!completed.contains(lessonId)) completed.add(lessonId);
    course['completed'] = completed;
    courses[courseId] = course;
    await doc.set({'courses': courses}, SetOptions(merge: true));
  }

  Future<void> unmarkLessonCompleted(String uid, String courseId, String lessonId) async {
    final doc = _progress.doc(uid);
    final data = (await doc.get()).data() ?? {};
    final courses = Map<String, dynamic>.from(data['courses'] as Map? ?? {});
    final course = Map<String, dynamic>.from(courses[courseId] as Map? ?? {});
    final completed = (course['completed'] as List?)?.cast<String>() ?? [];
    completed.remove(lessonId);
    course['completed'] = completed;
    courses[courseId] = course;
    await doc.set({'courses': courses}, SetOptions(merge: true));
  }

  Future<void> toggleLessonCompleted(String uid, String courseId, String lessonId, bool isCompleted) async {
    if (isCompleted) {
      await markLessonCompleted(uid, courseId, lessonId);
    } else {
      await unmarkLessonCompleted(uid, courseId, lessonId);
    }
  }

  Future<void> markLessonAnswered(String uid, String courseId, String lessonId) async {
    final doc = _progress.doc(uid);
    final data = (await doc.get()).data() ?? {};
    final courses = Map<String, dynamic>.from(data['courses'] as Map? ?? {});
    final course = Map<String, dynamic>.from(courses[courseId] as Map? ?? {});
    final answered = (course['answered'] as List?)?.cast<String>() ?? [];
    if (!answered.contains(lessonId)) answered.add(lessonId);
    course['answered'] = answered;
    courses[courseId] = course;
    await doc.set({'courses': courses}, SetOptions(merge: true));
  }

  Future<bool> isLessonCompleted(String uid, String courseId, String lessonId) async {
    final doc = await _progress.doc(uid).get();
    final data = doc.data() ?? {};
    final courses = Map<String, dynamic>.from(data['courses'] as Map? ?? {});
    final course = Map<String, dynamic>.from(courses[courseId] as Map? ?? {});
    return ((course['completed'] as List?)?.cast<String>() ?? []).contains(lessonId);
  }

  Future<bool> isLessonAnswered(String uid, String courseId, String lessonId) async {
    final doc = await _progress.doc(uid).get();
    final data = doc.data() ?? {};
    final courses = Map<String, dynamic>.from(data['courses'] as Map? ?? {});
    final course = Map<String, dynamic>.from(courses[courseId] as Map? ?? {});
    return ((course['answered'] as List?)?.cast<String>() ?? []).contains(lessonId);
  }

  // ---------- Tracks ----------

  Stream<List<Track>> tracksStream() {
    return _tracks
        .orderBy('order')
        .snapshots()
        .map((snap) => snap.docs.map((d) => Track.fromMap(d.id, d.data())).toList());
  }

  Stream<List<Track>> publishedTracksStream() {
    return _tracks
        .where('published', isEqualTo: true)
        .snapshots()
        .map((snap) {
          final list = snap.docs
              .map((d) => Track.fromMap(d.id, d.data()))
              .toList()
            ..sort((a, b) => a.order.compareTo(b.order));
          return list;
        });
  }

  Future<void> saveTrack(Track track) {
    return _tracks.doc(track.id).set(track.toMap());
  }

  Future<void> deleteTrack(String id) => _tracks.doc(id).delete();

  // ---------- Access Requests ----------

  Stream<List<AccessRequest>> accessRequestsStream() {
    return _requests.orderBy('createdAt', descending: true).snapshots().map(
          (snap) => snap.docs.map((d) => AccessRequest.fromMap(d.id, d.data())).toList(),
        );
  }

  Stream<List<AccessRequest>> userRequestsStream(String userId) {
    return _requests.where('userId', isEqualTo: userId).snapshots().map(
          (snap) => snap.docs.map((d) => AccessRequest.fromMap(d.id, d.data())).toList(),
        );
  }

  Future<void> createAccessRequest(AccessRequest req) async {
    await _requests.doc(req.id).set(req.toMap());
    await notifyAdmins(
      title: 'طلب وصول جديد',
      body: '${req.userName} طلب الوصول إلى ${req.courseTitle}',
      type: 'request_created',
      referenceId: req.id,
      courseId: req.courseId,
    );
  }

  Future<void> updateRequestStatus(String requestId, String status) async {
    await _requests.doc(requestId).update({'status': status});
    final reqDoc = await _requests.doc(requestId).get();
    if (!reqDoc.exists) return;
    final req = AccessRequest.fromMap(reqDoc.id, reqDoc.data()!);
    if (status == 'approved') {
      await toggleUserCourseAccess(req.userId, req.courseId, true);
    }
    final isApproved = status == 'approved';
    await createNotification(AppNotification(
      id: '${req.userId}_${DateTime.now().microsecondsSinceEpoch}_request_${status}',
      userId: req.userId,
      title: isApproved ? 'تم قبول طلبك' : 'تم رفض طلبك',
      body: isApproved ? 'تم منحك الوصول إلى ${req.courseTitle}' : 'تم رفض طلب الوصول إلى ${req.courseTitle}',
      type: isApproved ? 'request_approved' : 'request_rejected',
      referenceId: requestId,
      courseId: req.courseId,
      createdAt: DateTime.now(),
    ));
  }

  Future<void> deleteRequest(String id) => _requests.doc(id).delete();

  // ---------- Homework Submissions ----------

  Future<void> submitHomework(HomeworkSubmission sub) async {
    if (_useSupabase) {
      try {
        await _supa.submitHomework(sub);
      } catch (_) {}
    }
    await _homeworkSubs.doc(sub.id).set(sub.toMap());
    await notifyAdmins(
      title: 'واجب جديد',
      body: '${sub.userName} أرسل واجباً في ${sub.lessonTitle}',
      type: 'homework_submitted',
      referenceId: sub.id,
      courseId: sub.courseId,
      lessonId: sub.lessonId,
    );
  }

  Stream<List<HomeworkSubmission>> homeworkSubmissionsStream({
    String? courseId,
    String? lessonId,
    String? status,
  }) {
    if (_useSupabase) {
      try {
        return _supa.homeworkSubmissionsStream(courseId: courseId, lessonId: lessonId, status: status);
      } catch (_) {}
    }
    Query<Map<String, dynamic>> q = _homeworkSubs;
    if (courseId != null) q = q.where('courseId', isEqualTo: courseId);
    if (lessonId != null) q = q.where('lessonId', isEqualTo: lessonId);
    if (status != null) q = q.where('status', isEqualTo: status);
    return q.snapshots().map((snap) {
      final list = snap.docs.map((d) => HomeworkSubmission.fromMap(d.id, d.data())).toList()..sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return list;
    });
  }

  Stream<List<HomeworkSubmission>> allHomeworkSubmissionsStream() {
    if (_useSupabase) {
      try {
        return _supa.allHomeworkSubmissionsStream();
      } catch (_) {}
    }
    return _homeworkSubs.orderBy('createdAt', descending: true).snapshots().map(
          (snap) => snap.docs.map((d) => HomeworkSubmission.fromMap(d.id, d.data())).toList(),
        );
  }

  Stream<List<HomeworkSubmission>> userHomeworkStream(String userId) {
    if (_useSupabase) {
      try {
        return _supa.userHomeworkStream(userId);
      } catch (_) {}
    }
    return _homeworkSubs.where('userId', isEqualTo: userId).snapshots().map((snap) {
      final list = snap.docs.map((d) => HomeworkSubmission.fromMap(d.id, d.data())).toList()..sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return list;
    });
  }

  Stream<List<HomeworkSubmission>> lessonHomeworkStream(String lessonId, String userId) {
    if (_useSupabase) {
      try {
        return _supa.lessonHomeworkStream(lessonId, userId);
      } catch (_) {}
    }
    return _homeworkSubs.where('lessonId', isEqualTo: lessonId).where('userId', isEqualTo: userId).snapshots().map((snap) {
      final list = snap.docs.map((d) => HomeworkSubmission.fromMap(d.id, d.data())).toList()..sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return list;
    });
  }

  Future<void> reviewHomework(String submissionId, {required double grade, required String feedback, required String reviewedBy}) async {
    if (_useSupabase) {
      try {
        await _supa.reviewHomework(submissionId, grade: grade, feedback: feedback, reviewedBy: reviewedBy);
      } catch (_) {}
    }
    await _homeworkSubs.doc(submissionId).update({'status': 'reviewed', 'grade': grade, 'feedback': feedback, 'reviewedAt': Timestamp.now(), 'reviewedBy': reviewedBy});
    try {
      final doc = await _homeworkSubs.doc(submissionId).get();
      final userId = doc.data()?['userId'] as String?;
      if (userId != null) {
        await createNotification(AppNotification(
          id: '${userId}_${DateTime.now().microsecondsSinceEpoch}_homework_reviewed',
          userId: userId,
          title: 'تم تصحيح واجبك',
          body: 'حصلت على ${grade.toStringAsFixed(grade.truncateToDouble() == grade ? 0 : 1).replaceAll('.', ',')}/10 في ${doc.data()?['lessonTitle'] ?? ''}',
          type: 'homework_reviewed',
          referenceId: submissionId,
          courseId: doc.data()?['courseId'] as String?,
          lessonId: doc.data()?['lessonId'] as String?,
          createdAt: DateTime.now(),
        ));
      }
    } catch (_) {}
  }

  Future<void> deleteHomeworkSubmission(String id) async {
    if (_useSupabase) {
      try {
        await _supa.deleteHomeworkSubmission(id);
      } catch (_) {}
    }
    return _homeworkSubs.doc(id).delete();
  }

  Future<int> pendingHomeworkCount() async {
    final snap =
        await _homeworkSubs.where('status', isEqualTo: 'pending').get();
    return snap.docs.length;
  }

  // ---------- Exercise Submissions ----------

  Future<void> submitExercise(ExerciseSubmission sub) async {
    if (_useSupabase) {
      try {
        await _supa.submitExercise(sub);
      } catch (_) {}
    }
    await _exerciseSubs.doc(sub.id).set(sub.toMap());
    await notifyAdmins(
      title: 'تمرين محلول',
      body: '${sub.userName} أرسل حل تمرين في ${sub.lessonTitle}',
      type: 'exercise_submitted',
      referenceId: sub.id,
      courseId: sub.courseId,
      lessonId: sub.lessonId,
    );
  }

  Stream<List<ExerciseSubmission>> allExerciseSubmissionsStream() {
    if (_useSupabase) {
      try {
        return _supa.allExerciseSubmissionsStream();
      } catch (_) {}
    }
    return _exerciseSubs.orderBy('createdAt', descending: true).snapshots().map(
          (snap) => snap.docs.map((d) => ExerciseSubmission.fromMap(d.id, d.data())).toList(),
        );
  }

  Stream<List<ExerciseSubmission>> userExerciseStream(String userId) {
    if (_useSupabase) {
      try {
        return _supa.userExerciseStream(userId);
      } catch (_) {}
    }
    return _exerciseSubs.where('userId', isEqualTo: userId).snapshots().map((snap) {
      final list = snap.docs.map((d) => ExerciseSubmission.fromMap(d.id, d.data())).toList()..sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return list;
    });
  }

  Stream<List<ExerciseSubmission>> lessonExerciseStream(String lessonId, String userId) {
    if (_useSupabase) {
      try {
        return _supa.lessonExerciseStream(lessonId, userId);
      } catch (_) {}
    }
    return _exerciseSubs.where('lessonId', isEqualTo: lessonId).where('userId', isEqualTo: userId).snapshots().map((snap) {
      final list = snap.docs.map((d) => ExerciseSubmission.fromMap(d.id, d.data())).toList()..sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return list;
    });
  }

  Stream<List<ExerciseSubmission>> exerciseSubmissionsStream({
    String? courseId,
    String? lessonId,
    String? status,
  }) {
    if (_useSupabase) {
      try {
        return _supa.exerciseSubmissionsStream(courseId: courseId, lessonId: lessonId, status: status);
      } catch (_) {}
    }
    Query<Map<String, dynamic>> q = _exerciseSubs;
    if (courseId != null) q = q.where('courseId', isEqualTo: courseId);
    if (lessonId != null) q = q.where('lessonId', isEqualTo: lessonId);
    if (status != null) q = q.where('status', isEqualTo: status);
    return q.snapshots().map((snap) {
      final list = snap.docs.map((d) => ExerciseSubmission.fromMap(d.id, d.data())).toList()..sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return list;
    });
  }

  Future<void> reviewExercise(String submissionId, {required double grade, required String feedback, required String reviewedBy}) async {
    if (_useSupabase) {
      try {
        await _supa.reviewExercise(submissionId, grade: grade, feedback: feedback, reviewedBy: reviewedBy);
      } catch (_) {}
    }
    await _exerciseSubs.doc(submissionId).update({'status': 'reviewed', 'grade': grade, 'feedback': feedback, 'reviewedAt': Timestamp.now(), 'reviewedBy': reviewedBy});
    try {
      final doc = await _exerciseSubs.doc(submissionId).get();
      final userId = doc.data()?['userId'] as String?;
      if (userId != null) {
        await createNotification(AppNotification(
          id: '${userId}_${DateTime.now().microsecondsSinceEpoch}_exercise_reviewed',
          userId: userId,
          title: 'تم تصحيح تمرينك',
          body: 'حصلت على ${grade.toStringAsFixed(grade.truncateToDouble() == grade ? 0 : 1).replaceAll('.', ',')}/10 في ${doc.data()?['lessonTitle'] ?? ''}',
          type: 'exercise_reviewed',
          referenceId: submissionId,
          courseId: doc.data()?['courseId'] as String?,
          lessonId: doc.data()?['lessonId'] as String?,
          createdAt: DateTime.now(),
        ));
      }
    } catch (_) {}
  }

  Future<void> deleteExerciseSubmission(String id) async {
    if (_useSupabase) {
      try {
        await _supa.deleteExerciseSubmission(id);
      } catch (_) {}
    }
    return _exerciseSubs.doc(id).delete();
  }

  // ---------- Random Seen (per lesson) ----------
  Future<void> saveRandomSeen(
      String uid, String lessonId, List<int> seen) async {
    final doc = _progress.doc(uid);
    final data = (await doc.get()).data() ?? {};
    final randomSeen =
        Map<String, dynamic>.from(data['randomSeen'] as Map? ?? {});
    randomSeen[lessonId] = seen;
    await doc.set({'randomSeen': randomSeen}, SetOptions(merge: true));
  }

  Future<List<int>> getRandomSeen(String uid, String lessonId) async {
    final doc = await _progress.doc(uid).get();
    final data = doc.data() ?? {};
    final randomSeen =
        Map<String, dynamic>.from(data['randomSeen'] as Map? ?? {});
    return (randomSeen[lessonId] as List?)?.cast<int>() ?? [];
  }

  Stream<List<int>> randomSeenStream(String uid, String lessonId) {
    return _progress.doc(uid).snapshots().map((doc) {
      final data = doc.data() ?? {};
      final randomSeen =
          Map<String, dynamic>.from(data['randomSeen'] as Map? ?? {});
      return (randomSeen[lessonId] as List?)?.cast<int>() ?? [];
    });
  }

  // ---------- Notifications ----------
  Future<void> createNotification(AppNotification n) =>
      _notifications.doc(n.id).set(n.toMap());

  Stream<List<AppNotification>> notificationsStream(String userId) {
    return _notifications
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map((d) => AppNotification.fromMap(d.id, d.data())).toList());
  }

  Stream<int> unreadCountStream(String userId) {
    return _notifications
        .where('userId', isEqualTo: userId)
        .where('isRead', isEqualTo: false)
        .snapshots()
        .map((snap) => snap.docs.length);
  }

  Future<void> markNotificationRead(String id) =>
      _notifications.doc(id).update({'isRead': true});

  Future<void> markAllNotificationsRead(String userId) async {
    final snap = await _notifications.where('userId', isEqualTo: userId).where('isRead', isEqualTo: false).get();
    if (snap.docs.isEmpty) return;
    final batch = _db.batch();
    for (final d in snap.docs) {
      batch.update(d.reference, {'isRead': true});
    }
    await batch.commit();
  }

  Future<void> notifyAdmins({
    required String title,
    required String body,
    required String type,
    String? referenceId,
    String? courseId,
    String? lessonId,
  }) async {
    try {
      final admins = await _users.where('role', isEqualTo: 'admin').get();
      if (admins.docs.isEmpty) return;
      final batch = _db.batch();
      final now = DateTime.now().microsecondsSinceEpoch;
      for (int i = 0; i < admins.docs.length; i++) {
        final doc = admins.docs[i];
        final n = AppNotification(
          id: '${doc.id}_${now + i}_$type',
          userId: doc.id,
          title: title,
          body: body,
          type: type,
          referenceId: referenceId,
          courseId: courseId,
          lessonId: lessonId,
          createdAt: DateTime.now(),
        );
        batch.set(_notifications.doc(n.id), n.toMap());
      }
      await batch.commit();
    } catch (_) {}
  }
}