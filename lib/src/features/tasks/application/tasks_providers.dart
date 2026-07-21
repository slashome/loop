/// Application layer of the `tasks` feature — Riverpod providers (ViewModels).
///
/// Tasks now come from the database (Drift) via [TaskRepository]. The stream
/// is reactive: any write (edit, completion, generated occurrence) propagates
/// to tab 1 without intervention.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/db/database_provider.dart';
import '../data/task_repository.dart';
import '../domain/scoring.dart';
import '../domain/task.dart';
import '../domain/task_filters.dart';

export '../../../core/db/database_provider.dart' show appDatabaseProvider;

/// A task together with its computed score — presentation object.
class ScoredTask {
  const ScoredTask(this.task, this.score);
  final Task task;
  final double score;
}

/// Global scoring constants. Default = bounded anti-starvation (k=2, τ=14d).
final scoringConfigProvider = Provider<ScoringConfig>(
  (ref) => ScoringConfig.defaults,
);

/// Caps per priority tier. Default = {5:3, 4:5}.
final priorityCapsProvider = Provider<PriorityCaps>(
  (ref) => PriorityCaps.defaults,
);

final taskRepositoryProvider = Provider<TaskRepository>(
  (ref) => TaskRepository(ref.watch(appDatabaseProvider)),
);

/// Stream of non-deleted tasks (source of truth for tab 1).
final tasksProvider = StreamProvider<List<Task>>(
  (ref) => ref.watch(taskRepositoryProvider).watchTasks(),
);

/// Active view of tab 1 (Smart Lists). NOT persisted across sessions:
/// we always reopen on "To do".
final viewProvider = StateProvider<TaskView>((ref) => TaskView.todo);

/// Tab 1: tasks of the active view, sorted by score.
final nextActionsProvider = Provider<AsyncValue<List<ScoredTask>>>((ref) {
  final async = ref.watch(tasksProvider);
  final config = ref.watch(scoringConfigProvider);
  final view = ref.watch(viewProvider);
  return async.whenData((tasks) {
    final now = DateTime.now();
    final selected = tasksForView(tasks, view, now)
      ..sort((a, b) => compareByScore(a, b, config, now));
    return [
      for (final t in selected) ScoredTask(t, taskScore(t, config, now: now)),
    ];
  });
});
