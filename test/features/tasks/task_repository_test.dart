import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:loop/src/core/db/app_database.dart';
import 'package:loop/src/features/tasks/data/task_repository.dart';
import 'package:loop/src/features/tasks/domain/task.dart';

void main() {
  late AppDatabase db;
  late TaskRepository repo;
  // Midnight anchor: occurrences before a recurrence's dtstart are never
  // materialized, so control recurrences start at the beginning of the day.
  final mondayStart = DateTime(2026, 7, 6);
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
    final id = await repo.create(title: 'Fresh', priority: 4, desire: 0.5);
    final live = await repo.watchTasks().first;
    final t = live.firstWhere((t) => t.id == id);
    expect(t.title, 'Fresh');
    expect(t.priority, 4);
    expect(t.desire, 0.5);
  });

  test('reschedule moves the due date', () async {
    final id = await repo.create(
        title: 'Movable', dueAt: DateTime(2026, 7, 8, 20, 30));
    await repo.reschedule(id, DateTime(2026, 7, 12, 20, 30));
    final t = await repo.getById(id);
    expect(t!.dueAt, DateTime(2026, 7, 12, 20, 30));
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
        title: 'Daily',
        freq: 'daily',
        byHours: const Value('8,20'),
        dtstart: mondayStart,
        createdAt: monday,
        updatedAt: monday,
      ),
    );
    await db.insertRecurrence(
      RecurrenceRowsCompanion.insert(
        id: 'r-weekly-mon',
        title: 'Weekly Monday',
        freq: 'weekly',
        byWeekdays: const Value('1'), // Monday
        dtstart: mondayStart,
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
        dtstart: mondayStart,
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
        dtstart: mondayStart,
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
        title: 'Daily',
        freq: 'daily',
        byHours: const Value('8,20'),
        dtstart: mondayStart,
        createdAt: monday,
        updatedAt: monday,
      ),
    );
    // 3 days (Monday..Wednesday) × 2 hours = 6 occurrences.
    await repo.generateOccurrences(on: monday, horizonDays: 2);
    expect(
        (await db.allTasks()).where((r) => r.recurrenceId != null).length, 6);
  });

  test('never materializes occurrences before dtstart', () async {
    // Recurrence created Monday at noon with a 9:00 slot: today's 9:00 is in
    // the past relative to dtstart and must NOT spawn an overdue occurrence.
    await db.insertRecurrence(
      RecurrenceRowsCompanion.insert(
        id: 'r-noon',
        title: 'Noon-created',
        freq: 'daily',
        byHours: const Value('9,20'),
        dtstart: monday, // 12:00
        createdAt: monday,
        updatedAt: monday,
      ),
    );
    await repo.generateOccurrences(on: monday, horizonDays: 1);
    final occs = (await db.allTasks())
        .where((r) => r.recurrenceId == 'r-noon')
        .map((r) => r.dueAt!)
        .toList();
    // Monday 20:00, Tuesday 9:00, Tuesday 20:00 — but NOT Monday 9:00.
    expect(occs.length, 3);
    expect(occs.any((d) => d.isBefore(monday)), isFalse);
  });

  test('reconcileOccurrences drops stale future occurrences after an edit',
      () async {
    await db.insertRecurrence(
      RecurrenceRowsCompanion.insert(
        id: 'r-edit',
        title: 'Editable',
        freq: 'daily',
        byHours: const Value('9'),
        dtstart: mondayStart,
        createdAt: monday,
        updatedAt: monday,
      ),
    );
    await repo.generateOccurrences(on: monday, horizonDays: 2);
    // Edit: the 9:00 slot becomes 18:00.
    await (db.update(db.recurrenceRows)..where((r) => r.id.equals('r-edit')))
        .write(const RecurrenceRowsCompanion(byHours: Value('18')));

    await repo.reconcileOccurrences(recurrenceId: 'r-edit', on: monday);
    // PAST occurrences are never rewritten (Monday 9:00, already overdue,
    // survives); all FUTURE slots must follow the new 18:00 definition.
    final futureHours = (await db.allTasks())
        .where((r) =>
            r.recurrenceId == 'r-edit' &&
            r.deletedAt == null &&
            !r.dueAt!.isBefore(monday))
        .map((r) => r.dueAt!.hour)
        .toSet();
    expect(futureHours, {18});
  });

  test('create and applyEdit enforce the priority caps', () async {
    // Default caps: max 3 tasks in P5. Fill the band.
    for (var i = 0; i < 3; i++) {
      await repo.create(title: 'P5 #$i', priority: 5);
    }
    expect(
      () => repo.create(title: 'One too many', priority: 5),
      throwsA(isA<PriorityCapExceeded>()),
    );

    // Editing an existing P5 task keeps its own slot (no self-count).
    final id = (await db.allTasks()).first.id;
    await repo.applyEdit(id, title: 'Still P5', priority: 5);

    // But promoting a P3 into the full band throws.
    final p3 = await repo.create(title: 'P3', priority: 3);
    expect(
      () => repo.applyEdit(p3, title: 'P3', priority: 5),
      throwsA(isA<PriorityCapExceeded>()),
    );
  });
}
