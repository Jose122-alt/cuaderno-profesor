import 'package:flutter/material.dart';
import 'package:flutter_application_1cuadermo/models/course.dart';
import 'package:flutter_application_1cuadermo/models/student.dart';
import 'package:flutter_application_1cuadermo/services/enrollment_service.dart';
import 'package:flutter_application_1cuadermo/services/student_service.dart';
import 'package:flutter_application_1cuadermo/services/activity_service.dart';
import 'package:flutter_application_1cuadermo/services/evidence_service.dart';
import 'package:flutter_application_1cuadermo/services/attendance_record_service.dart';
import 'package:flutter_application_1cuadermo/models/attendance_record.dart';

class StudentStatusScreen extends StatefulWidget {
  final Course course;
  const StudentStatusScreen({super.key, required this.course});

  @override
  State<StudentStatusScreen> createState() => _StudentStatusScreenState();
}

class _StudentStatusScreenState extends State<StudentStatusScreen> {
  final EnrollmentService _enrollmentService = EnrollmentService();
  final StudentService _studentService = StudentService();
  final ActivityService _activityService = ActivityService();
  final EvidenceService _evidenceService = EvidenceService();
  final AttendanceRecordService _attendanceRecordService = AttendanceRecordService();

  bool _loading = true;
  List<_AlumnoEstado> _estados = [];
  int _totalTareas = 0;
  int _totalClases = 0;

  @override
  void initState() {
    super.initState();
    _cargarEstados();
  }

  Future<void> _cargarEstados() async {
    setState(() { _loading = true; _estados = []; _totalTareas = 0; _totalClases = 0; });
    final enrolls = await _enrollmentService.getEnrollmentsByCourseId(widget.course.id!);
    final actividades = await _activityService.getActivitiesByCourseId(widget.course.id!);
    _totalTareas = actividades.where((a) => a.activityType == 'task').length;
    final registrosCurso = await _attendanceRecordService.getAttendanceRecordsByCourseId(widget.course.id!);

    final estados = <_AlumnoEstado>[];
    for (final enr in enrolls) {
      if (enr.studentId == null) continue;
      final st = await _studentService.getStudentById(enr.studentId!);
      if (st == null) continue;
      final sid = int.tryParse(st.id ?? '');

      int presentes = 0;
      int entregas = 0;
      int calificadas = 0;
      int conA = 0; // A ~ >=90
      double asistenciaPct = 0.0;

      if (sid != null) {
        final registros = await _attendanceRecordService.getAttendanceRecordsByStudentIdAndCourseId(sid, widget.course.id!);
        
        Set<String> diasPresentes = {};
        for (final r in registros) {
          final s = (r.status).toLowerCase();
          if (s == 'present' || s == 'presente' || s == '1' || s == 'a' || s == 'p' || s == 'retraso' || s == 'late') {
            diasPresentes.add(r.date);
          }
        }
        presentes = diasPresentes.length;
        entregas = await _evidenceService.getStudentSubmittedEvidencesCountForCourse(sid, widget.course.id!);
        final evidencias = await _evidenceService.getEvidencesByStudentIdAndCourseId(sid, widget.course.id!);
        for (final ev in evidencias) {
          if ((ev.status).toLowerCase() == 'graded') {
            calificadas++;
            final g = ev.grade ?? 0;
            if (g >= 90) conA++;
          }
        }

        final int studentTotalClases = 48;

        asistenciaPct = (studentTotalClases > 0) ? (presentes.toDouble() / studentTotalClases.toDouble()) * 100.0 : 0.0;
        print('DEBUG: Student: ${st.name}, Presentes: $presentes, Total Clases (fijo): $studentTotalClases, Asistencia Pct: $asistenciaPct');
      }
      final evidenciasPct = _totalTareas > 0 ? entregas / _totalTareas : 0.0;
      final mayoriaA = calificadas > 0 ? (conA / calificadas) >= 0.5 : false;

      final riesgo = asistenciaPct < 0.8 || evidenciasPct < 0.5;
      final exento = asistenciaPct >= 0.95 && evidenciasPct >= 0.9 && mayoriaA;

      estados.add(_AlumnoEstado(
        alumno: st.name,
        asistenciaPct: asistenciaPct,
        evidenciasPct: evidenciasPct,
        riesgo: riesgo,
        exento: exento,
      ));
    }

    setState(() { _estados = estados; _loading = false; });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Estado: ${widget.course.courseName}'),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _estados.length,
              itemBuilder: (ctx, i) {
                final e = _estados[i];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  child: ListTile(
                    title: Text(e.alumno),
                    subtitle: Text('Asistencia: ${(e.asistenciaPct).toStringAsFixed(1)}% • Evidencias: ${(e.evidenciasPct*100).toStringAsFixed(1)}%'),
                    trailing: Wrap(spacing: 8, children: [
                      if (e.riesgo)
                        Chip(label: const Text('Riesgo'), backgroundColor: Colors.red.shade100),
                      if (e.exento)
                        Chip(label: const Text('Exento'), backgroundColor: Colors.green.shade100),
                    ]),
                  ),
                );
              },
            ),
    );
  }
}

class _AlumnoEstado {
  final String alumno;
  final double asistenciaPct;
  final double evidenciasPct;
  final bool riesgo;
  final bool exento;

  _AlumnoEstado({
    required this.alumno,
    required this.asistenciaPct,
    required this.evidenciasPct,
    required this.riesgo,
    required this.exento,
  });
}
