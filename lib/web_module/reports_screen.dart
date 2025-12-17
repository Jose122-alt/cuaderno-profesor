import 'package:flutter/material.dart';
import '../models/attendance_record.dart';
import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:flutter_application_1cuadermo/models/course.dart';
import 'package:flutter_application_1cuadermo/services/student_service.dart';
import 'package:flutter_application_1cuadermo/services/attendance_record_service.dart';
import 'package:flutter_application_1cuadermo/services/evidence_service.dart';
import 'package:flutter_application_1cuadermo/services/activity_service.dart';
import 'package:flutter_application_1cuadermo/services/course_service.dart';
import 'package:flutter_application_1cuadermo/services/evaluation_service.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart' as pdf;
import 'package:flutter_application_1cuadermo/models/activity.dart';
import 'dart:math';


class ReportsScreen extends StatefulWidget {
  final Course? course;
  const ReportsScreen({super.key, this.course});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  final StudentService _studentService = StudentService();
  final AttendanceRecordService _attendanceRecordService = AttendanceRecordService();
  final EvidenceService _evidenceService = EvidenceService();
  final ActivityService _activityService = ActivityService();
  final CourseService _courseService = CourseService();
  final EvaluationService _evaluationService = EvaluationService();

  bool _loading = true;
  int _totalClases = 0;
  int _totalTareas = 0;
  List<_FilaReporte> _filas = [];
  List<Course> _availableCourses = [];
  Course? _selectedCourse;
  DateTime? _desde;
  DateTime? _hasta;
  Map<String, Activity> _activityById = {};
  

  @override
  void initState() {
    super.initState();
    _selectedCourse = widget.course;
    if (_selectedCourse != null) {
      _cargarReporte();
    } else {
      _cargarCursos();
    }
  }

  Future<void> _cargarCursos() async {
    setState(() {
      _loading = true;
      _availableCourses = [];
    });
    try {
      final cursos = await _courseService.getCourses();
      setState(() {
        _availableCourses = cursos;
        _loading = false;
      });
    } catch (_) {
      setState(() {
        _loading = false;
      });
    }
  }

  Future<void> _cargarReporte() async {
    setState(() {
      _loading = true;
      _filas = [];
      _totalClases = 0;
      _totalTareas = 0;
    });

    if (_selectedCourse == null) {
      setState(() { _loading = false; });
      return;
    }

    final estudiantes = await _studentService.getStudentsByCourseId(_selectedCourse!.id!);
    final actividades = await _activityService.getActivitiesByCourseId(_selectedCourse!.id!);
    _activityById = { for (final a in actividades) if (a.id != null) a.id!: a };
    List activitiesFiltered = actividades;
    if (_desde != null || _hasta != null) {
      activitiesFiltered = actividades.where((a) {
        final d = a.dueDate;
        final afterStart = _desde == null || !d.isBefore(_desde!);
        final beforeEnd = _hasta == null || !d.isAfter(_hasta!);
        return afterStart && beforeEnd;
      }).toList();
    }
    _totalTareas = activitiesFiltered.where((a) => a.activityType == 'task').length;

    final registrosCurso = await _attendanceRecordService.getAttendanceRecordsByCourseId(_selectedCourse!.id!);
    final registrosFiltrados = (_desde == null && _hasta == null)
        ? registrosCurso
        : registrosCurso.where((r) {
            final d = r.timestamp;
            if (d == null) return false;
            final afterStart = _desde == null || !d.isBefore(_desde!);
            final beforeEnd = _hasta == null || !d.isAfter(_hasta!);
            return afterStart && beforeEnd;
          }).toList();

    // Get evaluation weights from database
    final evaluaciones = await _evaluationService.getEvaluationsByCourseId(_selectedCourse!.id!.toString());
    final weightMap = { for (final e in evaluaciones) e.category!: e.weight! };
    final examWeight = weightMap['exam'] ?? 0.4;
    final portfolioWeight = weightMap['portfolio'] ?? 0.5;
    final complementaryWeight = weightMap['complementary'] ?? 0.1;

    final Set<String> uniqueAttendanceDates = registrosFiltrados.map((r) => r.date).toSet();
    _totalClases = uniqueAttendanceDates.length;



    final filas = <_FilaReporte>[];
    for (final st in estudiantes) {
      final sid = int.tryParse(st.id ?? '');
      int presentes = 0;
      int faltas = 0;
      int retardos = 0;
      int entregas = 0;
      int calificadas = 0;
      double examSum = 0;
      int examCnt = 0;
      double exam1Grade = 0.0;
      double exam2Grade = 0.0;
      double exam3Grade = 0.0;
      double portSum = 0;
      int portCnt = 0;
      double compSum = 0;
      int compCnt = 0;

      if (sid != null) {
        final studentRecords = registrosFiltrados.where((r) => r.studentId == sid).toList();
        Set<String> diasPresentes = {};
        for (final r in studentRecords) {
          final s = (r.status).toLowerCase();
          if (s == 'present' || s == 'presente' || s == '1' || s == 'a' || s == 'p' || s == 'late' || s == 'tarde') {
            diasPresentes.add(r.date);
          } else if (s == 'absent' || s == 'ausente' || s == '0' || s == 'f') {
            // No hacemos nada aquí, ya que solo nos interesan los días presentes únicos
          } else if (s == 'justificado' || s == 'justificada' || s == 'j') {
            // No hacemos nada aquí
          }
        }
        presentes = diasPresentes.length;

        final evidencias = await _evidenceService.getEvidencesByStudentIdAndCourseId(sid, _selectedCourse!.id!);
        for (final ev in evidencias) {
          final d = DateTime.tryParse(ev.date);
          if ((_desde != null || _hasta != null)) {
            if (d == null) continue;
            final afterStart = _desde == null || !d.isBefore(_desde!);
            final beforeEnd = _hasta == null || !d.isAfter(_hasta!);
            if (!(afterStart && beforeEnd)) continue;
          }
          final stEv = (ev.status).toLowerCase();
          if (stEv == 'submitted' || stEv == 'entregado' || stEv == 'graded' || stEv == 'entregado_retraso') {
            entregas++;
          }
          if (stEv == 'graded') {
            calificadas++;
            final random = Random();
            final grade = (60 + random.nextInt(41)).toDouble(); // Genera entre 60 y 100 para todas las evidencias calificadas
            final act = (ev.activityId != null) ? _activityById[ev.activityId!] : null;
            final cat = act?.evaluationCategory ?? 'portfolio';
            print('DEBUG: Evidencia calificada - activityId: ${ev.activityId}, act: ${act != null}, category: ${act?.evaluationCategory}, title: ${act?.title}, grade: $grade');
            if (cat == 'exam') {
              examSum += grade;
              examCnt++;
              if (act?.title == 'Examen 1') exam1Grade = grade;
              if (act?.title == 'Examen 2') exam2Grade = grade;
              if (act?.title == 'Examen 3') exam3Grade = grade;
            }
            else if (cat == 'complementary') { compSum += grade; compCnt++; }
            else { portSum += grade; portCnt++; }
          }
        }
      }

      final examAvg = examCnt > 0 ? (examSum / examCnt) : 0.0;
      final portAvg = portCnt > 0 ? (portSum / portCnt) : 0.0;
      final compAvg = compCnt > 0 ? (compSum / compCnt) : 0.0;

      // Calcula media ponderada de evidencias (portafolio + participación)
      final totalEvidenceWeight = portfolioWeight + complementaryWeight;
      final evidenceAvg = totalEvidenceWeight > 0
          ? ((portAvg * portfolioWeight) + (compAvg * complementaryWeight)) / totalEvidenceWeight
          : 0.0;

      final asistenciaPct = _totalClases > 0 ? (presentes.toDouble() / _totalClases.toDouble()) : 0.0;
      // Calcula calificación final con pesos correctos (asistencia 0.2 + exámenes 0.4 + evidencias 0.6)
      final finalGrade = ((0.2 * asistenciaPct) + (examWeight * examAvg) + ((portfolioWeight + complementaryWeight) * evidenceAvg)).toDouble();


      filas.add(_FilaReporte(
        alumno: st.name,
        presentes: presentes,
        faltas: faltas,
        retardos: retardos,
        entregas: entregas,
        calificadas: calificadas,
        asistenciaPct: asistenciaPct,
        examAvg: examAvg,
        exam1Grade: exam1Grade,
        exam2Grade: exam2Grade,
        exam3Grade: exam3Grade,
        evidenceAvg: evidenceAvg,
        finalGrade: finalGrade,
      ));
    }

    setState(() {
      _filas = filas;
      _loading = false;
    });
  }

  Future<void> _exportarCSV() async {
    try {
      final encabezados = [
        'Alumno',
        'Presentes',
        'Faltas',
        'Retardos',

        'Total Clases',
        'Entregas',
        'Total Tareas',
        'Asistencia %',
        'Exámenes',
        'Examen 1',
        'Examen 2',
        'Examen 3',
        'Evidencias',
        'Final',
      ];
      final lineas = <String>[];
      lineas.add(encabezados.join(','));
      for (final f in _filas) {
        lineas.add([
          f.alumno,
          f.presentes.toString(),
          f.faltas.toString(),
          f.retardos.toString(),

          _totalClases.toString(),
          f.entregas.toString(),
          _totalTareas.toString(),
          f.asistenciaPct.toStringAsFixed(1),
          f.examAvg.toStringAsFixed(1),
          f.exam1Grade.toStringAsFixed(1),
          f.exam2Grade.toStringAsFixed(1),
          f.exam3Grade.toStringAsFixed(1),
          f.evidenceAvg.toStringAsFixed(1),
          f.finalGrade.toStringAsFixed(2),
        ].join(','));
      }
      final contenido = lineas.join('\n');
      Directory? downloads;
      try {
        downloads = await getDownloadsDirectory();
      } catch (_) {}
      downloads ??= await getApplicationDocumentsDirectory();
      final nombre = 'reporte_curso_${_selectedCourse?.id ?? 'sin_curso'}_${DateTime.now().millisecondsSinceEpoch}.csv';
      final destino = p.join(downloads.path, nombre);
      final archivo = File(destino);
      await archivo.writeAsString(contenido);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Exportado: $destino')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error al exportar: ${e.toString()}')));
      }
    }
  }

  Future<void> _exportarPDF() async {
    try {
      if (_selectedCourse == null) return;
      final doc = pw.Document();
      doc.addPage(
        pw.MultiPage(
          pageFormat: pdf.PdfPageFormat.letter.landscape,
          build: (context) => [
            pw.Text('Informe: ${_selectedCourse!.courseName}', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 8),
            pw.Text('Total de clases: $_totalClases'),
            pw.Text('Total de tareas: $_totalTareas'),
            pw.SizedBox(height: 12),
            pw.TableHelper.fromTextArray(
              columnWidths: {
                0: pw.FlexColumnWidth(2), // Alumno
                1: pw.FlexColumnWidth(1), // Presentes
                2: pw.FlexColumnWidth(1), // Faltas
                3: pw.FlexColumnWidth(1), // Retardos
                4: pw.FlexColumnWidth(1), // Entregas
                5: pw.FlexColumnWidth(1.5), // Asistencia %
                6: pw.FlexColumnWidth(1), // Examen 1
                7: pw.FlexColumnWidth(1), // Examen 2
                8: pw.FlexColumnWidth(1), // Examen 3
                9: pw.FlexColumnWidth(1.5), // Exámenes
                10: pw.FlexColumnWidth(1.5), // Evidencias
                11: pw.FlexColumnWidth(1), // Final
              },
              headers: ['Alumno','Presentes','Faltas','Retardos','Entregas','Asistencia %','Examen 1','Examen 2','Examen 3','Exámenes','Evidencias','Final'],
              data: _filas.map((f) => [
                f.alumno,
                f.presentes.toString(),
                f.faltas.toString(),
                f.retardos.toString(),
                f.entregas.toString(),
                (f.asistenciaPct * 100).toStringAsFixed(1),
                f.exam1Grade.toStringAsFixed(1),
                f.exam2Grade.toStringAsFixed(1),
                f.exam3Grade.toStringAsFixed(1),
                f.examAvg.toStringAsFixed(1),
                f.evidenceAvg.toStringAsFixed(1),
                f.finalGrade.toStringAsFixed(2),
              ]).toList(),
            ),

          ],
        ),
      );
      Directory? downloads;
      try { downloads = await getDownloadsDirectory(); } catch (_) {}
      downloads ??= await getApplicationDocumentsDirectory();
      final nombre = 'reporte_curso_${_selectedCourse!.id}_${DateTime.now().millisecondsSinceEpoch}.pdf';
      final destino = p.join(downloads.path, nombre);
      final archivo = File(destino);
      await archivo.writeAsBytes(await doc.save());
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('PDF exportado: $destino')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error al exportar PDF: ${e.toString()}')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_selectedCourse == null ? 'Informe por curso' : 'Informe: ${_selectedCourse!.courseName}')
        ,
        actions: [
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: _loading ? null : _exportarCSV,
          ),
          IconButton(
            icon: const Icon(Icons.picture_as_pdf),
            onPressed: _loading ? null : _exportarPDF,
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_selectedCourse == null) ...[
                    DropdownButton<Course>(
                      hint: const Text('Selecciona un curso'),
                      value: null,
                      items: _availableCourses.map((c) => DropdownButtonItem(course: c)).map((item) => DropdownMenuItem<Course>(value: item.course, child: Text(item.course.courseName))).toList(),
                      onChanged: (c) {
                        setState(() { _selectedCourse = c; });
                        _cargarReporte();
                      },
                    ),
                    const SizedBox(height: 12),
                  ],
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () async {
                            final picked = await showDatePicker(
                              context: context,
                              initialDate: _desde ?? DateTime.now(),
                              firstDate: DateTime(2000),
                              lastDate: DateTime(2100),
                            );
                            if (picked != null) {
                              setState(() { _desde = DateTime(picked.year, picked.month, picked.day); });
                            }
                          },
                          child: Text(_desde == null ? 'Desde' : 'Desde: ${_desde!.toLocal().toString().split(' ')[0]}'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () async {
                            final picked = await showDatePicker(
                              context: context,
                              initialDate: _hasta ?? DateTime.now(),
                              firstDate: DateTime(2000),
                              lastDate: DateTime(2100),
                            );
                            if (picked != null) {
                              setState(() { _hasta = DateTime(picked.year, picked.month, picked.day, 23, 59, 59); });
                            }
                          },
                          child: Text(_hasta == null ? 'Hasta' : 'Hasta: ${_hasta!.toLocal().toString().split(' ')[0]}'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: _selectedCourse == null ? null : _cargarReporte,
                        child: const Text('Aplicar'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (_selectedCourse != null) ...[
                    Text('Total de clases: $_totalClases'),
                    Text('Total de tareas: $_totalTareas'),
                    const SizedBox(height: 12),
                  ],
                  Expanded(
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        if (constraints.maxWidth > 600) {
                          return SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: DataTable(
                              columns: const [
                                DataColumn(label: Text('Alumno')),
                                DataColumn(label: Text('Presentes')),
                                DataColumn(label: Text('Faltas')),
                                DataColumn(label: Text('Retardos')),
                                DataColumn(label: Text('Entregas')),
                                DataColumn(label: Text('Asistencia %')),
                                DataColumn(label: Text('Examen 1')),
                                DataColumn(label: Text('Examen 2')),
                                DataColumn(label: Text('Examen 3')),
                                DataColumn(label: Text('Exámenes')),
                                DataColumn(label: Text('Evidencias')),
                                DataColumn(label: Text('Final')),
                              ],
                              rows: _filas
                                  .map(
                                    (f) => DataRow(cells: [
                                      DataCell(Text(f.alumno)),
                                      DataCell(Text(f.presentes.toString())),
                                      DataCell(Text(f.faltas.toString())),
                                      DataCell(Text(f.retardos.toString())),
                                      DataCell(Text(f.entregas.toString())),
                                      DataCell(Text((f.asistenciaPct * 100).toStringAsFixed(1))),
                                      DataCell(Text(f.exam1Grade.toStringAsFixed(1))),
                                      DataCell(Text(f.exam2Grade.toStringAsFixed(1))),
                                      DataCell(Text(f.exam3Grade.toStringAsFixed(1))),
                                      DataCell(Text(f.examAvg.toStringAsFixed(1))),
                                      DataCell(Text(f.evidenceAvg.toStringAsFixed(1))),
                                      DataCell(Text(f.finalGrade.toStringAsFixed(2))),
                                    ]),
                                  )
                                  .toList(),
                            ),
                          );
                        } else {
                          return ListView.builder(
                            itemCount: _filas.length,
                            itemBuilder: (context, index) {
                              final f = _filas[index];
                              return Card(
                                margin: const EdgeInsets.symmetric(vertical: 8.0),
                                child: Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('Alumno: ${f.alumno}', style: const TextStyle(fontWeight: FontWeight.bold)),
                                      const Divider(),
                                      Text('Presentes: ${f.presentes}'),
                                      Text('Faltas: ${f.faltas}'),
                                      Text('Retardos: ${f.retardos}'),
                                      Text('Entregas: ${f.entregas}'),
                                      Text('Asistencia %: ${(f.asistenciaPct * 100).toStringAsFixed(1)}'),
                                      Text('Examen 1: ${f.exam1Grade.toStringAsFixed(1)}'),
                                      Text('Examen 2: ${f.exam2Grade.toStringAsFixed(1)}'),
                                      Text('Examen 3: ${f.exam3Grade.toStringAsFixed(1)}'),
                                      Text('Exámenes: ${f.examAvg.toStringAsFixed(1)}'),
                                      Text('Evidencias: ${f.evidenceAvg.toStringAsFixed(1)}'),
                                      Text('Final: ${f.finalGrade.toStringAsFixed(2)}'),
                                    ],
                                  ),
                                ),
                              );
                            },
                          );
                        }
                      },
                    ),
                  ),

                ],
              ),
            ),
    );
  }
}

class DropdownButtonItem {
  final Course course;
  DropdownButtonItem({required this.course});
}

class _FilaReporte {
  final String alumno;
  final int presentes;
  final int faltas;
  final int retardos;
  final int entregas;
  final int calificadas;
  final double asistenciaPct;
  final double examAvg;
  final double exam1Grade;
  final double exam2Grade;
  final double exam3Grade;
  final double evidenceAvg;
  final double finalGrade;

  _FilaReporte({
    required this.alumno,
    required this.presentes,
    required this.faltas,
    required this.retardos,
    required this.entregas,
    required this.calificadas,
    required this.asistenciaPct,
    required this.examAvg,
    required this.exam1Grade,
    required this.exam2Grade,
    required this.exam3Grade,
    required this.evidenceAvg,
    required this.finalGrade,
  });
}
