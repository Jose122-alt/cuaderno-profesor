import 'mongo_service.dart';
import '../models/attendance_record.dart';

class AttendanceService {
  Future<void> addAttendanceRecord(AttendanceRecord record) async {
    await MongoService.instance.collection('attendanceRecords').insertOne(record.toMap());
  }

  Future<List<AttendanceRecord>> getAttendanceRecordsByCourseId(int courseId) async {
    final coll = MongoService.instance.collection('attendanceRecords');
    final docs = await coll.find({'course_id': courseId}).toList();
    return docs.map((data) => AttendanceRecord.fromMap(Map<String, dynamic>.from(data))).toList();
  }

  Future<void> updateAttendanceRecord(AttendanceRecord record) async {
    await MongoService.instance.collection('attendanceRecords').updateOne({'id': record.id}, {'\$set': record.toMap()});
  }

  Future<void> deleteAttendanceRecord(int id) async {
    await MongoService.instance.collection('attendanceRecords').deleteOne({'id': id.toString()});
  }
}

extension AttendanceServiceQueries on AttendanceService {
  Future<AttendanceRecord?> getAttendanceRecordByStudentCourseAndDate(int studentId, int courseId, String date) async {
    final coll = MongoService.instance.collection('attendanceRecords');
    final doc = await coll.findOne({'student_id': studentId, 'course_id': courseId, 'date': date});
    if (doc == null) return null;
    return AttendanceRecord.fromMap(Map<String, dynamic>.from(doc));
  }

  Future<List<AttendanceRecord>> getAttendanceRecordsByStudentIdAndCourseId(int studentId, int courseId) async {
    final coll = MongoService.instance.collection('attendanceRecords');
    final docs = await coll.find({'student_id': studentId, 'course_id': courseId}).toList();
    return docs.map((data) => AttendanceRecord.fromMap(Map<String, dynamic>.from(data))).toList();
  }
}
