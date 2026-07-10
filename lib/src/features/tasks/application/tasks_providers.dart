/// Couche application de la feature `tasks` — providers Riverpod (ViewModels).
///
/// Les tâches viennent désormais de la base (Drift) via [TaskRepository]. Le
/// flux est réactif : toute écriture (édition, complétion, occurrence générée)
/// se répercute dans l'onglet 1 sans intervention.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/db/app_database.dart';
import '../data/task_repository.dart';
import '../domain/scoring.dart';
import '../domain/task.dart';

/// Une tâche accompagnée de son score calculé — objet de présentation.
class ScoredTask {
  const ScoredTask(this.task, this.score);
  final Task task;
  final double score;
}

/// Constantes de scoring globales. Défaut = anti-famine borné (k=2, τ=14j).
final scoringConfigProvider = Provider<ScoringConfig>(
  (ref) => ScoringConfig.defaults,
);

/// Caps par palier de priorité. Défaut = {5:3, 4:5}.
final priorityCapsProvider = Provider<PriorityCaps>(
  (ref) => PriorityCaps.defaults,
);

/// Base de données. Surchargé dans `main()` (et les tests) par une instance
/// déjà ouverte/amorcée.
final appDatabaseProvider = Provider<AppDatabase>(
  (ref) => throw UnimplementedError('appDatabaseProvider must be overridden'),
);

final taskRepositoryProvider = Provider<TaskRepository>(
  (ref) => TaskRepository(ref.watch(appDatabaseProvider)),
);

/// Flux des tâches non supprimées (source de vérité de l'onglet 1).
final tasksProvider = StreamProvider<List<Task>>(
  (ref) => ref.watch(taskRepositoryProvider).watchTasks(),
);

/// L'onglet 1 : tâches vivantes triées par score, score exposé pour l'UI.
final nextActionsProvider = Provider<AsyncValue<List<ScoredTask>>>((ref) {
  final async = ref.watch(tasksProvider);
  final config = ref.watch(scoringConfigProvider);
  return async.whenData((tasks) {
    final now = DateTime.now();
    final sorted = nextActions(tasks, config: config, now: now);
    return [
      for (final t in sorted) ScoredTask(t, taskScore(t, config, now: now)),
    ];
  });
});
