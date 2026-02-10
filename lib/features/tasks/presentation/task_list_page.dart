import 'package:flutter/material.dart';
import 'package:loop/features/tasks/data/task_repository.dart';
import 'package:loop/features/tasks/domain/task_item.dart';
import 'package:loop/features/tasks/presentation/widgets/task_card.dart';

class TaskListPage extends StatelessWidget {
  final TaskRepository repository;

  const TaskListPage({
    super.key,
    this.repository = const TaskRepository(),
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tasks'),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1F2430),
        elevation: 0,
      ),
      body: FutureBuilder<List<TaskItem>>(
        future: repository.fetchTasks(),
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(child: Text('Failed to load tasks.'));
          }

          final List<TaskItem> tasks = snapshot.data ?? <TaskItem>[];
          if (tasks.isEmpty) {
            return const Center(child: Text('No tasks yet.'));
          }

          return ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            itemCount: tasks.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              return TaskCard(task: tasks[index]);
            },
          );
        },
      ),
    );
  }
}
