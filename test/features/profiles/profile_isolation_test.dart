import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:loop/src/core/db/app_database.dart';
import 'package:loop/src/features/profiles/data/profile_repository.dart';
import 'package:loop/src/features/tasks/data/task_repository.dart';

void main() {
  late AppDatabase db;
  setUp(() => db = AppDatabase.forTesting(NativeDatabase.memory()));
  tearDown(() => db.close());

  test('tasks are isolated per profile (owner)', () async {
    final alice = TaskRepository(db, ownerId: 'alice');
    final bob = TaskRepository(db, ownerId: 'bob');

    await alice.create(title: 'Alice task');
    await bob.create(title: 'Bob task 1');
    await bob.create(title: 'Bob task 2');

    final aliceTasks = await alice.watchTasks().first;
    final bobTasks = await bob.watchTasks().first;

    expect(aliceTasks.map((t) => t.title), ['Alice task']);
    expect(bobTasks.map((t) => t.title).toSet(), {'Bob task 1', 'Bob task 2'});
    // Counts are scoped too.
    expect(await db.countTasks('alice'), 1);
    expect(await db.countTasks('bob'), 2);
  });

  test('priority caps are counted per profile', () async {
    // Default caps: max 3 in P5. Filling Alice's P5 must not block Bob.
    final alice = TaskRepository(db, ownerId: 'alice');
    final bob = TaskRepository(db, ownerId: 'bob');
    for (var i = 0; i < 3; i++) {
      await alice.create(title: 'A$i', priority: 5);
    }
    // Bob's P5 band is still empty → allowed.
    await bob.create(title: 'B', priority: 5);
    expect(await db.countTasks('bob'), 1);
  });

  test('profiles: create, list, rename', () async {
    final repo = ProfileRepository(db);
    final id = await repo.create('Work');
    var all = await repo.watchAll().first;
    expect(all.map((p) => p.name), ['Work']);

    await repo.rename(id, 'Job');
    all = await repo.watchAll().first;
    expect(all.single.name, 'Job');
  });
}
