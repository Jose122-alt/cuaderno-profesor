import 'mongo_service.dart';
import 'package:mongo_dart/mongo_dart.dart';
import '../models/evidence.dart';

class EvidenceService {

  Future<void> insertEvidence(Evidence evidence) async {
    final coll = MongoService.instance.collection('evidences');
    final id = ObjectId();
    final doc = evidence.toMap();
    doc['_id'] = id;
    doc['id'] = id.toHexString();
    await coll.insertOne(doc);
  }

  Future<List<Evidence>> getEvidences() async {
    final docs = await MongoService.instance.collection('evidences').find().toList();
    return docs.map((data) => Evidence.fromMap(Map<String, dynamic>.from(data))).toList();
  }

  Future<Evidence?> getEvidenceById(String id) async {
    final doc = await MongoService.instance.collection('evidences').findOne({'id': id});
    if (doc == null) return null;
    return Evidence.fromMap(Map<String, dynamic>.from(doc));
  }

  Future<List<Evidence>> getEvidencesByStudentId(int studentId) async {
    final docs = await MongoService.instance.collection('evidences').find({'student_id': studentId}).toList();
    return docs.map((data) => Evidence.fromMap(Map<String, dynamic>.from(data))).toList();
  }

  Future<List<Evidence>> getEvidencesByCourseId(int courseId) async {
    final docs = await MongoService.instance.collection('evidences').find({'course_id': courseId}).toList();
    return docs.map((data) => Evidence.fromMap(Map<String, dynamic>.from(data))).toList();
  }

  Future<List<Evidence>> getEvidencesByStudentIdAndCourseId(int studentId, int courseId) async {
    final docs = await MongoService.instance.collection('evidences').find({'student_id': studentId, 'course_id': courseId}).toList();
    return docs.map((data) => Evidence.fromMap(Map<String, dynamic>.from(data))).toList();
  }

  Future<List<Evidence>> getEvidencesByActivityId(String activityId) async {
    final docs = await MongoService.instance.collection('evidences').find({'activity_id': activityId}).toList();
    return docs.map((data) => Evidence.fromMap(Map<String, dynamic>.from(data))).toList();
  }

  Future<int> getTotalEvidencesForCourse(int courseId) async {
    return await MongoService.instance.collection('evidences').count({'course_id': courseId});
  }

  Future<int> getStudentSubmittedEvidencesCountForCourse(int studentId, int courseId) async {
    return await MongoService.instance.collection('evidences').count({'student_id': studentId, 'course_id': courseId, 'status': 'submitted'});
  }

  Future<Evidence?> getEvidenceByStudentIdAndActivityId(int studentId, String activityId) async {
    final doc = await MongoService.instance.collection('evidences').findOne({'student_id': studentId, 'activity_id': activityId});
    if (doc == null) return null;
    return Evidence.fromMap(Map<String, dynamic>.from(doc));
  }

  Future<void> updateEvidence(Evidence evidence) async {
    if (evidence.id != null) {
      await MongoService.instance.collection('evidences').updateOne({'id': evidence.id}, {'\$set': evidence.toMap()});
    } else {
      await MongoService.instance.collection('evidences').updateOne(
        {
          'student_id': evidence.studentId,
          'course_id': evidence.courseId,
          'activity_id': evidence.activityId,
        },
        {'\$set': evidence.toMap()},
      );
    }
  }

  Future<void> deleteEvidence(String id) async {
    await MongoService.instance.collection('evidences').deleteOne({'id': id});
  }
}
