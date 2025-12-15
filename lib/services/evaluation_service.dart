import 'package:mongo_dart/mongo_dart.dart';
import '../models/evaluation.dart';
import 'mongo_service.dart';
class EvaluationService{
    Future <Evaluation> insertEvaluation(Evaluation evaluation) async {
        final coll = MongoService.instance.collection('evaluations');
        final id = ObjectId();
        final doc = evaluation.toMap();
        doc['_id'] = id;
        doc['id'] = evaluation.id ?? id.toHexString();
        await coll.insertOne(doc);
        return evaluation.copyWith(id: doc['id'] as String?);
        }
        Future<List<Evaluation>> getEvaluations() async {
        final coll = MongoService.instance.collection('evaluations');
        final docs = await coll.find().toList();
        return docs.map((data) {
        final Map<String, dynamic> evaluationData = Map<String, dynamic>.from(data);
        if (evaluationData['course_id'] != null) {
        evaluationData['course_id'] = evaluationData['course_id'].toString();
        }
        return Evaluation.fromMap(evaluationData);
        }).toList();
        }
        Future<Evaluation?> getEvaluationById(String id) async {
        final coll = MongoService.instance.collection('evaluations');
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
        return Evaluation.fromMap(Map<String, dynamic>.from(doc));
        }
        Future<List<Evaluation>> getEvaluationsByCourseId(String courseId) async {
        final coll = MongoService.instance.collection('evaluations');
        final int? courseIdInt = int.tryParse(courseId);
        final docs = await coll.find( where.oneFrom( 'course_id', [courseId, if (courseIdInt != null) courseIdInt],),).toList(); 
        return docs.map((data) {
        final Map<String, dynamic> evaluationData = Map<String, dynamic>.from(data);
        if (evaluationData['course_id'] != null) 
        {
          evaluationData['course_id'] = evaluationData['course_id'].toString();
          } 
          return Evaluation.fromMap(evaluationData);}).toList();}
          Future<void> updateEvaluation(Evaluation evaluation) async {
          await MongoService.instance.collection('evaluations').updateOne({'id': evaluation.id}, {'\$set': evaluation.toMap()});}
          Future<void> deleteEvaluation(String id) async {
          await MongoService.instance.collection('evaluations').deleteOne({'id': id});
          }
        }