import 'package:flutter/material.dart';
import 'package:flutter_application_1cuadermo/models/enrollment.dart';
import 'package:flutter_application_1cuadermo/models/student.dart';
import 'package:flutter_application_1cuadermo/services/enrollment_service.dart';
import 'package:flutter_application_1cuadermo/services/student_service.dart';

class EnrolledStudentsScreen extends StatefulWidget {
  final int courseId;
  final String courseName;

  EnrolledStudentsScreen({required this.courseId, required this.courseName});

  @override
  _EnrolledStudentsScreenState createState() => _EnrolledStudentsScreenState();
}

class _EnrolledStudentsScreenState extends State<EnrolledStudentsScreen> {
  final EnrollmentService _enrollmentService = EnrollmentService();
  final StudentService _studentService = StudentService();
  List<Student> _enrolledStudents = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadEnrolledStudents();
  }

  Future<void> _loadEnrolledStudents() async {
    try {
      final enrollments = await _enrollmentService.getEnrollmentsByCourseId(widget.courseId);
      List<Student> students = [];
      for (var enrollment in enrollments) {
        final student = await _studentService.getStudentById(enrollment.studentId!);
        if (student != null) {
          students.add(student);
        }
      }
      setState(() {
        _enrolledStudents = students;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading enrolled students: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Estudiantes en ${widget.courseName}',
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.blueAccent,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _enrolledStudents.isEmpty
              ? const Center(child: Text('No hay estudiantes inscritos en este curso aún.'))
              : ListView.builder(
                  itemCount: _enrolledStudents.length,
                  itemBuilder: (context, index) {
                    final student = _enrolledStudents[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                      elevation: 4,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(16.0),
                        title: Text(
                          student.name,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                        ),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 4.0),
                          child: Text(
                            student.accountNumber,
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        ),
                        // You can add more details or actions here, e.g., view student profile
                      ),
                    );
                  },
                ),
    );
  }
}