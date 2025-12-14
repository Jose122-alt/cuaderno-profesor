import 'package:flutter/material.dart';
import '../services/enrollment_service.dart';
import '../services/course_service.dart';
import '../models/student.dart';
import '../models/course.dart';
import 'package:flutter_application_1cuadermo/screens/student_activity_list_screen.dart';
import 'package:flutter_application_1cuadermo/screens/student_attendance_records_screen.dart';

class StudentCourseListScreen extends StatefulWidget {
  final Student student;

  StudentCourseListScreen({required this.student});

  @override
  _StudentCourseListScreenState createState() => _StudentCourseListScreenState();
}

class _StudentCourseListScreenState extends State<StudentCourseListScreen> {
  final EnrollmentService _enrollmentService = EnrollmentService();
  final CourseService _courseService = CourseService();
  List<Course> _enrolledCourses = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchEnrolledCourses();
  }

  Future<void> _fetchEnrolledCourses() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final enrollments = await _enrollmentService.getEnrollmentsByStudentId(widget.student.id!);
      List<Course> courses = [];
      for (var enrollment in enrollments) {
        final course = await _courseService.getCourseById(enrollment.courseId);
        if (course != null) {
          courses.add(course);
        }
      }
      setState(() {
        _enrolledCourses = courses;
      });
    } catch (e) {
      // Handle error
      print('Error fetching enrolled courses: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Mis Cursos',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.blueAccent,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _enrolledCourses.isEmpty
              ? const Center(child: Text('No estás inscrito en ningún curso.'))
              : ListView.builder(
                  itemCount: _enrolledCourses.length,
                  itemBuilder: (context, index) {
                    final course = _enrolledCourses[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
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
                            course.description ?? '',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              course.courseCode,
                              style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blueAccent),
                            ),
                            const SizedBox(width: 12),
                            IconButton(
                              icon: const Icon(Icons.fact_check, color: Colors.teal),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => StudentAttendanceRecordsScreen(student: widget.student, course: course),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => StudentActivityListScreen(course: course, student: widget.student),
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
