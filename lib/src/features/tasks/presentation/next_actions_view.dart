import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../application/tasks_providers.dart';
import '../domain/task.dart';
import '../domain/task_filters.dart';
import 'task_edit_view.dart';
import 'widgets/task_card.dart';

const Map<TaskNature, String> _natureLabels = {
  TaskNature.noDate: 'Sans date',
  TaskNature.dated: 'Datée',
  TaskNature.recurring: 'Récurrente',
};

const Map<TaskState, String> _stateLabels = {
  TaskState.overdue: 'En retard',
  TaskState.today: 'Aujourd\'hui',
  TaskState.upcoming: 'À venir',
};

/// Onglet 1 — Prochaines actions. Cœur de l'app : la liste triée par score.
class NextActionsView extends ConsumerWidget {
  const NextActionsView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(nextActionsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Prochaines actions'),
        centerTitle: false,
      ),
      body: Column(
        children: [
          const _FilterBar(),
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

/// Barre de chips à facettes (Nature / État) avec compteurs.
class _FilterBar extends ConsumerWidget {
  const _FilterBar();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filter = ref.watch(filterProvider);
    final tasks = ref.watch(tasksProvider).valueOrNull ?? const <Task>[];
    final now = DateTime.now();
    final notifier = ref.read(filterProvider.notifier);

    return SizedBox(
      height: 48,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          for (final n in TaskNature.values)
            _chip(
              label: _natureLabels[n]!,
              count: countByNature(tasks, filter, now, n),
              selected: filter.natures.contains(n),
              onTap: () => notifier.toggleNature(n),
            ),
          const _Separator(),
          for (final s in TaskState.values)
            _chip(
              label: _stateLabels[s]!,
              count: countByState(tasks, filter, now, s),
              selected: filter.states.contains(s),
              onTap: () => notifier.toggleState(s),
            ),
        ],
      ),
    );
  }

  Widget _chip({
    required String label,
    required int count,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text('$label ($count)'),
        selected: selected,
        onSelected: (_) => onTap(),
      ),
    );
  }
}

class _Separator extends StatelessWidget {
  const _Separator();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 10),
      child: VerticalDivider(
        width: 8,
        color: Theme.of(context).colorScheme.outlineVariant,
      ),
    );
  }
}
