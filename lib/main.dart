import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'src/app/app_shell.dart';
import 'src/core/db/app_database.dart';
import 'src/core/theme/app_theme.dart';
import 'src/features/settings/application/settings_providers.dart';
import 'src/features/tasks/application/tasks_providers.dart';
import 'src/features/tasks/data/task_repository.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final db = AppDatabase();
  // Seed au premier lancement + génération des occurrences du jour.
  // Résilient : une erreur d'amorçage ne doit jamais empêcher l'app de
  // s'afficher (l'onglet 1 montrera alors l'état d'erreur du flux).
  try {
    await TaskRepository(db).bootstrap();
  } catch (e, st) {
    debugPrint('bootstrap failed: $e\n$st');
  }
  runApp(
    ProviderScope(
      overrides: [
        appDatabaseProvider.overrideWithValue(db),
        sharedPreferencesProvider.overrideWithValue(prefs),
      ],
      child: const LoopApp(),
    ),
  );
}

/// Racine de l'application Loop.
class LoopApp extends StatelessWidget {
  const LoopApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Loop',
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(),
      home: const AppShell(),
    );
  }
}
