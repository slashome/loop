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
  group('classification', () {
    test('natureOf', () {
      expect(natureOf(task(id: 'a')), TaskNature.noDate);
      expect(natureOf(task(id: 'b', due: kNow)), TaskNature.dated);
      expect(
        natureOf(task(id: 'c', due: kNow, recurrenceId: 'r')),
        TaskNature.recurring,
      );
    });

    test('stateOf', () {
      expect(stateOf(task(id: 'a'), kNow), isNull);
      expect(
        stateOf(
            task(id: 'b', due: kNow.subtract(const Duration(hours: 1))), kNow),
        TaskState.overdue,
      );
      expect(
        stateOf(task(id: 'c', due: kNow.add(const Duration(hours: 2))), kNow),
        TaskState.today,
      );
      expect(
        stateOf(task(id: 'd', due: kNow.add(const Duration(days: 2))), kNow),
        TaskState.upcoming,
      );
    });
  });

  group('matchesFilter (OU dans l\'axe, ET entre axes)', () {
    final noDate = task(id: 'noDate');
    final datedLate =
        task(id: 'datedLate', due: kNow.subtract(const Duration(hours: 1)));
    final datedSoon =
        task(id: 'datedSoon', due: kNow.add(const Duration(days: 3)));
    final repeatLate = task(
      id: 'repeatLate',
      due: kNow.subtract(const Duration(hours: 2)),
      recurrenceId: 'r',
    );

    test('filtre vide = tout passe', () {
      const f = TaskFilter();
      for (final t in [noDate, datedLate, datedSoon, repeatLate]) {
        expect(matchesFilter(t, f, kNow), isTrue);
      }
    });

    test('OU dans l\'axe Nature', () {
      const f = TaskFilter(natures: {TaskNature.dated, TaskNature.recurring});
      expect(matchesFilter(datedLate, f, kNow), isTrue);
      expect(matchesFilter(repeatLate, f, kNow), isTrue);
      expect(matchesFilter(noDate, f, kNow), isFalse);
    });

    test('récurrente + en retard = occurrence non validée (valide)', () {
      const f = TaskFilter(
        natures: {TaskNature.recurring},
        states: {TaskState.overdue},
      );
      expect(matchesFilter(repeatLate, f, kNow), isTrue);
      expect(matchesFilter(datedLate, f, kNow), isFalse); // pas récurrente
    });

    test('sans date + en retard = impossible (vide)', () {
      const f = TaskFilter(
        natures: {TaskNature.noDate},
        states: {TaskState.overdue},
      );
      for (final t in [noDate, datedLate, datedSoon, repeatLate]) {
        expect(matchesFilter(t, f, kNow), isFalse);
      }
    });
  });

  group('compteurs à facettes', () {
    final tasks = [
      task(id: 'n1'),
      task(id: 'n2'),
      task(id: 'lateDated', due: kNow.subtract(const Duration(hours: 1))),
      task(
        id: 'lateRepeat',
        due: kNow.subtract(const Duration(hours: 1)),
        recurrenceId: 'r',
      ),
      task(id: 'soon', due: kNow.add(const Duration(days: 1))),
    ];

    test('compteur Nature ignore l\'axe Nature, applique l\'axe État', () {
      const f = TaskFilter(states: {TaskState.overdue});
      // en retard : lateDated (datée) + lateRepeat (récurrente)
      expect(countByNature(tasks, f, kNow, TaskNature.dated), 1);
      expect(countByNature(tasks, f, kNow, TaskNature.recurring), 1);
      expect(countByNature(tasks, f, kNow, TaskNature.noDate), 0);
    });

    test('compteur État applique l\'axe Nature', () {
      const f = TaskFilter(natures: {TaskNature.dated});
      // parmi les datées : lateDated (retard), soon (à venir)
      expect(countByState(tasks, f, kNow, TaskState.overdue), 1);
      expect(countByState(tasks, f, kNow, TaskState.upcoming), 1);
    });
  });
}
