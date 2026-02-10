import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:loop/features/tasks/domain/task_item.dart';
import 'package:loop/features/tasks/domain/task_schedule.dart';

class TaskRepository {
  const TaskRepository();

  static const String _fixturesAssetPath = '../fixtures/loops.json';

  Future<List<TaskItem>> fetchTasks() async {
    final String payload = await rootBundle.loadString(_fixturesAssetPath);
    final List<dynamic> rawItems = json.decode(payload) as List<dynamic>;
    return rawItems
        .map((dynamic item) => _taskFromJson(item as Map<String, dynamic>))
        .toList();
  }

  TaskItem _taskFromJson(Map<String, dynamic> json) {
    final String module = (json['module'] as String?) ?? 'unknown';
    final String label = _resolveLabel(json, module);
    final TaskSchedule schedule =
        _resolveSchedule(json['schedule'] as Map<String, dynamic>?);
    final String id = (json['id'] as String?) ?? '';

    return TaskItem(
      id: id,
      label: label,
      module: module,
      schedule: schedule,
    );
  }

  String _resolveLabel(Map<String, dynamic> json, String module) {
    final String? label = json['label'] as String?;
    if (label != null && label.trim().isNotEmpty) {
      return label;
    }

    final Map<String, dynamic>? params =
        json['params'] as Map<String, dynamic>?;
    final dynamic subject = params?['subject'];
    if (module == 'birthday' && subject is String && subject.trim().isNotEmpty) {
      return '$subject birthday';
    }

    return module;
  }

  TaskSchedule _resolveSchedule(Map<String, dynamic>? schedule) {
    final String? type = schedule?['type'] as String?;
    switch (type) {
      case 'time':
        return TaskSchedule.time((schedule?['time'] as String?) ?? '');
      case 'window':
        return TaskSchedule.window(
          (schedule?['start'] as String?) ?? '',
          (schedule?['end'] as String?) ?? '',
        );
      case 'any-day':
      case 'all-day':
        return TaskSchedule.allDay();
      default:
        return TaskSchedule.allDay();
    }
  }
}
