import 'mongo_service.dart';
import 'package:mongo_dart/mongo_dart.dart';
import '../models/teacher.dart';

class TeacherService {

  Future<Teacher> addTeacher(Teacher teacher) async {
    final coll = MongoService.instance.collection('teachers');
    final doc = teacher.toMap();
    final last = await coll.find(where.sortBy('id', descending: true)).toList();
    final nextId = (last.isNotEmpty && last.first['id'] is int) ? (last.first['id'] as int) + 1 : 1;
    doc['id'] = doc['id'] ?? nextId;
    await coll.insertOne(doc);
    return Teacher.fromMap(Map<String, dynamic>.from(doc));
  }

  Future<List<Teacher>> getTeachers() async {
    final docs = await MongoService.instance.collection('teachers').find().toList();
    return docs.map((data) => Teacher.fromMap(Map<String, dynamic>.from(data))).toList();
  }

  Future<List<Teacher>> getPendingTeachers() async {
    final docs = await MongoService.instance.collection('teachers').find({'status': 'pending'}).toList();
    return docs.map((data) => Teacher.fromMap(Map<String, dynamic>.from(data))).toList();
  }

  Future<void> approveTeacher(Teacher teacher) async {
    await MongoService.instance.collection('teachers').updateOne({'id': teacher.id}, {'\$set': {'status': 'approved'}});
  }

  Future<void> restrictTeacher(Teacher teacher) async {
    await MongoService.instance.collection('teachers').updateOne({'id': teacher.id}, {'\$set': {'status': 'restricted'}});
  }

  Future<Teacher?> getTeacherById(int id) async {
    final doc = await MongoService.instance.collection('teachers').findOne({'id': id});
    if (doc == null) return null;
    return Teacher.fromMap(Map<String, dynamic>.from(doc));
  }

  Future<Teacher?> getTeacherByAccountNumber(String accountNumber) async {
    final coll = MongoService.instance.collection('teachers');
    final doc = await coll.findOne({'accountNumber': accountNumber});
    if (doc == null) return null;
    if (doc['id'] == null) {
      final last = await coll.find(where.sortBy('id', descending: true)).toList();
      final nextId = (last.isNotEmpty && last.first['id'] is int) ? (last.first['id'] as int) + 1 : 1;
      await coll.updateOne({'accountNumber': accountNumber}, {'\$set': {'id': nextId}});
      doc['id'] = nextId;
    }
    return Teacher.fromMap(Map<String, dynamic>.from(doc));
  }

  Future<int> updateTeacher(Teacher teacher) async {
    await MongoService.instance.collection('teachers').updateOne({'id': teacher.id}, {'\$set': teacher.toMap()});
    return 1;
  }

  Future<int> deleteTeacher(int id) async {
    await MongoService.instance.collection('teachers').deleteOne({'id': id});
    return 1;
  }
}
