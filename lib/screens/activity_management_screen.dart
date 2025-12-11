import 'package:flutter/material.dart';
import 'package:flutter_application_1cuadermo/models/activity.dart';
import 'package:flutter_application_1cuadermo/models/course.dart';
import 'package:flutter_application_1cuadermo/services/activity_service.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_application_1cuadermo/services/file_upload_service.dart';
import 'package:path/path.dart' as p;
import 'package:flutter_application_1cuadermo/screens/activity_submissions_screen.dart';

class ActivityManagementScreen extends StatefulWidget {
  final Course course;

  const ActivityManagementScreen({super.key, required this.course});

  @override
  State<ActivityManagementScreen> createState() => _ActivityManagementScreenState();
}

class _ActivityManagementScreenState extends State<ActivityManagementScreen> {
  final ActivityService _activityService = ActivityService();
  final FileUploadService _fileUploadService = FileUploadService();
  List<Activity> _activities = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadActivities();
  }

  Future<void> _loadActivities() async {
    setState(() {
      _isLoading = true;
    });
    _activities = await _activityService.getActivitiesByCourseId(widget.course.id!);
    setState(() {
      _isLoading = false;
    });
  }



  Future<void> _addOrEditActivity({Activity? activity = null}) async {
    final TextEditingController titleController = TextEditingController(text: activity?.title);
    final TextEditingController descriptionController = TextEditingController(text: activity?.description);
    DateTime? selectedDate = activity?.dueDate;
    String? selectedActivityType = activity?.activityType ?? 'task';
    String selectedEvalCategory = activity?.evaluationCategory ?? 'portfolio';
    bool allowLate = activity?.allowLateSubmissions ?? false;
    // Asegurar que el tipo de actividad nunca sea nulo
    if (selectedActivityType == null) {
      selectedActivityType = 'task';
    }
    PlatformFile? selectedFile;
    String? fileUrl = activity?.fileUrl; // Initialize fileUrl with existing fileUrl

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (BuildContext context, StateSetter dialogSetState) {
          return AlertDialog(
            title: Text(activity == null ? 'Añadir Actividad' : 'Editar Actividad'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: titleController,
                    decoration: const InputDecoration(labelText: 'Título'),
                  ),
                  TextField(
                    controller: descriptionController,
                    decoration: const InputDecoration(labelText: 'Descripción'),
                    maxLines: 3,
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: RadioListTile<String>(
                          title: const Text('Tarea con entregable'),
                          value: 'task',
                          groupValue: selectedActivityType,
                          onChanged: (String? value) {
                            dialogSetState(() {
                              selectedActivityType = value;
                            });
                          },
                        ),
                      ),
                      Expanded(
                        child: RadioListTile<String>(
                          title: const Text('Solo material'),
                          value: 'material',
                          groupValue: selectedActivityType,
                          onChanged: (String? value) {
                            dialogSetState(() {
                              selectedActivityType = value;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: selectedEvalCategory,
                    decoration: const InputDecoration(labelText: 'Categoría de evaluación'),
                    items: const [
                      DropdownMenuItem(value: 'exam', child: Text('Examen (40%)')),
                      DropdownMenuItem(value: 'portfolio', child: Text('Portafolio (40%)')),
                      DropdownMenuItem(value: 'complementary', child: Text('Actividad Complementaria (20%)')),
                    ],
                    onChanged: (val) {
                      dialogSetState(() { selectedEvalCategory = val ?? 'portfolio'; });
                    },
                  ),

                  ListTile(
                    title: Text(selectedDate == null
                        ? 'Seleccionar Fecha de Cierre'
                        : 'Fecha de Cierre: ${selectedDate!.toLocal().toString().split(' ')[0]}'),
                    trailing: const Icon(Icons.calendar_today),
                    onTap: () async {
                      final DateTime? picked = await showDatePicker(
                        context: context,
                        initialDate: selectedDate ?? DateTime.now(),
                        firstDate: DateTime.now(),
                        lastDate: DateTime(2101),
                      );
                      if (picked != null && picked != selectedDate) {
                        dialogSetState(() {
                          selectedDate = picked;
                        });
                      }
                    },
                  ),
                  SwitchListTile(
                    title: const Text('Permitir entregas después de la fecha'),
                    value: allowLate,
                    onChanged: (v) {
                      dialogSetState(() { allowLate = v; });
                    },
                  ),
                  ListTile(
                    title: Text(selectedFile == null
                        ? 'Seleccionar Archivo'
                        : 'Archivo Seleccionado: ${selectedFile!.name}'),
                    trailing: const Icon(Icons.attach_file),
                    onTap: () async {
                      FilePickerResult? result = await FilePicker.platform.pickFiles(withData: true);
                      if (result != null) {
                        final int maxBytes = 50 * 1024 * 1024;
                        final int size = result.files.single.size;
                        if (size > maxBytes) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('El archivo supera el límite de 50 MB')),
                          );
                          return;
                        }
                        dialogSetState(() {
                          selectedFile = result.files.single;
                        });
                      }
                    },
                  ),
                  if (fileUrl != null && selectedFile == null)
                    Text('Archivo actual: ${p.basename(fileUrl!)}'),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancelar'),
              ),
              ElevatedButton(
                onPressed: () async {
                  if (titleController.text.isEmpty || selectedDate == null) {
                    // Show error or snackbar
                    return;
                  }

                  String? uploadedFileUrl = fileUrl;
                  if (selectedFile != null) {
                    final int maxBytes = 50 * 1024 * 1024;
                    final int size = selectedFile!.size;
                    if (size > maxBytes) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('El archivo supera el límite de 50 MB')),
                      );
                      return;
                    }
                    final String filename = selectedFile!.name;
                    final String target = 'activities/${widget.course.id}/$filename';
                    if (selectedFile!.path != null) {
                      uploadedFileUrl = await _fileUploadService.uploadFileFromPath(selectedFile!.path!, 'activities/${widget.course.id}');
                    } else if (selectedFile!.bytes != null) {
                      uploadedFileUrl = await _fileUploadService.uploadBytes(selectedFile!.bytes!, filename, 'activities/${widget.course.id}');
                    }
                    if (uploadedFileUrl == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Error al subir el archivo. Revisa los registros de depuración para más detalles.')),
                      );
                      return;
                    }
                  }

                  final newActivity = Activity(
                    id: activity?.id,
                    courseId: widget.course.id!,
                    title: titleController.text,
                    dueDate: selectedDate!,
                    description: descriptionController.text,
                    fileUrl: uploadedFileUrl,
                    activityType: selectedActivityType!, // Use selected activity type
                    evaluationCategory: selectedEvalCategory,
                    allowLateSubmissions: allowLate,
                  );

                  if (activity == null) {
                    await _activityService.addActivity(newActivity);
                  } else {
                    await _activityService.updateActivity(newActivity);
                  }
                  selectedFile = null; // Clear selected file after upload
                  fileUrl = null; // Clear file URL
                  _loadActivities();
                  Navigator.pop(context);
                },
                child: Text(activity == null ? 'Añadir' : 'Guardar'),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _deleteActivity(String activityId) async {
    await _activityService.deleteActivity(activityId);
    _loadActivities();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Actividades para ${widget.course.courseName}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _addOrEditActivity(),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _activities.isEmpty
              ? const Center(child: Text('No hay actividades para este curso.'))
              : ListView.builder(
                  itemCount: _activities.length,
                  itemBuilder: (context, index) {
                    final activity = _activities[index];
                    return Card(
                      margin: const EdgeInsets.all(8.0),
                      child: ListTile(
                        title: Text(activity.title),
                        subtitle: Text(
                            'Fecha de Cierre: ${activity.dueDate.toLocal().toString().split(' ')[0]}\nDescripción: ${activity.description}\nEntregas tardías: ${activity.allowLateSubmissions ? 'Sí' : 'No'}\n${activity.fileUrl != null ? 'Archivo: ${activity.fileUrl!.split('/').last}' : ''}'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.assignment_turned_in),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ActivitySubmissionsScreen(course: widget.course, activity: activity),
                                  ),
                                );
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () => _addOrEditActivity(activity: activity),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: activity.id != null ? () => _deleteActivity(activity.id!) : null,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
