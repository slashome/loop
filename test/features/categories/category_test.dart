import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:loop/src/core/db/app_database.dart';
import 'package:loop/src/features/categories/data/category_repository.dart';
import 'package:loop/src/features/categories/domain/category.dart';
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

  test('Category.icon resolves known keys and falls back gracefully', () {
    expect(const Category(id: '1', name: 'x', iconKey: 'work').icon,
        kCategoryIcons['work']);
    expect(const Category(id: '2', name: 'y', iconKey: 'unknown').icon,
        kFallbackCategoryIcon);
  });
}
