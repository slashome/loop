import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:loop/src/core/db/app_database.dart';
import 'package:loop/src/features/tasks/data/task_repository.dart';
import 'package:loop/src/features/tasks/domain/task.dart';

void main() {
  late AppDatabase db;
  late TaskRepository repo;
  // Lundi 6 juillet 2026 (la récurrence hebdo de démo est un lundi).
  final monday = DateTime(2026, 7, 6, 12);

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    repo = TaskRepository(db);
  });
  tearDown(() => db.close());

  test('bootstrap amorce tâches et récurrences quand la base est vide',
      () async {
    await repo.bootstrap(clock: monday);
    expect(await db.countTasks(), greaterThan(0));
    expect(await db.countRecurrences(), greaterThan(0));
  });

  test('bootstrap est idempotent (ne re-seed pas)', () async {
    await repo.bootstrap(clock: monday);
    final n1 = await db.countTasks();
    await repo.bootstrap(clock: monday);
    final n2 = await db.countTasks();
    expect(n2, n1);
  });

  test('applyEdit met à jour priorité/envie et peut effacer envie', () async {
    await repo.bootstrap(clock: monday);
    final id = (await db.allTasks()).first.id;

    await repo.applyEdit(id, title: 'Modifié', priority: 5, envie: 1.0);
    var t = await repo.getById(id);
    expect(t!.priority, 5);
    expect(t.envie, 1.0);
    expect(t.title, 'Modifié');

    await repo.applyEdit(id, title: 'Modifié', priority: 3);
    t = await repo.getById(id);
    expect(t!.envie, isNull);
  });

  test('complete passe le statut à done', () async {
    await repo.bootstrap(clock: monday);
    final id =
        (await db.allTasks()).firstWhere((r) => r.recurrenceId == null).id;
    await repo.complete(id);
    expect((await repo.getById(id))!.status, TaskStatus.done);
  });

  test('génère les occurrences du jour, sans doublon', () async {
    await repo.bootstrap(clock: monday);
    final occ = (await db.allTasks()).where((r) => r.recurrenceId != null);
    // lundi : hebdo (1×) + quotidienne 2× = 3 occurrences.
    expect(occ.length, 3);

    await repo.generateOccurrences(on: DateTime(2026, 7, 6, 18));
    final occ2 = (await db.allTasks()).where((r) => r.recurrenceId != null);
    expect(occ2.length, 3); // idempotent
  });
}
