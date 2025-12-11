class Evidence {
  final String? id;
  final int courseId;
  final int studentId;
  final String? activityId; // Nuevo campo para vincular con la actividad
  final String description;
  final String date;
  final String status; // e.g., 'pending', 'submitted', 'graded'
  final String? fileUrl;
  final int? grade; // calificación opcional
  final String? comment; // comentario del profesor

  Evidence({
    this.id,
    required this.courseId,
    required this.studentId,
    this.activityId,
    required this.description,
    required this.date,
    this.status = 'pending',
    this.fileUrl,
    this.grade,
    this.comment,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'course_id': courseId,
      'student_id': studentId,
      'activity_id': activityId,
      'description': description,
      'date': date,
      'status': status,
      'file_url': fileUrl,
      'grade': grade,
      'comment': comment,
    };
  }

  factory Evidence.fromMap(Map<String, dynamic> map) {
    return Evidence(
      id: map['id'] as String?,
      courseId: map['course_id'] as int,
      studentId: map['student_id'] as int,
      activityId: map['activity_id'] as String?, // Asegurarse de que se lea correctamente
      description: map['description'] as String,
      date: map['date'] as String,
      status: map['status'] as String? ?? 'pending',
      fileUrl: map['file_url'] as String?,
      grade: map['grade'] is int ? map['grade'] as int : (map['grade'] is String ? int.tryParse(map['grade']) : null),
      comment: map['comment'] as String?,
    );
  }

  Evidence copyWith({
    String? id,
    int? courseId,
    int? studentId,
    String? activityId,
    String? description,
    String? date,
    String? status,
    String? fileUrl,
    int? grade,
    String? comment,
  }) {
    return Evidence(
      id: id ?? this.id,
      courseId: courseId ?? this.courseId,
      studentId: studentId ?? this.studentId,
      activityId: activityId ?? this.activityId,
      description: description ?? this.description,
      date: date ?? this.date,
      status: status ?? this.status,
      fileUrl: fileUrl ?? this.fileUrl,
      grade: grade ?? this.grade,
      comment: comment ?? this.comment,
    );
  }
}
