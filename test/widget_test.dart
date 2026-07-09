import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:loop/main.dart';
import 'package:loop/src/features/tasks/presentation/widgets/task_card.dart';

void main() {
  testWidgets('l\'app démarre sur l\'onglet Prochaines actions avec des cartes',
      (tester) async {
    await tester.pumpWidget(const ProviderScope(child: LoopApp()));
    expect(find.text('Prochaines actions'), findsOneWidget);
    // Au moins une carte de tâche est rendue.
    expect(find.byType(TaskCard), findsWidgets);
  });
}
