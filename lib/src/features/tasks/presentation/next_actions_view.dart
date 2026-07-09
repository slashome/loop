import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../application/tasks_providers.dart';
import 'task_edit_view.dart';
import 'widgets/task_card.dart';

/// Onglet 1 — Prochaines actions. Cœur de l'app : la liste triée par score.
class NextActionsView extends ConsumerWidget {
  const NextActionsView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final items = ref.watch(nextActionsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Prochaines actions'),
        centerTitle: false,
      ),
      body: items.isEmpty
          ? const Center(child: Text('Rien à faire. 🎉'))
          : ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: items.length,
              itemBuilder: (context, i) {
                final scored = items[i];
                return TaskCard(
                  task: scored.task,
                  score: scored.score,
                  onComplete: () =>
                      ref.read(tasksProvider.notifier).complete(scored.task.id),
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => TaskEditView(taskId: scored.task.id),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
