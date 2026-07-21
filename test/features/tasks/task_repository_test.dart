import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:loop/src/core/db/app_database.dart';
import 'package:loop/src/features/tasks/data/task_repository.dart';
import 'package:loop/src/features/tasks/domain/task.dart';

void main() {
  late AppDatabase db;
  late TaskRepository repo;
  // Monday 6 July 2026 (the demo weekly recurrence is a Monday).
  final monday = DateTime(2026, 7, 6, 12);

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    repo = TaskRepository(db);
  });
  tearDown(() => db.close());

  test('bootstrap seeds tasks and recurrences when the database is empty',
      () async {
    await repo.bootstrap(clock: monday);
    expect(await db.countTasks(), greaterThan(0));
    expect(await db.countRecurrences(), greaterThan(0));
  });

  test('bootstrap is idempotent (does not re-seed)', () async {
    await repo.bootstrap(clock: monday);
    final n1 = await db.countTasks();
    await repo.bootstrap(clock: monday);
    final n2 = await db.countTasks();
    expect(n2, n1);
  });

  test('applyEdit updates priority/desire and can clear desire', () async {
    await repo.bootstrap(clock: monday);
    final id = (await db.allTasks()).first.id;

    await repo.applyEdit(id, title: 'Edited', priority: 5, desire: 1.0);
    var t = await repo.getById(id);
    expect(t!.priority, 5);
    expect(t.desire, 1.0);
    expect(t.title, 'Edited');

    await repo.applyEdit(id, title: 'Edited', priority: 3);
    t = await repo.getById(id);
    expect(t!.desire, isNull);
  });

  test('create inserts a new live task', () async {
    final id = await repo.create(title: 'Nouvelle', priority: 4, desire: 0.5);
    final live = await repo.watchTasks().first;
    final t = live.firstWhere((t) => t.id == id);
    expect(t.title, 'Nouvelle');
    expect(t.priority, 4);
    expect(t.desire, 0.5);
  });

  test('softDelete removes the task from the stream', () async {
    await repo.bootstrap(clock: monday);
    final id = (await db.allTasks()).first.id;
    await repo.softDelete(id);
    final live = await repo.watchTasks().first;
    expect(live.any((t) => t.id == id), isFalse);
  });

  test('complete sets the status to done', () async {
    await repo.bootstrap(clock: monday);
    final id =
        (await db.allTasks()).firstWhere((r) => r.recurrenceId == null).id;
    await repo.complete(id);
    expect((await repo.getById(id))!.status, TaskStatus.done);
  });

  test('generates the occurrences for the day, without duplicates', () async {
    // Control recurrences (independent of the local fixtures).
    await db.insertRecurrence(
      RecurrenceRowsCompanion.insert(
        id: 'r-daily',
        title: 'Quotidien',
        freq: 'daily',
        byHours: const Value('8,20'),
        dtstart: monday,
        createdAt: monday,
        updatedAt: monday,
      ),
    );
    await db.insertRecurrence(
      RecurrenceRowsCompanion.insert(
        id: 'r-weekly-mon',
        title: 'Hebdo lundi',
        freq: 'weekly',
        byWeekdays: const Value('1'), // Monday
        dtstart: monday,
        createdAt: monday,
        updatedAt: monday,
      ),
    );

    await repo.generateOccurrences(on: monday, horizonDays: 0);
    // Monday alone: daily 2× + weekly-Monday 1× = 3 occurrences.
    expect(
        (await db.allTasks()).where((r) => r.recurrenceId != null).length, 3);

    await repo.generateOccurrences(
        on: DateTime(2026, 7, 6, 18), horizonDays: 0);
    expect(
        (await db.allTasks()).where((r) => r.recurrenceId != null).length, 3);
  });

  test('cleanMissedOccurrences removes missed ones only if auto-clean',
      () async {
    final yesterday = DateTime(2026, 7, 5, 9);
    await db.insertRecurrence(
      RecurrenceRowsCompanion.insert(
        id: 'r-clean',
        title: 'Clean',
        freq: 'daily',
        autoCleanMissed: const Value(true),
        dtstart: monday,
        createdAt: monday,
        updatedAt: monday,
      ),
    );
    await db.insertRecurrence(
      RecurrenceRowsCompanion.insert(
        id: 'r-keep',
        title: 'Keep',
        freq: 'daily',
        autoCleanMissed: const Value(false),
        dtstart: monday,
        createdAt: monday,
        updatedAt: monday,
      ),
    );
    await db.upsertTask(
      TaskRowsCompanion.insert(
        id: 'occ-clean',
        title: 'Clean',
        recurrenceId: const Value('r-clean'),
        dueAt: Value(yesterday),
        occurrenceDate: Value(yesterday),
        createdAt: yesterday,
        updatedAt: yesterday,
      ),
    );
    await db.upsertTask(
      TaskRowsCompanion.insert(
        id: 'occ-keep',
        title: 'Keep',
        recurrenceId: const Value('r-keep'),
        dueAt: Value(yesterday),
        occurrenceDate: Value(yesterday),
        createdAt: yesterday,
        updatedAt: yesterday,
      ),
    );

    await repo.cleanMissedOccurrences(on: monday);
    final ids = (await repo.watchTasks().first).map((t) => t.id).toSet();
    expect(ids.contains('occ-clean'), isFalse); // cleaned up
    expect(ids.contains('occ-keep'), isTrue); // kept (auto-clean off)
  });

  test('generates the occurrences over a horizon (upcoming days)', () async {
    await db.insertRecurrence(
      RecurrenceRowsCompanion.insert(
        id: 'r-daily',
        title: 'Quotidien',
        freq: 'daily',
        byHours: const Value('8,20'),
        dtstart: monday,
        createdAt: monday,
        updatedAt: monday,
      ),
    );
    // 3 days (Monday..Wednesday) × 2 hours = 6 occurrences.
    await repo.generateOccurrences(on: monday, horizonDays: 2);
    expect(
        (await db.allTasks()).where((r) => r.recurrenceId != null).length, 6);
  });
}
