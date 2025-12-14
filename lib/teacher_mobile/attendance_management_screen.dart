import 'package:flutter/material.dart';
import 'package:flutter_application_1cuadermo/models/course.dart';
import 'package:flutter_application_1cuadermo/models/student.dart';
import 'package:flutter_application_1cuadermo/services/course_service.dart';
import 'package:flutter_application_1cuadermo/services/enrollment_service.dart';
import 'package:flutter_application_1cuadermo/services/student_service.dart';
import 'package:flutter_application_1cuadermo/services/attendance_record_service.dart'; // Importar AttendanceRecordService
import 'package:flutter_application_1cuadermo/models/attendance_record.dart'; // Importar AttendanceRecord

class AttendanceManagementScreen extends StatefulWidget {
  const AttendanceManagementScreen({super.key});

  @override
  State<AttendanceManagementScreen> createState() => _AttendanceManagementScreenState();
}

class _AttendanceManagementScreenState extends State<AttendanceManagementScreen> {
  final CourseService _courseService = CourseService();
  final EnrollmentService _enrollmentService = EnrollmentService();
  final StudentService _studentService = StudentService();
  final AttendanceRecordService _attendanceRecordService = AttendanceRecordService(); // Inicializar el servicio

  List<Course> _availableCourses = [];
  Course? _selectedCourse;
  List<Student> _studentsInSelectedCourse = [];
  DateTime _selectedDate = DateTime.now();
  bool _isLoading = true;

  // Map to store attendance status for each student (studentId -> status)
  final Map<String, String> _studentAttendanceStatus = {};

  @override
  void initState() {
    super.initState();
    _loadCoursesAndStudents();
  }

  Future<void> _loadCoursesAndStudents() async {
    try {
      final courses = await _courseService.getCourses();
      setState(() {
        _availableCourses = courses;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading courses: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadStudentsForSelectedCourse(Course course) async {
    setState(() {
      _isLoading = true;
      _studentsInSelectedCourse = [];
      _studentAttendanceStatus.clear();
    });
    try {
      final enrollments = await _enrollmentService.getEnrollmentsByCourseId(course.id!);
      List<Student> students = [];
      for (var enrollment in enrollments) {
        if (enrollment.studentId != null) {
          final student = await _studentService.getStudentById(enrollment.studentId!);
          if (student != null) {
              students.add(student);
              // Cargar el registro de asistencia más reciente para el estudiante en la fecha seleccionada
              final existingRecords = await _attendanceRecordService.getAttendanceRecordsByStudentCourseAndDate(
                int.parse(student.id!),
                course.id!,
                _selectedDate,
              );
              if (existingRecords.isNotEmpty) {
                // Ordenar por marca de tiempo más reciente
                existingRecords.sort((a, b) => (b.timestamp ?? DateTime(0)).compareTo(a.timestamp ?? DateTime(0)));
                _studentAttendanceStatus[student.id!] = existingRecords.first.status;
              } else {
                // Valor por defecto si no hay registros
                _studentAttendanceStatus[student.id!] = 'ausente';
              }
            }
        }
      }
      setState(() {
        _studentsInSelectedCourse = students;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading students for course ${course.courseName}: $e');
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
            }
          }

          Future<void> _saveAttendance() async {
            if (_selectedCourse == null) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Por favor, selecciona una clase.')),
              );
              return;
            }

            setState(() {
              _isLoading = true;
            });

            try {
              for (var student in _studentsInSelectedCourse) {
                final status = _studentAttendanceStatus[student.id!] ?? 'ausente';
                await _attendanceRecordService.recordAttendance(
                  studentId: int.parse(student.id!),
                  courseId: _selectedCourse!.id!,
                  date: _selectedDate,
                  status: status,
                );
              }
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Asistencia guardada exitosamente!')),
              );
              _resetAttendanceStatus();
            } catch (e) {
              print('Error al guardar asistencia: $e');
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Error al guardar asistencia: $e')),
              );
            } finally {
              setState(() {
                _isLoading = false;
              });
            }
          }

          void _resetAttendanceStatus() {
            setState(() {
              _studentAttendanceStatus.clear();
              for (var student in _studentsInSelectedCourse) {
                _studentAttendanceStatus[student.id!] = 'absent';
              }
            });
          }

          @override
          Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestión de Asistencia'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            DropdownButtonFormField<Course>(
              value: _selectedCourse,
              hint: const Text('Selecciona una clase'),
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.white,
                labelText: 'Clase',
              ),
              onChanged: (Course? newValue) {
                setState(() {
                  _selectedCourse = newValue;
                  if (newValue != null) {
                    _loadStudentsForSelectedCourse(newValue);
                  }
                });
              },
              items: _availableCourses.map<DropdownMenuItem<Course>>((Course course) {
                return DropdownMenuItem<Course>(
                  value: course,
                  child: Text(course.courseName),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Fecha seleccionada: ${_selectedDate == null ? 'No seleccionada' : _selectedDate!.toLocal().toString().split(' ')[0]}',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                TextButton.icon(
                  onPressed: () => _selectDate(context),
                  icon: const Icon(Icons.calendar_today),
                  label: const Text('Seleccionar Fecha'),
                ),
              ],
            ),
            const SizedBox(height: 20),
            if (_isLoading)
              const Expanded(
                child: Center(child: CircularProgressIndicator()),
              )
            else if (_selectedCourse != null)
              Expanded(
                child: ListView.builder(
                  itemCount: _studentsInSelectedCourse.length,
                  itemBuilder: (context, index) {
                    final student = _studentsInSelectedCourse[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(student.name,
                                style: Theme.of(context).textTheme.bodyLarge),
                          ),
                          DropdownButton<String>(
                            value: _studentAttendanceStatus[student.id!],
                            onChanged: (String? newValue) {
                              setState(() {
                                if (newValue != null) {
                                  _studentAttendanceStatus[student.id!] = newValue;
                                }
                              });
                            },
                            items: <String>['presente', 'ausente', 'retraso', 'justificado']
                                .map<DropdownMenuItem<String>>((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              )
            else
              const Expanded(
                child: Center(
                  child: Text('Por favor, selecciona una clase para ver la lista de estudiantes.'),
                ),
              ),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50), // Make button full width and a bit taller
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: _selectedCourse == null || _studentsInSelectedCourse.isEmpty
                  ? null
                  : () async {
                      await _saveAttendance();
                    },
              child: const Text('Guardar Asistencia'),
            ),
          ],
        ),
      ),
    );
  }
}