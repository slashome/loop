/// Vues de l'onglet 1 — Dart PUR, testable. Couche orthogonale au score.
///
/// Modèle « Smart Lists » : une seule vue active à la fois, chacune = un
/// prédicat pré-écrit (peut mêler OU/ET/NON librement). L'utilisateur ne
/// compose jamais de filtre → l'union « sans date + aujourd'hui » est native.
library;

import 'task.dart';

/// Nature d'une tâche (usage interne au diagnostic / futurs besoins).
enum TaskNature { noDate, dated, recurring }

/// État temporel — n'existe que pour les tâches avec une échéance.
enum TaskState { overdue, today, upcoming }

/// Les 4 vues nommées de l'onglet Actions.
enum TaskView { aFaire, enRetard, datees, aVenir }

TaskNature natureOf(Task t) {
  if (t.recurrenceId != null) return TaskNature.recurring;
  if (t.dueAt != null) return TaskNature.dated;
  return TaskNature.noDate;
}

/// État d'une tâche à l'instant [now]. `null` si pas d'échéance.
TaskState? stateOf(Task t, DateTime now) {
  final due = t.dueAt;
  if (due == null) return null;
  if (due.isBefore(now)) return TaskState.overdue;
  final today = DateTime(now.year, now.month, now.day);
  final dueDay = DateTime(due.year, due.month, due.day);
  return dueDay.isAtSameMomentAs(today) ? TaskState.today : TaskState.upcoming;
}

/// Prédicat d'appartenance d'une tâche à une vue.
///
/// - [TaskView.aFaire] : le « maintenant » = sans date OU en retard OU
///   aujourd'hui (et PAS à venir). « Sans date » n'est pas un état : c'est
///   juste un terme de ce prédicat, jamais immunisé ailleurs.
/// - [TaskView.enRetard] : datée & échéance passée.
/// - [TaskView.datees] : a une date (tous états) — sans-date exclues.
/// - [TaskView.aVenir] : datée & future.
bool matchesView(Task t, TaskView v, DateTime now) {
  final s = stateOf(t, now);
  return switch (v) {
    TaskView.aFaire =>
      s == null || s == TaskState.overdue || s == TaskState.today,
    TaskView.enRetard => s == TaskState.overdue,
    TaskView.datees => t.dueAt != null,
    TaskView.aVenir => s == TaskState.upcoming,
  };
}

/// Tâches vivantes d'une vue. Applique le repli anti-noyade dans [datees] :
/// les occurrences récurrentes FUTURES sont réduites à la prochaine par
/// récurrence (le déroulé complet des 14 jours n'existe que dans [aVenir]).
List<Task> tasksForView(Iterable<Task> tasks, TaskView v, DateTime now) {
  final selected =
      tasks.where((t) => t.isLive && matchesView(t, v, now)).toList();
  if (v == TaskView.datees) return _collapseFutureRecurring(selected, now);
  return selected;
}

List<Task> _collapseFutureRecurring(List<Task> tasks, DateTime now) {
  final out = <Task>[];
  final nextByRec = <String, Task>{};
  for (final t in tasks) {
    final isFutureRecurring =
        t.recurrenceId != null && stateOf(t, now) == TaskState.upcoming;
    if (!isFutureRecurring) {
      out.add(t);
      continue;
    }
    final cur = nextByRec[t.recurrenceId];
    if (cur == null || t.dueAt!.isBefore(cur.dueAt!)) {
      nextByRec[t.recurrenceId!] = t;
    }
  }
  out.addAll(nextByRec.values);
  return out;
}
