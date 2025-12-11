import 'package:flutter/material.dart';
import '../models/teacher.dart';
import '../models/course.dart';

class CourseManagementScreen extends StatefulWidget {
  final Teacher teacher;
  final Course course;

  const CourseManagementScreen({
    Key? key,
    required this.teacher,
    required this.course,
  }) : super(key: key);

  @override
  State<CourseManagementScreen> createState() => _CourseManagementScreenState();
}

class _CourseManagementScreenState extends State<CourseManagementScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Gestión de Curso: ${widget.course.courseName}'),
      ),
      body: Center(
        child: Text('Aquí se gestionarán los estudiantes, asistencias y evidencias.'),
      ),
    );
  }
}
