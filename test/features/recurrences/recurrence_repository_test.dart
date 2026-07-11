import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:loop/src/core/db/app_database.dart';
import 'package:loop/src/features/recurrences/data/recurrence_repository.dart';
import 'package:loop/src/features/recurrences/domain/recurrence.dart';
import 'package:loop/src/features/tasks/data/task_repository.dart';

void main() {
  late AppDatabase db;
  late RecurrenceRepository repo;
  final now = DateTime(2026, 7, 6, 12);

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    repo = RecurrenceRepository(db);
  });
  tearDown(() => db.close());

  Recurrence make(String id) => Recurrence(
        id: id,
        title: 'Sport',
        freq: RecurrenceFreq.weekly,
        byWeekdays: const [DateTime.monday, DateTime.thursday],
        byHours: const [18],
        dtstart: now,
        createdAt: now,
        updatedAt: now,
      );

  test('save puis relecture conserve la cadence multi-valuée', () async {
    await repo.save(make('r1'));
    final all = await repo.watchAll().first;
    expect(all, hasLength(1));
    expect(all.first.byWeekdays, [DateTime.monday, DateTime.thursday]);
    expect(all.first.byHours, [18]);
  });

  test('setActive bascule le drapeau', () async {
    await repo.save(make('r1'));
    await repo.setActive('r1', false);
    final r = (await repo.watchAll().first).first;
    expect(r.active, isFalse);
  });

  test('delete retire la récurrence et ses occurrences ouvertes', () async {
    await repo.save(make('r1'));
    // génère les occurrences d'un lundi
    await TaskRepository(db).generateOccurrences(on: now);
    expect(
      (await db.allTasks()).where((t) => t.recurrenceId == 'r1').isNotEmpty,
      isTrue,
    );

    await repo.delete('r1');
    expect(await repo.watchAll().first, isEmpty);
    expect(
      (await db.allTasks()).where((t) => t.recurrenceId == 'r1'),
      isEmpty,
    );
  });
}
