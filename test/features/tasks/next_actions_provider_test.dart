import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:loop/src/features/tasks/application/tasks_providers.dart';
import 'package:loop/src/features/tasks/domain/task.dart';

void main() {
  test('nextActionsProvider expose les tâches triées par score décroissant',
      () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final items = container.read(nextActionsProvider);
    expect(items, isNotEmpty);
    for (var i = 1; i < items.length; i++) {
      expect(items[i - 1].score, greaterThanOrEqualTo(items[i].score));
    }
  });

  test('applyEdit met à jour priorité et envie', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final id = container.read(nextActionsProvider).first.task.id;
    container.read(tasksProvider.notifier).applyEdit(
          id,
          title: 'Titre modifié',
          priority: 5,
          envie: 1.0,
        );

    final task = container.read(tasksProvider).firstWhere((t) => t.id == id);
    expect(task.title, 'Titre modifié');
    expect(task.priority, 5);
    expect(task.envie, 1.0);
  });

  test('applyEdit peut effacer un champ optionnel (envie -> null)', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final id = container.read(nextActionsProvider).first.task.id;
    // d'abord on la règle, puis on l'efface.
    container.read(tasksProvider.notifier).applyEdit(
          id,
          title: 'x',
          priority: 3,
          envie: 0.5,
        );
    container.read(tasksProvider.notifier).applyEdit(
          id,
          title: 'x',
          priority: 3,
        );
    final task = container.read(tasksProvider).firstWhere((t) => t.id == id);
    expect(task.envie, isNull);
  });

  test('compléter une tâche la retire de l\'onglet 1', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final firstId = container.read(nextActionsProvider).first.task.id;
    container.read(tasksProvider.notifier).complete(firstId);

    final stillThere =
        container.read(nextActionsProvider).any((s) => s.task.id == firstId);
    expect(stillThere, isFalse);

    final task =
        container.read(tasksProvider).firstWhere((t) => t.id == firstId);
    expect(task.status, TaskStatus.done);
  });
}
