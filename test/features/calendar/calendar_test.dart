import 'package:flutter_test/flutter_test.dart';
import 'package:loop/src/features/calendar/domain/calendar.dart';
import 'package:loop/src/features/tasks/domain/task.dart';

Task dated(String id, DateTime due, {TaskStatus status = TaskStatus.open}) =>
    Task(
      id: id,
      title: id,
      dueAt: due,
      status: status,
      createdAt: due,
      updatedAt: due,
    );

void main() {
  test('isSameDay ignores time', () {
    expect(
        isSameDay(DateTime(2026, 7, 8, 9), DateTime(2026, 7, 8, 23)), isTrue);
    expect(isSameDay(DateTime(2026, 7, 8), DateTime(2026, 7, 9)), isFalse);
  });

  test('tasksOnDay keeps live dated tasks, sorted by time', () {
    final tasks = [
      dated('evening', DateTime(2026, 7, 8, 20)),
      dated('morning', DateTime(2026, 7, 8, 8)),
      dated('otherDay', DateTime(2026, 7, 9, 8)),
      dated('done', DateTime(2026, 7, 8, 12), status: TaskStatus.done),
      Task(
        id: 'undated',
        title: 'undated',
        createdAt: DateTime(2026, 7, 8),
        updatedAt: DateTime(2026, 7, 8),
      ),
    ];
    final ids =
        tasksOnDay(tasks, DateTime(2026, 7, 8)).map((t) => t.id).toList();
    expect(ids, ['morning', 'evening']); // done/otherDay/undated excluded
  });

  test('daysWithTasks returns marked day numbers of the month', () {
    final tasks = [
      dated('a', DateTime(2026, 7, 8, 9)),
      dated('b', DateTime(2026, 7, 8, 18)), // same day
      dated('c', DateTime(2026, 7, 20)),
      dated('d', DateTime(2026, 8, 3)), // other month
    ];
    expect(daysWithTasks(tasks, DateTime(2026, 7)), {8, 20});
  });

  test('monthGrid has 42 cells starting on the Monday on/before the 1st', () {
    // July 2026: 1st is a Wednesday → grid starts Mon 29 June.
    final grid = monthGrid(DateTime(2026, 7));
    expect(grid.length, 42);
    expect(grid.first, DateTime(2026, 6, 29));
    expect(grid.first.weekday, DateTime.monday);
  });
}
