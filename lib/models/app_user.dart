import 'package:cloud_firestore/cloud_firestore.dart';

class AppUser {
  final String uid;
  final String name;
  final String email;
  final String photoUrl;
  final String role; // 'student' | 'admin'
  final List<String> accessCourses;
  final DateTime createdAt;

  const AppUser({
    required this.uid,
    required this.name,
    required this.email,
    this.photoUrl = '',
    this.role = 'student',
    this.accessCourses = const [],
    required this.createdAt,
  });

  bool get isAdmin => role == 'admin';

  bool hasAccess(String courseId) => isAdmin || accessCourses.contains(courseId);

  factory AppUser.fromMap(String uid, Map<String, dynamic> map) {
    return AppUser(
      uid: uid,
      name: map['name'] as String? ?? '',
      email: map['email'] as String? ?? '',
      photoUrl: map['photoUrl'] as String? ?? '',
      role: map['role'] as String? ?? 'student',
      accessCourses: (map['accessCourses'] as List?)?.cast<String>() ?? [],
      createdAt: map['createdAt'] is Timestamp
          ? (map['createdAt'] as Timestamp).toDate()
          : (map['createdAt'] as DateTime?) ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'photoUrl': photoUrl,
      'role': role,
      'accessCourses': accessCourses,
      'createdAt': createdAt,
    };
  }

  AppUser copyWith({
    String? name,
    String? role,
    String? photoUrl,
    List<String>? accessCourses,
  }) {
    return AppUser(
      uid: uid,
      name: name ?? this.name,
      email: email,
      photoUrl: photoUrl ?? this.photoUrl,
      role: role ?? this.role,
      accessCourses: accessCourses ?? this.accessCourses,
      createdAt: createdAt,
    );
  }
}