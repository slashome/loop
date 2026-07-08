import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:loop/src/features/tasks/application/tasks_providers.dart';
import 'package:loop/src/features/tasks/domain/task.dart';

void main() {
  test('nextActionsProvider trie les tâches de démo par score décroissant', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final items = container.read(nextActionsProvider);

    // scores décroissants et cohérents avec l'ordre.
    for (var i = 1; i < items.length; i++) {
      expect(items[i - 1].score, greaterThanOrEqualTo(items[i].score));
    }

    final ids = items.map((s) => s.task.id).toList();
    // t1 (P5 fraîche) en tête, t7 (P1) en fin.
    expect(ids.first, 't1');
    expect(ids.last, 't7');
    // anti-famine borné : les vieilles P2 (t3, t4) passent devant les P3
    // fraîches (t5, t6)...
    expect(ids.indexOf('t3'), lessThan(ids.indexOf('t5')));
    expect(ids.indexOf('t4'), lessThan(ids.indexOf('t6')));
    // ...mais restent sous la P4 fraîche (t2).
    expect(ids.indexOf('t2'), lessThan(ids.indexOf('t3')));
  });

  test('completer une tâche la retire de l\'onglet 1', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    expect(
      container.read(nextActionsProvider).any((s) => s.task.id == 't1'),
      isTrue,
    );
    container.read(tasksProvider.notifier).complete('t1');
    expect(
      container.read(nextActionsProvider).any((s) => s.task.id == 't1'),
      isFalse,
    );
    // et son statut est bien `done`.
    final t1 = container.read(tasksProvider).firstWhere((t) => t.id == 't1');
    expect(t1.status, TaskStatus.done);
  });
}
