class AttendanceRecord {
  String? id;
  final int studentId;
  final int courseId;
  final String date;
  final String status;
  final DateTime? timestamp;

  AttendanceRecord({
    this.id,
    required this.studentId,
    required this.courseId,
    required this.date,
    required this.status,
    this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'student_id': studentId,
      'course_id': courseId,
      'date': date,
      'status': status,
      'timestamp': timestamp?.toIso8601String(),
    };
  }

  factory AttendanceRecord.fromMap(Map<String, dynamic> map) {
    return AttendanceRecord(
      id: map['id'] as String?,
      studentId: map['student_id'] as int,
      courseId: map['course_id'] as int,
      date: map['date'] as String? ?? '',
      status: map['status'] as String? ?? '',
      timestamp: map['timestamp'] != null ? DateTime.parse(map['timestamp']) : DateTime.now(),
    );
  }
}