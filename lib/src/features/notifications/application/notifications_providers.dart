import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../settings/application/settings_providers.dart';
import '../../tasks/application/tasks_providers.dart';
import '../data/notification_service.dart';
import '../domain/reminder.dart';

/// Platform notification backend. Overridden in `main()` with an already
/// initialized instance; defaults to a fresh (uninitialized) one so tests and
/// isolated widgets don't crash.
final notificationServiceProvider = Provider<NotificationService>(
  (ref) => createNotificationService(),
);

/// How far ahead reminders are planned. Matches the occurrence generation
/// horizon (no occurrences exist beyond it) and keeps the web timer set bounded.
const kReminderHorizon = Duration(days: 14);

/// Reminders that should currently be scheduled — derived from the live tasks,
/// the shared clock, and the user's opt-in. Empty when notifications are off,
/// which drives the backend to cancel everything.
final plannedRemindersProvider = Provider<List<Reminder>>((ref) {
  final enabled =
      ref.watch(settingsProvider.select((s) => s.notificationsEnabled));
  if (!enabled) return const [];
  final tasks = ref.watch(tasksProvider).value ?? const [];
  final now = ref.watch(nowProvider);
  return plannedReminders(tasks, now, horizon: kReminderHorizon);
});
