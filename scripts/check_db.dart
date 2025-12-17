import 'package:mongo_dart/mongo_dart.dart';
import 'package:flutter_application_1cuadermo/models/activity.dart';
import 'package:flutter_application_1cuadermo/models/evidence.dart';
import 'package:flutter_application_1cuadermo/models/student.dart';
import 'package:flutter_application_1cuadermo/models/teacher.dart';
import 'package:flutter_application_1cuadermo/services/mongo_service.dart';
import 'package:flutter_application_1cuadermo/services/student_service.dart';
import 'package:flutter_application_1cuadermo/services/teacher_service.dart';

void main() async {
  await MongoService.instance.init(connectionString: 'mongodb://localhost:27017', dbName: 'cuaderno');

  print('Conectado a la base de datos MongoDB.');

  final activityCollection = MongoService.instance.collection('activities');
  final evidenceCollection = MongoService.instance.collection('evidences');
  final studentService = StudentService();
  final teacherService = TeacherService();

  print('\n--- Actividades ---');
  final activities = await activityCollection.find().toList();
  if (activities.isEmpty) {
    print('No hay actividades en la base de datos.');
  } else {
    for (var activityMap in activities) {
      final activity = Activity.fromMap(activityMap);
      print('ID: ${activity.id}, Título: ${activity.title}, Categoría: ${activity.evaluationCategory}, DueDate: ${activity.dueDate}, Raw Map: $activityMap');
    }
  }

  print('\n--- Evidencias ---');
  final evidences = await evidenceCollection.find().toList();
  if (evidences.isEmpty) {
    print('No hay evidencias en la base de datos.');
  } else {
    for (var evidenceMap in evidences) {
      final evidence = Evidence.fromMap(evidenceMap);
      print('ID: ${evidence.id}, Estudiante ID: ${evidence.studentId}, Actividad ID: ${evidence.activityId}, Grado: ${evidence.grade}, Estado: ${evidence.status}, Raw Map: $evidenceMap');
    }
  }

  print('\n--- Estudiantes ---');
  final students = await studentService.getStudents();
  if (students.isEmpty) {
    print('No hay estudiantes en la base de datos.');
  } else {
    for (var student in students) {
      print('ID: ${student.id}, Nombre: ${student.name}, Cuenta: ${student.accountNumber}, Estado: ${student.status}');
    }
  }

  print('\n--- Profesores ---');
  final teachers = await teacherService.getTeachers();
  if (teachers.isEmpty) {
    print('No hay profesores en la base de datos.');
  } else {
    for (var teacher in teachers) {
      print('ID: ${teacher.id}, Nombre: ${teacher.name}, Cuenta: ${teacher.accountNumber}, Estado: ${teacher.status}, Contraseña: ${teacher.password}');
    }
  }

  print('\n--- Verificación de contraseña para el profesor 0212355 ---');
  final teacherCollection = MongoService.instance.collection('teachers');
  final rawTeacherDoc = await teacherCollection.findOne({'accountNumber': '0212355'});
  if (rawTeacherDoc != null) {
    print('Documento crudo del profesor 0212355 desde la base de datos: $rawTeacherDoc');
  } else {
    print('Profesor 0212355 no encontrado en la base de datos.');
  }

  print('--- Colecciones en la base de datos ---');
  final collections = await MongoService.instance.db.getCollectionNames();
  if (collections.isEmpty) {
    print('No hay colecciones en la base de datos.');
  } else {
    for (var collectionName in collections) {
      print('Colección: $collectionName');
    }
  }
  print('Conexión a la base de datos cerrada.');
  await MongoService.instance.db.close();
}
