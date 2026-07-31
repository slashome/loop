import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'l10n/app_localizations.dart';
import 'src/app/app_shell.dart';
import 'src/core/db/app_database.dart';
import 'src/core/theme/app_theme.dart';
import 'src/features/notifications/application/notifications_providers.dart';
import 'src/features/notifications/data/notification_service.dart';
import 'src/features/notifications/domain/reminder.dart';
import 'src/features/settings/application/settings_providers.dart';
import 'src/features/splash/presentation/splash_screen.dart';
import 'src/features/tasks/application/tasks_providers.dart';
import 'src/features/tasks/data/task_repository.dart';

Future<void> main() async {
  final binding = WidgetsFlutterBinding.ensureInitialized();
  // Hold the native splash through the async bootstrap so it doesn't flash to
  // a blank frame before the first UI is ready.
  FlutterNativeSplash.preserve(widgetsBinding: binding);
  await initializeDateFormatting(); // localized month/weekday names
  final prefs = await SharedPreferences.getInstance();
  final db = AppDatabase();
  // Seed on first launch + generate today's occurrences.
  // Resilient: a bootstrap error must never prevent the app from
  // displaying (tab 1 will then show the stream's error state).
  try {
    // Default profile: ensures it exists, seeds demo once, generates its
    // occurrences.
    await TaskRepository(db).bootstrap();
    // If a different local profile is active, generate/clean its occurrences
    // too (no seeding for non-default profiles).
    final current = prefs.getString('currentProfileId');
    if (current != null && current != AppDatabase.defaultProfileId) {
      await TaskRepository(db, ownerId: current).bootstrap();
    }
  } catch (e, st) {
    debugPrint('bootstrap failed: $e\n$st');
  }
  // Notification backend (native / web / stub). Init failures must never block
  // the app — reminders just won't fire.
  final notifications = createNotificationService();
  try {
    await notifications.init();
  } catch (e, st) {
    debugPrint('notifications init failed: $e\n$st');
  }
  runApp(
    ProviderScope(
      overrides: [
        appDatabaseProvider.overrideWithValue(db),
        sharedPreferencesProvider.overrideWithValue(prefs),
        notificationServiceProvider.overrideWithValue(notifications),
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
    // Remove the native splash once the first frame is on screen.
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => FlutterNativeSplash.remove(),
    );
    final tag = ref.watch(settingsProvider.select((s) => s.languageTag));
    final locale = tag == 'system' ? null : Locale(tag);
    return MaterialApp(
      onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
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
      // In "system" mode: match the device language if supported, else fall
      // back to English (never to French). Explicit choices (fr/en) win via
      // [locale] above.
      localeResolutionCallback: (deviceLocale, supported) {
        for (final l in supported) {
          if (l.languageCode == deviceLocale?.languageCode) return l;
        }
        return const Locale('en');
      },
      home: const _NotificationScheduler(child: _Root()),
    );
  }
}

/// Keeps the platform notification backend in sync with the planned reminders.
/// Placed under [MaterialApp] so it can read the locale for the notification
/// body text. Reconciles on the initial build and on every reminder change.
class _NotificationScheduler extends ConsumerWidget {
  const _NotificationScheduler({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    void syncNow(List<Reminder> reminders) {
      final withBody = [for (final r in reminders) r.withBody(l.notificationBody)];
      // Fire-and-forget: the backend diffs, so redundant calls are cheap.
      ref.read(notificationServiceProvider).sync(withBody);
    }

    // `listen` covers subsequent changes; the direct read covers the first one
    // (listen does not fire for the current value).
    ref.listen<List<Reminder>>(
      plannedRemindersProvider,
      (_, next) => syncNow(next),
    );
    syncNow(ref.read(plannedRemindersProvider));
    return child;
  }
}

/// Shows the animated splash first, then swaps to the app shell.
class _Root extends StatefulWidget {
  const _Root();

  @override
  State<_Root> createState() => _RootState();
}

class _RootState extends State<_Root> {
  bool _ready = false;

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 350),
      child: _ready
          ? const AppShell()
          : SplashScreen(onDone: () => setState(() => _ready = true)),
    );
  }
}
