
import 'package:flutter_application_1cuadermo/services/course_service.dart';
import 'package:flutter_application_1cuadermo/services/student_service.dart';
import 'package:flutter_application_1cuadermo/services/attendance_record_service.dart';
import 'package:flutter_application_1cuadermo/services/mongo_service.dart';
import 'package:flutter_application_1cuadermo/services/activity_service.dart';
import 'package:flutter_application_1cuadermo/services/evidence_service.dart';
import 'package:flutter_application_1cuadermo/models/attendance_record.dart';
import 'package:flutter_application_1cuadermo/models/course.dart';
import 'package:flutter_application_1cuadermo/models/student.dart';
import 'package:flutter_application_1cuadermo/models/activity.dart';
import 'package:flutter_application_1cuadermo/models/evidence.dart';
import 'package:mongo_dart/mongo_dart.dart';

void main() async {
  await MongoService.instance.init();

  final courseService = CourseService();
  final studentService = StudentService();
  final attendanceRecordService = AttendanceRecordService();
  final activityService = ActivityService();
  final evidenceService = EvidenceService();

  final String targetCourseName = "topicos avanzados de ingenieria de software";
  Course? targetCourse;

  try {
    final courses = await courseService.getCourses();
    for (var course in courses) {
      if (course.courseName == targetCourseName) {
        targetCourse = course;
        break;
      }
    }

    if (targetCourse == null) {
      print("Error: Course '$targetCourseName' not found.");
      return;
    }

    print("Found course: ${targetCourse.courseName} with ID: ${targetCourse.id}");

    // Clear existing attendance records for this course to avoid duplicates
    // await attendanceRecordService.deleteAttendanceRecordsByCourseId(targetCourse.id!); // Uncomment if you want to clear previous records

    final students = await studentService.getStudentsByCourseId(targetCourse.id!);
    if (students.isEmpty) {
      print("No students found for course '${targetCourse.courseName}'.");
      return;
    }

    print("Found ${students.length} students for course '${targetCourse.courseName}'.");

    // Insert 48 attendance records for each student
    for (var student in students) {
      print("Processing attendance for student: ${student.name} (ID: ${student.id})");
      for (int i = 0; i < 48; i++) {
        final date = DateTime.now().subtract(Duration(days: i)).toIso8601String().split('T')[0];
        final attendanceRecord = AttendanceRecord(
          studentId: int.parse(student.id!), // Assuming student.id is a string that can be parsed to int
          courseId: targetCourse.id!,
          date: date,
          status: 'presente',
          timestamp: DateTime.now(),
        );
        await attendanceRecordService.insertAttendanceRecord(attendanceRecord);
        // print("  Inserted attendance for ${student.name} on $date");
      }
    }
    print("Successfully inserted 48 attendance records for all students in '${targetCourseName}'.");

    // --- Insert Activities and Evidences ---

    // Clear existing activities and evidences for this course
    // await activityService.deleteActivitiesByCourseId(targetCourse.id!); // Uncomment if you want to clear previous records
    // await evidenceService.deleteEvidencesByCourseId(targetCourse.id!); // Uncomment if you want to clear previous records

    // Create sample activities
    final List<Activity> activities = [
      Activity(
        courseId: targetCourse.id!,
        title: 'Examen Parcial 1',
        description: 'Primer examen parcial del curso',
        dueDate: DateTime.now().subtract(Duration(days: 30)),
        evaluationCategory: 'exam',
      ),
      Activity(
        courseId: targetCourse.id!,
        title: 'Tarea 1',
        description: 'Primera tarea del curso',
        dueDate: DateTime.now().subtract(Duration(days: 20)),
        evaluationCategory: 'portfolio',
      ),
      Activity(
        courseId: targetCourse.id!,
        title: 'Proyecto Final',
        description: 'Proyecto final del curso',
        dueDate: DateTime.now().subtract(Duration(days: 10)),
        evaluationCategory: 'complementary',
      ),
    ];

    for (var activity in activities) {
      await activityService.addActivity(activity);
      print("Inserted activity: ${activity.title}");
    }

    final insertedActivities = await activityService.getActivitiesByCourseId(targetCourse.id!); // Get activities with generated IDs

    // Insert evidences with varied grades for each student
    final grades = [10, 7, 5, 8, 9]; // Varied grades for students
    int studentIndex = 0;

    for (var student in students) {
      print("Processing evidences for student: ${student.name} (ID: ${student.id})");
      int activityIndex = 0;
      for (var activity in insertedActivities) {
        final grade = grades[(studentIndex + activityIndex) % grades.length];
        final evidence = Evidence(
          studentId: int.parse(student.id!),
          courseId: targetCourse.id!,
          activityId: activity.id,
          date: DateTime.now().toIso8601String().split('T')[0],
          status: 'graded',
          grade: grade,
          comment: 'Comentario de prueba para ${activity.title}',
          description: 'Descripción de la evidencia para ${activity.title}',
        );
        await evidenceService.insertEvidence(evidence);
        print("  Inserted evidence for ${student.name} - ${activity.title} with grade: $grade");
        activityIndex++;
      }
      studentIndex++;
    }

    print("Successfully inserted activities and evidences for all students.");

  } catch (e) {
    print("An error occurred: $e");
  } finally {
    // await MongoService.instance.close(); // Uncomment if you want to close the connection
  }
}
