import 'package:flutter/material.dart';
import 'package:flutter_application_1cuadermo/models/course.dart';
import 'package:flutter_application_1cuadermo/models/teacher.dart';
import 'package:flutter_application_1cuadermo/services/course_service.dart';
import 'package:flutter_application_1cuadermo/screens/add_course_screen.dart';
import 'package:flutter_application_1cuadermo/screens/activity_management_screen.dart';
import 'package:flutter_application_1cuadermo/screens/attendance_recording_screen.dart';
import 'package:flutter_application_1cuadermo/screens/course_management_screen.dart';
import 'package:flutter_application_1cuadermo/web_module/reports_screen.dart';
import 'package:flutter_application_1cuadermo/teacher_mobile/student_status_screen.dart';

class CourseListScreen extends StatefulWidget {
  final Teacher teacher;

  CourseListScreen({required this.teacher});

  @override
  _CourseListScreenState createState() => _CourseListScreenState();
}

class _CourseListScreenState extends State<CourseListScreen> {
  final CourseService _courseService = CourseService();
  List<Course> _courses = [];

  @override
  void initState() {
    super.initState();
    _loadCourses();
  }

  Future<void> _loadCourses() async {
    print('Loading courses for teacher ID: ${widget.teacher.id}');
    final courses = await _courseService.getCoursesByTeacherId(widget.teacher.id!);
    setState(() {
      _courses = courses;
    });
  }

  Future<void> _deleteCourse(int id) async {
    await _courseService.deleteCourse(id);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Course deleted successfully!')),
    );
    _loadCourses(); // Reload courses after deletion
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Gestión de Cursos',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.blueAccent,
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline, color: Colors.white, size: 28),
            onPressed: () async {
              await Navigator.push(context, MaterialPageRoute(builder: (context) => AddCourseScreen(teacher: widget.teacher)));
              _loadCourses(); // Reload courses after adding a new one
            },
          ),
        ],
      ),
      body: _courses.isEmpty
          ? const Center(child: Text('No hay cursos disponibles. ¡Añade un nuevo curso!'))
          : ListView.builder(
              itemCount: _courses.length,
              itemBuilder: (context, index) {
                final course = _courses[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  elevation: 4,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16.0),
                    title: Text(
                      course.courseName,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 4.0),
                      child: Text(
                        'Código: ${course.courseCode} - ID Profesor: ${course.teacherId}',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blueAccent),
                          onPressed: () {
                            // TODO: Implement edit course screen navigation
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Funcionalidad de edición aún no implementada')),
                            );
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.assignment, color: Colors.green), // Icono para gestionar actividades
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ActivityManagementScreen(course: course),
                              ),
                            );
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.check_circle, color: Colors.purple), // Icono para registrar asistencia
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => AttendanceRecordingScreen(course: course),
                              ),
                            );
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.bar_chart, color: Colors.orange),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ReportsScreen(course: course),
                              ),
                            );
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.people, color: Colors.deepPurple),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => StudentStatusScreen(course: course),
                              ),
                            );
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.redAccent),
                          onPressed: () => _deleteCourse(course.id!),
                        ),
                      ],
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CourseManagementScreen(
                            teacher: widget.teacher,
                            course: course,
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
    );
  }
}
