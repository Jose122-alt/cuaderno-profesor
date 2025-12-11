import 'package:flutter/material.dart';
import 'package:flutter_application_1cuadermo/models/user_type.dart';
import 'package:flutter_application_1cuadermo/services/teacher_service.dart';
import 'package:flutter_application_1cuadermo/services/student_service.dart';
// import 'package:flutter_application_1cuadermo/services/admin_service.dart';
import 'package:flutter_application_1cuadermo/models/teacher.dart';
import 'package:flutter_application_1cuadermo/models/student.dart';
// import 'package:flutter_application_1cuadermo/models/admin.dart';

class RegistrationScreen extends StatefulWidget {
  final UserType userType;

  const RegistrationScreen({Key? key, required this.userType}) : super(key: key);

  @override
  _RegistrationScreenState createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _accountNumberController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TeacherService _teacherService = TeacherService();
  final StudentService _studentService = StudentService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
            'Registro de ${widget.userType == UserType.teacher ? 'Profesor' : (widget.userType == UserType.student ? 'Estudiante' : 'Administrador')}'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: <Widget>[
              TextFormField(
                controller: _accountNumberController,
                decoration: InputDecoration(
                  labelText: 'No. de cuenta',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingrese su número de cuenta';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Nombre',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingrese su nombre';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _passwordController,
                decoration: InputDecoration(
                  labelText: 'Contraseña',
                ),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingrese su contraseña';
                  }
                  return null;
                },
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: ElevatedButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      final String accountNumber = _accountNumberController.text;
                      final String name = _nameController.text;
                      final String password = _passwordController.text;

                      try {
                        if (widget.userType == UserType.teacher) {
                          final Teacher newTeacher = Teacher(
                            name: name,
                            accountNumber: accountNumber,
                            password: password,
                          );
                          final Teacher registeredTeacher = await _teacherService.addTeacher(newTeacher);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Profesor registrado exitosamente.')),
                          );
                        } else if (widget.userType == UserType.student) {
                          final Student newStudent = Student(
                            name: name,
                            accountNumber: accountNumber,
                            password: password,
                          );
                          await _studentService.addStudent(newStudent);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Estudiante registrado exitosamente.')),
                          );
                        } else if (widget.userType == UserType.admin) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('El registro de administrador no está habilitado.')),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Tipo de usuario no reconocido.')),
                          );
                        }
                        Navigator.pop(context); // Volver a la pantalla de inicio de sesión
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Error al registrar: ${e.toString()}')),
                        );
                      }
                    }
                  },
                  child: const Text('Registrarse'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
