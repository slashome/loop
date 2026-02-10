import 'package:flutter/material.dart';
import 'package:loop/features/tasks/domain/task_item.dart';

class TaskCard extends StatelessWidget {
  final TaskItem task;

  const TaskCard({
    super.key,
    required this.task,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: const Color(0xFFF6F7FA),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: ListTile(
        title: Text(
          task.label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Text(
            task.schedule.displayLabel(),
            style: const TextStyle(
              color: Color(0xFF6B7280),
            ),
          ),
        ),
        trailing: Text(
          task.module,
          style: const TextStyle(
            color: Color(0xFF3B82F6),
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
