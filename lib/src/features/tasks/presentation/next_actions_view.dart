import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../core/theme/brand_fab.dart';
import '../../settings/application/settings_providers.dart';
import '../../settings/presentation/settings_view.dart';
import '../application/tasks_providers.dart';
import '../domain/task.dart';
import '../domain/task_filters.dart';
import 'task_edit_view.dart';
import 'widgets/task_card.dart';

String _viewLabel(AppLocalizations l, TaskView v) => switch (v) {
      TaskView.todo => l.viewTodo,
      TaskView.overdue => l.viewOverdue,
      TaskView.upcoming => l.viewUpcoming,
      TaskView.undated => l.viewUndated,
    };

/// Tab 1 — Next actions. Heart of the app: the list sorted by score.
class NextActionsView extends ConsumerWidget {
  const NextActionsView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final async = ref.watch(nextActionsProvider);
    final newestAtBottom = ref.watch(
      settingsProvider.select((s) => s.newestAtBottom),
    );

    return Scaffold(
      appBar: AppBar(
        title: const _BrandTitle(),
        centerTitle: true,
        actions: [
          IconButton(
            tooltip: l.settingsTooltip,
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(builder: (_) => const SettingsView()),
            ),
          ),
        ],
      ),
      floatingActionButton: BrandFab(
        tooltip: l.newTaskTooltip,
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute<void>(builder: (_) => const TaskEditView()),
        ),
      ),
      // View selector placed AT THE BOTTOM: reachable with the thumb one-handed.
      bottomNavigationBar: const _ViewBar(),
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Erreur : $e')),
        data: (items) => items.isEmpty
            ? Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Opacity(
                      opacity: 0.9,
                      child: Image.asset(
                        'assets/branding/logo_tight.png',
                        width: 140,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      l.emptyList,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                    ),
                  ],
                ),
              )
            : ListView.builder(
                // Bottom anchoring (best score near the thumb) or top (classic),
                // depending on user preference.
                reverse: newestAtBottom,
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
    );
  }
}

/// Brand title: the ∞ symbol from the logo, centered (no text).
class _BrandTitle extends StatelessWidget {
  const _BrandTitle();

  @override
  Widget build(BuildContext context) {
    return Image.asset('assets/branding/logo_mark.png', height: 30);
  }
}

/// View selector (Smart Lists) at the bottom of the screen: single-select chips
/// with counters, reachable with the thumb.
class _ViewBar extends ConsumerWidget {
  const _ViewBar();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l = AppLocalizations.of(context);
    final view = ref.watch(viewProvider);
    final tasks = ref.watch(tasksProvider).valueOrNull ?? const <Task>[];
    final now = DateTime.now();

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Divider(height: 1, color: theme.colorScheme.outlineVariant),
        if (view == TaskView.todo)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 6, 16, 0),
            child: Text(
              l.todoHint,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        SizedBox(
          height: 52,
          child: ListView(
            scrollDirection: Axis.horizontal,
            // right margin so it does not slip under the FAB.
            padding: const EdgeInsets.fromLTRB(16, 8, 88, 8),
            children: [
              for (final v in TaskView.values)
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(
                      '${_viewLabel(l, v)} (${tasksForView(tasks, v, now).length})',
                    ),
                    selected: view == v,
                    showCheckmark: false,
                    onSelected: (_) =>
                        ref.read(viewProvider.notifier).state = v,
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
