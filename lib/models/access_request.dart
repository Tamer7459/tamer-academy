import 'package:cloud_firestore/cloud_firestore.dart';

class AccessRequest {
  final String id;
  final String userId;
  final String userName;
  final String userEmail;
  final String courseId;
  final String courseTitle;
  final String status; // pending | approved | denied
  final DateTime createdAt;

  const AccessRequest({
    required this.id,
    required this.userId,
    required this.userName,
    required this.userEmail,
    required this.courseId,
    required this.courseTitle,
    this.status = 'pending',
    required this.createdAt,
  });

  factory AccessRequest.fromMap(String id, Map<String, dynamic> map) {
    return AccessRequest(
      id: id,
      userId: map['userId'] as String? ?? '',
      userName: map['userName'] as String? ?? '',
      userEmail: map['userEmail'] as String? ?? '',
      courseId: map['courseId'] as String? ?? '',
      courseTitle: map['courseTitle'] as String? ?? '',
      status: map['status'] as String? ?? 'pending',
      createdAt: map['createdAt'] is Timestamp
          ? (map['createdAt'] as Timestamp).toDate()
          : (map['createdAt'] as DateTime?) ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'userName': userName,
      'userEmail': userEmail,
      'courseId': courseId,
      'courseTitle': courseTitle,
      'status': status,
      'createdAt': createdAt,
    };
  }

  AccessRequest copyWith({String? status}) {
    return AccessRequest(
      id: id,
      userId: userId,
      userName: userName,
      userEmail: userEmail,
      courseId: courseId,
      courseTitle: courseTitle,
      status: status ?? this.status,
      createdAt: createdAt,
    );
  }
}
