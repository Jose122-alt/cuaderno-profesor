import 'package:flutter/material.dart';
import 'package:flutter_application_1cuadermo/services/teacher_service.dart';
import 'package:flutter_application_1cuadermo/services/student_service.dart';
import 'package:flutter_application_1cuadermo/services/admin_service.dart'; // Importar AdminService
import 'package:flutter_application_1cuadermo/models/teacher.dart';
import 'package:flutter_application_1cuadermo/models/student.dart';
import 'package:flutter_application_1cuadermo/models/admin.dart'; // Importar modelo Admin
import 'package:flutter_application_1cuadermo/screens/course_list_screen.dart';
import 'package:flutter_application_1cuadermo/screens/student_course_list_screen.dart';
import 'package:flutter_application_1cuadermo/screens/admin_module_page.dart'; // Importar AdminModulePage
import 'package:flutter_application_1cuadermo/main.dart'; // Import HomePage, TeacherModulePage, StudentModulePage
import 'package:flutter_application_1cuadermo/role_selection_screen.dart';
import 'package:flutter_application_1cuadermo/registration_screen.dart';
import 'package:flutter_application_1cuadermo/models/user_type.dart';

class LoginScreen extends StatefulWidget {
  final UserType userType;

  const LoginScreen({super.key, required this.userType});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _accountNumberController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _accountNumberController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  final TeacherService _teacherService = TeacherService();
  final StudentService _studentService = StudentService();
  final AdminService _adminService = AdminService(); // Instanciar AdminService
  String? _errorMessage;

  Future<void> _login() async {
    setState(() {
      _errorMessage = null;
    });

    final String identifier = _accountNumberController.text;
    final String password = _passwordController.text;

    if (identifier.isEmpty || password.isEmpty) {
      setState(() {
        _errorMessage = 'Por favor, ingrese su identificador y contraseña.';
      });
      return;
    }

    try {
      if (widget.userType == UserType.teacher) {
        print('DEBUG: Intentando iniciar sesión como profesor.');
        print('DEBUG: Identificador ingresado: $identifier');
        print('DEBUG: Contraseña ingresada: $password');
        final Teacher? teacher = await _teacherService.getTeacherByAccountNumber(identifier);
        print('DEBUG: Profesor recuperado de la base de datos: $teacher');
        if (teacher != null) {
          print('DEBUG: Contraseña almacenada para el profesor: ${teacher.password}');
        }
        if (teacher != null && teacher.password == password) {
          print('DEBUG: Credenciales de profesor válidas. Navegando a TeacherModulePage.');
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => TeacherModulePage(teacher: teacher),
            ),
          );
        } else {
          setState(() {
            _errorMessage = 'Credenciales de profesor inválidas.';
          });
          print('DEBUG: Credenciales de profesor inválidas. Error: $_errorMessage');
        }
      } else if (widget.userType == UserType.student) {
        final Student? student = await _studentService.getStudentByAccountNumber(identifier);
        if (student != null && student.password == password) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => StudentModulePage(student: student),
            ),
          );
        } else {
          setState(() {
            _errorMessage = 'Credenciales de estudiante inválidas.';
          });
        }
      } else if (widget.userType == UserType.admin) { // Manejar inicio de sesión de administrador
        final Admin? admin = await _adminService.getAdminByAccountNumber(identifier);
        if (admin != null && admin.password == password) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const AdminModulePage(),
            ),
          );
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Inicio de sesión de administrador exitoso.')),
          );
        } else {
          setState(() {
            _errorMessage = 'Credenciales de administrador inválidas.';
          });
          print('DEBUG: Admin login failed. Error message: $_errorMessage'); // Added for debugging
        }
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error al iniciar sesión: ${e.toString()}';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    String titleText;
    String welcomeText;
    String accountNumberLabel;

    if (widget.userType == UserType.teacher) {
      titleText = 'Inicio de Sesión Profesor';
      welcomeText = 'Bienvenido Profesor';
      accountNumberLabel = 'Número de Cuenta del Profesor';
    } else if (widget.userType == UserType.student) {
      titleText = 'Inicio de Sesión Estudiante';
      welcomeText = 'Bienvenido Estudiante';
      accountNumberLabel = 'Número de Cuenta del Estudiante';
    } else {
      titleText = 'Inicio de Sesión Administrador';
      welcomeText = 'Bienvenido Administrador';
      accountNumberLabel = 'Número de Cuenta del Administrador';
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(titleText),
        centerTitle: true,
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                welcomeText,
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 30),
              TextFormField(
                controller: _accountNumberController,
                decoration: InputDecoration(
                  labelText: accountNumberLabel,
                  prefixIcon: Icon(widget.userType == UserType.teacher ? Icons.person : (widget.userType == UserType.student ? Icons.account_circle : Icons.admin_panel_settings)),
                  border: const OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Contraseña',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.lock),
                ),
              ),
              const SizedBox(height: 20),
              if (_errorMessage != null)
                Text(
                  _errorMessage!,
                  style: const TextStyle(color: Colors.red, fontSize: 16),
                ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _login,
                style: ElevatedButton.styleFrom(
                  foregroundColor: Theme.of(context).colorScheme.onPrimary,
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                  textStyle: const TextStyle(fontSize: 18),
                ),
                child: const Text('Iniciar Sesión'),
              ),
              const SizedBox(height: 10),
              if (widget.userType != UserType.admin)
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => RegistrationScreen(userType: widget.userType),
                      ),
                    );
                  },
                  child: const Text('¿No tienes cuenta? Regístrate aquí'),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
