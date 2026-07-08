/// Couche application de la feature `tasks` — providers Riverpod (ViewModels).
///
/// Pour cette première itération, les tâches viennent d'une source EN MÉMOIRE
/// (démo). À terme, [tasksProvider] sera alimenté par le `TaskRepository`
/// (Drift) ; le reste de la chaîne (scoring, tri) ne changera pas.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/scoring.dart';
import '../domain/task.dart';

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

/// Source des tâches. Démo en mémoire pour l'instant (voir [_seedDemoTasks]).
final tasksProvider = NotifierProvider<TasksNotifier, List<Task>>(
  TasksNotifier.new,
);

class TasksNotifier extends Notifier<List<Task>> {
  @override
  List<Task> build() => _seedDemoTasks(DateTime.now());

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

/// Données de démo conçues pour montrer l'anti-famine BORNÉ à l'œuvre :
/// les deux vieilles P2 remontent au-dessus des P3 fraîches, mais restent
/// SOUS la P4 fraîche — la priorité domine, personne ne meurt de faim.
List<Task> _seedDemoTasks(DateTime now) {
  Task t(
    String id,
    String title,
    int priority,
    Duration age, {
    TaskStatus status = TaskStatus.open,
  }) {
    final created = now.subtract(age);
    return Task(
      id: id,
      title: title,
      priority: priority,
      status: status,
      createdAt: created,
      updatedAt: created,
    );
  }

  return [
    t('t1', 'Rappeler le comptable avant 17h', 5, const Duration(hours: 1)),
    t('t2', 'Payer la facture d\'électricité', 4, const Duration(days: 2)),
    t('t3', 'Trier les photos de vacances', 2, const Duration(days: 250)),
    t('t4', 'Refactorer le module d\'authentification', 2,
        const Duration(days: 90)),
    t('t5', 'Préparer l\'ordre du jour de la réunion', 3,
        const Duration(hours: 5)),
    t('t6', 'Répondre au mail de Léa', 3, const Duration(days: 1)),
    t('t7', 'Lire l\'article sur Riverpod', 1, const Duration(days: 3)),
    // Terminée : prouve que le filtre « vivant » l'exclut de l'onglet 1.
    t('t8', 'Réserver le restaurant', 5, const Duration(hours: 3),
        status: TaskStatus.done),
  ];
}
