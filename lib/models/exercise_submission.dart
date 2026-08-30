import 'package:cloud_firestore/cloud_firestore.dart';

class ExerciseSubmission {
  final String id;
  final String userId;
  final String userName;
  final String userEmail;
  final String courseId;
  final String courseTitle;
  final String lessonId;
  final String lessonTitle;
  final String answerText;
  final int? selectedOptionIndex;
  final bool isCorrect;
  final String status; // pending | reviewed
  final double? grade;
  final String feedback;
  final DateTime createdAt;
  final DateTime? reviewedAt;
  final String reviewedBy;

  const ExerciseSubmission({
    required this.id,
    required this.userId,
    required this.userName,
    required this.userEmail,
    required this.courseId,
    required this.courseTitle,
    required this.lessonId,
    required this.lessonTitle,
    required this.answerText,
    this.selectedOptionIndex,
    this.isCorrect = false,
    this.status = 'pending',
    this.grade,
    this.feedback = '',
    required this.createdAt,
    this.reviewedAt,
    this.reviewedBy = '',
  });

  bool get isPending => status == 'pending';
  bool get isReviewed => status == 'reviewed';

  factory ExerciseSubmission.fromMap(String id, Map<String, dynamic> map) {
    double? parseGrade(dynamic v) {
      if (v == null) return null;
      if (v is num) return v.toDouble();
      final s = v.toString().replaceAll(',', '.').trim();
      return double.tryParse(s);
    }
    return ExerciseSubmission(
      id: id,
      userId: map['userId'] as String? ?? '',
      userName: map['userName'] as String? ?? '',
      userEmail: map['userEmail'] as String? ?? '',
      courseId: map['courseId'] as String? ?? '',
      courseTitle: map['courseTitle'] as String? ?? '',
      lessonId: map['lessonId'] as String? ?? '',
      lessonTitle: map['lessonTitle'] as String? ?? '',
      answerText: map['answerText'] as String? ?? '',
      selectedOptionIndex: (map['selectedOptionIndex'] as num?)?.toInt(),
      isCorrect: map['isCorrect'] as bool? ?? false,
      status: map['status'] as String? ?? 'pending',
      grade: parseGrade(map['grade']),
      feedback: map['feedback'] as String? ?? '',
      createdAt: map['createdAt'] is Timestamp
          ? (map['createdAt'] as Timestamp).toDate()
          : DateTime.tryParse(map['createdAt']?.toString() ?? '') ?? DateTime.now(),
      reviewedAt: map['reviewedAt'] is Timestamp
          ? (map['reviewedAt'] as Timestamp).toDate()
          : (map['reviewedAt'] != null ? DateTime.tryParse(map['reviewedAt'].toString()) : null),
      reviewedBy: map['reviewedBy'] as String? ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'userName': userName,
      'userEmail': userEmail,
      'courseId': courseId,
      'courseTitle': courseTitle,
      'lessonId': lessonId,
      'lessonTitle': lessonTitle,
      'answerText': answerText,
      'selectedOptionIndex': selectedOptionIndex,
      'isCorrect': isCorrect,
      'status': status,
      'grade': grade,
      'feedback': feedback,
      'createdAt': Timestamp.fromDate(createdAt),
      'reviewedAt': reviewedAt != null ? Timestamp.fromDate(reviewedAt!) : null,
      'reviewedBy': reviewedBy,
    };
  }
}
