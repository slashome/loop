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
  (ref) => TaskRepository(
    ref.watch(appDatabaseProvider),
    caps: ref.watch(priorityCapsProvider),
  ),
);

/// Periodic tick so time-dependent state (overdue/today boundaries, relative
/// dates) refreshes while the app stays open — e.g. across midnight.
final _clockProvider = StreamProvider<int>(
  (ref) => Stream<int>.periodic(const Duration(minutes: 1), (i) => i),
);

/// Single source of "now" for the tasks feature. Re-evaluated every clock
/// tick; list, view counters and cards must all read this same instant so
/// they can never contradict each other.
final nowProvider = Provider<DateTime>((ref) {
  ref.watch(_clockProvider);
  return DateTime.now();
});

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
  final now = ref.watch(nowProvider);
  return async.whenData((tasks) {
    final selected = tasksForView(tasks, view, now)
      ..sort((a, b) => compareByScore(a, b, config, now));
    return [
      for (final t in selected) ScoredTask(t, taskScore(t, config, now: now)),
    ];
  });
});
