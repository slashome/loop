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
    test('À faire = en retard + aujourd\'hui (PAS sans-date, PAS futur)', () {
      expect(matchesView(overdue, TaskView.aFaire, kNow), isTrue);
      expect(matchesView(todayFuture, TaskView.aFaire, kNow), isTrue);
      expect(matchesView(noDate, TaskView.aFaire, kNow), isFalse);
      expect(matchesView(upcoming, TaskView.aFaire, kNow), isFalse);
    });

    test('En retard = uniquement les échéances passées', () {
      expect(matchesView(overdue, TaskView.enRetard, kNow), isTrue);
      expect(matchesView(noDate, TaskView.enRetard, kNow), isFalse);
      expect(matchesView(todayFuture, TaskView.enRetard, kNow), isFalse);
    });

    test('À venir = uniquement le futur', () {
      expect(matchesView(upcoming, TaskView.aVenir, kNow), isTrue);
      expect(matchesView(todayFuture, TaskView.aVenir, kNow), isFalse);
      expect(matchesView(noDate, TaskView.aVenir, kNow), isFalse);
    });

    test('Non datées = uniquement le backlog sans échéance', () {
      expect(matchesView(noDate, TaskView.nonDatees, kNow), isTrue);
      expect(matchesView(overdue, TaskView.nonDatees, kNow), isFalse);
      expect(matchesView(upcoming, TaskView.nonDatees, kNow), isFalse);
    });
  });

  test('tasksForView ne garde que les tâches vivantes de la vue', () {
    final done = Task(
      id: 'done',
      title: 'done',
      status: TaskStatus.done,
      dueAt: kNow.subtract(const Duration(hours: 1)),
      createdAt: kNow,
      updatedAt: kNow,
    );
    final ids = tasksForView([overdue, done, noDate], TaskView.aFaire, kNow)
        .map((t) => t.id)
        .toSet();
    expect(ids, {'overdue'}); // done exclu (non vivant), noDate exclu (vue)
  });
}
