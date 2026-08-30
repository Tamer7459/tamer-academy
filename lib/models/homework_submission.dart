import 'package:cloud_firestore/cloud_firestore.dart';

class HomeworkSubmission {
  final String id;
  final String userId;
  final String userName;
  final String userEmail;
  final String courseId;
  final String courseTitle;
  final String lessonId;
  final String lessonTitle;
  final String codeAnswer;
  final String status; // pending | reviewed
  final double? grade; // 0-10 with comma support
  final String feedback;
  final DateTime createdAt;
  final DateTime? reviewedAt;
  final String reviewedBy;

  const HomeworkSubmission({
    required this.id,
    required this.userId,
    required this.userName,
    required this.userEmail,
    required this.courseId,
    required this.courseTitle,
    required this.lessonId,
    required this.lessonTitle,
    required this.codeAnswer,
    this.status = 'pending',
    this.grade,
    this.feedback = '',
    required this.createdAt,
    this.reviewedAt,
    this.reviewedBy = '',
  });

  bool get isPending => status == 'pending';
  bool get isReviewed => status == 'reviewed';

  factory HomeworkSubmission.fromMap(String id, Map<String, dynamic> map) {
    double? parseGrade(dynamic v) {
      if (v == null) return null;
      if (v is num) return v.toDouble();
      final s = v.toString().replaceAll(',', '.').trim();
      return double.tryParse(s);
    }
    return HomeworkSubmission(
      id: id,
      userId: map['userId'] as String? ?? '',
      userName: map['userName'] as String? ?? '',
      userEmail: map['userEmail'] as String? ?? '',
      courseId: map['courseId'] as String? ?? '',
      courseTitle: map['courseTitle'] as String? ?? '',
      lessonId: map['lessonId'] as String? ?? '',
      lessonTitle: map['lessonTitle'] as String? ?? '',
      codeAnswer: map['codeAnswer'] as String? ?? '',
      status: map['status'] as String? ?? 'pending',
      grade: parseGrade(map['grade']),
      feedback: map['feedback'] as String? ?? '',
      createdAt: map['createdAt'] is Timestamp
          ? (map['createdAt'] as Timestamp).toDate()
          : DateTime.tryParse(map['createdAt']?.toString() ?? '') ?? DateTime.now(),
      reviewedAt: map['reviewedAt'] is Timestamp
          ? (map['reviewedAt'] as Timestamp).toDate()
          : (map['reviewedAt'] != null
              ? DateTime.tryParse(map['reviewedAt'].toString())
              : null),
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
      'codeAnswer': codeAnswer,
      'status': status,
      'grade': grade,
      'feedback': feedback,
      'createdAt': Timestamp.fromDate(createdAt),
      'reviewedAt': reviewedAt != null ? Timestamp.fromDate(reviewedAt!) : null,
      'reviewedBy': reviewedBy,
    };
  }

  HomeworkSubmission copyWith({
    String? status,
    double? grade,
    String? feedback,
    DateTime? reviewedAt,
    String? reviewedBy,
    String? codeAnswer,
  }) {
    return HomeworkSubmission(
      id: id,
      userId: userId,
      userName: userName,
      userEmail: userEmail,
      courseId: courseId,
      courseTitle: courseTitle,
      lessonId: lessonId,
      lessonTitle: lessonTitle,
      codeAnswer: codeAnswer ?? this.codeAnswer,
      status: status ?? this.status,
      grade: grade ?? this.grade,
      feedback: feedback ?? this.feedback,
      createdAt: createdAt,
      reviewedAt: reviewedAt ?? this.reviewedAt,
      reviewedBy: reviewedBy ?? this.reviewedBy,
    );
  }
}
