import 'mongo_service.dart';
import 'package:mongo_dart/mongo_dart.dart';
import '../models/student.dart';
 

class StudentService {

  Future<void> addStudent(Student student) async {
    await MongoService.instance.collection('students').insertOne(student.toMap());
  }

  Future<List<Student>> getStudents() async {
    final docs = await MongoService.instance.collection('students').find().toList();
    return docs.map((data) => Student.fromMap(Map<String, dynamic>.from(data))).toList();
  }

  Future<List<Student>> getPendingStudents() async {
    final docs = await MongoService.instance.collection('students').find({'status': 'pending'}).toList();
    return docs.map((data) => Student.fromMap(Map<String, dynamic>.from(data))).toList();
  }

  Future<void> approveStudent(Student student) async {
    await MongoService.instance.collection('students').updateOne({'id': student.id}, {'\$set': {'status': 'approved'}});
  }

  Future<void> restrictStudent(Student student) async {
    await MongoService.instance.collection('students').updateOne({'id': student.id}, {'\$set': {'status': 'restricted'}});
  }

  Future<Student?> getStudentById(String id) async {
    final coll = MongoService.instance.collection('students');
    Map<String, dynamic>? doc = await coll.findOne({'id': id});
    if (doc == null) {
      final intId = int.tryParse(id);
      if (intId != null) {
        doc = await coll.findOne({'id': intId});
      }
    }
    final isHex24 = RegExp(r'^[a-fA-F0-9]{24}$').hasMatch(id);
    if (doc == null && isHex24) {
      try {
        doc = await coll.findOne({'_id': ObjectId.fromHexString(id)});
      } catch (_) {}
    }
    if (doc == null) return null;
    return Student.fromMap(Map<String, dynamic>.from(doc));
  }

  Future<void> updateStudent(Student student) async {
    await MongoService.instance.collection('students').updateOne({'id': student.id}, {'\$set': student.toMap()});
  }

  Future<void> deleteStudent(String id) async {
    await MongoService.instance.collection('students').deleteOne({'id': id});
  }

  Future<List<Student>> getStudentsByCourseId(int courseId) async {
    final enrollDocs = await MongoService.instance.collection('enrollments').find({'course_id': courseId}).toList();
    final rawIds = enrollDocs.map((e) => e['student_id']).toList();
    final stringIds = <String>[];
    final intIds = <int>[];
    final objectIds = <ObjectId>[];
    for (final v in rawIds) {
      if (v is String) {
        stringIds.add(v);
        final int? parsed = int.tryParse(v);
        if (parsed != null) intIds.add(parsed);
        if (RegExp(r'^[a-fA-F0-9]{24}$').hasMatch(v)) {
          try { objectIds.add(ObjectId.fromHexString(v)); } catch (_) {}
        }
      } else if (v is int) {
        intIds.add(v);
        stringIds.add(v.toString());
      } else if (v is ObjectId) {
        stringIds.add(v.oid);
        objectIds.add(v);
      }
    }
    if (stringIds.isEmpty && intIds.isEmpty && objectIds.isEmpty) return [];
    final coll = MongoService.instance.collection('students');
    final orClauses = <Map<String, dynamic>>[];
    if (stringIds.isNotEmpty) { orClauses.add({'id': {'\$in': stringIds}}); }
    if (intIds.isNotEmpty) { orClauses.add({'id': {'\$in': intIds}}); }
    if (objectIds.isNotEmpty) { orClauses.add({'_id': {'\$in': objectIds}}); }
    final query = orClauses.length == 1 ? orClauses.first : {'\$or': orClauses};
    final students = await coll.find(query).toList();
    return students.map((data) => Student.fromMap(Map<String, dynamic>.from(data))).toList();
  }

  Future<int> getTotalClassesForStudentInCourse(String studentId, int courseId) async {
    final docs = await MongoService.instance.collection('attendanceRecords').find({'student_id': studentId, 'course_id': courseId}).toList();
    final Set<String> uniqueDates = docs.map((doc) => (doc['date'] as String)).toSet();
    return uniqueDates.length;
  }

  Future<Map<String, int>> getStudentAttendanceInCourse(String studentId, int courseId) async {
    final docs = await MongoService.instance.collection('attendanceRecords').find({'student_id': studentId, 'course_id': courseId}).toList();

    int present = 0;
    int justified = 0;
    int absent = 0;
    int late = 0;

    for (var record in docs) {
      final status = record['status'] as String;
      switch (status) {
        case 'A':
          present++;
          break;
        case 'J':
          justified++;
          break;
        case 'F':
          absent++;
          break;
        case 'R':
          late++;
          break;
      }
    }

    // Convert 3 lates to 1 absent
    absent += (late ~/ 3);
    late = late % 3;

    return {
      'present': present,
      'justified': justified,
      'absent': absent,
      'late': late,
    };
  }

  Future<int> getTotalEvidencesForCourse(int courseId) async {
    final count = await MongoService.instance.collection('evidences').count({'course_id': courseId});
    return count;
  }

  Future<int> getSubmittedEvidencesForStudentInCourse(int studentId, int courseId) async {
    final count = await MongoService.instance.collection('evidences').count({'student_id': studentId, 'course_id': courseId, 'status': <String, dynamic>{r'$in': ['submitted', 'entregado_retraso']}});
    return count;
  }

  Future<Student?> getStudentByAccountNumber(String accountNumber) async {
    final coll = MongoService.instance.collection('students');
    final doc = await coll.findOne({'accountNumber': accountNumber});
    if (doc == null) return null;
    if (doc['id'] == null) {
      final last = await coll.find(where.sortBy('id', descending: true)).toList();
      final nextId = (last.isNotEmpty && last.first['id'] is int) ? (last.first['id'] as int) + 1 : 1;
      await coll.updateOne({'accountNumber': accountNumber}, {'\$set': {'id': nextId}});
      doc['id'] = nextId;
    }
    return Student.fromMap(Map<String, dynamic>.from(doc));
  }
}
