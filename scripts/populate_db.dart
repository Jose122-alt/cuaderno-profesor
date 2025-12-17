import 'package:mongo_dart/mongo_dart.dart';
import '../lib/models/student.dart';
import '../lib/models/teacher.dart';
import '../lib/models/course.dart';
import '../lib/models/enrollment.dart';
import '../lib/models/activity.dart';
import '../lib/models/evaluation.dart';
import '../lib/models/attendance_record.dart';
import '../lib/models/evidence.dart';
import 'dart:math';

import '../lib/services/student_service.dart';
import '../lib/services/teacher_service.dart';
import '../lib/services/course_service.dart';
import '../lib/services/enrollment_service.dart';
import '../lib/services/activity_service.dart';
import '../lib/services/evaluation_service.dart';
import '../lib/services/attendance_record_service.dart';
import '../lib/services/evidence_service.dart';
import '../lib/services/mongo_service.dart';

// Asegura que los métodos de servicio devuelvan tipos concretos
extension ServiceTypeFix on ActivityService {
  Future<Activity?> addActivityTyped(Activity activity) async => await addActivity(activity) as Activity?;
}
extension EvaluationServiceTypeFix on EvaluationService {
  Future<Evaluation> insertEvaluationTyped(Evaluation evaluation) async => await insertEvaluation(evaluation);
}
extension EvidenceServiceTypeFix on EvidenceService {
  Future<Evidence?> addEvidenceTyped(Evidence evidence) async => await insertEvidence(evidence) as Evidence?;
}



void main() async {
  await MongoService.instance.init(connectionString: 'mongodb://localhost:27017', dbName: 'cuaderno');

  print('Conectado a la base de datos MongoDB.');

  // Initialize services
  final studentService = StudentService();
  final teacherService = TeacherService();
  final courseService = CourseService();
  final enrollmentService = EnrollmentService();
  final activityService = ActivityService();
  final evaluationService = EvaluationService();
  final attendanceRecordService = AttendanceRecordService();
  final evidenceService = EvidenceService();

  // --- Cleanup existing data (optional, but good for fresh start) ---
  print('Limpiando colecciones existentes...');
  await MongoService.instance.collection('students').remove({});
  print('Colección students limpiada.');
  await MongoService.instance.collection('teachers').remove({});
  print('Colección teachers limpiada.');
  await MongoService.instance.collection('courses').remove({});
  print('Colección courses limpiada.');
  await MongoService.instance.collection('enrollments').remove({});
  print('Colección enrollments limpiada.');
  await MongoService.instance.collection('activities').remove({});
  print('Colección activities limpiada.');
  await MongoService.instance.collection('evaluations').remove({});
  print('Colección evaluations limpiada.');
  await MongoService.instance.collection('attendanceRecords').remove({});
  print('Colección attendanceRecords limpiada.');
  await MongoService.instance.collection('evidences').remove({});
  print('Colección evidences limpiada.');
  print('Colecciones limpiadas.');

  // --- Populate Students ---
  print('Poblando estudiantes...');
  final studentsData = [
    {'name': 'Andrea Navarro Gil', 'accountNumber': '8301592'},
    {'name': 'Javier López Núñez', 'accountNumber': '2746108'},
    {'name': 'Carmen Ríos Bravo', 'accountNumber': '4059317'},
    {'name': 'Manuel Ortega Sanz', 'accountNumber': '6192843'},
    {'name': 'Laura Ferrer Díez', 'accountNumber': '9573026'},
  ];
  final List<Student> students = [];
  for (var data in studentsData) {
    final student = await studentService.addStudent(Student(
      name: data['name']!,
      accountNumber: data['accountNumber']!,
      password: 'password123', // Contraseña por defecto
    ));
    students.add(student);
    print('Estudiante añadido: ${student.name}');
  }

  // --- Populate Professors ---
  print('Poblando profesores...');
  final teachersData = [
    {'name': 'Alejandro Vargas Soto', 'accountNumber': '0212355'},
    {'name': 'Sofía Jiménez Torres', 'accountNumber': '9423125'},
    {'name': 'Ricardo Mendoza Castro', 'accountNumber': '5391245'},
    {'name': 'Valentina Ruiz Herrera', 'accountNumber': '3201242'},
    {'name': 'Miguel Ángel Gómez Ponce', 'accountNumber': '6912442'},
  ];
  final List<Teacher> teachers = [];
  for (var data in teachersData) {
    final teacher = await teacherService.addTeacher(Teacher(
      name: data['name']!,
      accountNumber: data['accountNumber']!,
      password: 'password123', // Contraseña por defecto
    ));
    if (teacher != null) {
      teachers.add(teacher);
      print('Profesor añadido: ${teacher.name}');
    }
  }

  // --- Populate Courses ---
  print('Poblando cursos...');
  final List<Course> courses = [];
  if (teachers.isNotEmpty) {
    final course1 = await courseService.insertCourse(Course(
      teacherId: teachers[0].id!,
      courseName: 'Matemáticas Avanzadas',
      courseCode: 'MA101',
      description: 'Curso de matemáticas para estudiantes avanzados.',
    ));
    if (course1 != null) {
      courses.add(course1);
      print('Curso añadido: ${course1.courseName}');
    }

    final course2 = await courseService.insertCourse(Course(
      teacherId: teachers[1].id!,
      courseName: 'Programación Orientada a Objetos',
      courseCode: 'POO202',
      description: 'Principios y prácticas de POO.',
    ));
    if (course2 != null) {
      courses.add(course2);
      print('Curso añadido: ${course2.courseName}');
    }
  }

  // --- Enroll Students in Courses ---
  print('Inscribiendo estudiantes en cursos...');
  if (students.isNotEmpty && courses.isNotEmpty) {
    // Enroll all students in Matemáticas Avanzadas
    for (var student in students) {
      await enrollmentService.insertEnrollment(Enrollment(
        studentId: student.id!,
        courseId: courses[0].id!,
        enrollmentDate: DateTime.now().toIso8601String(),
      ));
      print('Estudiante ${student.name} inscrito en ${courses[0].courseName}');
    }
    // Enroll some students in Programación Orientada a Objetos
    if (students.length >= 2) {
      await enrollmentService.insertEnrollment(Enrollment(
        studentId: students[0].id!,
        courseId: courses[1].id!,
        enrollmentDate: DateTime.now().toIso8601String(),
      ));
      print('Estudiante ${students[0].name} inscrito en ${courses[1].courseName}');
      await enrollmentService.insertEnrollment(Enrollment(
        studentId: students[1].id!,
        courseId: courses[1].id!,
        enrollmentDate: DateTime.now().toIso8601String(),
      ));
      print('Estudiante ${students[1].name} inscrito en ${courses[1].courseName}');
    }
  }

  // --- Populate Activities (including exams) ---
  print('Poblando actividades...');
  final List<Activity> activities = [];
  if (courses.isNotEmpty) {
    // Actividades para Matemáticas Avanzadas (courses[0])
    final activity1 = await activityService.addActivityTyped(Activity(
      courseId: courses[0].id!,
      title: 'Tarea 1: Álgebra Lineal',
      description: 'Resolver ejercicios de álgebra lineal.',
      dueDate: DateTime.now().add(const Duration(days: 7)),
      evaluationCategory: 'portfolio',
    ));
    if (activity1 != null) activities.add(activity1);

    final activity2 = await activityService.addActivityTyped(Activity(
  courseId: courses[0].id!,
  title: 'Examen 1',
  description: 'Primer examen de Matemáticas Avanzadas.',
  dueDate: DateTime.now().add(const Duration(days: 14)),
  evaluationCategory: 'exam', // Categoría de examen
));
if (activity2 != null) activities.add(activity2);

final activity3 = await activityService.addActivityTyped(Activity(
  courseId: courses[0].id!,
  title: 'Examen 2',
  description: 'Segundo examen de Matemáticas Avanzadas.',
  dueDate: DateTime.now().add(const Duration(days: 21)),
  evaluationCategory: 'exam', // Categoría de examen
));
if (activity3 != null) activities.add(activity3);

final activity4 = await activityService.addActivityTyped(Activity(
  courseId: courses[0].id!,
  title: 'Examen 3',
  description: 'Tercer examen de Matemáticas Avanzadas.',
  dueDate: DateTime.now().add(const Duration(days: 35)),
  evaluationCategory: 'exam', // Categoría de examen
));
if (activity4 != null) activities.add(activity4);

    final activity5 = await activityService.addActivityTyped(Activity(
      courseId: courses[0].id!,
      title: 'Proyecto Final',
      description: 'Desarrollar un proyecto aplicando conceptos del curso.',
      dueDate: DateTime.now().add(const Duration(days: 28)),
      evaluationCategory: 'portfolio',
    ));
    if (activity5 != null) activities.add(activity5);

    final activity6 = await activityService.addActivityTyped(Activity(
      courseId: courses[0].id!,
      title: 'Participación en Clase',
      description: 'Evaluación de la participación activa en clase.',
      dueDate: DateTime.now().add(const Duration(days: 30)),
      evaluationCategory: 'complementary',
    ));
    if (activity6 != null) activities.add(activity6);

    // Actividades para Programación Orientada a Objetos (courses[1])
    if (courses.length > 1) {
      final activity5 = await activityService.addActivityTyped(Activity(
        courseId: courses[1].id!,
        title: 'Laboratorio 1: Clases y Objetos',
        description: 'Implementar clases y objetos básicos en Dart.',
        dueDate: DateTime.now().add(const Duration(days: 10)),
        evaluationCategory: 'portfolio',
      ));
      if (activity5 != null) activities.add(activity5);

      final activity6 = await activityService.addActivityTyped(Activity(
        courseId: courses[1].id!,
        title: 'Examen Final POO',
        description: 'Examen final de Programación Orientada a Objetos.',
        dueDate: DateTime.now().add(const Duration(days: 25)),
        evaluationCategory: 'exam', // Categoría de examen
      ));
      if (activity6 != null) activities.add(activity6);
    }
  }

  // --- Populate Evaluations (weights for categories) ---
  print('Poblando evaluaciones (pesos de categorías)...');
  final List<Evaluation> evaluations = [];
  if (courses.isNotEmpty) {
    // Evaluaciones para Matemáticas Avanzadas (courses[0])
    evaluations.add(await evaluationService.insertEvaluationTyped(Evaluation(
      courseId: courses[0].id!.toString(), // courseId es String en Evaluation
      evaluationName: 'Exámenes',
      weight: 0.4,
      category: 'exam',
      maxGrade: 10.0,
      date: DateTime.now().subtract(const Duration(days: 30)),
    )));
    evaluations.add(await evaluationService.insertEvaluationTyped(Evaluation(
      courseId: courses[0].id!.toString(),
      evaluationName: 'Portafolio',
      weight: 0.5,
      category: 'portfolio',
      maxGrade: 10.0,
      date: DateTime.now().subtract(const Duration(days: 30)),
    )));
    evaluations.add(await evaluationService.insertEvaluationTyped(Evaluation(
      courseId: courses[0].id!.toString(),
      evaluationName: 'Participación',
      weight: 0.1,
      category: 'complementary',
      maxGrade: 10.0,
      date: DateTime.now().subtract(const Duration(days: 30)),
    )));

    // Evaluaciones para Programación Orientada a Objetos (courses[1])
    if (courses.length > 1) {
      evaluations.add(await evaluationService.insertEvaluationTyped(Evaluation(
        courseId: courses[1].id!.toString(),
        evaluationName: 'Exámenes',
        weight: 0.5,
        category: 'exam',
        maxGrade: 10.0,
        date: DateTime.now().subtract(const Duration(days: 20)),
      )));
      evaluations.add(await evaluationService.insertEvaluationTyped(Evaluation(
        courseId: courses[1].id!.toString(),
        evaluationName: 'Laboratorios',
        weight: 0.5,
        category: 'portfolio',
        maxGrade: 10.0,
        date: DateTime.now().subtract(const Duration(days: 20)),
      )));
    }
  }

  // --- Record Attendance ---
  print('Registrando asistencia...');
  if (students.isNotEmpty && courses.isNotEmpty) {
    final courseId = courses[0].id!; // Assuming we are populating for the first course

    for (int i = 0; i < 48; i++) {
      final date = DateTime.now().subtract(Duration(days: 60 - i)); // Generate 48 distinct dates
      for (var student in students) {
        await attendanceRecordService.recordAttendance(
          studentId: int.parse(student.id!),
          courseId: courseId,
          date: date,
          status: 'presente',
        );
      }
      print('Asistencia registrada para el día ${date.toIso8601String().split('T')[0]} en ${courses[0].courseName}');
    }
  }

  // --- Populate Evidence (linking to activities) ---
  print('Poblando evidencias...');
  final random = Random();
  if (students.isNotEmpty && activities.isNotEmpty) {
    // Evidencia para Tarea 1 (Matemáticas Avanzadas)
    final tarea1Activity = activities.firstWhere((act) => act.title == 'Tarea 1: Álgebra Lineal') as Activity;
    for (var student in students) {
      final randomGrade = (6.0 + random.nextDouble() * 4.0); // Genera entre 6.0 y 10.0
      await evidenceService.addEvidenceTyped(Evidence(
        studentId: int.parse(student.id!),
        courseId: tarea1Activity.courseId,
        activityId: tarea1Activity.id!,
        description: 'Entrega de Tarea 1 por ${student.name}',
        date: DateTime.now().subtract(const Duration(days: 2)).toIso8601String(),
        grade: double.parse(randomGrade.toStringAsFixed(2)),
        status: 'graded',
        fileUrl: 'http://example.com/tarea1_${student.name.replaceAll(' ', '').toLowerCase()}.pdf',
      ));
    }

    // Evidencia para Examen 1 (Matemáticas Avanzadas)
final examen1Activity = activities.firstWhere((act) => act.title == 'Examen 1') as Activity;

for (var student in students) {
  final randomGrade = (6.0 + random.nextDouble() * 4.0); // Genera entre 6.0 y 10.0
  await evidenceService.addEvidenceTyped(Evidence(
    studentId: int.parse(student.id!),
    courseId: examen1Activity.courseId,
    activityId: examen1Activity.id!,
    description: 'Entrega de Examen 1 por ${student.name}',
    date: DateTime.now().subtract(const Duration(days: 1)).toIso8601String(),
    grade: double.parse(randomGrade.toStringAsFixed(2)),
    status: 'graded',
    fileUrl: 'http://example.com/examen1_${student.name.replaceAll(' ', '').toLowerCase()}.pdf',
  ));
}


    // Evidencia para Examen 2 (Matemáticas Avanzadas)
final examen2Activity = activities.firstWhere((act) => act.title == 'Examen 2') as Activity;

for (var student in students) {
  final randomGrade = (6.0 + random.nextDouble() * 4.0); // Genera entre 6.0 y 10.0
  await evidenceService.addEvidenceTyped(Evidence(
    studentId: int.parse(student.id!),
    courseId: examen2Activity.courseId,
    activityId: examen2Activity.id!,
    description: 'Entrega de Examen 2 por ${student.name}',
    date: DateTime.now().subtract(const Duration(days: 2)).toIso8601String(),
    grade: double.parse(randomGrade.toStringAsFixed(2)),
    status: 'graded',
    fileUrl: 'http://example.com/examen2_${student.name.replaceAll(' ', '').toLowerCase()}.pdf',
  ));
}


    // Evidencia para Examen 3 (Matemáticas Avanzadas)
    final examen3Activity = activities.firstWhere((act) => act.title == 'Examen 3') as Activity;
  
  for (var student in students) {
    final randomGrade = (6.0 + random.nextDouble() * 4.0); // Genera entre 6.0 y 10.0
    await evidenceService.addEvidenceTyped(Evidence(
      studentId: int.parse(student.id!),
      courseId: examen3Activity.courseId,
      activityId: examen3Activity.id!,
      description: 'Entrega de Examen 3 por ${student.name}',
      date: DateTime.now().subtract(const Duration(days: 3)).toIso8601String(),
      grade: double.parse(randomGrade.toStringAsFixed(2)),
      status: 'graded',
      fileUrl: 'http://example.com/examen3_${student.name.replaceAll(' ', '').toLowerCase()}.pdf',
    ));
  }



    // Evidencia para Proyecto Final (Matemáticas Avanzadas)
    final proyectoFinalActivity = activities.firstWhere((act) => act.title == 'Proyecto Final') as Activity;
    for (var student in students) {
      final randomGrade = (6.0 + random.nextDouble() * 4.0); // Genera entre 6.0 y 10.0
      await evidenceService.addEvidenceTyped(Evidence(
        studentId: int.parse(student.id!),
        courseId: proyectoFinalActivity.courseId,
        activityId: proyectoFinalActivity.id!,
        description: 'Entrega de Proyecto Final por ${student.name}',
        date: DateTime.now().subtract(const Duration(days: 1)).toIso8601String(),
        grade: double.parse(randomGrade.toStringAsFixed(2)),
        status: 'graded',
        fileUrl: 'http://example.com/proyecto_${student.name.replaceAll(' ', '').toLowerCase()}.zip',
      ));
    }

    // Evidencia para Participación en Clase (Matemáticas Avanzadas)
    final participacionActivity = activities.firstWhere((act) => act.title == 'Participación en Clase') as Activity;
    for (var student in students) {
      final randomGrade = (6.0 + random.nextDouble() * 4.0); // Genera entre 6.0 y 10.0
      await evidenceService.addEvidenceTyped(Evidence(
        studentId: int.parse(student.id!),
        courseId: participacionActivity.courseId,
        activityId: participacionActivity.id!,
        description: 'Participación activa de ${student.name} en clase',
        date: DateTime.now().subtract(const Duration(days: 5)).toIso8601String(),
        grade: double.parse(randomGrade.toStringAsFixed(2)),
        status: 'graded',
        fileUrl: 'http://example.com/participacion_${student.name.replaceAll(' ', '').toLowerCase()}.pdf',
      ));
    }

    // Evidencia para Laboratorio 1 (Programación Orientada a Objetos)
    if (courses.length > 1) {
      final lab1Activity = activities.firstWhere((act) => act.title == 'Laboratorio 1: Clases y Objetos') as Activity;
      await evidenceService.addEvidenceTyped(Evidence(
        studentId: int.parse(students[0].id!),
        courseId: lab1Activity.courseId, // Añadido
        activityId: lab1Activity.id!,
        description: 'Entrega de Laboratorio 1 por Andrea', // Añadido
        date: DateTime.now().subtract(const Duration(days: 1)).toIso8601String(),
        grade: 9.2 as double?,
        fileUrl: 'http://example.com/lab1_andrea.zip',
      ));
    }

    // Evidencia para Examen Final POO (Programación Orientada a Objetos)
    if (courses.length > 1) {
      final examenFinalPooActivity = activities.firstWhere((act) => act.title == 'Examen Final POO') as Activity;
      await evidenceService.addEvidenceTyped(Evidence(
        studentId: int.parse(students[0].id!),
        courseId: examenFinalPooActivity.courseId, // Añadido
        activityId: examenFinalPooActivity.id!,
        description: 'Entrega de Examen Final POO por Andrea', // Añadido
        date: DateTime.now().toIso8601String(),
        grade: 7.0 as double?,
        fileUrl: 'http://example.com/examen_final_poo_andrea.pdf',
      ));
    }
  }

  print('Base de datos poblada exitosamente.');
  await MongoService.instance.db.close();
  print('Conexión a la base de datos cerrada.');
}
