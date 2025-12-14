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

  Future<List<AttendanceRecord>> getAttendanceRecordsByStudentCourseAndDate(int studentId, int courseId, DateTime date) async {
    final coll = MongoService.instance.collection('attendanceRecords');
    final dateString = date.toIso8601String().split('T')[0];
    final docs = await coll.find({'student_id': studentId, 'course_id': courseId, 'date': dateString}).toList();
    return docs.map((data) => AttendanceRecord.fromMap(Map<String, dynamic>.from(data))).toList();
  }

  Future<void> recordAttendance({
    required int studentId,
    required int courseId,
    required DateTime date,
    required String status,
  }) async {
    print('DEBUG: recordAttendance called with studentId: $studentId, courseId: $courseId, date: $date, status: $status (Inserting new record with timestamp)');
    final coll = MongoService.instance.collection('attendanceRecords');
    final dateString = date.toIso8601String().split('T')[0]; // Convert DateTime to YYYY-MM-DD string
    print('DEBUG: dateString for new record: $dateString');
    final newRecord = AttendanceRecord(
        studentId: studentId, courseId: courseId, date: dateString, status: status, timestamp: DateTime.now());
    await insertAttendanceRecord(newRecord);
    print('DEBUG: New attendance record inserted with timestamp: ${newRecord.timestamp}');
  }

  Future<int> getTotalClassesForCourse(int courseId) async {
    print('DEBUG: getTotalClassesForCourse called for courseId: $courseId');
    final coll = MongoService.instance.collection('attendanceRecords');
    final docs = await coll.find({'course_id': courseId}).toList();
    final Set<String> uniqueDates = docs.map((doc) => doc['date'] as String).toSet();
    print('DEBUG: getTotalClassesForCourse - uniqueDates count for courseId $courseId: ${uniqueDates.length}');
    return uniqueDates.length;
  }

  Future<int> getStudentAttendanceCountForCourse(int studentId, int courseId) async {
    print('DEBUG: getStudentAttendanceCountForCourse called for studentId: $studentId, courseId: $courseId');
    final coll = MongoService.instance.collection('attendanceRecords');
    final docs = await coll.find({'student_id': studentId, 'course_id': courseId, 'status': 'present'}).toList();
    final Set<String> uniquePresentDates = docs.map((doc) => doc['date'] as String).toSet();
    print('DEBUG: getStudentAttendanceCountForCourse - unique present dates count for studentId $studentId, courseId $courseId: ${uniquePresentDates.length}');
    return uniquePresentDates.length;
  }

  Future<Map<String, int>> getStudentDailyAttendanceSummaryForCourse(int studentId, int courseId) async {
    print('DEBUG: getStudentDailyAttendanceSummaryForCourse - Function called for studentId: $studentId, courseId: $courseId');
    final coll = MongoService.instance.collection('attendanceRecords');
    final docs = await coll.find({'student_id': studentId, 'course_id': courseId}).toList();

    print('DEBUG: getStudentDailyAttendanceSummaryForCourse - Fetched ${docs.length} raw documents.');
    final Map<String, List<AttendanceRecord>> recordsByDate = {};
    for (var doc in docs) {
      final record = AttendanceRecord.fromMap(Map<String, dynamic>.from(doc));
      final dateString = record.date;
      recordsByDate.putIfAbsent(dateString, () => []).add(record);
    }
    print('DEBUG: getStudentDailyAttendanceSummaryForCourse - Records grouped by date: ${recordsByDate.length} unique dates.');

    final Map<String, int> summary = {
      'present': 0,
      'absent': 0,
      'late': 0,
      'justified': 0,
    };

    recordsByDate.forEach((date, records) {
        if (records.isNotEmpty) {
          records.sort((a, b) => (b.timestamp ?? DateTime(0)).compareTo(a.timestamp ?? DateTime(0))); // Sort by latest timestamp, treating nulls as earliest
          final latestStatus = records.first.status;
          print('DEBUG: getStudentDailyAttendanceSummaryForCourse - Date: $date, Latest Status: $latestStatus');
          if (summary.containsKey(latestStatus)) {
            summary[latestStatus] = (summary[latestStatus] ?? 0) + 1;
          } else {
            print('DEBUG: getStudentDailyAttendanceSummaryForCourse - Unknown status encountered: $latestStatus');
          }
        } else {
          print('DEBUG: getStudentDailyAttendanceSummaryForCourse - Empty records list for date: $date (should not happen)');
        }
    });
    print('DEBUG: getStudentDailyAttendanceSummaryForCourse - summary for studentId $studentId, courseId $courseId: $summary');
    return summary;
  }
}
