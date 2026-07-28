/// Calendar helpers — pure Dart, testable. Operate on the same live tasks as
/// the Actions tab; only dated tasks (with a `dueAt`) appear on the calendar.
library;

import '../../tasks/domain/task.dart';

/// Same calendar day (ignores time).
bool isSameDay(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;

/// First day of the month containing [d] (at midnight).
DateTime monthStart(DateTime d) => DateTime(d.year, d.month);

/// Live, dated tasks due on [day], sorted chronologically by due time.
List<Task> tasksOnDay(Iterable<Task> tasks, DateTime day) {
  final result = tasks
      .where((t) => t.isLive && t.dueAt != null && isSameDay(t.dueAt!, day))
      .toList()
    ..sort((a, b) => a.dueAt!.compareTo(b.dueAt!));
  return result;
}

/// Set of day-of-month numbers (1..31) in [month] that have at least one live
/// dated task — used to render the dots under day cells.
Set<int> daysWithTasks(Iterable<Task> tasks, DateTime month) {
  final days = <int>{};
  for (final t in tasks) {
    final due = t.dueAt;
    if (t.isLive &&
        due != null &&
        due.year == month.year &&
        due.month == month.month) {
      days.add(due.day);
    }
  }
  return days;
}

/// The 42 cells (6 weeks × 7 days) of the month grid for [month], starting on
/// Monday. Cells before/after the month belong to adjacent months.
List<DateTime> monthGrid(DateTime month) {
  final first = monthStart(month);
  // weekday: Mon=1..Sun=7 → offset to the Monday on/before the 1st.
  final leading = first.weekday - 1;
  final start = first.subtract(Duration(days: leading));
  return [for (var i = 0; i < 42; i++) start.add(Duration(days: i))];
}
