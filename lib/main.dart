import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'l10n/app_localizations.dart';
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
  // Seed on first launch + generate today's occurrences.
  // Resilient: a bootstrap error must never prevent the app from
  // displaying (tab 1 will then show the stream's error state).
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

/// Root of the Loop application.
class LoopApp extends ConsumerWidget {
  const LoopApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tag = ref.watch(settingsProvider.select((s) => s.languageTag));
    final locale = tag == 'system' ? null : Locale(tag);
    return MaterialApp(
      title: 'Loop',
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(),
      locale: locale,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      home: const AppShell(),
    );
  }
}
