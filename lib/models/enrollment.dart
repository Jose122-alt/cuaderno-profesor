import 'package:mongo_dart/mongo_dart.dart';

class Enrollment {
  String? id;
  final String? studentId;
  final int courseId;
  final String enrollmentDate;

  Enrollment({
    this.id,
    required this.studentId,
    required this.courseId,
    required this.enrollmentDate,
  });

  Map<String, dynamic> toMap() {
    return {
      'student_id': studentId,
      'course_id': courseId,
      'enrollment_date': enrollmentDate,
    };
  }

  factory Enrollment.fromMap(Map<String, dynamic> map) {
    String? studentId;
    final dynamic sid = map['student_id'];
    if (sid is String) {
      studentId = sid;
    } else if (sid is int) {
      studentId = sid.toString();
    } else if (sid is ObjectId) {
      studentId = sid.toHexString();
    }
    return Enrollment(
      id: map['id'] as String?,
      studentId: studentId,
      courseId: map['course_id'],
      enrollmentDate: map['enrollment_date'],
    );
  }

  Enrollment copyWith({
    String? id,
    String? studentId,
    int? courseId,
    String? enrollmentDate,
  }) {
    return Enrollment(
      id: id ?? this.id,
      studentId: studentId ?? this.studentId,
      courseId: courseId ?? this.courseId,
      enrollmentDate: enrollmentDate ?? this.enrollmentDate,
    );
  }
}
