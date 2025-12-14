
import 'package:mongo_dart/mongo_dart.dart';

class Activity {
  final String? id;
  final int courseId;
  final String title;
  final String description;
  final DateTime dueDate;
  final bool allowLateSubmissions;
  final String? fileUrl;
  final String activityType; // 'task' or 'material'
  final String evaluationCategory; // 'exam', 'portfolio', 'complementary'

  Activity({
    this.id,
    required this.courseId,
    required this.title,
    required this.description,
    required this.dueDate,
    this.allowLateSubmissions = false,
    this.fileUrl,
    this.activityType = 'task', // Default to 'task'
    this.evaluationCategory = 'portfolio',
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'course_id': courseId,
      'title': title,
      'description': description,
      'due_date': dueDate.toIso8601String(),
      'allow_late_submissions': allowLateSubmissions ? 1 : 0,
      'file_url': fileUrl,
      'activity_type': activityType,
      'evaluation_category': evaluationCategory,
    };
  }

  static Activity fromMap(Map<String, dynamic> map) {
    final String? activityId = map['id'] as String? ?? (map['_id'] is ObjectId ? (map['_id'] as ObjectId).toHexString() : null);
    final dynamic dueRaw = map['due_date'];
    final DateTime due = dueRaw is DateTime ? dueRaw : DateTime.parse(dueRaw.toString());
    final dynamic lateRaw = map['allow_late_submissions'];
    final bool allowLate = lateRaw == 1 || lateRaw == true || lateRaw == '1' || lateRaw == 'true';
    return Activity(
      id: activityId,
      courseId: map['course_id'] as int,
      title: map['title'] as String,
      description: map['description'] as String,
      dueDate: due,
      allowLateSubmissions: allowLate,
      fileUrl: map['file_url'] as String?,
      activityType: map['activity_type'] as String? ?? 'task',
      evaluationCategory: map['evaluation_category'] as String? ?? 'portfolio',
    );
  }

  Activity copyWith({
    String? id,
    int? courseId,
    String? title,
    String? description,
    DateTime? dueDate,
    bool? allowLateSubmissions,
    String? fileUrl,
    String? activityType,
    String? evaluationCategory,
  }) {
    return Activity(
      id: id ?? this.id,
      courseId: courseId ?? this.courseId,
      title: title ?? this.title,
      description: description ?? this.description,
      dueDate: dueDate ?? this.dueDate,
      allowLateSubmissions: allowLateSubmissions ?? this.allowLateSubmissions,
      fileUrl: fileUrl ?? this.fileUrl,
      activityType: activityType ?? this.activityType,
      evaluationCategory: evaluationCategory ?? this.evaluationCategory,
    );
  }
}
