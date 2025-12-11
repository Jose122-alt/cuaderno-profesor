import 'package:mongo_dart/mongo_dart.dart';
import 'mongo_service.dart';
import '../models/attendance_record.dart';

class AttendanceRecordService {

  Future<void> insertAttendanceRecord(AttendanceRecord record) async {
    final coll = MongoService.instance.collection('attendanceRecords');
    final id = ObjectId();
    final doc = record.toMap();
    doc['_id'] = id;
    doc['id'] = id.toHexString();
    await coll.insertOne(doc);
    record.id = doc['id'] as String?;
  }

  Future<List<AttendanceRecord>> getAttendanceRecords() async {
    final coll = MongoService.instance.collection('attendanceRecords');
    final docs = await coll.find().toList();
    return docs.map((data) => AttendanceRecord.fromMap(Map<String, dynamic>.from(data))).toList();
  }

  Future<AttendanceRecord?> getAttendanceRecordById(String id) async {
    final coll = MongoService.instance.collection('attendanceRecords');
    final doc = await coll.findOne({'id': id});
    if (doc == null) return null;
    return AttendanceRecord.fromMap(Map<String, dynamic>.from(doc));
  }

  Future<List<AttendanceRecord>> getAttendanceRecordsByStudentId(int studentId) async {
    final coll = MongoService.instance.collection('attendanceRecords');
    final docs = await coll.find({'student_id': studentId}).toList();
    return docs.map((data) => AttendanceRecord.fromMap(Map<String, dynamic>.from(data))).toList();
  }

  Future<List<AttendanceRecord>> getAttendanceRecordsByCourseId(int courseId) async {
    final coll = MongoService.instance.collection('attendanceRecords');
    final docs = await coll.find(where.eq('course_id', courseId)).toList();
    return docs.map((data) => AttendanceRecord.fromMap(Map<String, dynamic>.from(data))).toList();
  }

  Future<List<AttendanceRecord>> getAttendanceRecordsByStudentIdAndCourseId(int studentId, int courseId) async {
    final coll = MongoService.instance.collection('attendanceRecords');
    final docs = await coll.find({'student_id': studentId, 'course_id': courseId}).toList();
    return docs.map((data) => AttendanceRecord.fromMap(Map<String, dynamic>.from(data))).toList();
  }

  Future<AttendanceRecord?> getAttendanceRecordByStudentCourseAndDate(int studentId, int courseId, String date) async {
    final coll = MongoService.instance.collection('attendanceRecords');
    final doc = await coll.findOne({'student_id': studentId, 'course_id': courseId, 'date': date});
    if (doc == null) return null;
    return AttendanceRecord.fromMap(Map<String, dynamic>.from(doc));
  }

  Future<void> updateAttendanceRecord(AttendanceRecord record) async {
    final coll = MongoService.instance.collection('attendanceRecords');
    if (record.id == null) return;
    await coll.updateOne({'id': record.id}, {'\$set': record.toMap()});
  }

  Future<void> deleteAttendanceRecord(String id) async {
    final coll = MongoService.instance.collection('attendanceRecords');
    await coll.deleteOne({'id': id});
  }

  Future<void> recordAttendance(int studentId, int courseId, String date, String status) async {
    final coll = MongoService.instance.collection('attendanceRecords');
    final existing = await coll.findOne({'student_id': studentId, 'course_id': courseId, 'date': date});
    if (existing != null) {
      await coll.updateOne({'student_id': studentId, 'course_id': courseId, 'date': date}, {'\$set': {'status': status}});
    } else {
      final newRecord = AttendanceRecord(studentId: studentId, courseId: courseId, date: date, status: status);
      await insertAttendanceRecord(newRecord);
    }
  }

  Future<int> getTotalClassesForCourse(int courseId) async {
    final coll = MongoService.instance.collection('attendanceRecords');
    final docs = await coll.find({'course_id': courseId}).toList();
    final Set<String> uniqueDates = docs.map((doc) => doc['date'] as String).toSet();
    return uniqueDates.length;
  }

  Future<int> getStudentAttendanceCountForCourse(int studentId, int courseId) async {
    final coll = MongoService.instance.collection('attendanceRecords');
    final count = await coll.count({'student_id': studentId, 'course_id': courseId, 'status': 'present'});
    return count;
  }
}
