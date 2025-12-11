import 'package:flutter/material.dart';
import 'package:flutter_application_1cuadermo/models/course.dart';
import 'package:flutter_application_1cuadermo/services/course_service.dart';
import 'package:flutter_application_1cuadermo/models/teacher.dart';

class AddCourseScreen extends StatefulWidget {
  final Teacher teacher;

  const AddCourseScreen({super.key, required this.teacher});
  @override
  _AddCourseScreenState createState() => _AddCourseScreenState();
}

class _AddCourseScreenState extends State<AddCourseScreen> {
  final _formKey = GlobalKey<FormState>();
  final _courseNameController = TextEditingController();
  final _courseCodeController = TextEditingController();
  final _descriptionController = TextEditingController();

  final CourseService _courseService = CourseService();

  @override
  void dispose() {
    _courseNameController.dispose();
    _courseCodeController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _addCourse() async {
    if (_formKey.currentState!.validate()) {
      final newCourse = Course(
        teacherId: widget.teacher.id!,
        courseName: _courseNameController.text,
        courseCode: _courseCodeController.text,
        description: _descriptionController.text,
      );

      await _courseService.insertCourse(newCourse);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Curso añadido exitosamente!')),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Añadir Nuevo Curso'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: <Widget>[
              TextFormField(
                controller: _courseNameController,
                decoration: const InputDecoration(
                  labelText: 'Nombre del Curso',
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.white,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingresa el nombre del curso';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _courseCodeController,
                decoration: const InputDecoration(
                  labelText: 'Código del Curso',
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.white,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingresa el código del curso';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Descripción',
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.white,
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _addCourse,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Añadir Curso',
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}