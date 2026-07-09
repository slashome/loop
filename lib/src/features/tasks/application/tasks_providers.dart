/// Couche application de la feature `tasks` — providers Riverpod (ViewModels).
///
/// Les tâches viennent pour l'instant de [seedTasks] (en mémoire). À terme,
/// [tasksProvider] sera alimenté par le `TaskRepository` (Drift) ; le reste de
/// la chaîne (scoring, tri) ne changera pas.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/scoring.dart';
import '../domain/task.dart';
import 'fixtures.dart';

/// Une tâche accompagnée de son score calculé — objet de présentation, pour
/// afficher le score dans l'UI pendant qu'on itère sur k/τ.
class ScoredTask {
  const ScoredTask(this.task, this.score);
  final Task task;
  final double score;
}

/// Constantes de scoring globales. Défaut = anti-famine borné (k=2, τ=14j).
/// À terme lu depuis la feature `settings`.
final scoringConfigProvider = Provider<ScoringConfig>(
  (ref) => ScoringConfig.defaults,
);

/// Source des tâches. En mémoire pour l'instant (voir [seedTasks]).
final tasksProvider = NotifierProvider<TasksNotifier, List<Task>>(
  TasksNotifier.new,
);

class TasksNotifier extends Notifier<List<Task>> {
  @override
  List<Task> build() => seedTasks(DateTime.now());

  /// Bascule une tâche en `done` (retirée de l'onglet 1 par le filtre « vivant »).
  void complete(String id) {
    state = [
      for (final t in state)
        if (t.id == id)
          t.copyWith(status: TaskStatus.done, completedAt: DateTime.now())
        else
          t,
    ];
  }
}

/// L'onglet 1 : liste triée par score (avec le score exposé pour l'affichage).
///
/// Recalculé à chaque changement de tâches ou de config. `now` est pris à la
/// volée — l'ordre est cohérent car un seul `now` sert au tri ET aux scores.
final nextActionsProvider = Provider<List<ScoredTask>>((ref) {
  final tasks = ref.watch(tasksProvider);
  final config = ref.watch(scoringConfigProvider);
  final now = DateTime.now();
  final sorted = nextActions(tasks, config: config, now: now);
  return [
    for (final t in sorted) ScoredTask(t, taskScore(t, config, now: now)),
  ];
});
