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
enum TaskView { todo, overdue, upcoming, undated }

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
/// - [TaskView.todo] (défaut) : ce qui est dû MAINTENANT = en retard OU
///   aujourd'hui. PAS de sans-date (backlog), PAS de futur.
/// - [TaskView.overdue] : datée & échéance passée.
/// - [TaskView.upcoming] : datée & future.
/// - [TaskView.undated] : le backlog (aucune échéance).
bool matchesView(Task t, TaskView v, DateTime now) {
  final s = stateOf(t, now);
  return switch (v) {
    TaskView.todo => s == TaskState.overdue || s == TaskState.today,
    TaskView.overdue => s == TaskState.overdue,
    TaskView.upcoming => s == TaskState.upcoming,
    TaskView.undated => t.dueAt == null,
  };
}

/// Tâches vivantes d'une vue, non triées (le tri par score est appliqué en
/// aval par la couche application).
List<Task> tasksForView(Iterable<Task> tasks, TaskView v, DateTime now) =>
    tasks.where((t) => t.isLive && matchesView(t, v, now)).toList();
