import 'package:flutter_application_1cuadermo/models/course.dart';
import 'package:flutter_application_1cuadermo/models/student.dart';
import 'package:flutter_application_1cuadermo/models/enrollment.dart';
import 'package:flutter_application_1cuadermo/models/evaluation.dart';
import 'package:flutter_application_1cuadermo/models/evidence.dart';
import 'package:flutter_application_1cuadermo/models/activity.dart'; // Importar el modelo Activity
import 'package:flutter_application_1cuadermo/services/mongo_service.dart';
import 'package:flutter_application_1cuadermo/services/course_service.dart';
import 'package:flutter_application_1cuadermo/services/student_service.dart';
import 'package:flutter_application_1cuadermo/services/enrollment_service.dart';
import 'package:flutter_application_1cuadermo/services/evaluation_service.dart';
import 'package:flutter_application_1cuadermo/services/evidence_service.dart';
import 'package:flutter_application_1cuadermo/services/attendance_record_service.dart';
import 'package:flutter_application_1cuadermo/services/activity_service.dart'; // Importar ActivityService
import 'package:mongo_dart/mongo_dart.dart';
import 'dart:math';

Future<void> main() async {
  await MongoService.instance.init();

  final courseService = CourseService();
  final studentService = StudentService();
  final enrollmentService = EnrollmentService();
  final evaluationService = EvaluationService();
  final evidenceService = EvidenceService();
  final attendanceRecordService = AttendanceRecordService();
  final activityService = ActivityService(); // Inicializar ActivityService

  print('Limpiando colecciones existentes...');
  await MongoService.instance.db.collection('courses').drop();
  await MongoService.instance.db.collection('students').drop();
  await MongoService.instance.db.collection('enrollments').drop();
  await MongoService.instance.db.collection('evaluations').drop();
  await MongoService.instance.db.collection('evidences').drop();
  await MongoService.instance.db.collection('attendanceRecords').drop();
  await MongoService.instance.db.collection('activities').drop(); // Limpiar colección de actividades
  print('Colecciones limpiadas.');

  // 1. Crear un curso
  Course course = Course(
    courseName: 'Matemáticas Avanzadas',
    courseCode: '1',
    teacherId: '2',
    description: 'Curso de matemáticas para estudiantes avanzados.',
  );
  course = await courseService.insertCourse(course);
  print('Curso creado: ${course.courseName}');

  // 2. Crear estudiantes
  final students = [
    Student(name: 'Andrea', lastName: 'Navarro Gil', email: 'andrea.navarro@example.com', password: 'pass123', accountNumber: '8301592'),
    Student(name: 'Javier', lastName: 'López Núñez', email: 'javier.lopez@example.com', password: 'pass123', accountNumber: '2746108'),
    Student(name: 'Carmen', lastName: 'Ríos Bravo', email: 'carmen.rios@example.com', password: 'pass123', accountNumber: '4059317'),
    Student(name: 'Manuel', lastName: 'Ortega Sanz', email: 'manuel.ortega@example.com', password: 'pass123', accountNumber: '6192843'),
    Student(name: 'Laura', lastName: 'Ferrer Díez', email: 'laura.ferrer@example.com', password: 'pass123', accountNumber: '9573026'),
    Student(name: 'Alejandro', lastName: 'Vargas Soto', email: 'alejandro.vargas@example.com', password: 'pass123', accountNumber: '0212355'),
    Student(name: 'Estudiante', lastName: 'Perfecto', email: 'perfecto@example.com', password: 'pass123', accountNumber: '1010101'),
    Student(name: 'Nuevo', lastName: 'Uno', email: 'nuevo.uno@example.com', password: 'pass123', accountNumber: '1111111'),
    Student(name: 'Nuevo', lastName: 'Dos', email: 'nuevo.dos@example.com', password: 'pass123', accountNumber: '2222222'),
    Student(name: 'Nuevo', lastName: 'Tres', email: 'nuevo.tres@example.com', password: 'pass123', accountNumber: '3333333'),
    Student(name: 'Nuevo', lastName: 'Cuatro', email: 'nuevo.cuatro@example.com', password: 'pass123', accountNumber: '4444444'),
    Student(name: 'Nuevo', lastName: 'Cinco', email: 'nuevo.cinco@example.com', password: 'pass123', accountNumber: '5555555'),
  ];
  for (var i = 0; i < students.length; i++) {
    students[i] = await studentService.addStudent(students[i]);
    print('Estudiante creado: ${students[i].name}');
  }

  // 3. Inscribir estudiantes en el curso
  for (var student in students) {
    final enrollment = Enrollment(
      studentId: student.id!,
      courseId: course.id!,
      enrollmentDate: DateTime.now().toIso8601String(),
    );
    await enrollmentService.insertEnrollment(enrollment);
    print('Estudiante ${student.name} inscrito en ${course.courseName}');
  }

  // 4. Crear 48 registros de asistencia para cada estudiante
  print('Creando registros de asistencia...');
  for (var student in students) {
    for (int i = 0; i < 48; i++) {
      final date = DateTime.now().subtract(Duration(days: i));
      await attendanceRecordService.recordAttendance(
        studentId: student.id!,
        courseId: course.id!,
        date: date,
        status: 'presente',
      );
    }
    print('48 registros de asistencia creados para ${student.name}');
  }

  // 5. Crear tres evaluaciones (exámenes)
  final evaluations = <Evaluation>[];
    evaluations.add(await evaluationService.insertEvaluation(Evaluation(
      courseId: course.id!,
      evaluationName: 'Examen Parcial 1',
      weight: 0.3,
      category: 'Parcial',
      maxGrade: 10.0,
      date: DateTime.now().subtract(const Duration(days: 30)),
    )));
    print('Evaluación creada: ${evaluations.last.evaluationName}');

    evaluations.add(await evaluationService.insertEvaluation(Evaluation(
      courseId: course.id!,
      evaluationName: 'Examen Parcial 2',
      weight: 0.3,
      category: 'Parcial',
      maxGrade: 10.0,
      date: DateTime.now().subtract(const Duration(days: 15)),
    )));
    print('Evaluación creada: ${evaluations.last.evaluationName}');

    evaluations.add(await evaluationService.insertEvaluation(Evaluation(
      courseId: course.id!,
      evaluationName: 'Examen Final',
      weight: 0.4,
      category: 'Ordinaria',
      maxGrade: 10.0,
      date: DateTime.now(),
    )));
    print('Evaluación creada: ${evaluations.last.evaluationName}');

  // Crear actividades de tipo 'task'
  final activities = <Activity>[];
  final random = Random();
    activities.add(await activityService.addActivity(Activity(
      courseId: course.id!,
      title: 'Tarea 1',
      description: 'Primera tarea del curso',
      dueDate: DateTime.now().add(const Duration(days: 7)),
    )));
  print('Actividad creada: ${activities.last.title}');

  activities.add(await activityService.addActivity(Activity(
    courseId: course.id!,
    title: 'Tarea 2',
    description: 'Segunda tarea del curso',
    activityType: 'task',
    dueDate: DateTime.now().add(const Duration(days: 14)),
  )));
  print('Actividad creada: ${activities.last.title}');

  activities.add(await activityService.addActivity(Activity(
    courseId: course.id!,
    title: 'Actividad Complementaria',
    description: 'Actividad para puntos extras',
    dueDate: DateTime.now().add(const Duration(days: 21)),
    evaluationCategory: 'complementary',
  )));
  print('Actividad creada: ${activities.last.title}');

  // 5. Crear evidencias para cada estudiante para cada examen y actividad
  for (var student in students) {
    for (var eval in evaluations) {
      final grade = (student.name == 'Estudiante' && student.lastName == 'Perfecto') ? 10 : (random.nextInt(6) + 5);
      final evidence = Evidence(
        studentId: student.id!,
        courseId: course.id!,
        activityId: eval.id!,
        description: 'Evidencia para ${eval.evaluationName}',
        grade: grade,
        status: 'graded',
        date: DateTime.now().toIso8601String(),
      );
      await evidenceService.insertEvidence(evidence);
      print('Evidencia creada para ${student.name} en ${eval.evaluationName} con calificación: $grade');
    }
    for (var activity in activities) {
      final grade = (student.name == 'Estudiante' && student.lastName == 'Perfecto') ? 10 : (random.nextDouble() * 10).round().toInt();
      final evidence = Evidence(
        studentId: student.id!,
        courseId: course.id!,
        activityId: activity.id!,
        description: 'Evidencia para ${activity.title}',
        grade: grade,
        status: 'graded',
        date: DateTime.now().toIso8601String(),
      );
      await evidenceService.insertEvidence(evidence);
      print('Evidencia creada para ${student.name} en ${activity.title} con calificación: $grade');
    }
  }

  print('Base de datos poblada con éxito.');
  await MongoService.instance.db.close();
}
