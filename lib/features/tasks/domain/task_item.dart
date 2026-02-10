import 'package:loop/features/tasks/domain/task_schedule.dart';

class TaskItem {
  final String id;
  final String label;
  final String module;
  final TaskSchedule schedule;

  const TaskItem({
    required this.id,
    required this.label,
    required this.module,
    required this.schedule,
  });
}
