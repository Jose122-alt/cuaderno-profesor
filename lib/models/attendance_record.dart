class AttendanceRecord {
  String? id;
  final int studentId;
  final int courseId;
  final String date;
  final String status;

  AttendanceRecord({
    this.id,
    required this.studentId,
    required this.courseId,
    required this.date,
    required this.status,
  });

  Map<String, dynamic> toMap() {
    return {
      'student_id': studentId,
      'course_id': courseId,
      'date': date,
      'status': status,
    };
  }

  factory AttendanceRecord.fromMap(Map<String, dynamic> map) {
    return AttendanceRecord(
      id: map['id'] as String?,
      studentId: map['student_id'],
      courseId: map['course_id'],
      date: map['date'],
      status: map['status'],
    );
  }
}