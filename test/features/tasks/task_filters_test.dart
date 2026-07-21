import 'package:flutter_test/flutter_test.dart';
import 'package:loop/src/features/tasks/domain/task.dart';
import 'package:loop/src/features/tasks/domain/task_filters.dart';

final DateTime kNow = DateTime(2026, 7, 11, 12);

Task task({
  required String id,
  DateTime? due,
  String? recurrenceId,
}) =>
    Task(
      id: id,
      title: id,
      dueAt: due,
      recurrenceId: recurrenceId,
      createdAt: kNow,
      updatedAt: kNow,
    );

void main() {
  final noDate = task(id: 'noDate');
  final overdue =
      task(id: 'overdue', due: kNow.subtract(const Duration(hours: 1)));
  final todayFuture =
      task(id: 'today', due: kNow.add(const Duration(hours: 3)));
  final upcoming = task(id: 'upcoming', due: kNow.add(const Duration(days: 3)));

  group('matchesView', () {
    test('Todo = overdue + today (NOT undated, NOT future)', () {
      expect(matchesView(overdue, TaskView.todo, kNow), isTrue);
      expect(matchesView(todayFuture, TaskView.todo, kNow), isTrue);
      expect(matchesView(noDate, TaskView.todo, kNow), isFalse);
      expect(matchesView(upcoming, TaskView.todo, kNow), isFalse);
    });

    test('Overdue = only past due dates', () {
      expect(matchesView(overdue, TaskView.overdue, kNow), isTrue);
      expect(matchesView(noDate, TaskView.overdue, kNow), isFalse);
      expect(matchesView(todayFuture, TaskView.overdue, kNow), isFalse);
    });

    test('Upcoming = only the future', () {
      expect(matchesView(upcoming, TaskView.upcoming, kNow), isTrue);
      expect(matchesView(todayFuture, TaskView.upcoming, kNow), isFalse);
      expect(matchesView(noDate, TaskView.upcoming, kNow), isFalse);
    });

    test('Undated = only the backlog without a due date', () {
      expect(matchesView(noDate, TaskView.undated, kNow), isTrue);
      expect(matchesView(overdue, TaskView.undated, kNow), isFalse);
      expect(matchesView(upcoming, TaskView.undated, kNow), isFalse);
    });
  });

  test('tasksForView keeps only the live tasks of the view', () {
    final done = Task(
      id: 'done',
      title: 'done',
      status: TaskStatus.done,
      dueAt: kNow.subtract(const Duration(hours: 1)),
      createdAt: kNow,
      updatedAt: kNow,
    );
    final ids = tasksForView([overdue, done, noDate], TaskView.todo, kNow)
        .map((t) => t.id)
        .toSet();
    expect(
        ids, {'overdue'}); // done excluded (non-live), noDate excluded (view)
  });
}
