import 'package:flutter/material.dart';
import '../models/student.dart';
import '../services/student_service.dart';
import '../services/course_service.dart';
import '../services/attendance_record_service.dart'; // Importar AttendanceRecordService
import '../models/course.dart';

class StudentDashboardScreen extends StatefulWidget {
  final Student student;

  const StudentDashboardScreen({Key? key, required this.student}) : super(key: key);

  @override
  _StudentDashboardScreenState createState() => _StudentDashboardScreenState();
}

class _StudentDashboardScreenState extends State<StudentDashboardScreen> {
  final StudentService _studentService = StudentService();
  final CourseService _courseService = CourseService();
  final AttendanceRecordService _attendanceRecordService = AttendanceRecordService(); // Inicializar AttendanceRecordService
  List<Course> _enrolledCourses = [];
  Map<int, int> _totalClasses = {};
  Map<int, Map<String, int>> _attendanceData = {};
  Map<int, int> _totalEvidences = {};
  Map<int, int> _submittedEvidences = {};
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadStudentData();
  }

  Future<void> _loadStudentData() async {
    _enrolledCourses = await _courseService.getCoursesByStudentId(int.parse(widget.student.id!));

    for (Course course in _enrolledCourses) {
      _totalClasses[course.id!] = await _attendanceRecordService.getTotalClassesForCourse(course.id!); // Usar AttendanceRecordService
      _attendanceData[course.id!] = await _attendanceRecordService.getStudentDailyAttendanceSummaryForCourse(int.parse(widget.student.id!), course.id!); // Usar AttendanceRecordService
      _totalEvidences[course.id!] = await _studentService.getTotalEvidencesForCourse(course.id!);
      _submittedEvidences[course.id!] = await _studentService.getSubmittedEvidencesForStudentInCourse(int.parse(widget.student.id!), course.id!);
    }
    setState(() { _loading = false; });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tu progreso'),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [
              Theme.of(context).colorScheme.primary,
              Theme.of(context).colorScheme.secondary,
            ]),
          ),
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _enrolledCourses.isEmpty
              ? Center(child: Text('No estás inscrito en ningún curso.', style: TextStyle(color: Colors.grey[700])))
              : ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(colors: [
                          Theme.of(context).colorScheme.primaryContainer,
                          Theme.of(context).colorScheme.secondaryContainer,
                        ]),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 28,
                            backgroundColor: Theme.of(context).colorScheme.onPrimaryContainer.withOpacity(0.15),
                            child: Text(widget.student.name.isNotEmpty ? widget.student.name[0].toUpperCase() : '?', style: TextStyle(fontSize: 24, color: Theme.of(context).colorScheme.onPrimaryContainer)),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Hola, ${widget.student.name}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                                Text('Cursos inscritos: ${_enrolledCourses.length}', style: TextStyle(color: Colors.black.withOpacity(0.6))),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    ..._enrolledCourses.map((course) {
                      final totalClasses = _totalClasses[course.id!] ?? 0;
                      final attendance = _attendanceData[course.id!];
                      final totalEvidences = _totalEvidences[course.id!] ?? 0;
                      final submittedEvidences = _submittedEvidences[course.id!] ?? 0;
                      final attendancePercentage = totalClasses > 0 ? (((attendance?['present'] ?? 0) / totalClasses) * 100) : 0.0;
                      print('DEBUG: StudentDashboardScreen - Course: ${course.courseName}, Total Classes: $totalClasses, Attendance Data: $attendance, Attendance Percentage: $attendancePercentage');
                      final evidencePercentage = totalEvidences > 0 ? ((submittedEvidences / totalEvidences) * 100) : 0.0;
                      final atRisk = attendancePercentage < 80 || evidencePercentage < 50;

                      return Card(
                        elevation: 6,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(course.courseName, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                                  ),
                                  if (atRisk)
                                    Chip(label: const Text('Riesgo'), backgroundColor: Colors.red.shade100),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Icon(Icons.event_available, color: Theme.of(context).colorScheme.primary),
                                  const SizedBox(width: 8),
                                  Text('Clases: $totalClasses'),
                                  const SizedBox(width: 16),
                                  Icon(Icons.assignment, color: Theme.of(context).colorScheme.primary),
                                  const SizedBox(width: 8),
                                  Text('Evidencias: $totalEvidences'),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Text('Asistencia ${attendancePercentage.toStringAsFixed(0)}%'),
                              const SizedBox(height: 6),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: LinearProgressIndicator(
                                  value: attendancePercentage / 100,
                                  minHeight: 10,
                                  color: attendancePercentage >= 95 ? Colors.green : (attendancePercentage >= 80 ? Colors.amber : Colors.red),
                                  backgroundColor: Colors.grey.shade200,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text('Evidencias ${evidencePercentage.toStringAsFixed(0)}%'),
                              const SizedBox(height: 6),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: LinearProgressIndicator(
                                  value: evidencePercentage / 100,
                                  minHeight: 10,
                                  color: evidencePercentage >= 90 ? Colors.green : (evidencePercentage >= 50 ? Colors.amber : Colors.red),
                                  backgroundColor: Colors.grey.shade200,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Expanded(
                                    child: Text('Presente: ${attendance?['present'] ?? 0} • Falta: ${attendance?['absent'] ?? 0} • Retardo: ${attendance?['late'] ?? 0} • Justificado: ${attendance?['justified'] ?? 0}',
                                        style: TextStyle(color: Colors.grey[700])),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ],
                ),
    );
  }
}
