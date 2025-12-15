import 'package:flutter/material.dart';
import 'package:flutter_application_1cuadermo/models/evaluation.dart';
import 'package:flutter_application_1cuadermo/models/course.dart';
import 'package:flutter_application_1cuadermo/services/evaluation_service.dart';
import 'package:flutter_application_1cuadermo/screens/grade_assignment_screen.dart';

class EvaluationManagementScreen extends StatefulWidget {
  final Course course;

  const EvaluationManagementScreen({super.key, required this.course});

  @override
  State<EvaluationManagementScreen> createState() => _EvaluationManagementScreenState();
}

class _EvaluationManagementScreenState extends State<EvaluationManagementScreen> {
  final EvaluationService _evaluationService = EvaluationService();
  List<Evaluation> _evaluations = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadEvaluations();
  }

  Future<void> _loadEvaluations() async {
    setState(() {
      _isLoading = true;
    });
    _evaluations = await _evaluationService.getEvaluationsByCourseId(widget.course.id!);
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _addOrEditEvaluation({Evaluation? evaluation}) async {
    final TextEditingController nameController = TextEditingController(text: evaluation?.evaluationName);
    final TextEditingController weightController = TextEditingController(text: evaluation?.weight.toString());
    final TextEditingController maxGradeController = TextEditingController(text: evaluation?.maxGrade.toString());
    DateTime? selectedDate = evaluation?.date;
    String selectedCategory = evaluation?.category ?? 'Parcial';

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (BuildContext context, StateSetter dialogSetState) {
          return AlertDialog(
            title: Text(evaluation == null ? 'Añadir Evaluación' : 'Editar Evaluación'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(labelText: 'Nombre de la Evaluación'),
                  ),
                  TextField(
                    controller: weightController,
                    decoration: const InputDecoration(labelText: 'Ponderación (ej. 0.3 para 30%)'),
                    keyboardType: TextInputType.number,
                  ),
                  TextField(
                    controller: maxGradeController,
                    decoration: const InputDecoration(labelText: 'Calificación Máxima'),
                    keyboardType: TextInputType.number,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: DropdownButtonFormField<String>(
                      value: selectedCategory,
                      decoration: const InputDecoration(labelText: 'Categoría'),
                      items: const [
                        DropdownMenuItem(value: 'Parcial', child: Text('Parcial')),
                        DropdownMenuItem(value: 'Ordinaria', child: Text('Ordinaria')),
                        DropdownMenuItem(value: 'Actividad', child: Text('Actividad')),
                      ],
                      onChanged: (val) {
                        dialogSetState(() { selectedCategory = val ?? 'Parcial'; });
                      },
                    ),
                  ),
                  ListTile(
                    title: Text(selectedDate == null
                        ? 'Seleccionar Fecha'
                        : 'Fecha: ${selectedDate!.toLocal().toString().split(' ')[0]}'),
                    trailing: const Icon(Icons.calendar_today),
                    onTap: () async {
                      final DateTime? picked = await showDatePicker(
                        context: context,
                        initialDate: selectedDate ?? DateTime.now(),
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2101),
                      );
                      if (picked != null && picked != selectedDate) {
                        dialogSetState(() {
                          selectedDate = picked;
                        });
                      }
                    },
                  ),
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
                  if (nameController.text.isEmpty || weightController.text.isEmpty || maxGradeController.text.isEmpty || selectedDate == null) {
                    // Show error or snackbar
                    return;
                  }

                  final newEvaluation = Evaluation(
                    id: evaluation?.id,
                    courseId: widget.course.id!,
                    evaluationName: nameController.text,
                    weight: double.parse(weightController.text),
                    category: selectedCategory,
                    maxGrade: double.parse(maxGradeController.text),
                    date: selectedDate!,
                  );

                  if (evaluation == null) {
                    await _evaluationService.insertEvaluation(newEvaluation);
                  } else {
                    await _evaluationService.updateEvaluation(newEvaluation);
                  }
                  _loadEvaluations();
                  Navigator.pop(context);
                },
                child: Text(evaluation == null ? 'Añadir' : 'Guardar'),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _deleteEvaluation(String evaluationId) async {
    await _evaluationService.deleteEvaluation(evaluationId);
    _loadEvaluations();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Gestión de Evaluaciones - ${widget.course.courseName}'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _evaluations.isEmpty
              ? const Center(child: Text('No hay evaluaciones aún.'))
              : ListView.builder(
                  itemCount: _evaluations.length,
                  itemBuilder: (context, index) {
                    final evaluation = _evaluations[index];
                    return Card(
                      margin: const EdgeInsets.all(8.0),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              evaluation.evaluationName,
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 4),
                            Text('Categoría: ${evaluation.category}'),
                            Text('Ponderación: ${(evaluation.weight * 100).toStringAsFixed(0)}%'),
                            Text('Calificación Máxima: ${evaluation.maxGrade}'),
                            Text('Fecha: ${evaluation.date.toLocal().toString().split(' ')[0]}'),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit),
                                  onPressed: () => _addOrEditEvaluation(evaluation: evaluation),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete),
                                  onPressed: () => _deleteEvaluation(evaluation.id!),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.grade),
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => GradeAssignmentScreen(evaluation: evaluation),
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _addOrEditEvaluation(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
