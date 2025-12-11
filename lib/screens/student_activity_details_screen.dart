import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_application_1cuadermo/models/activity.dart';
import 'package:path/path.dart' as p;
import 'package:flutter_application_1cuadermo/services/file_upload_service.dart';
import 'package:flutter_application_1cuadermo/services/evidence_service.dart';
import 'package:flutter_application_1cuadermo/models/evidence.dart';
import 'package:flutter_application_1cuadermo/models/student.dart';
import 'package:flutter_application_1cuadermo/services/activity_service.dart';

class StudentActivityDetailsScreen extends StatelessWidget {
  final Activity activity;
  final Student student;
  final FileUploadService _fileUploadService = FileUploadService();
  final EvidenceService _evidenceService = EvidenceService();
  final ActivityService _activityService = ActivityService();

  StudentActivityDetailsScreen({super.key, required this.activity, required this.student});

  @override
  Widget build(BuildContext context) {
    final bool isTask = activity.activityType == 'task';
    final bool isClosed = isTask && DateTime.now().isAfter(activity.dueDate) && !activity.allowLateSubmissions;
    return Scaffold(
      appBar: AppBar(
        title: Text(activity.title),
        backgroundColor: Colors.blueAccent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Descripción',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(activity.description),
                const SizedBox(height: 16),
                if (isTask)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children:
                    [
                      Text(
                        'Fecha de Cierre',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text(activity.dueDate.toLocal().toString().split(' ')[0]),
                    const SizedBox(height: 16),
                  ],
                ),
                FutureBuilder<Activity?>(
                  future: activity.id != null ? _activityService.getActivityById(activity.id!) : Future.value(activity),
                  builder: (ctx, snap) {
                    final Activity act = snap.data ?? activity;
                    final bool isTask2 = act.activityType == 'task';
                    if (!isTask2) return const SizedBox.shrink();
                    final bool isClosed2 = DateTime.now().isAfter(act.dueDate) && !act.allowLateSubmissions;
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Entrega de Actividad',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        FutureBuilder<Evidence?>(
                          future: (() async {
                            final int? sid = int.tryParse(student.id ?? '');
                            if (sid == null || act.id == null) return null;
                            return await _evidenceService.getEvidenceByStudentIdAndActivityId(sid, act.id!);
                          })(),
                          builder: (ctx2, evSnap) {
                            final Evidence? ev = evSnap.data;
                            if (ev == null) return const SizedBox.shrink();
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Tu entrega',
                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 8),
                                Text('Estado: ${ev.status}${ev.grade != null ? ' • Calificación: ${ev.grade}' : ''}'),
                                if (ev.comment != null && ev.comment!.trim().isNotEmpty)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 4.0),
                                    child: Text('Comentario: ${ev.comment}'),
                                  ),
                                if (ev.fileUrl != null)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 4.0),
                                    child: Text('Archivo: ${p.basename(ev.fileUrl!)}'),
                                  ),
                                const SizedBox(height: 12),
                              ],
                            );
                          },
                        ),
                        if (isClosed2)
                          Text(
                            'Entrega cerrada. Fecha límite: ${act.dueDate.toLocal().toString().split(' ')[0]}',
                            style: const TextStyle(color: Colors.redAccent),
                          )
                        else
                          FutureBuilder<Evidence?>(
                            future: (() async {
                              final int? sid = int.tryParse(student.id ?? '');
                              if (sid == null || act.id == null) return null;
                              return await _evidenceService.getEvidenceByStudentIdAndActivityId(sid, act.id!);
                            })(),
                            builder: (ctx3, evSnap2) {
                              final Evidence? ev2 = evSnap2.data;
                              if (ev2 != null) return const SizedBox.shrink();
                              return ElevatedButton(
                                onPressed: () async {
                                  final Activity current = act;
                                  final bool isAfterDue = DateTime.now().isAfter(current.dueDate);
                                  if (isAfterDue && !current.allowLateSubmissions) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('La fecha de entrega ha pasado. No es posible entregar.')),
                                    );
                                    return;
                                  }
                                  if (isAfterDue && current.allowLateSubmissions) {
                                    final bool? confirm = await showDialog<bool>(
                                      context: context,
                                      builder: (ctx) => AlertDialog(
                                        title: const Text('Entrega tardía'),
                                        content: Text('La fecha límite fue ${current.dueDate.toLocal().toString().split(' ')[0]}. Esta entrega se registrará como tardía. ¿Desea continuar?'),
                                        actions: [
                                          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar')),
                                          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Continuar')),
                                        ],
                                      ),
                                    );
                                    if (confirm != true) return;
                                  }
                                  FilePickerResult? result = await FilePicker.platform.pickFiles();
                                  if (result != null) {
                                    final PlatformFile file = result.files.first;
                                    final String? filePath = file.path;
                                    if (current.id == null) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text('Error: ID de actividad no disponible.')),
                                      );
                                      return;
                                    }
                                    final String uploadPath = 'submissions/activity_${current.id}/student_${student.id}';
                                    String? uploadedFilePath;
                                    if (filePath != null && !kIsWeb) {
                                      uploadedFilePath = await _fileUploadService.uploadFileFromPath(filePath, uploadPath);
                                    } else if (file.bytes != null) {
                                      uploadedFilePath = await _fileUploadService.uploadBytes(file.bytes!, file.name, uploadPath);
                                    }
                                    if (uploadedFilePath != null) {
                                      try {
                                        final int? sid = int.tryParse(student.id ?? '');
                                        if (sid == null) {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            const SnackBar(content: Text('Error: ID de estudiante inválido.')),
                                          );
                                          return;
                                        }
                                        final Evidence newEvidence = Evidence(
                                          courseId: current.courseId,
                                          studentId: sid,
                                          activityId: current.id,
                                          description: 'Entrega de actividad ${current.title}',
                                          date: DateTime.now().toIso8601String(),
                                          status: 'submitted',
                                          fileUrl: uploadedFilePath,
                                        );
                                        await _evidenceService.insertEvidence(newEvidence);
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(content: Text('Archivo ${file.name} subido y evidencia registrada.')),
                                        );
                                      } catch (e) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(content: Text('Error al procesar la entrega: ${e.toString()}')),
                                        );
                                      }
                                    } else {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text('Error al subir el archivo.')),
                                      );
                                    }
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('Selección de archivo cancelada.')),
                                    );
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.upload_file, color: Colors.white),
                                    const SizedBox(width: 8),
                                    const Text('Subir Actividad', style: TextStyle(color: Colors.white)),
                                  ],
                                ),
                              );
                            },
                          ),
                        if (DateTime.now().isAfter(act.dueDate) && act.allowLateSubmissions)
                          Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              'Entrega tardía habilitada por el profesor',
                              style: const TextStyle(color: Colors.amber),
                            ),
                          ),
                        const SizedBox(height: 16),
                      ],
                    );
                  },
                ),
                if (activity.fileUrl != null)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Archivo Adjunto',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text(p.basename(activity.fileUrl!)),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
