import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import 'package:flutter/foundation.dart';
import 'package:flutter_application_1cuadermo/models/activity.dart';
import 'package:flutter_application_1cuadermo/models/course.dart';
import 'package:flutter_application_1cuadermo/models/student.dart';
import 'package:flutter_application_1cuadermo/services/enrollment_service.dart';
import 'package:flutter_application_1cuadermo/services/student_service.dart';
import 'package:flutter_application_1cuadermo/services/evidence_service.dart';
import 'package:flutter_application_1cuadermo/models/evidence.dart';

class ActivitySubmissionsScreen extends StatefulWidget {
  final Course course;
  final Activity activity;

  const ActivitySubmissionsScreen({super.key, required this.course, required this.activity});

  @override
  State<ActivitySubmissionsScreen> createState() => _ActivitySubmissionsScreenState();
}

class _ActivitySubmissionsScreenState extends State<ActivitySubmissionsScreen> {
  final EnrollmentService _enrollmentService = EnrollmentService();
  final StudentService _studentService = StudentService();
  final EvidenceService _evidenceService = EvidenceService();

  List<Student> _students = [];
  Map<String, Evidence?> _evidenceByStudentId = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _students = [];
      _evidenceByStudentId = {};
    });

    final enrollments = await _enrollmentService.getEnrollmentsByCourseId(widget.course.id!);
    final List<Student> students = [];
    for (final enr in enrollments) {
      if (enr.studentId == null) continue;
      final st = await _studentService.getStudentById(enr.studentId!);
      if (st != null) {
        students.add(st);
        Evidence? ev;
        final sid = int.tryParse(st.id ?? '');
        if (sid != null) {
          ev = await _evidenceService.getEvidenceByStudentIdAndActivityId(sid, widget.activity.id!);
        }
        _evidenceByStudentId[st.id!] = ev;
      }
    }
    setState(() {
      _students = students;
      _isLoading = false;
    });
  }

  Future<void> _downloadFile(String sourcePath, String studentId) async {
    if (kIsWeb) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Descarga no disponible en navegador')));
      return;
    }
    final fileName = p.basename(sourcePath);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Archivo: $fileName')));
  }

  Future<void> _gradeEvidence(Student student, Evidence evidence) async {
    final gradeCtrl = TextEditingController(text: evidence.grade?.toString() ?? '');
    final commentCtrl = TextEditingController(text: evidence.comment ?? '');
    final descriptionCtrl = TextEditingController(text: evidence.description);
    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Calificar entrega'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: gradeCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Calificación'),
            ),
            TextField(
              controller: descriptionCtrl,
              decoration: const InputDecoration(labelText: 'Descripción de la evidencia'),
              maxLines: 2,
            ),
            TextField(
              controller: commentCtrl,
              decoration: const InputDecoration(labelText: 'Comentario'),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () async {
              final grade = int.tryParse(gradeCtrl.text);
              final updated = evidence.copyWith(
                grade: grade,
                description: descriptionCtrl.text.trim().isEmpty ? evidence.description : descriptionCtrl.text.trim(),
                comment: commentCtrl.text.isEmpty ? null : commentCtrl.text,
                status: 'graded',
              );
              await _evidenceService.updateEvidence(updated);
              setState(() {
                _evidenceByStudentId[student.id!] = updated;
              });
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Calificación guardada')));
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Entregas: ${widget.activity.title}'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _students.isEmpty
              ? const Center(child: Text('No hay estudiantes inscritos.'))
              : ListView.builder(
                  itemCount: _students.length,
                  itemBuilder: (ctx, i) {
                    final st = _students[i];
                    final ev = _evidenceByStudentId[st.id!];
                    final delivered = ev != null;
                    return Card(
                      margin: const EdgeInsets.all(8.0),
                      child: ListTile(
                        title: Text(st.name),
                        subtitle: Text(
                          delivered
                              ? 'Estado: ${ev!.status}'
                                  '${ev.grade != null ? ' • Calificación: ${ev.grade}' : ''}'
                                  '\nArchivo: ${ev.fileUrl != null ? p.basename(ev.fileUrl!) : 'sin archivo'}'
                                  '${ev.comment != null && ev.comment!.trim().isNotEmpty ? '\nComentario: ${ev.comment}' : ''}'
                              : 'No entregado',
                        ),
                        trailing: delivered
                            ? Wrap(
                                spacing: 8,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.download),
                                    onPressed: ev!.fileUrl != null ? () => _downloadFile(ev.fileUrl!, st.id!) : null,
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.rate_review),
                                    onPressed: () => _gradeEvidence(st, ev!),
                                  ),
                                ],
                              )
                            : null,
                      ),
                    );
                  },
                ),
    );
  }
}
