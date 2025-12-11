import 'package:flutter/material.dart';
import 'package:flutter_application_1cuadermo/models/activity.dart';
import 'package:flutter_application_1cuadermo/models/course.dart';
import 'package:flutter_application_1cuadermo/services/activity_service.dart';
import 'package:flutter_application_1cuadermo/models/student.dart';
import 'package:flutter_application_1cuadermo/screens/student_activity_details_screen.dart';

class StudentActivityListScreen extends StatefulWidget {
  final Course course;
  final Student student;

  const StudentActivityListScreen({super.key, required this.course, required this.student});

  @override
  State<StudentActivityListScreen> createState() => _StudentActivityListScreenState();
}

class _StudentActivityListScreenState extends State<StudentActivityListScreen> {
  final ActivityService _activityService = ActivityService();
  List<Activity> _activities = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadActivities();
  }

  Future<void> _loadActivities() async {
    setState(() {
      _isLoading = true;
    });
    _activities = await _activityService.getActivitiesByCourseId(widget.course.id!);
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Actividades de ${widget.course.courseName}'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _activities.isEmpty
              ? const Center(child: Text('No hay actividades para este curso.'))
              : ListView.builder(
                  itemCount: _activities.length,
                  itemBuilder: (context, index) {
                    final activity = _activities[index];
                    return Card(
                      margin: const EdgeInsets.all(8.0),
                      child: ListTile(
                      title: Text(activity.title),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Descripción: ${activity.description}'),
                          if (activity.activityType == 'task')
                            Text('Fecha de Cierre: ${activity.dueDate.toLocal().toString().split(' ')[0]}'),
                          if (activity.fileUrl != null)
                            Text('Archivo: ${activity.fileUrl!.split('/').last}'),
                        ],
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => StudentActivityDetailsScreen(activity: activity, student: widget.student),
                          ),
                        );
                      },
                    ),
                    );
                  },
                ),
    );
  }
}
