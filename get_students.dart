import 'package:flutter_application_1cuadermo/services/mongo_service.dart';
import 'package:flutter_application_1cuadermo/services/student_service.dart';
import 'package:flutter_application_1cuadermo/models/student.dart';

void main() async {
  await MongoService.instance.init();
  final studentService = StudentService();

  print('Obteniendo todos los estudiantes...');
  final students = await studentService.getStudents();

  if (students.isEmpty) {
    print('No se encontraron estudiantes en la base de datos.');
  } else {
    print('Estudiantes encontrados:');
    for (var student in students) {
      print('--------------------');
      print('ID: ${student.id}');
      print('Nombre: ${student.name}');
      print('Apellido: ${student.lastName}');
      print('Email: ${student.email}');
      print('Número de Cuenta: ${student.accountNumber}');
      print('Estado: ${student.status}');
      print('Cursos Inscritos: ${student.courseIds.join(', ')}');
    }
  }

  await MongoService.instance.db.close();
}
