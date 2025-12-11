import 'package:flutter/material.dart';
import 'package:flutter_application_1cuadermo/models/student.dart';
import 'package:flutter_application_1cuadermo/models/course.dart';
import 'package:flutter_application_1cuadermo/services/course_service.dart';
import 'package:flutter_application_1cuadermo/services/attendance_record_service.dart';
import 'package:flutter_application_1cuadermo/services/enrollment_service.dart';
import 'package:flutter_application_1cuadermo/services/evidence_service.dart'; // Importar EvidenceService
import 'package:flutter_application_1cuadermo/models/student.dart';
import 'package:flutter_application_1cuadermo/models/course.dart';

class StudentProgressScreen extends StatefulWidget {
  final Student student;

  StudentProgressScreen({required this.student});

  @override
  _StudentProgressScreenState createState() => _StudentProgressScreenState();
}

class _StudentProgressScreenState extends State<StudentProgressScreen> {
  final CourseService _courseService = CourseService();
  final EnrollmentService _enrollmentService = EnrollmentService();
  final AttendanceRecordService _attendanceRecordService = AttendanceRecordService();
  final EvidenceService _evidenceService = EvidenceService(); // Inicializar EvidenceService

  List<Map<String, dynamic>> _enrolledCoursesProgress = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadStudentProgress();
  }

  Future<void> _loadStudentProgress() async {
    try {
      final studentId = widget.student.id;
      if (studentId == null) {
        setState(() {
          _errorMessage = 'Error: Student ID is null.';
          _isLoading = false;
        });
        return;
      }
      final enrollments = await _enrollmentService.getEnrollmentsByStudentId(studentId);
      final List<Map<String, dynamic>> progressData = [];

      for (var enrollment in enrollments) {
        final course = await _courseService.getCourseById(enrollment.courseId);
        if (course != null && course.id != null) {
          final totalClasses = await _attendanceRecordService.getTotalClassesForCourse(course.id!);
          final studentAttendanceCount = await _attendanceRecordService.getStudentAttendanceCountForCourse(int.parse(studentId), course.id!);
          final attendancePercentage = totalClasses > 0 ? (studentAttendanceCount / totalClasses) * 100 : 0.0;

          final totalEvidences = await _evidenceService.getTotalEvidencesForCourse(course.id!);
          final studentSubmittedEvidencesCount = await _evidenceService.getStudentSubmittedEvidencesCountForCourse(int.parse(studentId), course.id!);
          final evidencesPercentage = totalEvidences > 0 ? (studentSubmittedEvidencesCount / totalEvidences) * 100 : 0.0;

          progressData.add({
            'course': course,
            'totalClasses': totalClasses,
            'studentAttendanceCount': studentAttendanceCount,
            'attendancePercentage': attendancePercentage,
            'totalEvidences': totalEvidences,
            'studentSubmittedEvidencesCount': studentSubmittedEvidencesCount,
            'evidencesPercentage': evidencesPercentage,
          });
        }
      }

      setState(() {
        _enrolledCoursesProgress = progressData;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Error al cargar el progreso del alumno: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Progreso del Alumno'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(child: Text(_errorMessage!))
              : _enrolledCoursesProgress.isEmpty
                  ? const Center(child: Text('No estás inscrito en ningún curso.'))
                  : ListView.builder(
                      itemCount: _enrolledCoursesProgress.length,
                      itemBuilder: (context, index) {
                        final courseProgress = _enrolledCoursesProgress[index];
                        final Course course = courseProgress['course'];
                        final int totalClasses = courseProgress['totalClasses'];
                        final int studentAttendanceCount = courseProgress['studentAttendanceCount'];
                        final double attendancePercentage = courseProgress['attendancePercentage'];
                        final int totalEvidences = courseProgress['totalEvidences'];
                        final int studentSubmittedEvidencesCount = courseProgress['studentSubmittedEvidencesCount'];
                        final double evidencesPercentage = courseProgress['evidencesPercentage'];

                        return Card(
                          margin: const EdgeInsets.all(8.0),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  course.courseName,
                                  style: const TextStyle(
                                    fontSize: 18.0,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 10.0),
                                Text('Total de Clases: $totalClasses'),
                                Text('Asistencia: $studentAttendanceCount'),
                                Text('Porcentaje de Asistencia: ${attendancePercentage.toStringAsFixed(2)}%'),
                                const SizedBox(height: 10.0),
                                Text('Total de Evidencias: $totalEvidences'),
                                Text('Evidencias Entregadas: $studentSubmittedEvidencesCount'),
                                Text('Porcentaje de Evidencias Entregadas: ${evidencesPercentage.toStringAsFixed(2)}%'),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
    );
  }
}
