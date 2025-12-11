import 'package:flutter/material.dart';
import 'package:flutter_application_1cuadermo/models/student.dart';
import 'package:flutter_application_1cuadermo/models/teacher.dart';
import 'package:flutter_application_1cuadermo/services/student_service.dart';
import 'package:flutter_application_1cuadermo/services/teacher_service.dart';
import 'package:flutter_application_1cuadermo/role_selection_screen.dart';

class AdminModulePage extends StatefulWidget {
  const AdminModulePage({super.key});

  @override
  State<AdminModulePage> createState() => _AdminModulePageState();
}

class _AdminModulePageState extends State<AdminModulePage> {
  final TeacherService _teacherService = TeacherService();
  final StudentService _studentService = StudentService();

  List<Teacher> _pendingTeachers = [];
  List<Student> _pendingStudents = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadPendingUsers();
  }

  Future<void> _loadPendingUsers() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      // Assuming a method to get pending teachers/students exists or will be created
      _pendingTeachers = await _teacherService.getPendingTeachers();
      _pendingStudents = await _studentService.getPendingStudents();
    } catch (e) {
      _errorMessage = 'Error al cargar usuarios pendientes: ${e.toString()}';
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _approveTeacher(Teacher teacher) async {
    try {
      await _teacherService.approveTeacher(teacher);
      _loadPendingUsers(); // Reload lists after approval
    } catch (e) {
      setState(() {
        _errorMessage = 'Error al aprobar profesor: ${e.toString()}';
      });
    }
  }

  Future<void> _restrictTeacher(Teacher teacher) async {
    try {
      await _teacherService.restrictTeacher(teacher);
      _loadPendingUsers(); // Reload lists after restriction
    } catch (e) {
      setState(() {
        _errorMessage = 'Error al restringir profesor: ${e.toString()}';
      });
    }
  }

  Future<void> _approveStudent(Student student) async {
    try {
      await _studentService.approveStudent(student);
      _loadPendingUsers(); // Reload lists after approval
    } catch (e) {
      setState(() {
        _errorMessage = 'Error al aprobar estudiante: ${e.toString()}';
      });
    }
  }

  Future<void> _restrictStudent(Student student) async {
    try {
      await _studentService.restrictStudent(student);
      _loadPendingUsers(); // Reload lists after restriction
    } catch (e) {
      setState(() {
        _errorMessage = 'Error al restringir estudiante: ${e.toString()}';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Panel de Administración'),
        centerTitle: true,
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.people_alt),
            onPressed: () => _showAllTeachers(),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _confirmLogout(),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(
                  child: Text(
                    _errorMessage!,
                    style: const TextStyle(color: Colors.red, fontSize: 16),
                  ),
                )
              : Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Solicitudes Pendientes de Profesores',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 10),
                      Expanded(
                        child: _pendingTeachers.isEmpty
                            ? const Center(child: Text('No hay profesores pendientes.'))
                            : ListView.builder(
                                itemCount: _pendingTeachers.length,
                                itemBuilder: (context, index) {
                                  final teacher = _pendingTeachers[index];
                                  return Card(
                                    margin: const EdgeInsets.symmetric(vertical: 8.0),
                                    child: ListTile(
                                      title: Text(teacher.name),
                                      subtitle: Text('Cuenta: ${teacher.accountNumber}'),
                                      trailing: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          IconButton(
                                            icon: const Icon(Icons.check_circle, color: Colors.green),
                                            onPressed: () => _approveTeacher(teacher),
                                          ),
                                          IconButton(
                                            icon: const Icon(Icons.cancel, color: Colors.red),
                                            onPressed: () => _restrictTeacher(teacher),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Solicitudes Pendientes de Estudiantes',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 10),
                      Expanded(
                        child: _pendingStudents.isEmpty
                            ? const Center(child: Text('No hay estudiantes pendientes.'))
                            : ListView.builder(
                                itemCount: _pendingStudents.length,
                                itemBuilder: (context, index) {
                                  final student = _pendingStudents[index];
                                  return Card(
                                    margin: const EdgeInsets.symmetric(vertical: 8.0),
                                    child: ListTile(
                                      title: Text(student.name),
                                      subtitle: Text('Cuenta: ${student.accountNumber}'),
                                      trailing: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          IconButton(
                                            icon: const Icon(Icons.check_circle, color: Colors.green),
                                            onPressed: () => _approveStudent(student),
                                          ),
                                          IconButton(
                                            icon: const Icon(Icons.cancel, color: Colors.red),
                                            onPressed: () => _restrictStudent(student),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                      ),
                    ],
                ),
              ),
    );
  }

  void _showAllTeachers() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) {
        return SafeArea(
          child: SizedBox(
            height: MediaQuery.of(ctx).size.height * 0.8,
            child: FutureBuilder<List<Teacher>>(
              future: _teacherService.getTeachers(),
              builder: (context, snapshot) {
                if (snapshot.connectionState != ConnectionState.done) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                final items = snapshot.data ?? [];
                if (items.isEmpty) {
                  return const Center(child: Text('No hay profesores registrados.'));
                }
                return ListView.builder(
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final t = items[index];
                    return ListTile(
                      title: Text(t.name),
                      subtitle: Text('Cuenta: ${t.accountNumber} | Estado: ${t.status}'),
                    );
                  },
                );
              },
            ),
          ),
        );
      },
    );
  }

  void _confirmLogout() {
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
