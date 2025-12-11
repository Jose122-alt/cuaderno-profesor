class Course {
  final int? id;
  final int teacherId;
  final String courseName;
  final String courseCode;
  final String? description;

  Course({
    this.id,
    required this.teacherId,
    required this.courseName,
    required this.courseCode,
    this.description,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'teacher_id': teacherId,
      'course_name': courseName,
      'course_code': courseCode,
      'description': description,
    };
  }

  factory Course.fromMap(Map<String, dynamic> map) {
    return Course(
      id: map['id'],
      teacherId: map['teacher_id'],
      courseName: map['course_name'],
      courseCode: map['course_code'],
      description: map['description'],
    );
  }
}