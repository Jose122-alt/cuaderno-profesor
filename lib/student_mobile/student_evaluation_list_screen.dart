import 'package:flutter/material.dart';
import 'package:flutter_application_1cuadermo/models/course.dart';
import 'package:flutter_application_1cuadermo/models/student.dart';
import 'package:flutter_application_1cuadermo/models/evaluation.dart';
import 'package:flutter_application_1cuadermo/models/grade.dart';
import 'package:flutter_application_1cuadermo/services/evaluation_service.dart';
import 'package:flutter_application_1cuadermo/services/grade_service.dart';

class StudentEvaluationListScreen extends StatefulWidget {
  final Course course;
  final Student student;

  const StudentEvaluationListScreen({super.key, required this.course, required this.student});

  @override
  State<StudentEvaluationListScreen> createState() => _StudentEvaluationListScreenState();
}

class _StudentEvaluationListScreenState extends State<StudentEvaluationListScreen> {
  final EvaluationService _evaluationService = EvaluationService();
  final GradeService _gradeService = GradeService();
  List<Evaluation> _evaluations = [];
  Map<String, Grade?> _studentGrades = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadEvaluationsAndGrades();
  }

  Future<void> _loadEvaluationsAndGrades() async {
    setState(() {
      _isLoading = true;
    });

    _evaluations = await _evaluationService.getEvaluationsByCourseId(widget.course.id!);
    for (var evaluation in _evaluations) {
      final grades = await _gradeService.getGradesByEvaluationId(evaluation.id!);
      _studentGrades[evaluation.id!] = grades.firstWhere(
        (grade) => grade.studentId == widget.student.id,
        orElse: () => Grade(evaluationId: evaluation.id!, studentId: widget.student.id!, score: 0.0), // Default to 0 if no grade found
      );
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Mis Calificaciones - ${widget.course.courseName}'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _evaluations.isEmpty
              ? const Center(child: Text('No hay evaluaciones registradas para este curso.'))
              : ListView.builder(
                  itemCount: _evaluations.length,
                  itemBuilder: (context, index) {
                    final evaluation = _evaluations[index];
                    final grade = _studentGrades[evaluation.id!];
                    return Card(
                      margin: const EdgeInsets.all(8.0),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              evaluation.evaluationName,
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 4),
                            Text('Categoría: ${evaluation.category}'),
                            Text('Ponderación: ${(evaluation.weight * 100).toStringAsFixed(0)}%'),
                            Text('Calificación Máxima: ${evaluation.maxGrade}'),
                            Text('Tu Calificación: ${grade?.score.toStringAsFixed(2) ?? 'N/A'}'),
                            Text('Fecha: ${evaluation.date.toLocal().toString().split(' ')[0]}'),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
