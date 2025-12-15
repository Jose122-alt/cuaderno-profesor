class Evaluation {
  final String? id;
  final String courseId;
  final String evaluationName;
  final double weight;
  final String category; // e.g., "Parcial", "Ordinaria", "Actividad"
  final double maxGrade;
  final DateTime date;

  Evaluation({
    this.id,
    required this.courseId,
    required this.evaluationName,
    required this.weight,
    required this.category,
    required this.maxGrade,
    required this.date,
  });

  Evaluation copyWith({
    String? id,
    String? courseId,
    String? evaluationName,
    double? weight,
    String? category,
    double? maxGrade,
    DateTime? date,
  }) {
    return Evaluation(
      id: id ?? this.id,
      courseId: courseId ?? this.courseId,
      evaluationName: evaluationName ?? this.evaluationName,
      weight: weight ?? this.weight,
      category: category ?? this.category,
      maxGrade: maxGrade ?? this.maxGrade,
      date: date ?? this.date,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'course_id': courseId,
      'evaluation_name': evaluationName,
      'weight': weight,
      'category': category,
      'max_grade': maxGrade,
      'date': date.toIso8601String(),
    };
  }

  factory Evaluation.fromMap(Map<String, dynamic> map) {
    return Evaluation(
      id: (map['id'] as dynamic)?.toString(),
      courseId: (map['course_id'] as dynamic)?.toString() ?? '',
      evaluationName: map['evaluation_name'] as String,
      weight: (map['weight'] as num).toDouble(),
      category: map['category'] as String,
      maxGrade: (map['max_grade'] as num).toDouble(),
      date: DateTime.parse(map['date'] as String),
    );
  }
}
