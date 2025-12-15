import 'package:mongo_dart/mongo_dart.dart';
import '../models/grade.dart';
import 'mongo_service.dart';

class GradeService {

  Future<void> insertGrade(Grade grade) async {
    final coll = MongoService.instance.collection('grades');
    final id = ObjectId();
    final doc = grade.toMap();
    doc['_id'] = id;
    doc['id'] = grade.id ?? id.toHexString();
    await coll.insertOne(doc);
  }

  Future<List<Grade>> getGrades() async {
    final coll = MongoService.instance.collection('grades');
    final docs = await coll.find().toList();
    return docs.map((data) {
      final Map<String, dynamic> gradeData = Map<String, dynamic>.from(data);
      return Grade.fromMap(gradeData);
    }).toList();
  }

  Future<Grade?> getGradeById(String id) async {
    final coll = MongoService.instance.collection('grades');
    final int? idInt = int.tryParse(id);
    ObjectId? idObjId;
    try {
      idObjId = ObjectId.fromHexString(id);
    } catch (_) {
      idObjId = null;
    }
    final query = where.oneFrom('id', [id, if (idInt != null) idInt, if (idObjId != null) idObjId]);
    final doc = await coll.findOne(query);
    if (doc == null) return null;
    return Grade.fromMap(Map<String, dynamic>.from(doc));
  }

  Future<List<Grade>> getGradesByEvaluationId(String evaluationId) async {
    final coll = MongoService.instance.collection('grades');
    final int? evaluationIdInt = int.tryParse(evaluationId);
    final docs = await coll.find(
      where.oneFrom(
        'evaluation_id',
        [evaluationId, if (evaluationIdInt != null) evaluationIdInt],
      ),
    ).toList();
    return docs.map((data) {
      final Map<String, dynamic> gradeData = Map<String, dynamic>.from(data);
      return Grade.fromMap(gradeData);
    }).toList();
  }

  Future<List<Grade>> getGradesByStudentId(String studentId) async {
    final coll = MongoService.instance.collection('grades');
    final int? studentIdInt = int.tryParse(studentId);
    final docs = await coll.find(
      where.oneFrom(
        'student_id',
        [studentId, if (studentIdInt != null) studentIdInt],
      ),
    ).toList();
    return docs.map((data) {
      final Map<String, dynamic> gradeData = Map<String, dynamic>.from(data);
      return Grade.fromMap(gradeData);
    }).toList();
  }

  Future<void> updateGrade(Grade grade) async {
    await MongoService.instance.collection('grades').updateOne({'id': grade.id}, {'\$set': grade.toMap()});
  }

  Future<void> deleteGrade(String id) async {
    await MongoService.instance.collection('grades').deleteOne({'id': id});
  }
}
