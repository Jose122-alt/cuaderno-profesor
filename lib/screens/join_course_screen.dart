import 'package:flutter/material.dart';
import '../services/enrollment_service.dart';
import '../models/student.dart'; // Assuming Student model is available

class JoinCourseScreen extends StatefulWidget {
  final Student student; // The student who is trying to join the course

  JoinCourseScreen({required this.student});

  @override
  _JoinCourseScreenState createState() => _JoinCourseScreenState();
}

class _JoinCourseScreenState extends State<JoinCourseScreen> {
  final _courseCodeController = TextEditingController();
  final EnrollmentService _enrollmentService = EnrollmentService();
  String? _errorMessage;

  void _joinCourse() async {
    setState(() {
      _errorMessage = null;
    });

    String courseCode = _courseCodeController.text.trim();
    if (courseCode.isEmpty) {
      setState(() {
        _errorMessage = 'Por favor, introduce un código de curso.';
      });
      return;
    }

    try {
      bool success = await _enrollmentService.joinCourse(
        widget.student.id!,
        courseCode,
      );

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Te has unido al curso exitosamente!')),
        );
        Navigator.pop(context); // Go back after successful enrollment
      } else {
        setState(() {
          _errorMessage = 'No se pudo unir al curso. El código es inválido o ya estás inscrito.';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Ocurrió un error: ${e.toString()}';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Unirse a un Curso',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.blueAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _courseCodeController,
              decoration: const InputDecoration(
                labelText: 'Código del Curso',
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
            if (_errorMessage != null)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  _errorMessage!,
                  style: TextStyle(color: Colors.red[700], fontWeight: FontWeight.bold),
                ),
              ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _joinCourse,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                'Unirse al Curso',
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}