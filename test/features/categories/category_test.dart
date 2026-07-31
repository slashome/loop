import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:loop/src/core/db/app_database.dart';
import 'package:loop/src/features/categories/data/category_repository.dart';
import 'package:loop/src/features/categories/domain/category.dart';
import 'package:loop/src/features/recurrences/data/recurrence_repository.dart';
import 'package:loop/src/features/recurrences/domain/recurrence.dart';
import 'package:loop/src/features/tasks/data/task_repository.dart';

void main() {
  late AppDatabase db;
  setUp(() => db = AppDatabase.forTesting(NativeDatabase.memory()));
  tearDown(() => db.close());

  test('categories are isolated per profile', () async {
    final alice = CategoryRepository(db, ownerId: 'alice');
    final bob = CategoryRepository(db, ownerId: 'bob');
    await alice.create('Work', 'work');
    await bob.create('Home', 'home');

    expect((await alice.watchAll().first).map((c) => c.name), ['Work']);
    expect((await bob.watchAll().first).map((c) => c.name), ['Home']);
  });

  test(
      'assigning a category to a task, then deleting the category unassigns it',
      () async {
    final catRepo = CategoryRepository(db);
    final taskRepo = TaskRepository(db);
    final catId = await catRepo.create('Sport', 'sport');
    final taskId = await taskRepo.create(title: 'Run', categoryId: catId);

    expect((await taskRepo.getById(taskId))!.categoryId, catId);

    await catRepo.delete(catId);
    // The task falls back to uncategorized, not left dangling.
    expect((await taskRepo.getById(taskId))!.categoryId, isNull);
    expect(await catRepo.watchAll().first, isEmpty);
  });

  test('recurrence occurrences inherit the recurrence category', () async {
    final catRepo = CategoryRepository(db);
    final recRepo = RecurrenceRepository(db);
    final taskRepo = TaskRepository(db);
    final now = DateTime(2026, 7, 6, 8); // Monday, before the 18h occurrence
    final healthId = await catRepo.create('Santé', 'health');

    await recRepo.save(Recurrence(
      id: 'r1',
      title: 'Vitamins',
      freq: RecurrenceFreq.weekly,
      byWeekdays: const [DateTime.monday],
      byHours: const [18],
      categoryId: healthId,
      dtstart: now,
      createdAt: now,
      updatedAt: now,
    ));
    await taskRepo.generateOccurrences(on: now);

    final occ = (await db.allTasks()).firstWhere((t) => t.recurrenceId == 'r1');
    expect(occ.categoryId, healthId);
  });

  test('editing a recurrence category syncs onto its open occurrences',
      () async {
    final catRepo = CategoryRepository(db);
    final recRepo = RecurrenceRepository(db);
    final taskRepo = TaskRepository(db);
    final now = DateTime(2026, 7, 6, 8);
    final healthId = await catRepo.create('Santé', 'health');

    // First materialized without a category…
    await recRepo.save(Recurrence(
      id: 'r1',
      title: 'Vitamins',
      freq: RecurrenceFreq.weekly,
      byWeekdays: const [DateTime.monday],
      byHours: const [18],
      dtstart: now,
      createdAt: now,
      updatedAt: now,
    ));
    await taskRepo.generateOccurrences(on: now);
    expect(
      (await db.allTasks()).firstWhere((t) => t.recurrenceId == 'r1').categoryId,
      isNull,
    );

    // …then the recurrence gets a category and occurrences are reconciled.
    await recRepo.save(Recurrence(
      id: 'r1',
      title: 'Vitamins',
      freq: RecurrenceFreq.weekly,
      byWeekdays: const [DateTime.monday],
      byHours: const [18],
      categoryId: healthId,
      dtstart: now,
      createdAt: now,
      updatedAt: now,
    ));
    await taskRepo.reconcileOccurrences(recurrenceId: 'r1', on: now);

    expect(
      (await db.allTasks()).firstWhere((t) => t.recurrenceId == 'r1').categoryId,
      healthId,
    );
  });

  test('Category.icon resolves known keys and falls back gracefully', () {
    expect(const Category(id: '1', name: 'x', iconKey: 'work').icon,
        kCategoryIcons['work']);
    expect(const Category(id: '2', name: 'y', iconKey: 'unknown').icon,
        kFallbackCategoryIcon);
  });
}
