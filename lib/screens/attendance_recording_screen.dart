import 'package:flutter/material.dart';
import 'package:flutter_application_1cuadermo/models/course.dart';
import 'package:flutter_application_1cuadermo/models/student.dart';
import 'package:flutter_application_1cuadermo/models/attendance_record.dart';
import 'package:flutter_application_1cuadermo/services/student_service.dart';
import 'package:flutter_application_1cuadermo/services/attendance_record_service.dart';

class AttendanceRecordingScreen extends StatefulWidget {
  final Course course;

  const AttendanceRecordingScreen({Key? key, required this.course}) : super(key: key);

  @override
  _AttendanceRecordingScreenState createState() => _AttendanceRecordingScreenState();
}

class _AttendanceRecordingScreenState extends State<AttendanceRecordingScreen> {
  final StudentService _studentService = StudentService();
  final AttendanceRecordService _attendanceRecordService = AttendanceRecordService();
  List<Student> _students = [];
  Map<String, String> _attendanceStatus = {}; // studentId -> status (presente, ausente, tarde)

  @override
  void initState() {
    super.initState();
    _loadStudentsAndAttendance();
  }

  Future<void> _loadStudentsAndAttendance() async {
    final students = await _studentService.getStudentsByCourseId(widget.course.id!);
    setState(() {
      _students = students;
    });

    // Cargar el estado de asistencia para la fecha actual
    final today = DateTime.now();
    final formattedDate = "${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}";

    for (var student in _students) {
      final sid = int.tryParse(student.id ?? '');
      if (sid != null) {
        final existingRecords = await _attendanceRecordService.getAttendanceRecordsByStudentCourseAndDate(
          sid,
          widget.course.id!,
          today,
        );
        if (existingRecords.isNotEmpty) {
          existingRecords.sort((a, b) => b.timestamp!.compareTo(a.timestamp!));
          _attendanceStatus[student.id!] = existingRecords.first.status;
        } else {
          _attendanceStatus[student.id!] = 'ausente';
        }
      } else {
        _attendanceStatus[student.id!] = 'ausente';
      }
    }
  }

  void _updateAttendanceStatus(String studentId, String status) {
    setState(() {
      _attendanceStatus[studentId] = status;
    });
  }

  Future<void> _saveAttendance() async {
    final today = DateTime.now();
    final formattedDate = "${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}";

    for (var student in _students) {
      final status = _attendanceStatus[student.id!] ?? 'ausente';
      final sid = int.tryParse(student.id ?? '');
      if (sid == null) {
        continue;
      }
      await _attendanceRecordService.recordAttendance(
        studentId: sid,
        courseId: widget.course.id!,
        date: today,
        status: status,
      );
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Asistencia guardada exitosamente!')),
    );
    Navigator.pop(context); // Volver a la pantalla anterior
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Registrar Asistencia - ${widget.course.courseName}'),
        backgroundColor: Colors.blueAccent,
      ),
      body: _students.isEmpty
          ? const Center(child: Text('No hay estudiantes inscritos en este curso.'))
          : ListView.builder(
              itemCount: _students.length,
              itemBuilder: (context, index) {
                final student = _students[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  elevation: 4,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  child: ListTile(
                    title: Text(student.name),
                    trailing: DropdownButton<String>(
                      value: _attendanceStatus[student.id!] ?? 'ausente',
                      onChanged: (String? newValue) {
                        if (newValue != null) {
                          _updateAttendanceStatus(student.id!, newValue);
                        }
                      },
                      items: <String>['presente', 'ausente', 'tarde']
                          .map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value.capitalize()),
                        );
                      }).toList(),
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _saveAttendance,
        child: const Icon(Icons.save),
        backgroundColor: Colors.blueAccent,
      ),
    );
  }
}

extension StringExtension on String {
    String capitalize() {
      return "${this[0].toUpperCase()}${substring(1)}";
    }
}
