import 'package:flutter/material.dart';
import '../services/attendance_record_service.dart';
import '../models/student.dart';
import '../models/course.dart';
import '../models/attendance_record.dart';

class StudentAttendanceRecordsScreen extends StatefulWidget {
  final Student student;
  final Course course;

  StudentAttendanceRecordsScreen({
    required this.student,
    required this.course,
  });

  @override
  _StudentAttendanceRecordsScreenState createState() => _StudentAttendanceRecordsScreenState();
}

class _StudentAttendanceRecordsScreenState extends State<StudentAttendanceRecordsScreen> {
  final AttendanceRecordService _attendanceRecordService = AttendanceRecordService();
  List<AttendanceRecord> _attendanceRecords = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchAttendanceRecords();
  }

  Future<void> _fetchAttendanceRecords() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final sid = int.tryParse(widget.student.id ?? '');
      if (sid == null) {
        setState(() {
          _attendanceRecords = [];
        });
        return;
      }
      final records = await _attendanceRecordService.getAttendanceRecordsByStudentIdAndCourseId(
        sid,
        widget.course.id!,
      );
      setState(() {
        _attendanceRecords = records;
      });
    } catch (e) {
      print('Error fetching attendance records: $e');
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
        title: Text(
          'Asistencia de ${widget.course.courseName}',
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.blueAccent,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _attendanceRecords.isEmpty
              ? const Center(child: Text('No hay registros de asistencia para este curso.'))
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        'Total asistencias: ${_attendanceRecords.where((r) => r.status == 'present' || r.status == 'presente').length}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        itemCount: _attendanceRecords.length,
                        itemBuilder: (context, index) {
                          final record = _attendanceRecords[index];
                          final recordDate = DateTime.parse(record.date);
                          final estado = (record.status == 'present' || record.status == 'presente')
                              ? 'Presente'
                              : (record.status == 'late' || record.status == 'tarde')
                                  ? 'Tarde'
                                  : 'Ausente';
                          return Card(
                            margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                            elevation: 4,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            child: ListTile(
                              contentPadding: const EdgeInsets.all(16.0),
                              title: Text(
                                'Fecha: ${recordDate.toLocal().toString().split(' ')[0]}',
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                              subtitle: Padding(
                                padding: const EdgeInsets.only(top: 4.0),
                                child: Text(
                                  'Estado: $estado',
                                  style: TextStyle(color: Colors.grey[600]),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
    );
  }
}
