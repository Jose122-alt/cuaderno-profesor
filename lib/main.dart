import 'package:flutter/material.dart';
import 'services/mongo_service.dart';
import 'package:flutter_application_1cuadermo/teacher_mobile/attendance_screen.dart';
import 'package:flutter_application_1cuadermo/teacher_mobile/evidence_screen.dart';
import 'package:flutter_application_1cuadermo/teacher_mobile/student_status_screen.dart';
import 'package:flutter_application_1cuadermo/screens/student_dashboard_screen.dart';
// import 'package:flutter_application_1cuadermo/student_mobile/student_attendance_screen.dart';
// import 'package:flutter_application_1cuadermo/student_mobile/student_evidence_screen.dart';
import 'package:flutter_application_1cuadermo/screens/join_course_screen.dart';
import 'package:flutter_application_1cuadermo/screens/student_course_list_screen.dart';
import 'package:flutter_application_1cuadermo/screens/student_attendance_records_screen.dart';
import 'package:flutter_application_1cuadermo/models/student.dart';
import 'package:flutter_application_1cuadermo/models/course.dart';
import 'package:flutter_application_1cuadermo/models/teacher.dart';
import 'package:flutter_application_1cuadermo/web_module/reports_screen.dart';
import 'package:flutter_application_1cuadermo/web_module/statistics_screen.dart';
import 'package:flutter_application_1cuadermo/login_screen.dart';
import 'package:flutter_application_1cuadermo/teacher_mobile/attendance_management_screen.dart';
import 'package:flutter_application_1cuadermo/screens/add_course_screen.dart';
import 'package:flutter_application_1cuadermo/screens/course_list_screen.dart';

import 'package:flutter_application_1cuadermo/role_selection_screen.dart';
import 'package:flutter_application_1cuadermo/services/admin_service.dart';
import 'package:flutter_application_1cuadermo/models/admin.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await MongoService.instance.init();
  final AdminService _adminService = AdminService();
  final Admin? existingAdmin = await _adminService.getAdminByAccountNumber('8010212');
  if (existingAdmin == null) {
    await _adminService.addAdmin(Admin(accountNumber: '8010212', password: 'admin'));
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cuaderno Profesor Z',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const RoleSelectionScreen(), // Set RoleSelectionScreen as the initial route
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final Student demoStudent = Student(id: '1', name: 'Demo Student', accountNumber: '000000000', password: 'demo');
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cuaderno Profesor Z'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => StudentModulePage(student: demoStudent)));
              },
              child: const Text('Módulo Alumno'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => WebModulePage()));
              },
              child: const Text('Módulo Web'),
            ),
          ],
        ),
      ),
    );
  }
}

class TeacherModulePage extends StatelessWidget {
  final Teacher teacher;

  const TeacherModulePage({super.key, required this.teacher});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Panel del Profesor'),
        centerTitle: true,
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _confirmLogout(context),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: GridView.count( // Using GridView for a more organized layout
          crossAxisCount: 2, // Two columns
          crossAxisSpacing: 20.0,
          mainAxisSpacing: 20.0,
          children: <Widget>[
            _buildModuleButton(
              context,
              icon: Icons.add_box,
              label: 'Añadir Curso',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AddCourseScreen(teacher: teacher)),
                );
              },
            ),
            _buildModuleButton(
              context,
              icon: Icons.list_alt,
              label: 'Lista de Cursos',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => CourseListScreen(teacher: teacher)),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModuleButton(BuildContext context, {required IconData icon, required String label, required VoidCallback onPressed}) {
    return ElevatedButton.icon(
      icon: Icon(icon, size: 40), // Larger icon
      label: Text(label, textAlign: TextAlign.center, style: const TextStyle(fontSize: 16)),
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        foregroundColor: Theme.of(context).colorScheme.onPrimaryContainer, // Text color
        backgroundColor: Theme.of(context).colorScheme.primaryContainer, // Button background color
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.0),
        ),
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
        elevation: 5, // Add shadow
      ),
    );
  }

  void _confirmLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cerrar sesión'),
        content: const Text('¿Seguro que quiere cerrar sesión?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const RoleSelectionScreen()),
                (route) => false,
              );
            },
            child: const Text('Cerrar sesión'),
          ),
        ],
      ),
    );
  }
}

class StudentModulePage extends StatelessWidget {
  final Student student;

  const StudentModulePage({super.key, required this.student});

  @override
  Widget build(BuildContext context) {
    final Course dummyCourse = Course(id: 1, courseName: 'Matemáticas', courseCode: 'MATH101', description: 'Curso de matemáticas básicas', teacherId: 1);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Módulo Alumno'),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Theme.of(context).colorScheme.primary,
                Theme.of(context).colorScheme.secondary,
              ],
            ),
          ),
        ),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _confirmLogout(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Theme.of(context).colorScheme.primaryContainer,
                    Theme.of(context).colorScheme.secondaryContainer,
                  ],
                ),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    child: Text(
                      student.name.isNotEmpty ? student.name[0].toUpperCase() : 'A',
                      style: const TextStyle(fontSize: 24, color: Colors.white),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Hola, ${student.name.split(' ').first}',
                          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 6),
                        const Text('¿Qué te gustaría hacer hoy?'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: GridView.count(
                crossAxisCount: 2,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _buildActionCard(
                    context,
                    icon: Icons.insights,
                    label: 'Progreso',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => StudentDashboardScreen(student: student)),
                      );
                    },
                  ),
                  _buildActionCard(
                    context,
                    icon: Icons.group_add,
                    label: 'Unirse a curso',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => JoinCourseScreen(student: student)),
                      );
                    },
                  ),
                  _buildActionCard(
                    context,
                    icon: Icons.class_,
                    label: 'Mis cursos',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => StudentCourseListScreen(student: student)),
                      );
                    },
                  ),
                  _buildActionCard(
                    context,
                    icon: Icons.fact_check,
                    label: 'Asistencia',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => StudentAttendanceRecordsScreen(student: student, course: dummyCourse)),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cerrar sesión'),
        content: const Text('¿Seguro que quiere cerrar sesión?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const RoleSelectionScreen()),
                (route) => false,
              );
            },
            child: const Text('Cerrar sesión'),
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard(BuildContext context, {required IconData icon, required String label, required VoidCallback onTap}) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 36, color: Theme.of(context).colorScheme.primary),
              const SizedBox(height: 12),
              Text(label, textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    );
  }
}

class WebModulePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Módulo Web'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => ReportsScreen()));
              },
              child: const Text('Reportes'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => StatisticsScreen()));
              },
              child: const Text('Estadísticas'),
            ),
          ],
        ),
      ),
    );
  }
}
