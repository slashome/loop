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

/// The 7 days of the week containing [d], Monday-first (field arithmetic).
List<DateTime> weekOf(DateTime d) {
  final leading = d.weekday - 1; // Mon=0 … Sun=6
  return [
    for (var i = 0; i < 7; i++) DateTime(d.year, d.month, d.day - leading + i),
  ];
}

/// New due date when a task is dropped on [targetDay]: keep its time of day
/// (default 09:00 if it somehow had none).
DateTime rescheduledDueAt(DateTime? old, DateTime targetDay) {
  return DateTime(
    targetDay.year,
    targetDay.month,
    targetDay.day,
    old?.hour ?? 9,
    old?.minute ?? 0,
  );
}

/// The 42 cells (6 weeks × 7 days) of the month grid for [month], starting on
/// Monday. Cells before/after the month belong to adjacent months.
///
/// Uses calendar-field arithmetic — `DateTime(y, m, dayNumber)` with over/under
/// -flowing day numbers, which Dart normalizes across month/year boundaries —
/// instead of `Duration(days:)`. The latter is 24h-based and drifts by a day
/// across a DST transition; field arithmetic stays on calendar days.
List<DateTime> monthGrid(DateTime month) {
  final first = monthStart(month);
  final leading = first.weekday - 1; // Mon=0 … Sun=6
  return [
    for (var i = 0; i < 42; i++)
      DateTime(first.year, first.month, 1 - leading + i),
  ];
}
