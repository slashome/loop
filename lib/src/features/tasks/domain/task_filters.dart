/// Filtres de l'onglet 1 — Dart PUR, testable. Couche orthogonale au score
/// (décision de design) : réduit le sous-ensemble visible, ne le classe pas.
///
/// Modèle à facettes : deux axes indépendants. Plusieurs valeurs d'un même axe
/// = OU (union) ; entre axes = ET (intersection). Un axe vide n'impose rien.
library;

import 'task.dart';

/// Axe « Nature » — partition : une tâche est dans exactement une case.
enum TaskNature { noDate, dated, recurring }

/// Axe « État » temporel — n'existe que pour les tâches avec une échéance.
enum TaskState { overdue, today, upcoming }

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

/// Sélection de filtres (immutable).
class TaskFilter {
  const TaskFilter({this.natures = const {}, this.states = const {}});

  final Set<TaskNature> natures;
  final Set<TaskState> states;

  bool get isEmpty => natures.isEmpty && states.isEmpty;

  TaskFilter toggleNature(TaskNature n) =>
      TaskFilter(natures: _toggled(natures, n), states: states);

  TaskFilter toggleState(TaskState s) =>
      TaskFilter(natures: natures, states: _toggled(states, s));
}

Set<T> _toggled<T>(Set<T> set, T v) =>
    set.contains(v) ? ({...set}..remove(v)) : {...set, v};

bool _matchesNatureAxis(Task t, TaskFilter f) =>
    f.natures.isEmpty || f.natures.contains(natureOf(t));

bool _matchesStateAxis(Task t, TaskFilter f, DateTime now) {
  if (f.states.isEmpty) return true;
  final s = stateOf(t, now);
  return s != null && f.states.contains(s);
}

/// Prédicat complet : OU dans chaque axe, ET entre les axes.
bool matchesFilter(Task t, TaskFilter f, DateTime now) =>
    _matchesNatureAxis(t, f) && _matchesStateAxis(t, f, now);

/// Compteur d'un chip Nature : nombre de tâches vivantes de cette nature, en
/// tenant compte de l'AUTRE axe (convention facettes), pas de l'axe Nature
/// lui-même.
int countByNature(
  Iterable<Task> tasks,
  TaskFilter f,
  DateTime now,
  TaskNature n,
) =>
    tasks
        .where(
            (t) => t.isLive && _matchesStateAxis(t, f, now) && natureOf(t) == n)
        .length;

/// Compteur d'un chip État (tient compte de l'axe Nature seulement).
int countByState(
  Iterable<Task> tasks,
  TaskFilter f,
  DateTime now,
  TaskState s,
) =>
    tasks
        .where(
            (t) => t.isLive && _matchesNatureAxis(t, f) && stateOf(t, now) == s)
        .length;
