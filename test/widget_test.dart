import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:loop/main.dart';
import 'package:loop/src/features/tasks/application/tasks_providers.dart';
import 'package:loop/src/features/tasks/domain/task.dart';
import 'package:loop/src/features/tasks/presentation/widgets/task_card.dart';

void main() {
  // Teste le câblage UI (stream -> tri -> cartes) sans Drift : on override
  // tasksProvider avec un flux fixe. Le vrai chemin base est couvert par
  // task_repository_test.dart.
  testWidgets('affiche les tâches triées par score', (tester) async {
    final now = DateTime.now();
    final tasks = [
      Task(
        id: 'a',
        title: 'Tâche P2',
        priority: 2,
        createdAt: now,
        updatedAt: now,
      ),
      Task(
        id: 'b',
        title: 'Tâche P5',
        priority: 5,
        createdAt: now,
        updatedAt: now,
      ),
    ];

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          tasksProvider.overrideWith((ref) => Stream.value(tasks)),
        ],
        child: const LoopApp(),
      ),
    );
    await tester.pump(); // laisse le Stream.value émettre

    expect(find.text('Prochaines actions'), findsOneWidget);
    expect(find.byType(TaskCard), findsNWidgets(2));
    // Liste ancrée en bas (reverse) : la P5 (meilleur score) est SOUS la P2.
    expect(
      tester.getTopLeft(find.text('Tâche P5')).dy,
      greaterThan(tester.getTopLeft(find.text('Tâche P2')).dy),
    );
  });
}
