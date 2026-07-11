import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../application/tasks_providers.dart';
import '../domain/task.dart';
import '../domain/task_filters.dart';
import 'task_edit_view.dart';
import 'widgets/task_card.dart';

const Map<TaskView, String> _viewLabels = {
  TaskView.aFaire: 'À faire',
  TaskView.enRetard: 'En retard',
  TaskView.datees: 'Datées',
  TaskView.aVenir: 'À venir',
};

/// Onglet 1 — Prochaines actions. Cœur de l'app : la liste triée par score.
class NextActionsView extends ConsumerWidget {
  const NextActionsView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(nextActionsProvider);
    final view = ref.watch(viewProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Prochaines actions'),
        centerTitle: false,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute<void>(builder: (_) => const TaskEditView()),
        ),
        child: const Icon(Icons.add),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _ViewBar(),
          if (view == TaskView.aFaire)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 4),
              child: Text(
                'urgences + backlog',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
            ),
          Expanded(
            child: async.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Erreur : $e')),
              data: (items) => items.isEmpty
                  ? const Center(child: Text('Rien à afficher.'))
                  : ListView.builder(
                      padding: const EdgeInsets.only(top: 4, bottom: 8),
                      itemCount: items.length,
                      itemBuilder: (context, i) {
                        final scored = items[i];
                        return TaskCard(
                          task: scored.task,
                          score: scored.score,
                          onComplete: () => ref
                              .read(taskRepositoryProvider)
                              .complete(scored.task.id),
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (_) => TaskEditView(task: scored.task),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Sélecteur de vue (Smart Lists) : chips mono-sélection avec compteurs.
class _ViewBar extends ConsumerWidget {
  const _ViewBar();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final view = ref.watch(viewProvider);
    final tasks = ref.watch(tasksProvider).valueOrNull ?? const <Task>[];
    final now = DateTime.now();

    return SizedBox(
      height: 48,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          for (final v in TaskView.values)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ChoiceChip(
                label: Text(
                  '${_viewLabels[v]} (${tasksForView(tasks, v, now).length})',
                ),
                selected: view == v,
                showCheckmark: false,
                onSelected: (_) => ref.read(viewProvider.notifier).state = v,
              ),
            ),
        ],
      ),
    );
  }
}
