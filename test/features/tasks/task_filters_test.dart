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
    test('À faire = sans date + en retard + aujourd\'hui, PAS à venir', () {
      expect(matchesView(noDate, TaskView.aFaire, kNow), isTrue);
      expect(matchesView(overdue, TaskView.aFaire, kNow), isTrue);
      expect(matchesView(todayFuture, TaskView.aFaire, kNow), isTrue);
      expect(matchesView(upcoming, TaskView.aFaire, kNow), isFalse);
    });

    test('En retard = uniquement les échéances passées', () {
      expect(matchesView(overdue, TaskView.enRetard, kNow), isTrue);
      expect(matchesView(noDate, TaskView.enRetard, kNow), isFalse);
      expect(matchesView(todayFuture, TaskView.enRetard, kNow), isFalse);
    });

    test('Datées = tout ce qui a une date, sans-date exclues', () {
      expect(matchesView(noDate, TaskView.datees, kNow), isFalse);
      expect(matchesView(overdue, TaskView.datees, kNow), isTrue);
      expect(matchesView(upcoming, TaskView.datees, kNow), isTrue);
    });

    test('À venir = uniquement le futur', () {
      expect(matchesView(upcoming, TaskView.aVenir, kNow), isTrue);
      expect(matchesView(todayFuture, TaskView.aVenir, kNow), isFalse);
      expect(matchesView(noDate, TaskView.aVenir, kNow), isFalse);
    });
  });

  group('anti-noyade : repli des récurrences futures dans Datées', () {
    // 3 occurrences futures d'une même récurrence + 1 datée ponctuelle future.
    final occ1 = task(
        id: 'o1', due: kNow.add(const Duration(days: 1)), recurrenceId: 'r');
    final occ2 = task(
        id: 'o2', due: kNow.add(const Duration(days: 2)), recurrenceId: 'r');
    final occ3 = task(
        id: 'o3', due: kNow.add(const Duration(days: 3)), recurrenceId: 'r');
    final tasks = [occ3, occ1, occ2, upcoming, overdue];

    test('Datées : la récurrence future est réduite à sa prochaine occurrence',
        () {
      final ids =
          tasksForView(tasks, TaskView.datees, kNow).map((t) => t.id).toSet();
      // occ1 (la plus proche) gardée ; occ2/occ3 repliées.
      expect(ids.contains('o1'), isTrue);
      expect(ids.contains('o2'), isFalse);
      expect(ids.contains('o3'), isFalse);
      // les autres datées restent
      expect(ids.contains('upcoming'), isTrue);
      expect(ids.contains('overdue'), isTrue);
    });

    test('À venir : le déroulé complet des occurrences est conservé', () {
      final ids =
          tasksForView(tasks, TaskView.aVenir, kNow).map((t) => t.id).toSet();
      expect(ids.containsAll({'o1', 'o2', 'o3'}), isTrue);
    });
  });
}
