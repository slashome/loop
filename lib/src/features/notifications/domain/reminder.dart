/// Reminder planning — PURE (no Flutter/platform dependency), like the rest of
/// the domain layer. The platform services in `data/` turn these into OS or
/// browser notifications.
library;

import '../../tasks/domain/task.dart';

/// A single reminder to fire at [when] for [taskId].
///
/// [notificationId] is the stable integer key the platform layers use
/// (OS notification systems address notifications by int, not by string id).
class Reminder {
  const Reminder({
    required this.taskId,
    required this.notificationId,
    required this.title,
    required this.when,
    this.body = '',
  });

  final String taskId;
  final int notificationId;

  /// Shown as the notification's title — the task's own title.
  final String title;

  /// Localized supporting line (e.g. "Reminder"). Filled by the UI layer,
  /// which has the locale; the pure planner leaves it empty.
  final String body;

  final DateTime when;

  Reminder withBody(String body) => Reminder(
        taskId: taskId,
        notificationId: notificationId,
        title: title,
        when: when,
        body: body,
      );

  /// Two reminders are "the same schedule" if firing the same id at the same
  /// instant with the same text — used by the services to skip needless
  /// reschedules.
  bool sameSchedule(Reminder other) =>
      notificationId == other.notificationId &&
      when.isAtSameMomentAs(other.when) &&
      title == other.title &&
      body == other.body;
}

/// Stable, non-negative 31-bit id derived from a task's string id. Deterministic
/// so the same task always maps to the same notification slot (idempotent
/// reschedules, cancel-by-task).
int notificationIdForTask(String taskId) => taskId.hashCode & 0x7fffffff;

/// Reminders to schedule for [tasks] as of [now].
///
/// A task yields a reminder when it is live (open, not deleted) and has a due
/// instant strictly in the future. Recurrence occurrences are ordinary tasks
/// carrying a `dueAt`, so they are handled here with no separate path.
///
/// [horizon] bounds how far ahead to schedule (null = unbounded). The web
/// backend relies on in-memory timers that only survive while the tab is open,
/// so it passes a short horizon; native scheduling can be unbounded.
List<Reminder> plannedReminders(
  Iterable<Task> tasks,
  DateTime now, {
  Duration? horizon,
}) {
  final cutoff = horizon == null ? null : now.add(horizon);
  final out = <Reminder>[];
  for (final t in tasks) {
    final due = t.dueAt;
    if (!t.isLive || due == null) continue;
    if (!due.isAfter(now)) continue;
    if (cutoff != null && due.isAfter(cutoff)) continue;
    out.add(Reminder(
      taskId: t.id,
      notificationId: notificationIdForTask(t.id),
      title: t.title,
      when: due,
    ));
  }
  return out;
}
