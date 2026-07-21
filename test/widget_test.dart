import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:loop/main.dart';
import 'package:loop/src/features/settings/application/settings_providers.dart';
import 'package:loop/src/features/tasks/application/tasks_providers.dart';
import 'package:loop/src/features/tasks/domain/task.dart';
import 'package:loop/src/features/tasks/presentation/widgets/task_card.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  // Tests the UI wiring (stream -> sort -> cards) without Drift: we override
  // tasksProvider with a fixed stream. The real database path is covered by
  // task_repository_test.dart.
  testWidgets('displays tasks sorted by score', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now();
    // Due today → present in the "To do" view by default.
    final due = now.add(const Duration(hours: 1));
    final tasks = [
      Task(
        id: 'a',
        title: 'Task P2',
        priority: 2,
        dueAt: due,
        createdAt: now,
        updatedAt: now,
      ),
      Task(
        id: 'b',
        title: 'Task P5',
        priority: 5,
        dueAt: due,
        createdAt: now,
        updatedAt: now,
      ),
    ];

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          tasksProvider.overrideWith((ref) => Stream.value(tasks)),
          sharedPreferencesProvider.overrideWithValue(prefs),
        ],
        child: const LoopApp(),
      ),
    );
    await tester.pump(); // let the Stream.value emit

    expect(find.byType(TaskCard), findsNWidgets(2));
    // List anchored at the bottom (reverse): P5 (best score) is BELOW P2.
    expect(
      tester.getTopLeft(find.text('Task P5')).dy,
      greaterThan(tester.getTopLeft(find.text('Task P2')).dy),
    );
  });
}
