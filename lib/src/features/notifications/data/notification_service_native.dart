import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

import '../domain/reminder.dart';
import 'notification_service.dart';

/// Native backend (Android / iOS / macOS) using `flutter_local_notifications`.
/// Reminders are scheduled with the OS, so they fire even when Loop is closed.
class NativeNotificationService implements NotificationService {
  final _plugin = FlutterLocalNotificationsPlugin();

  /// Reminders currently scheduled, keyed by notification id — lets [sync] diff
  /// instead of cancelling and rescheduling everything each time.
  final Map<int, Reminder> _current = {};

  bool _ready = false;

  @override
  bool get isSupported => true;

  @override
  Future<void> init() async {
    if (_ready) return;
    tzdata.initializeTimeZones();
    // Tolerate flutter_timezone returning either a String (3.x) or an object
    // with `.identifier` (4.x).
    String localName;
    try {
      final dynamic r = await FlutterTimezone.getLocalTimezone();
      localName = r is String ? r : (r.identifier as String);
    } catch (_) {
      localName = 'UTC';
    }
    tz.setLocalLocation(tz.getLocation(localName));

    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const darwin = DarwinInitializationSettings(
      // We request permissions explicitly via [requestPermission].
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );
    await _plugin.initialize(
      const InitializationSettings(
        android: android,
        iOS: darwin,
        macOS: darwin,
      ),
    );
    _ready = true;
  }

  @override
  Future<bool> requestPermission() async {
    await init();
    final ios = _plugin.resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>();
    if (ios != null) {
      return await ios.requestPermissions(alert: true, badge: true, sound: true) ??
          false;
    }
    final macos = _plugin.resolvePlatformSpecificImplementation<
        MacOSFlutterLocalNotificationsPlugin>();
    if (macos != null) {
      return await macos.requestPermissions(
              alert: true, badge: true, sound: true) ??
          false;
    }
    final android = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    if (android != null) {
      return await android.requestNotificationsPermission() ?? true;
    }
    return false;
  }

  static const _details = NotificationDetails(
    android: AndroidNotificationDetails(
      'reminders',
      'Reminders',
      channelDescription: 'Task reminders',
      importance: Importance.high,
      priority: Priority.high,
    ),
    iOS: DarwinNotificationDetails(),
    macOS: DarwinNotificationDetails(),
  );

  @override
  Future<void> sync(List<Reminder> reminders) async {
    await init();
    final desired = {for (final r in reminders) r.notificationId: r};

    // Cancel reminders that are no longer wanted.
    for (final id in _current.keys.toList()) {
      if (!desired.containsKey(id)) {
        await _plugin.cancel(id);
        _current.remove(id);
      }
    }

    // Schedule new or changed reminders.
    for (final r in desired.values) {
      final prev = _current[r.notificationId];
      if (prev != null && prev.sameSchedule(r)) continue;
      await _plugin.zonedSchedule(
        r.notificationId,
        r.title,
        r.body.isEmpty ? null : r.body,
        tz.TZDateTime.from(r.when, tz.local),
        _details,
        // Inexact avoids the Android 12+ exact-alarm permission; a few minutes'
        // slack is fine for task reminders.
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      );
      _current[r.notificationId] = r;
    }
  }

  @override
  Future<void> cancelAll() async {
    await _plugin.cancelAll();
    _current.clear();
  }
}

NotificationService createNotificationService() => NativeNotificationService();
