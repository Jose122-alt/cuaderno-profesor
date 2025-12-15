import 'package:flutter/material.dart';

class Grade {
  final String? id;
  final String evaluationId;
  final String studentId;
  final double score;

  Grade({
    this.id,
    required this.evaluationId,
    required this.studentId,
    required this.score,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'evaluation_id': evaluationId,
      'student_id': studentId,
      'score': score,
    };
  }

  factory Grade.fromMap(Map<String, dynamic> map) {
    return Grade(
      id: (map['id'] as dynamic)?.toString(),
      evaluationId: (map['evaluation_id'] as dynamic)?.toString() ?? '',
      studentId: (map['student_id'] as dynamic)?.toString() ?? '',
      score: (map['score'] as num).toDouble(),
    );
  }
}
