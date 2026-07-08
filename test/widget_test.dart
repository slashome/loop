import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:loop/main.dart';

void main() {
  testWidgets('l\'app démarre sur l\'onglet Prochaines actions',
      (tester) async {
    await tester.pumpWidget(const ProviderScope(child: LoopApp()));
    expect(find.text('Prochaines actions'), findsOneWidget);
    // La P5 fraîche est en tête (donc rendue).
    expect(find.text('Rappeler le comptable avant 17h'), findsOneWidget);
    // La tâche terminée est exclue par le filtre « vivant ».
    expect(find.text('Réserver le restaurant'), findsNothing);
  });
}
