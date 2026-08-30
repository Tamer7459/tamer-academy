import 'package:cloud_firestore/cloud_firestore.dart';

class AppNotification {
  final String id;
  final String userId; // المستلم
  final String title;
  final String body;
  final String type; // homework_submitted, exercise_submitted, homework_reviewed, exercise_reviewed, request_created, request_approved, request_rejected
  final String? referenceId; // id الواجب/التمرين
  final String? courseId;
  final String? lessonId;
  final bool isRead;
  final DateTime createdAt;

  const AppNotification({
    required this.id,
    required this.userId,
    required this.title,
    required this.body,
    required this.type,
    this.referenceId,
    this.courseId,
    this.lessonId,
    this.isRead = false,
    required this.createdAt,
  });

  factory AppNotification.fromMap(String id, Map<String, dynamic> map) {
    return AppNotification(
      id: id,
      userId: map['userId'] as String? ?? '',
      title: map['title'] as String? ?? '',
      body: map['body'] as String? ?? '',
      type: map['type'] as String? ?? 'general',
      referenceId: map['referenceId'] as String?,
      courseId: map['courseId'] as String?,
      lessonId: map['lessonId'] as String?,
      isRead: map['isRead'] as bool? ?? false,
      createdAt: map['createdAt'] is Timestamp
          ? (map['createdAt'] as Timestamp).toDate()
          : (map['createdAt'] is String ? DateTime.tryParse(map['createdAt'] as String) ?? DateTime.now() : DateTime.now()),
    );
  }

  Map<String, dynamic> toMap() => {
        'userId': userId,
        'title': title,
        'body': body,
        'type': type,
        'referenceId': referenceId,
        'courseId': courseId,
        'lessonId': lessonId,
        'isRead': isRead,
        'createdAt': Timestamp.fromDate(createdAt),
      };
}
