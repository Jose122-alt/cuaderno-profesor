import 'package:mongo_dart/mongo_dart.dart';
import '../models/course.dart';
import 'mongo_service.dart';

class CourseService {

  Future<void> insertCourse(Course course) async {
    final coll = MongoService.instance.collection('courses');
    final id = ObjectId();
    final doc = course.toMap();
    final last = await coll.find(where.sortBy('id', descending: true)).toList();
    final nextId = (last.isNotEmpty && last.first['id'] is int) ? (last.first['id'] as int) + 1 : 1;
    doc['_id'] = id;
    doc['id'] = course.id ?? nextId;
    await coll.insertOne(doc);
  }

  Future<List<Course>> getCourses() async {
    final coll = MongoService.instance.collection('courses');
    final docs = await coll.find().toList();
    return docs.map((data) => Course.fromMap(Map<String, dynamic>.from(data))).toList();
  }

  Future<Course?> getCourseById(int id) async {
    final coll = MongoService.instance.collection('courses');
    final doc = await coll.findOne({'id': id});
    if (doc == null) return null;
    return Course.fromMap(Map<String, dynamic>.from(doc));
  }

  Future<List<Course>> getCoursesByTeacherId(int teacherId) async {
    final coll = MongoService.instance.collection('courses');
    final docs = await coll.find(where.eq('teacher_id', teacherId)).toList();
    return docs.map((data) => Course.fromMap(Map<String, dynamic>.from(data))).toList();
  }

  Future<List<Course>> getCoursesByStudentId(int studentId) async {
    final enrollColl = MongoService.instance.collection('enrollments');
    final enrollmentDocs = await enrollColl.find({
      '\$or': [
        {'student_id': studentId},
        {'student_id': studentId.toString()},
      ]
    }).toList();
    final courseIds = enrollmentDocs.map((e) => (e['course_id'] as int)).toList();
    if (courseIds.isEmpty) return [];
    final courseColl = MongoService.instance.collection('courses');
    final courses = await courseColl.find({'id': { '\$in': courseIds }}).toList();
    return courses.map((data) => Course.fromMap(Map<String, dynamic>.from(data))).toList();
  }

  Future<void> updateCourse(Course course) async {
    await MongoService.instance.collection('courses').updateOne({'id': course.id}, {'\$set': course.toMap()});
  }

  Future<void> deleteCourse(int id) async {
    await MongoService.instance.collection('courses').deleteOne({'id': id});
  }
}
