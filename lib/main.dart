import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'src/app/app_shell.dart';
import 'src/core/db/app_database.dart';
import 'src/features/tasks/application/tasks_providers.dart';
import 'src/features/tasks/data/task_repository.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
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
      overrides: [appDatabaseProvider.overrideWithValue(db)],
      child: const LoopApp(),
    ),
  );
}

/// Racine de l'application Loop.
class LoopApp extends StatelessWidget {
  const LoopApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Bleu de la marque (logo ∞ bleu→vert) comme graine du thème Material 3.
    final scheme = ColorScheme.fromSeed(seedColor: const Color(0xFF3B82C4));
    return MaterialApp(
      title: 'Loop',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: scheme,
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF7F8FA),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
      ),
      home: const AppShell(),
    );
  }
}
