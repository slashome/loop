import '../domain/reminder.dart';

// Picks the platform factory at compile time: native (dart:io — Android, iOS,
// macOS), web (dart:js_interop), or the no-op stub as a last resort. The chosen
// file provides `createNotificationService()`.
export 'notification_service_stub.dart'
    if (dart.library.io) 'notification_service_native.dart'
    if (dart.library.js_interop) 'notification_service_web.dart';

/// Platform-agnostic reminder backend. Implementations live per platform and
/// are selected by the conditional export above.
abstract interface class NotificationService {
  /// Whether reminders can actually be delivered on this build. False for the
  /// stub; the UI hides the toggle when so.
  bool get isSupported;

  /// One-time setup (timezone data, plugin init…). Safe to call once at start.
  Future<void> init();

  /// Ask the OS/browser for permission. Returns whether it is granted.
  Future<bool> requestPermission();

  /// Reconcile the currently scheduled reminders to exactly [reminders]:
  /// schedule new/changed ones, cancel the rest. Idempotent — safe to call on
  /// every task change.
  Future<void> sync(List<Reminder> reminders);

  /// Cancel every scheduled reminder (e.g. the user turned notifications off).
  Future<void> cancelAll();
}
