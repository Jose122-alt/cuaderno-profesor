import 'package:mongo_dart/mongo_dart.dart';
import 'dart:math';
import '../models/enrollment.dart';
import '../models/course.dart';
import 'mongo_service.dart';

class EnrollmentService {

  Future<void> insertEnrollment(Enrollment enrollment) async {
    final coll = MongoService.instance.collection('enrollments');
    final id = ObjectId();
    final doc = enrollment.toMap();
    doc['_id'] = id;
    doc['id'] = id.toHexString();
    await coll.insertOne(doc);
    enrollment.id = doc['id'] as String?;
  }

  Future<List<Enrollment>> getEnrollments() async {
    final coll = MongoService.instance.collection('enrollments');
    final docs = await coll.find().toList();
    return docs.map((data) => Enrollment.fromMap(Map<String, dynamic>.from(data))).toList();
  }

  Future<Enrollment?> getEnrollmentById(String id) async {
    final coll = MongoService.instance.collection('enrollments');
    final doc = await coll.findOne({'id': id});
    if (doc == null) return null;
    return Enrollment.fromMap(Map<String, dynamic>.from(doc));
  }

  Future<List<Enrollment>> getEnrollmentsByStudentId(String studentId) async {
    final coll = MongoService.instance.collection('enrollments');
    final int? sidInt = int.tryParse(studentId);
    final Map<String, dynamic> query = sidInt != null
        ? {
            '\$or': [
              {'student_id': studentId},
              {'student_id': sidInt},
            ]
          }
        : {'student_id': studentId};
    final docs = await coll.find(query).toList();
    return docs.map((data) => Enrollment.fromMap(Map<String, dynamic>.from(data))).toList();
  }

  Future<List<Enrollment>> getEnrollmentsByCourseId(int courseId) async {
    final coll = MongoService.instance.collection('enrollments');
    final docs = await coll.find(where.eq('course_id', courseId)).toList();
    return docs.map((data) => Enrollment.fromMap(Map<String, dynamic>.from(data))).toList();
  }

  Future<void> updateEnrollment(Enrollment enrollment) async {
    await MongoService.instance.collection('enrollments').updateOne({'id': enrollment.id}, {'\$set': enrollment.toMap()});
  }

  Future<void> deleteEnrollment(String id) async {
    await MongoService.instance.collection('enrollments').deleteOne({'id': id});
  }

  Future<Enrollment?> getEnrollmentByStudentIdAndCourseId(String studentId, int courseId) async {
    final coll = MongoService.instance.collection('enrollments');
    final int? sidInt = int.tryParse(studentId);
    final Map<String, dynamic> query = sidInt != null
        ? {
            'course_id': courseId,
            '\$or': [
              {'student_id': studentId},
              {'student_id': sidInt},
            ]
          }
        : {
            'course_id': courseId,
            'student_id': studentId,
          };
    final doc = await coll.findOne(query);
    if (doc == null) return null;
    return Enrollment.fromMap(Map<String, dynamic>.from(doc));
  }

  Future<String> generateCourseCode() async {
    // Generar un código alfanumérico único de 6 caracteres
    const String chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final Random random = Random();
    String code = String.fromCharCodes(Iterable.generate(
        6, (_) => chars.codeUnitAt(random.nextInt(chars.length))));
    return code;
  }

  Future<bool> joinCourse(String studentId, String courseCode) async {
    final courseDoc = await MongoService.instance.collection('courses').findOne({'course_code': courseCode});
    if (courseDoc == null) return false;
    final Course course = Course.fromMap(Map<String, dynamic>.from(courseDoc));

    // Verificar si el estudiante ya está inscrito en el curso
    final existingEnrollment = await getEnrollmentByStudentIdAndCourseId(studentId, course.id!);
    if (existingEnrollment != null) {
      return false; // El estudiante ya está inscrito en este curso
    }

    final Enrollment newEnrollment = Enrollment(
      studentId: studentId,
      courseId: course.id!,
      enrollmentDate: DateTime.now().toIso8601String(),
    );

    await insertEnrollment(newEnrollment);
    return true;
  }
}
