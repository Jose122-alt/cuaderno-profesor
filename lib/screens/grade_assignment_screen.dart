import 'package:flutter/material.dart';
import 'package:flutter_application_1cuadermo/models/evaluation.dart';
import 'package:flutter_application_1cuadermo/models/student.dart';
import 'package:flutter_application_1cuadermo/models/grade.dart';
import 'package:flutter_application_1cuadermo/services/enrollment_service.dart';
import 'package:flutter_application_1cuadermo/services/student_service.dart';
import 'package:flutter_application_1cuadermo/services/grade_service.dart';

class GradeAssignmentScreen extends StatefulWidget {
  final Evaluation evaluation;

  const GradeAssignmentScreen({super.key, required this.evaluation});

  @override
  State<GradeAssignmentScreen> createState() => _GradeAssignmentScreenState();
}

class _GradeAssignmentScreenState extends State<GradeAssignmentScreen> {
  final EnrollmentService _enrollmentService = EnrollmentService();
  final StudentService _studentService = StudentService();
  final GradeService _gradeService = GradeService();
  List<Student> _students = [];
  Map<String, TextEditingController> _gradeControllers = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStudentsAndGrades();
  }

  Future<void> _loadStudentsAndGrades() async {
    setState(() {
      _isLoading = true;
    });

    final enrollments = await _enrollmentService.getEnrollmentsByCourseId(int.parse(widget.evaluation.courseId));
    final studentIds = enrollments.map((e) => e.studentId).whereType<String>().toList();
    _students = await _studentService.getStudentsByIds(studentIds);

    final grades = await _gradeService.getGradesByEvaluationId(widget.evaluation.id!);
    final Map<String, Grade> studentGrades = { for (var grade in grades) grade.studentId: grade };

    for (var student in _students) {
      final grade = studentGrades[student.id];
      _gradeControllers[student.id!] = TextEditingController(text: grade?.score.toString() ?? '');
    }

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _saveGrades() async {
    for (var student in _students) {
      final studentId = student.id!;
      final scoreText = _gradeControllers[studentId]?.text;
      if (scoreText != null && scoreText.isNotEmpty) {
        final score = double.tryParse(scoreText);
        if (score != null) {
          final existingGrades = await _gradeService.getGradesByEvaluationId(widget.evaluation.id!); // Get all grades for this evaluation
          final existingGrade = existingGrades.firstWhere(
            (grade) => grade.studentId == studentId, // Find the grade for the current student
            orElse: () => Grade(evaluationId: widget.evaluation.id!, studentId: studentId, score: 0.0), // Create a dummy grade if not found
          );

          if (existingGrade.id != null) {
            // Update existing grade
            await _gradeService.updateGrade(Grade(
              id: existingGrade.id,
              evaluationId: widget.evaluation.id!,
              studentId: studentId,
              score: score,
            ));
          } else {
            // Insert new grade
            await _gradeService.insertGrade(Grade(
              evaluationId: widget.evaluation.id!,
              studentId: studentId,
              score: score,
            ));
          }
        }
      }
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Calificaciones guardadas exitosamente!')),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Asignar Calificaciones - ${widget.evaluation.evaluationName}'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: _students.length,
                    itemBuilder: (context, index) {
                      final student = _students[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Row(
                            children: [
                              Expanded(child: Text(student.name)),
                              SizedBox(
                                width: 100,
                                child: TextField(
                                  controller: _gradeControllers[student.id],
                                  keyboardType: TextInputType.number,
                                  decoration: InputDecoration(
                                    labelText: 'Calificación (Max ${widget.evaluation.maxGrade})',
                                    border: const OutlineInputBorder(),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: ElevatedButton(
                    onPressed: _saveGrades,
                    child: const Text('Guardar Calificaciones'),
                  ),
                ),
              ],
            ),
    );
  }
}
