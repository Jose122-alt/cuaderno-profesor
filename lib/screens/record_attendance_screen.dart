import 'package:flutter/material.dart';
import 'package:flutter_application_1cuadermo/models/attendance_record.dart';
import 'package:flutter_application_1cuadermo/models/course.dart';
import 'package:flutter_application_1cuadermo/models/enrollment.dart';
import 'package:flutter_application_1cuadermo/models/student.dart';
import 'package:flutter_application_1cuadermo/services/attendance_record_service.dart';
import 'package:flutter_application_1cuadermo/services/course_service.dart';
import 'package:flutter_application_1cuadermo/services/enrollment_service.dart';
import 'package:flutter_application_1cuadermo/services/student_service.dart';

class RecordAttendanceScreen extends StatefulWidget {
  @override
  _RecordAttendanceScreenState createState() => _RecordAttendanceScreenState();
}

class _RecordAttendanceScreenState extends State<RecordAttendanceScreen> {
  final CourseService _courseService = CourseService();
  final EnrollmentService _enrollmentService = EnrollmentService();
  final StudentService _studentService = StudentService();
  final AttendanceRecordService _attendanceRecordService = AttendanceRecordService();

  List<Course> _courses = [];
  Course? _selectedCourse;
  List<Student> _enrolledStudents = [];
  Map<String, bool> _attendanceStatus = {}; // studentId -> isPresent
  DateTime _selectedDate = DateTime.now();

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCourses();
  }

  Future<void> _loadCourses() async {
    try {
      final courses = await _courseService.getCourses();
      setState(() {
        _courses = courses;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading courses: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadEnrolledStudentsAndAttendance() async {
    if (_selectedCourse == null) return;

    setState(() {
      _isLoading = true;
      _enrolledStudents = [];
      _attendanceStatus = {};
    });

    try {
      final enrollments = await _enrollmentService.getEnrollmentsByCourseId(_selectedCourse!.id!);
      List<Student> students = [];
      for (var enrollment in enrollments) {
        if (enrollment.studentId == null) continue;
        final student = await _studentService.getStudentById(enrollment.studentId!);
        if (student != null) {
          students.add(student);
          // Load existing attendance record for this student and date
          final sid = int.tryParse(student.id ?? '');
          if (sid != null) {
            final existingRecords = await _attendanceRecordService.getAttendanceRecordsByStudentCourseAndDate(
              sid,
              _selectedCourse!.id!,
              _selectedDate,
            );
            // Get the latest attendance status for the student on this date
            if (existingRecords.isNotEmpty) {
              existingRecords.sort((a, b) => (b.timestamp ?? DateTime(0)).compareTo(a.timestamp ?? DateTime(0))); // Sort by latest timestamp
              _attendanceStatus[student.id!] = existingRecords.first.status == 'present';
            } else {
              _attendanceStatus[student.id!] = false; // Default to absent if no records
            }
          } else {
            _attendanceStatus[student.id!] = false;
          }
        }
      }
      setState(() {
        _enrolledStudents = students;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading enrolled students or attendance: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
      _loadEnrolledStudentsAndAttendance(); // Reload attendance for the new date
    }
  }

  Future<void> _saveAttendance() async {
    if (_selectedCourse == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please select a course first')),
      );
      return;
    }

    for (var student in _enrolledStudents) {
      final status = _attendanceStatus[student.id!] == true ? 'present' : 'absent';
      final sid = int.tryParse(student.id ?? '');
      if (sid == null) {
        continue;
      }
      await _attendanceRecordService.recordAttendance(
        studentId: sid,
        courseId: _selectedCourse!.id!,
        date: _selectedDate,
        status: status,
      );
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Attendance saved successfully!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Record Attendance'),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  DropdownButtonFormField<Course>(
                    value: _selectedCourse,
                    hint: Text('Select Course'),
                    onChanged: (Course? newValue) {
                      setState(() {
                        _selectedCourse = newValue;
                      });
                      _loadEnrolledStudentsAndAttendance();
                    },
                    items: _courses.map<DropdownMenuItem<Course>>((Course course) {
                      return DropdownMenuItem<Course>(
                        value: course,
                        child: Text(course.courseName),
                      );
                    }).toList(),
                    validator: (value) {
                      if (value == null) {
                        return 'Please select a course';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 20),
                  Row(
                    children: [
                      Text('Date: ${_selectedDate.toLocal().toString().split(' ')[0]}'),
                      IconButton(
                        icon: Icon(Icons.calendar_today),
                        onPressed: () => _selectDate(context),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  Expanded(
                    child: _enrolledStudents.isEmpty
                        ? Center(child: Text('No students enrolled in the selected course.'))
                        : ListView.builder(
                            itemCount: _enrolledStudents.length,
                            itemBuilder: (context, index) {
                              final student = _enrolledStudents[index];
                              return Card(
                                margin: EdgeInsets.symmetric(vertical: 8.0),
                                child: CheckboxListTile(
                                  title: Text(student.name),
                                  subtitle: Text(student.accountNumber),
                                  value: _attendanceStatus[student.id!] ?? false,
                                  onChanged: (bool? value) {
                                    setState(() {
                                      _attendanceStatus[student.id!] = value ?? false;
                                    });
                                  },
                                ),
                              );
                            },
                          ),
                  ),
                  ElevatedButton(
                    onPressed: _saveAttendance,
                    child: Text('Save Attendance'),
                  ),
                ],
              ),
            ),
    );
  }
}
