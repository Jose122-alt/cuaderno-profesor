import 'package:mongo_dart/mongo_dart.dart';

class StudentEvaluationGrade {
  final ObjectId? id;
  final ObjectId studentId;
  final ObjectId courseId;
  final ObjectId evaluationId;
  final double examScore; // Calificación del examen
  final double portfolioScore; // Calificación del portafolio
  final double complementaryScore; // Calificación de actividad complementaria
  final double weightedScore; // Calificación ponderada de la evaluación

  StudentEvaluationGrade({
    this.id,
    required this.studentId,
    required this.courseId,
    required this.evaluationId,
    required this.examScore,
    required this.portfolioScore,
    required this.complementaryScore,
    required this.weightedScore,
  });

  Map<String, dynamic> toMap() {
    return {
      '_id': id,
      'studentId': studentId,
      'courseId': courseId,
      'evaluationId': evaluationId,
      'examScore': examScore,
      'portfolioScore': portfolioScore,
      'complementaryScore': complementaryScore,
      'weightedScore': weightedScore,
    };
  }

  factory StudentEvaluationGrade.fromMap(Map<String, dynamic> map) {
    return StudentEvaluationGrade(
      id: map['_id'] as ObjectId?,
      studentId: map['studentId'] as ObjectId,
      courseId: map['courseId'] as ObjectId,
      evaluationId: map['evaluationId'] as ObjectId,
      examScore: (map['examScore'] as num).toDouble(),
      portfolioScore: (map['portfolioScore'] as num).toDouble(),
      complementaryScore: (map['complementaryScore'] as num).toDouble(),
      weightedScore: (map['weightedScore'] as num).toDouble(),
    );
  }
}
