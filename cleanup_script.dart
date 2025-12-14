import 'lib/services/mongo_service.dart';
import 'lib/services/course_service.dart';
import 'lib/services/activity_service.dart';
import 'lib/models/activity.dart';

Future<void> main() async {
  await MongoService.instance.init();

  final courseService = CourseService();
  final activityService = ActivityService();

  final courses = await courseService.getCourses();
  int? targetCourseId;
  for (var course in courses) {
    if (course.courseName == 'Optativa II (Mineria de datos)') {
      targetCourseId = course.id;
      break;
    }
  }

  if (targetCourseId == null) {
    print('Course "Optativa II (Mineria de datos)" not found.');
  
    return;
  }

  print('Found Course ID: $targetCourseId for "Optativa II (Mineria de datos)"');

  final activities = await activityService.getActivitiesByCourseId(targetCourseId);
  print('Total activities for course: ${activities.length}');

  final Map<String, Activity> uniqueActivities = {};
  final List<Activity> duplicatesToDelete = [];

  for (var activity in activities) {
    if (uniqueActivities.containsKey(activity.title)) {
      duplicatesToDelete.add(activity);
    } else {
      uniqueActivities[activity.title] = activity;
    }
  }

  print('Found ${duplicatesToDelete.length} duplicate activities.');

  for (var duplicate in duplicatesToDelete) {
    if (duplicate.id != null) {
      print('Deleting duplicate activity: ${duplicate.title} (ID: ${duplicate.id})');
      await activityService.deleteActivity(duplicate.id!);
    }
  }

  print('Cleanup complete.');

}
