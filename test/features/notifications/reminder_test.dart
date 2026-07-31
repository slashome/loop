import 'package:flutter_test/flutter_test.dart';
import 'package:loop/src/features/notifications/domain/reminder.dart';
import 'package:loop/src/features/tasks/domain/task.dart';

void main() {
  final now = DateTime(2026, 8, 1, 12);
  Task task(
    String id, {
    DateTime? dueAt,
    TaskStatus status = TaskStatus.open,
    DateTime? deletedAt,
  }) =>
      Task(
        id: id,
        title: 'T-$id',
        dueAt: dueAt,
        status: status,
        deletedAt: deletedAt,
        createdAt: now,
        updatedAt: now,
      );

  test('only live, future, dated tasks yield reminders', () {
    final tasks = [
      task('future', dueAt: now.add(const Duration(hours: 2))), // ✓
      task('past', dueAt: now.subtract(const Duration(hours: 1))), // overdue ✗
      task('undated'), // ✗
      task('done',
          dueAt: now.add(const Duration(hours: 3)),
          status: TaskStatus.done), // ✗
      task('deleted',
          dueAt: now.add(const Duration(hours: 4)),
          deletedAt: now), // ✗
    ];

    final reminders = plannedReminders(tasks, now);
    expect(reminders.map((r) => r.taskId), ['future']);
  });

  test('recurrence occurrences are just dated tasks — same path', () {
    // An occurrence is a Task with a recurrenceId and a dueAt; nothing special.
    final occ = Task(
      id: 'occ_r1_x',
      title: 'Vitamins',
      recurrenceId: 'r1',
      dueAt: now.add(const Duration(hours: 6)),
      createdAt: now,
      updatedAt: now,
    );
    final reminders = plannedReminders([occ], now);
    expect(reminders, hasLength(1));
    expect(reminders.single.title, 'Vitamins');
    expect(reminders.single.when, now.add(const Duration(hours: 6)));
  });

  test('horizon bounds how far ahead reminders are planned', () {
    final tasks = [
      task('soon', dueAt: now.add(const Duration(hours: 1))),
      task('far', dueAt: now.add(const Duration(days: 30))),
    ];
    final reminders =
        plannedReminders(tasks, now, horizon: const Duration(days: 14));
    expect(reminders.map((r) => r.taskId), ['soon']);
  });

  test('notificationIdForTask is stable and non-negative', () {
    final a = notificationIdForTask('task-abc');
    expect(a, notificationIdForTask('task-abc')); // deterministic
    expect(a, greaterThanOrEqualTo(0));
    expect(a, lessThanOrEqualTo(0x7fffffff));
    // Different ids (almost always) differ — sanity, not a guarantee.
    expect(a, isNot(notificationIdForTask('task-xyz')));
  });

  test('sameSchedule detects unchanged vs changed reminders', () {
    final at = DateTime(2026, 8, 1, 18);
    final r1 = Reminder(taskId: 't', notificationId: 1, title: 'A', when: at);
    final sameTime =
        Reminder(taskId: 't', notificationId: 1, title: 'A', when: at);
    final retitled =
        Reminder(taskId: 't', notificationId: 1, title: 'B', when: at);
    expect(r1.sameSchedule(sameTime), isTrue);
    expect(r1.sameSchedule(retitled), isFalse);
  });
}
