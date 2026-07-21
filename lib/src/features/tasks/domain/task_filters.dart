/// Views of tab 1 — PURE Dart, testable. Layer orthogonal to the score.
///
/// "Smart Lists" model: only one active view at a time, each = a pre-written
/// predicate (may freely mix OR/AND/NOT). The user never composes a filter →
/// the "no date + today" union is native.
library;

import 'task.dart';

/// Nature of a task (internal use for diagnostics / future needs).
enum TaskNature { noDate, dated, recurring }

/// Temporal state — only exists for tasks with a due date.
enum TaskState { overdue, today, upcoming }

/// The 4 named views of the Actions tab.
enum TaskView { todo, overdue, upcoming, undated }

TaskNature natureOf(Task t) {
  if (t.recurrenceId != null) return TaskNature.recurring;
  if (t.dueAt != null) return TaskNature.dated;
  return TaskNature.noDate;
}

/// State of a task at instant [now]. `null` if no due date.
TaskState? stateOf(Task t, DateTime now) {
  final due = t.dueAt;
  if (due == null) return null;
  if (due.isBefore(now)) return TaskState.overdue;
  final today = DateTime(now.year, now.month, now.day);
  final dueDay = DateTime(due.year, due.month, due.day);
  return dueDay.isAtSameMomentAs(today) ? TaskState.today : TaskState.upcoming;
}

/// Predicate for whether a task belongs to a view.
///
/// - [TaskView.todo] (default): what is due NOW = overdue OR today. NO
///   undated (backlog), NO future.
/// - [TaskView.overdue]: dated & due date past.
/// - [TaskView.upcoming]: dated & future.
/// - [TaskView.undated]: the backlog (no due date).
bool matchesView(Task t, TaskView v, DateTime now) {
  final s = stateOf(t, now);
  return switch (v) {
    TaskView.todo => s == TaskState.overdue || s == TaskState.today,
    TaskView.overdue => s == TaskState.overdue,
    TaskView.upcoming => s == TaskState.upcoming,
    TaskView.undated => t.dueAt == null,
  };
}

/// Live tasks of a view, unsorted (sorting by score is applied downstream by
/// the application layer).
List<Task> tasksForView(Iterable<Task> tasks, TaskView v, DateTime now) =>
    tasks.where((t) => t.isLive && matchesView(t, v, now)).toList();
