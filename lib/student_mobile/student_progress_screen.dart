import 'package:flutter/material.dart';
import 'package:flutter_application_1cuadermo/models/student.dart';
import 'package:flutter_application_1cuadermo/models/course.dart';
import 'package:flutter_application_1cuadermo/services/course_service.dart';
import 'package:flutter_application_1cuadermo/services/attendance_record_service.dart';
import 'package:flutter_application_1cuadermo/services/enrollment_service.dart';
import 'package:flutter_application_1cuadermo/services/evidence_service.dart'; // Importar EvidenceService
import 'package:flutter_application_1cuadermo/services/activity_service.dart'; // Importar ActivityService
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
  final ActivityService _activityService = ActivityService(); // Inicializar ActivityService

  List<Map<String, dynamic>> _enrolledCoursesProgress = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadStudentProgress();
  }

  Future<void> _loadStudentProgress() async {
    print('DEBUG: _loadStudentProgress called.');
    try {
      final studentId = widget.student.id;
          print('DEBUG: Student ID from widget: $studentId');
          if (studentId == null) {
            setState(() {
              _errorMessage = 'Error: Student ID is null.';
              _isLoading = false;
            });
            return;
          }
          final enrollments = await _enrollmentService.getEnrollmentsByStudentId(studentId);
          print('DEBUG: Number of enrollments found for student $studentId: ${enrollments.length}');
          final List<Map<String, dynamic>> progressData = [];

          for (var enrollment in enrollments) {
            final course = await _courseService.getCourseById(enrollment.courseId);
            if (course != null && course.id != null) {
            print('DEBUG: StudentProgressScreen - Processing course: ${course.courseName} (ID: ${course.id!})');
            print('DEBUG: StudentProgressScreen - Student ID: $studentId');
            int studentIdInt;
            try {
              studentIdInt = int.parse(studentId);
              print('DEBUG: StudentProgressScreen - Student ID converted to int: $studentIdInt');
            } catch (e) {
              print('DEBUG: StudentProgressScreen - Failed to parse student ID $studentId: $e');
              continue;
            }
            final attendanceSummary = await _attendanceRecordService.getStudentDailyAttendanceSummaryForCourse(studentIdInt, course.id!);
            print('DEBUG: StudentProgressScreen - Attendance Summary: $attendanceSummary');
            final studentPresentCount = attendanceSummary['present'] ?? 0;
            final studentAbsentCount = attendanceSummary['absent'] ?? 0;
            final studentLateCount = attendanceSummary['late'] ?? 0;
            final studentJustifiedCount = attendanceSummary['justified'] ?? 0;

            final totalAttendanceRecords = studentPresentCount + studentAbsentCount + studentLateCount + studentJustifiedCount;
            final attendancePercentage = totalAttendanceRecords > 0 ? (studentPresentCount / totalAttendanceRecords) * 100 : 0.0;

            print('DEBUG: StudentProgressScreen - studentPresentCount: $studentPresentCount, totalAttendanceRecords: $totalAttendanceRecords, attendancePercentage: $attendancePercentage');
            final totalEvidences = await _activityService.getTotalActivitiesForCourse(course.id!);
            final studentSubmittedEvidencesCount = await _evidenceService.getStudentSubmittedEvidencesCountForCourse(studentIdInt, course.id!);
            final evidencesPercentage = totalEvidences > 0 ? (studentSubmittedEvidencesCount / totalEvidences) * 100 : 0.0;

            progressData.add({
              'course': course,
              'studentAttendanceCount': studentPresentCount,
              'totalClasses': totalAttendanceRecords,
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
                                Text('Asistencia: ${studentAttendanceCount} / ${totalClasses} (${attendancePercentage.toStringAsFixed(2)}%)'),
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
