import 'package:flutter_application_1cuadermo/models/activity.dart';
import 'package:mongo_dart/mongo_dart.dart';
import 'mongo_service.dart';

class ActivityService {

  Future<void> addActivity(Activity activity) async {
    final coll = MongoService.instance.collection('activities');
    final id = ObjectId();
    final doc = activity.toMap();
    doc['_id'] = id;
    doc['id'] = activity.id ?? id.toHexString();
    await coll.insertOne(doc);
  }

  Future<List<Activity>> getActivitiesByCourseId(int courseId) async {
    final coll = MongoService.instance.collection('activities');
    final docs = await coll.find(where.eq('course_id', courseId)).toList();
    return docs.map((data) => Activity.fromMap(Map<String, dynamic>.from(data))).toList();
  }

  Future<Activity?> getActivityById(String id) async {
    final coll = MongoService.instance.collection('activities');
    final List<Map<String, dynamic>> orClauses = [];
    final int? intId = int.tryParse(id);
    if (intId != null) {
      orClauses.add({'id': intId});
    }
    orClauses.add({'id': id});
    if (RegExp(r'^[a-fA-F0-9]{24}$').hasMatch(id)) {
      try {
        orClauses.add({'_id': ObjectId.fromHexString(id)});
      } catch (_) {}
    }
    final query = orClauses.length == 1 ? orClauses.first : {'\$or': orClauses};
    final doc = await coll.findOne(query);
    if (doc == null) return null;
    return Activity.fromMap(Map<String, dynamic>.from(doc));
  }

  Future<void> updateActivity(Activity activity) async {
    final coll = MongoService.instance.collection('activities');
    final String id = activity.id ?? '';
    final List<Map<String, dynamic>> orClauses = [];
    final int? intId = int.tryParse(id);
    if (intId != null) {
      orClauses.add({'id': intId});
    }
    if (id.isNotEmpty) {
      orClauses.add({'id': id});
      if (RegExp(r'^[a-fA-F0-9]{24}$').hasMatch(id)) {
        try {
          orClauses.add({'_id': ObjectId.fromHexString(id)});
        } catch (_) {}
      }
    }
    final query = orClauses.isEmpty ? {'id': activity.id} : (orClauses.length == 1 ? orClauses.first : {'\$or': orClauses});
    await coll.updateOne(query, {'\$set': activity.toMap()});
  }

  Future<void> deleteActivity(String activityId) async {
    final coll = MongoService.instance.collection('activities');
    final List<Map<String, dynamic>> orClauses = [];
    final int? intId = int.tryParse(activityId);
    if (intId != null) {
      orClauses.add({'id': intId});
    }
    orClauses.add({'id': activityId});
    if (RegExp(r'^[a-fA-F0-9]{24}$').hasMatch(activityId)) {
      try {
        orClauses.add({'_id': ObjectId.fromHexString(activityId)});
      } catch (_) {}
    }
    final query = orClauses.length == 1 ? orClauses.first : {'\$or': orClauses};
    await coll.deleteOne(query);
  }
}
